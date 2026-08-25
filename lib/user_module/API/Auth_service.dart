import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api/APIclient.dart';
import '../Models/Profissional/companyverification_model.dart';
import '../Models/Profissional/profisionalTransactionHistory.dart';
import '../Models/address_model.dart';
import '../Models/companyrestaurentledger.dart';
import '../Models/coupon_model.dart';
import '../Models/location_model.dart';
import '../Models/notification_model.dart';
import '../Models/profile_model.dart';
import '../Models/transaction_model.dart';
import '../Models/user_account.dart';
import '../Models/wallet_model.dart';
import 'Apiclient.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();

  static final String baseUrlgateway =
      // "http://staging.maamaas.com:8080/subscription";
      "http://staging.maamaas.com:8080/subscription";

  static final String baseurlnotifications =
      "http://staging.maamaas.com:8080/catering";
  // "http://staging.maamaas.com:8080/catering";

  static Future<String> login({
    required String identifier,
    required String password,
    bool isProfessional = false,
  }) async {
    final url = Uri.parse('$baseUrlgateway/api/auth/login/user').replace(
      queryParameters: {"identifier": identifier, "password": password},
    );

    final body = jsonEncode({
      "username": identifier,
      "password": password,
      "userId": 0,
      "professionalUserId": 0,
      "userType": isProfessional ? "PROFESSIONAL" : "PERSONAL",
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // debugPrint("📤 REQUEST BODY:");
      // debugPrint(body);

      // debugPrint("📨 RESPONSE STATUS: ${response.statusCode}");
      // debugPrint("📨 RAW RESPONSE BODY:");
      // debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String token = data['token'] ?? "";
        final String refreshToken = data['refreshToken'] ?? "";

        // debugPrint("🔑 TOKEN RECEIVED: ${token.isNotEmpty}");
        // debugPrint("🔁 REFRESH TOKEN RECEIVED: ${refreshToken.isNotEmpty}");
        // debugPrint("🎭 ROLE FROM BACKEND: ${data['role']}");
        // debugPrint("🧭 USER TYPE FROM BACKEND: ${data['userType']}");

        if (token.isEmpty || refreshToken.isEmpty) {
          // debugPrint("⚠️ Tokens missing in response");
          return "Missing tokens in response";
        }

        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);

        final prefs = await SharedPreferences.getInstance();
        final userId = (data['userId'] ?? 0) as int;
        final professionalUserId = (data['professionalUserId'] is int)
            ? data['professionalUserId']
            : 0;

        await prefs.setInt('userId', userId);
        if (professionalUserId != 0) {
          await prefs.setInt('professionalUserId', professionalUserId);
        }

        await prefs.setString('userType', data['userType'] ?? "PERSONAL");
        await prefs.setString('role', data['role'] ?? "");
        await prefs.setBool('isLoggedIn', true);

        // debugPrint("✅ LOGIN SUCCESSFUL");
        return "success";
      } else {
        String errorMsg = "Login failed! Please try again.";
        try {
          final errorJson = jsonDecode(response.body);
          errorMsg = errorJson['message'] ?? errorMsg;
        } catch (_) {}
        // debugPrint("❌ Login failed: $errorMsg");
        return errorMsg;
      }
    } catch (e) {
      // debugPrint("⚠️ Exception during login: $e");
      // debugPrint(st.toString());
      return "Something went wrong. Please check your internet connection.";
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    return userId != null && userId > 0;
  }

  static Future<bool> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final endpoint = "api/user/delete/account/$userId";

      // Call ApiClient helper (adjust if your helper uses GET/POST)
      final response = await ApiClient.delete(
        endpoint,
        service: "subscription",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // debugPrint("✅ Account deleted successfully");
        return true;
      } else {
        // debugPrint(
        //   "❌ Failed to delete account: ${response.statusCode} ${response.body}",
        // );
        return false;
      }
    } catch (e) {
      // debugPrint("❌ Exception in deleteAccount: $e");
      return false;
    }
  }

  /// Helper to get stored user info
  static Future<Map<String, dynamic>> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "userId": prefs.getInt('userId') ?? 0,
      "professionalUserId": prefs.getInt('professionalUserId') ?? 0,
      "userType": prefs.getString('userType') ?? "PERSONAL",
      "isLoggedIn": prefs.getBool('isLoggedIn') ?? false,
    };
  }

  Future<bool> registerUser({
    required String userName,
    required String password,
    required String emailId,
    required String mobileNumber,
    required String userType, // PERSONAL / PROFESSIONAL
    String? referralCodeUsed,
    String? companyName,
  }) async {
    final Uri url = Uri.parse('$baseUrlgateway/api/user/registration');
    final String localDateTime = DateTime.now().toLocal().toIso8601String();

    final Map<String, dynamic> body = {
      "userName": userName,
      "password": password,
      "emailId": emailId,
      "mobileNumber": mobileNumber,
      "role": "ROLE_USER",
      "userType": userType,
      "registeredTime": localDateTime,
      "referralCodeUsed": referralCodeUsed,
    };

    if (userType == "PROFESSIONAL" &&
        companyName != null &&
        companyName.isNotEmpty) {
      body["companyName"] = companyName;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📥 Raw Response Body:");
      debugPrint(response.body);

      /// Optional: pretty JSON if response is JSON
      try {
        jsonDecode(response.body);
        // debugPrint("📥 Parsed Response:");
        // debugPrint(const JsonEncoder.withIndent('  ').convert(decoded));
      } catch (_) {
        // debugPrint("ℹ️ Response is not JSON");
      }

      final success = response.statusCode == 200 || response.statusCode == 201;

      // debugPrint(success
      //     ? "✅ User registration SUCCESS"
      //     : "❌ User registration FAILED");

      return success;
    } catch (e) {
      // debugPrint("❌ Signup Exception: $e");
      // debugPrint("📛 StackTrace:");
      // debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> verifyOTP({required String mobile, required String otp}) async {
    try {
      final Uri url = Uri.parse(
        '$baseUrlgateway/api/user/registration/verifyotp',
      ).replace(queryParameters: {'mobile': mobile.trim(), 'otp': otp.trim()});

      final response = await http.post(url);
      // 👆 backend expects params in URL, body empty

      debugPrint("Request URL: $url");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final endpoint = '$baseUrlgateway/api/user/forget/password';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': email, // or 'email' depending on your backend key
        }),
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          return {
            'success': true,
            'message': decoded['message'] ?? 'Reset link sent!',
          };
        } catch (_) {
          return {
            'success': true,
            'message': response.body.isNotEmpty
                ? response.body
                : 'Reset link sent!',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['error'] ?? 'Something went wrong',
          };
        } catch (_) {
          return {
            'success': false,
            'message': response.body.isNotEmpty
                ? response.body
                : 'Something went wrong',
          };
        }
      }
    } catch (e) {
      // print("Unexpected error: $e");
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  static Future<void> registerFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    print("📌 Sending FCM token → userId=$userId | token=$token");

    final url = Uri.parse("$baseurlnotifications/api/register-token");

    final body = {"userId": userId, "fcmToken": token, "deviceType": "ANDROID"};

    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // if (kDebugMode) {
      //   print("FCM Token API Response: ${response.statusCode}");
      // }
    } catch (e) {
      // if (kDebugMode) {
      //   print("FCM token error: $e");
      // }
    }
  }

  static Future<List<CouponModel>> fetchCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      // debugPrint("🧾 SharedPreferences userId = $userId");

      if (userId == null) {
        // debugPrint("❌ No userId found in SharedPreferences");
        return [];
      }

      final endpoint = "api/coupon/user/$userId";
      // debugPrint("📡 API Endpoint: $endpoint");

      final response = await ApiClient.get(endpoint, service: 'food');

      // debugPrint("📥 Status Code: ${response.statusCode}");
      // debugPrint("📥 Raw Response Body:");
      // debugPrint(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // debugPrint("✅ Coupons count: ${data.length}");

        /// Pretty print full JSON
        // debugPrint("🧾 Pretty JSON Response:");
        // debugPrint(encoder.convert(data));

        /// Log each coupon separately (very useful)
        // for (int i = 0; i < data.length; i++) {
        //   debugPrint("🎟 Coupon [$i]: ${encoder.convert(data[i])}");
        // }

        return data.map((e) => CouponModel.fromJson(e)).toList();
      } else {
        // debugPrint(
        //   "⚠️ API Error ${response.statusCode} → ${response.body}",
        // );
        return [];
      }
    } catch (e) {
      // debugPrint("❌ Exception in fetchCoupons: $e");
      // debugPrint("📛 StackTrace:");
      // debugPrint(stack.toString());
      return [];
    }
  }

  static Future<List<Transactions>> fetchTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("❌ No userId found in SharedPreferences");
        return [];
      }

      final endpoint =
          "api/user/wallet/transactions/$userId"; // ✅ no leading slash
      // print("📡 Fetching transactions from: $endpoint");

      final response = await ApiClient.get(
        endpoint,
        service: "subscription",
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // print("✅ Transactions fetched successfully (${data.length} items)");

        return data.map((json) => Transactions.fromJson(json)).toList();
      } else {
        // print("⚠️ Failed to fetch transactions: ${response.statusCode}");
        // print("🔴 Response: ${response.body}");
        return [];
      }
    } catch (e) {
      // print("❌ Error fetching transactions: $e");
      // print(stack);
      return [];
    }
  }

  static Future<UserProfile_model?> fetchUserProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        // print("⚠️ No user ID found in SharedPreferences");
        return null;
      }

      final endpoint = "api/user/getprofile/$userId"; // ✅ relative endpoint
      final response = await ApiClient.get(endpoint, service: "subscription");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Log only minimal info for debugging
        // print("✅ User Profile fetched successfully for ID: $userId");

        // Create model (includes 'image' if backend sends it)
        return UserProfile_model.fromJson(data);
      } else {
        // print("❌ Failed to fetch profile: ${response.statusCode}");
        // print("🔴 Response: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("⚠️ Exception while fetching profile: $e");
      // print(stack);
      return null;
    }
  }

  static Future<Wallet?> fetchWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final endpoint = "api/user/wallet/$userId";

      // print("🔹 Fetching wallet for userId: $userId → $endpoint");

      final response = await ApiClient.get(endpoint, service: "subscription");

      print("📩 Wallet Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Wallet.fromJson(jsonData);
      } else {
        // print("❌ Failed to load wallet: ${response.statusCode}");
        return null; // return null instead of crashing
      }
    } catch (e) {
      // print("⚠️ Exception in fetchWallet: $e");
      return null; // safe return
    }
  }

  static Future<List<Address>> fetchAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      if (customerId == null) {
        // debugPrint("❌ No userId in SharedPreferences");
        return [];
      }

      final endpoint = "api/customer/get/address?customerId=$customerId";

      final response = await ApiClient.get(endpoint, service: "subscription");

      debugPrint("📡 GET → $endpoint");
      debugPrint("📡 Response Status: ${response.statusCode}");
      debugPrint("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Address.fromJson(e)).toList();
      } else {
        // debugPrint("❌ Failed to fetch addresses: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // debugPrint("❌ Exception in fetchAddresses: $e");
      return [];
    }
  }

  // ✅ Add new address
  static Future<bool> addAddress(Map<String, dynamic> body) async {
    final endpoint = Uri.parse("$baseUrlgateway/api/user/location/add");

    try {
      final response = await http.post(
        endpoint,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // debugPrint("⚠️ Exception in addAddressWithoutToken: $e");
      return false;
    }
  }

  static Future<bool> updateAddress(
    int addressId,
    Map<String, dynamic> body,
  ) async {
    try {
      final endpoint = "api/user/update/$addressId";

      final response = await ApiClient.put(
        endpoint,
        body,
        service: "subscription",
      );

      // debugPrint("📡 PUT → $endpoint");
      // debugPrint("📥 Status: ${response.statusCode}");
      // debugPrint("📥 Body: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      // debugPrint("⚠️ Exception in updateAddress: $e");
      return false;
    }
  }

  // ✅ Delete address
  static Future<bool> deleteAddress(int addressId) async {
    try {
      // 🔹 Only relative endpoint (no base URL here)
      final endpoint = "api/user/delete/$addressId";

      // 🔹 Use the helper method
      final response = await ApiClient.delete(
        endpoint,
        service: "subscription",
      );

      // debugPrint("🗑️ DELETE → $endpoint");
      // debugPrint("📥 Status: ${response.statusCode}");
      // debugPrint("📥 Body: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      // debugPrint("⚠️ Exception in deleteAddress: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // debugPrint("❌ No professionalUserId found in SharedPreferences");
      return [];
    }

    final endpoint = "api/user/employee/getBy/$professionalUserId";

    try {
      final response = await ApiClient.get(endpoint, service: "subscription");

      // debugPrint("📡 Fetch Employees → ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // debugPrint(
        //   "⚠️ No employees found for professionalUserId=$professionalUserId",
        // );
        return [];
      } else {
        throw Exception("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      // debugPrint("❌ Exception in fetchEmployees: $e");
      rethrow;
    }
  }

  static Future<bool> addEmployee(Map<String, dynamic> emp) async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // debugPrint("❌ No professionalUserId found in SharedPreferences");
      return false;
    }

    final endpoint =
        "api/wallet/add/employee?professionalUserId=$professionalUserId";

    try {
      // debugPrint("📤 Add request body: ${jsonEncode(emp)}");

      final response = await ApiClient.post(
        endpoint,
        emp,
        service: "subscription",
      );

      // debugPrint("📥 Add response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // success
      } else {
        throw Exception("Failed to add employee: ${response.statusCode}");
      }
    } catch (e) {
      // debugPrint("❌ Exception in addEmployee: $e");
      return false;
    }
  }

  static Future<bool> updateEmployee(int id, Map<String, dynamic> emp) async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // debugPrint("❌ No professionalUserId found in SharedPreferences");
      return false;
    }

    final endpoint =
        "api/user/employee/update/$id?professionalUserId=$professionalUserId";

    try {
      // debugPrint("📤 Update request body: ${jsonEncode(emp)}");

      final response = await ApiClient.put(
        endpoint,
        emp,
        service: "subscription",
      );

      // debugPrint("📥 Update response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Failed to update employee: ${response.statusCode}");
      }
    } catch (e) {
      // debugPrint("❌ Exception in updateEmployee: $e");
      return false;
    }
  }

  static Future<bool> deleteEmployee(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // debugPrint("❌ No professionalUserId found in SharedPreferences");
      return false;
    }

    final endpoint =
        "api/user/employee/delete/$userId?professionalUserId=$professionalUserId";

    try {
      // debugPrint("📤 Delete request: $endpoint");

      final response = await ApiClient.delete(
        endpoint,
        service: "subscription",
      );

      // debugPrint("📥 Delete response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Failed to delete employee: ${response.statusCode}");
      }
    } catch (e) {
      // debugPrint("❌ Exception in deleteEmployee: $e");
      return false;
    }
  }

  static Future<bool> updateProfileImage(File profileImage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        // print("❌ userId null");
        return false;
      }
      //
      // print("🔄 Starting profile image upload...");
      // print("📁 File path: ${profileImage.path}");
      // print("📦 File size: ${await profileImage.length()}");

      final response = await ApiClient.sendMultipartRequest(
        service: "subscription",
        endpoint: "api/user/editprofile/$userId",
        method: "PUT",
        // same as Postman
        data: {
          // EXACTLY like Postman: key=userProfileData, value={}
          'userProfileData': '{}',
        },
        files: {
          // field name must match Postman: profileImage
          'profileImage': profileImage,
        },
      );

      // print("📨 Status: ${response.statusCode}");
      // print("📨 Body: ${response.body}");

      final success = response.statusCode == 200 || response.statusCode == 201;
      // print("✅ Upload response success: $success");
      return success;
    } catch (e) {
      // print("❌ Upload error: $e");
      // print(st);
      return false;
    }
  }

  static Future<bool> addMoney({
    required List<String> phoneNumber,
    required String amount,
    required String month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // print("❌ No professionalUserId found");
      return false;
    }

    // ✅ Clean and validate phone numbers
    final validPhoneNumbers = phoneNumber
        .where((p) => p.trim().isNotEmpty && p != 'null')
        .map((p) => p.trim())
        .toList();

    if (validPhoneNumbers.isEmpty) {
      // print("⚠️ No valid phone numbers provided");
      return false;
    }

    // ✅ Relative endpoint only (no base URL)
    final endpoint =
        "api/user/money/add/transfer?professionalUserId=$professionalUserId"
        "&phoneNumber=${validPhoneNumbers.join(',')}"
        "&amount=$amount"
        "&month=$month";
    // /api/user/money/add/transfer?professionalUserId=4&phoneNumber=string7036646624&amount=100&month=JANUARY
    try {
      // print("📡 API Request: $endpoint");

      // ✅ Use ApiClient.post and specify service if needed
      final response = await ApiClient.post(
        endpoint,
        {},
        service: 'subscription',
      );

      // print("📩 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        // print("✅ Money added successfully");
        return true;
      } else {
        // print(
        //   "❌ Failed to add money: ${response.statusCode} - ${response.body}",
        // );
        return false;
      }
    } catch (e) {
      // print("⚠️ Error while adding money: $e");
      return false;
    }
  }

  static Future<bool> addApproval({
    required List<String> phoneNumber,
    required String amount,
    required String month,
    String? year,
    String? limit,
    String? restaurantName,
    bool isPostpaid = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;

    if (professionalUserId == 0) {
      // print("❌ No professionalUserId found");
      return false;
    }

    // ✅ Clean & validate phone numbers
    final validPhoneNumbers = phoneNumber
        .where((p) => p.trim().isNotEmpty && p != "null")
        .map((p) => p.trim())
        .toList();

    if (validPhoneNumbers.isEmpty) {
      // print("⚠️ No valid phone numbers provided");
      return false;
    }

    // 🔹 Base relative endpoint
    String endpoint = isPostpaid
        ? "api/user/postpaid/approval"
        : "api/user/money/add/transfer";

    // 🔹 Build query params
    Map<String, String> params = {
      "professionalUserId": professionalUserId.toString(),
      "phoneNumber": validPhoneNumbers.join(","),
      "amount": amount,
      "month": month,
    };

    if (year != null) params["year"] = year;
    if (limit != null) params["limit"] = limit;
    if (restaurantName != null) params["restaurentname"] = restaurantName;
    params["postpaid"] = isPostpaid.toString();

    // 🔹 Build final endpoint string
    final fullEndpoint =
        "$endpoint?${params.entries.map((e) => "${e.key}=${e.value}").join("&")}";

    // print("📡 API Request: $fullEndpoint");

    try {
      final response = await ApiClient.post(
        fullEndpoint,
        {},
        service: "subscription",
      );

      // print("📩 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print("✅ Approval sent successfully");
        return true;
      } else {
        // print("❌ Approval failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      // print("⚠️ Error during approval API: $e");
      return false;
    }
  }

  Future<List<ProfessionalTransaction>> fetchTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final int professionalUserId = prefs.getInt('professionalUserId') ?? 0;
    final endpoint = "/api/user/money/get/transfer/$professionalUserId";

    try {
      final response = await ApiClient.get(endpoint, service: "subscription");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body); // This is List<dynamic>
        return (jsonData as List)
            .map((e) => ProfessionalTransaction.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load transaction');
      }
    } catch (e) {
      // print('❌ Error fetching transaction: $e');
      return [];
    }
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/user/create-order";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };

      final res = await ApiClient.post(endpoint, body, service: "subscription");

      // debugPrint("📤 CreateOrder Response: ${res.statusCode} ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["orderId"] ?? data["id"]; // ensure correct key
      }

      // debugPrint("❌ Order creation failed: ${res.body}");
      return null;
    } catch (e) {
      // debugPrint("⚠️ Exception in createOrder: $e");
      return null;
    }
  }

  // 2️⃣ CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final String endpoint = "$baseUrlgateway/api/user/capture";

      final Map<String, dynamic> body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      // debugPrint("📡 POST → $endpoint");
      // debugPrint("📦 Body → ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // debugPrint(
      //   "💰 Capture Payment Response: ${response.statusCode} ${response.body}",
      // );

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint("❌ Capture API Exception: $e");
      return false;
    }
  }

  // 3️⃣ ADD CASH TO WALLET
  static Future<bool> addCashToWallet({
    required String paymentId,
    String? orderId,
    required double amount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      if (userId == 0) {
        // debugPrint("❌ No userId found in SharedPreferences");
        return false;
      }

      final endpoint =
          "api/user/addCash/self-loaded?userId=$userId&amount=$amount&paymentId=$paymentId&orderId=${orderId ?? 'NA'}";

      final res = await ApiClient.post(endpoint, {}, service: "subscription");

      // debugPrint("📥 Wallet Response: ${res.statusCode} ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      // debugPrint("❌ Wallet API Exception: $e");
      return false;
    }
  }

  static Future<bool> professionalSelfLoaded({
    required double amount,
    required String paymentId,
    required String orderId,
    required bool useCashback,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    try {
      final endpoint =
          'api/user/profesional/self-loaded'
          '?userId=$userId&amount=$amount&paymentId=$paymentId&orderId=$orderId&useCashback=$useCashback';

      final res = await ApiClient.post(endpoint, {}, service: "subscription");
      if (res.statusCode == 200) return true;

      return false;
    } catch (e) {
      // debugPrint("⚠️ professionalSelfLoaded error: $e");
      return false;
    }
  }

  static Future<List<NotificationModel>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/user/$userId";

    try {
      final response = await ApiClient.get(endpoint, service: "notification");

      // debugPrint("📩 Response → ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // debugPrint("✅ Notifications fetched: ${data.length}");
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        // debugPrint("❌ Failed → ${response.statusCode} : ${response.body}");
        return [];
      }
    } catch (e) {
      // debugPrint("💥 Error fetching notifications: $e");
      return [];
    }
  }

  static Future<bool> deleteNotification(String id) async {
    final endpoint = "api/user/$id";

    try {
      final response = await ApiClient.delete(
        endpoint,
        service: "notification",
      );

      // debugPrint("📩 Status Code → ${response.statusCode}");

      // ✅ Treat both 200 and 204 as success (204 = No Content = successful deletion)
      if (response.statusCode == 200 || response.statusCode == 204) {
        // debugPrint("✅ Notification deleted successfully (ID: $id)");
        return true;
      } else {
        // debugPrint("❌ Failed to delete notification → ${response.statusCode}");
        // debugPrint("📦 Response → ${response.body}");
        return false;
      }
    } catch (e) {
      // debugPrint("💥 Error deleting notification: $e");
      return false;
    }
  }

  static Future<bool> deleteallNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final endpoint = "api/user/all/$userId";

    try {
      final response = await ApiClient.delete(
        endpoint,
        service: "notification",
      );

      // debugPrint("📩 Status Code → ${response.statusCode}");

      // ✅ Treat both 200 and 204 as success (204 = No Content = successful deletion)
      if (response.statusCode == 200 || response.statusCode == 204) {
        // debugPrint("✅ Notification deleted successfully (ID: $id)");
        return true;
      } else {
        // debugPrint("❌ Failed to delete notification → ${response.statusCode}");
        // debugPrint("📦 Response → ${response.body}");
        return false;
      }
    } catch (e) {
      // debugPrint("💥 Error deleting notification: $e");
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      // debugPrint("❌ No userId found in SharedPreferences");
      return false;
    }

    final endpoint =
        "api/user/$userId/mark-all-read"; // relative endpoint (ApiClient adds base URL)

    try {
      // debugPrint("📤 PUT request → $endpoint");

      final response = await ApiClient.put(
        endpoint,
        {}, // empty body
        service: "notification",
      );

      // debugPrint("📥 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          "Failed to mark all notifications read → ${response.statusCode}",
        );
      }
    } catch (e) {
      // debugPrint("❌ Exception in markAllNotificationsRead: $e");
      return false;
    }
  }

  // 🔹 Mark a single notification as read
  static Future<bool> markSingleNotificationRead(String notifId) async {
    if (notifId.isEmpty) {
      // debugPrint("❌ Invalid notifId");
      return false;
    }

    final endpoint = "api/user/$notifId/read";

    try {
      // debugPrint("📤 PUT request → $endpoint");

      final response = await ApiClient.put(
        endpoint,
        {}, // empty body
        service: "notification",
      );

      // debugPrint("📥 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          "Failed to mark notification read → ${response.statusCode}",
        );
      }
    } catch (e) {
      // debugPrint("❌ Exception in markSingleNotificationRead: $e");
      return false;
    }
  }

  static Future<int> fetchUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final String endpoint = "api/user/$userId/unread-count";

    try {
      final response = await ApiClient.get(endpoint, service: "notification");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map ? (data['count'] ?? 0) : (data as int);
      } else {
        // debugPrint("⚠️ Failed to fetch count: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      // debugPrint("❌ Error fetching unread count: $e");
      return 0;
    }
  }

  static Future<bool> updateLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString("customerId") ?? 0;

      // Default fallback address: coordinates
      String address = "${position.latitude}, ${position.longitude}";

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final subAdministrativeArea = (place.subLocality ?? "").trim();
          final city = (place.locality ?? "").trim();
          final pincode = (place.postalCode ?? "").trim();
          final landmark = (place.subLocality ?? "").trim();
          final area = (place.name ?? "").trim();

          if (area.isNotEmpty &&
              subAdministrativeArea.isNotEmpty &&
              city.isNotEmpty &&
              landmark.isNotEmpty &&
              pincode.isNotEmpty) {
            address = "$area,$subAdministrativeArea, $city,$landmark,$pincode,";
          } else if (area.isNotEmpty) {
            address = area;
          } else if (subAdministrativeArea.isNotEmpty) {
            address = subAdministrativeArea;
          } else if (city.isNotEmpty) {
            address = city;
          } else if (pincode.isNotEmpty) {
            address = pincode;
          } else if (landmark.isNotEmpty) {
            address = landmark;
          }
        }
      } catch (_) {
        // ignore geocoding errors, fallback to coordinates/api/location/curret-location/update
      }

      final endpoint =
          "$baseUrlgateway/api/user/curret/location/update"; // POST endpoint

      final Map<String, dynamic> body = {
        "customerId": customerId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          // No Authorization header
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint("⚠️ Failed to post location: $e");
      return false;
    }
  }

  static Future<UserLocationModel?> fetchCurrentLocation() async {
    print("========== fetchCurrentLocation START ==========");

    try {
      print("Step 1: Getting SharedPreferences instance...");
      final prefs = await SharedPreferences.getInstance();
      print("SharedPreferences loaded successfully.");

      print("Step 2: Fetching customerId from SharedPreferences...");
      final customerId = prefs.getString("customerId") ?? "";
      print("customerId: $customerId");

      if (customerId.isEmpty) {
        print("WARNING: customerId is empty!");
      }

      print("Step 3: Preparing API endpoint...");
      final endpoint =
          "api/customer/get/current/location?customerId=$customerId";
      print("Endpoint: $endpoint");

      print("Step 4: Sending GET request to API...");
      final response = await ApiClient.get(endpoint, service: "subscription");

      print("API call completed.");
      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Step 5: Decoding JSON response...");
        final jsonData = jsonDecode(response.body);
        print("Decoded JSON: $jsonData");

        print("Step 6: Converting JSON to UserLocationModel...");
        final model = UserLocationModel.fromJson(jsonData);
        print("Model created successfully: $model");

        print("========== fetchCurrentLocation SUCCESS ==========");
        return model;
      } else {
        print("❌ API Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
        print("========== fetchCurrentLocation FAILED ==========");
        return null;
      }
    } catch (e, stackTrace) {
      print("❌ Exception occurred: $e");
      print("StackTrace: $stackTrace");
      print("========== fetchCurrentLocation EXCEPTION ==========");
      return null;
    }
  }

  static Future<bool> isCompanyRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId") ?? 0;
    final endpoint = "api/user/company/verification/$userId";

    final response = await ApiClient.get(
      endpoint,
      service: "subscription", // ✅ fixed spelling
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();

      // API returns object when registered, null when not
      return body.isNotEmpty && body != "null";
    }

    // 404 / 204 / empty → not registered
    return false;
  }

  static Future<List<String>> loadRestaurantNames() async {
    try {
      // debugPrint("🚀 [Restaurant API] Hitting restaurant names API...");

      final res = await ApiClient.get(
        "api/vendors/restaurants/names",
        service: "food",
      );

      // debugPrint("📡 [Restaurant API] Status Code: ${res.statusCode}");
      // debugPrint("📦 [Restaurant API] Raw Response: ${res.body}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);

        // debugPrint("🧹 [Restaurant API] Parsed List: $data");

        final cleanedList = data
            .whereType<String>()
            .where((e) => e.trim().isNotEmpty)
            .toList();
        //
        // debugPrint(
        //   "✅ [Restaurant API] Cleaned Restaurant Names (${cleanedList.length}): $cleanedList",
        // );

        return cleanedList;
      } else {
        // debugPrint("❌ [Restaurant API] Non-200 response: ${res.statusCode}");
        return [];
      }
    } catch (e) {
      // debugPrint("🔥 [Restaurant API] Exception: $e");
      // debugPrint("🧵 StackTrace: $stack");
      return [];
    }
  }

  static Future<List<CompanyRestaurantLedger>> fetchCompanyRestaurantLedger({
    required String companyName,
    required String fromDate,
    required String toDate,
  }) async {
    final endpoint =
        "api/ledger/company/restaurants"
        "?companyName=$companyName"
        "&fromDate=$fromDate"
        "&toDate=$toDate";

    final res = await ApiClient.get(endpoint, service: "food");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CompanyRestaurantLedger.fromJson(e)).toList();
    }
    return [];
  }

  static Future<CompanyVerificationModel?> fetchCompanyVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null || userId == 0) {
        return null;
      }

      final response = await ApiClient.get(
        "api/user/company/verification/$userId",
        service: "subscription",
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        return CompanyVerificationModel.fromJson(json);
      }

      return null;
    } catch (e) {
      // debugPrint("AuthService fetchCompanyVerification error: $e");
      return null;
    }
  }

  static Future<bool> logout() async {
    // debugPrint("🚪 Logout started");

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      // debugPrint("👤 User ID: $userId");

      // 🔹 1. Auth logout
      // debugPrint("🔐 Calling AUTH logout API...");

      await ApiClient.post("api/auth/logout", {}, service: "subscription");

      // debugPrint("📥 AUTH Logout Status: ${authResponse.statusCode}");
      // debugPrint("📥 AUTH Logout Body: ${authResponse.body}");

      // 🔹 2. Delete notification token
      if (userId != null) {
        // debugPrint("🔔 Deleting notification token for userId=$userId");

        await ApiClient.delete(
          // "api/delete-token/$userId",
          "api/delete-token/$userId",
          service: "notification",
        );
        //
        // debugPrint("📥 Delete Token Status: ${notifyResponse.statusCode}");
        // debugPrint("📥 Delete Token Body: ${notifyResponse.body}");
      } else {
        // debugPrint("⚠️ userId is null, skipping delete-token API");
      }
    } catch (e) {
      // debugPrint("❌ Logout API error: $e");
      // debugPrint("📍 StackTrace: $stack");
    } finally {
      // debugPrint("🧹 Clearing local storage...");

      await _secureStorage.delete(key: 'token');
      await _secureStorage.delete(key: 'refreshToken');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('userType');

      // debugPrint("✅ Local data cleared");
      // debugPrint("🚪 Logout completed");
    }

    return true;
  }

  static Future<UserAccount> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final response = await ApiClient.get(
      "api/user/account/get/$userId",
      service: "subscription",
    );

    if (response.statusCode == 200) {
      return UserAccount.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load profile");
    }
  }

  static Future<bool> saveAccount(UserAccount account) async {
    final endpoint = "api/user/account/save"; // POST endpoint
    final response = await ApiClient.post(
      endpoint,
      account.toJson(),
      service: 'subscription',
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
