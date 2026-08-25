// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
//
// import 'Models.dart';
//
// class ApiService {
//   static const String baseUrl = 'http://staging.maamaas.com:8080';
//
//   String? getAuthToken() {
//     // Implement your token retrieval logic
//     return null;
//   }
//
//   String? getVendorId() {
//     // Implement your vendor ID retrieval logic
//     return null;
//   }
//
//   String? getCustomerId() {
//     // Implement your customer ID retrieval logic
//     return null;
//   }
//
//   Future<List<MenuItem>> fetchMenuItems() async {
//     final vendorId = getVendorId();
//     final token = getAuthToken();
//
//     if (vendorId == null || token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.get(
//       Uri.parse('$baseUrl/food/api/dish/getbyvendor/$vendorId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final List<dynamic> dishData = json.decode(response.body);
//
//       final dishes = dishData
//           .where((item) => item['parentId'] != 0 && item['parentId'] != null)
//           .toList();
//
//       return dishes.map((dish) {
//         final parent = dishData.firstWhere(
//           (p) => p['dishId'] == dish['parentId'],
//           orElse: () => {'dishName': 'Uncategorized'},
//         );
//
//         return MenuItem(
//           id: dish['dishId'],
//           name: dish['dishName'],
//           category: parent['dishName'] ?? 'Uncategorized',
//           price: (dish['price'] ?? 0).toDouble(),
//           image: dish['dishImage'],
//           tag: dish['tag'] ?? 'Veg',
//           menuStatus: dish['menuStatus'] ?? 'Enable',
//           selected: false,
//           discountType: 'percentage',
//           discountValue: '',
//         );
//       }).toList();
//     } else {
//       throw Exception('Failed to fetch menu items');
//     }
//   }
//
//   Future<List<Screen>> fetchScreens() async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.get(
//       Uri.parse('$baseUrl/promotions/api/user/get/screens'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((e) => Screen.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to fetch screens');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchBilling() async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.get(
//       Uri.parse('$baseUrl/promotions/api/user/get/billing'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to fetch billing');
//     }
//   }
//
//   Future<Map<String, dynamic>> applyCoupon({
//     required String customerId,
//     required String couponCode,
//     required double amount,
//   }) async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/promotions/api/vendor/apply/coupon'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode({
//         'customerId': customerId,
//         'couponCode': couponCode,
//         'amount': amount,
//         'usageType': 'CAMPAIGN',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Invalid coupon');
//     }
//   }
//
//   Future<Map<String, dynamic>> createOrder(double amount) async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/promotions/api/payments/create-order/user'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode({'amount': amount, 'currency': 'INR'}),
//     );
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to create order');
//     }
//   }
//
//   Future<Map<String, dynamic>> capturePayment({
//     required String paymentId,
//     required String orderId,
//     required String signature,
//     required double amount,
//   }) async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/promotions/api/payments/capture'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode({
//         'paymentId': paymentId,
//         'orderId': orderId,
//         'signature': signature,
//         'amount': amount,
//         'currency': 'INR',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Payment capture failed');
//     }
//   }
//
//   Future<Map<String, dynamic>> createCampaign(
//     Map<String, dynamic> payload,
//     File? mediaFile,
//   ) async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/promotions/api/user/create/campaign'),
//     );
//
//     request.headers['Authorization'] = 'Bearer $token';
//
//     // Add campaign data as JSON
//     request.fields['campaign'] = json.encode(payload);
//
//     // Add media file if present
//     if (mediaFile != null) {
//       final extension = mediaFile.path.split('.').last;
//       final mimeType = extension == 'mp4' ? 'video/mp4' : 'image/jpeg';
//
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'creative',
//           mediaFile.path,
//           contentType: MediaType.parse(mimeType),
//         ),
//       );
//     }
//
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return json.decode(responseBody);
//     } else {
//       throw Exception('Failed to create campaign: $responseBody');
//     }
//   }
//
//   Future<Map<String, dynamic>> createDigitalCampaign(
//     Map<String, dynamic> payload,
//     File? mediaFile,
//   ) async {
//     final token = getAuthToken();
//
//     if (token == null) {
//       throw Exception('Authentication required');
//     }
//
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/promotions/api/user/create/campaign'),
//     );
//
//     request.headers['Authorization'] = 'Bearer $token';
//
//     // Add campaign data as JSON
//     request.fields['campaign'] = json.encode(payload);
//
//     // Add media file if present
//     if (mediaFile != null) {
//       final extension = mediaFile.path.split('.').last;
//       final mimeType = extension == 'mp4' ? 'video/mp4' : 'image/jpeg';
//
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'creative',
//           mediaFile.path,
//           contentType: MediaType.parse(mimeType),
//         ),
//       );
//     }
//
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return json.decode(responseBody);
//     } else {
//       throw Exception('Failed to create campaign: $responseBody');
//     }
//   }
// }
// lib/Promotion&Marketing/ApiService.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'Models.dart';

class ApiService {
  static const String baseUrl = 'http://staging.maamaas.com:8080';

  String? getAuthToken() {
    // TODO: Implement your token retrieval logic
    // Example: return SharedPreferences.getInstance().then((prefs) => prefs.getString('authToken'));
    return null;
  }

  String? getVendorId() {
    // TODO: Implement your vendor ID retrieval logic
    return null;
  }

  String? getCustomerId() {
    // TODO: Implement your customer ID retrieval logic
    return null;
  }

  Future<List<MenuItem>> fetchMenuItems() async {
    final vendorId = getVendorId();
    final token = getAuthToken();

    if (vendorId == null || token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/api/dish/getbyvendor/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dishData = json.decode(response.body);

        final dishes = dishData
            .where((item) => item['parentId'] != 0 && item['parentId'] != null)
            .toList();

        return dishes.map((dish) {
          final parent = dishData.firstWhere(
            (p) => p['dishId'] == dish['parentId'],
            orElse: () => {'dishName': 'Uncategorized'},
          );

          return MenuItem(
            id: dish['dishId'],
            name: dish['dishName'],
            category: parent['dishName'] ?? 'Uncategorized',
            price: (dish['price'] ?? 0).toDouble(),
            image: dish['dishImage'],
            tag: dish['tag'] ?? 'Veg',
            menuStatus: dish['menuStatus'] ?? 'Enable',
            selected: false,
            discountType: 'percentage',
            discountValue: '',
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching menu items: $e');
    }
    return [];
  }

  Future<List<Screen>> fetchScreens() async {
    final token = getAuthToken();

    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/api/user/get/screens'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Screen.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching screens: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchBilling() async {
    final token = getAuthToken();

    if (token == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/promotions/api/user/get/billing'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch billing');
    }
  }

  Future<Map<String, dynamic>> applyCoupon({
    required String customerId,
    required String couponCode,
    required double amount,
  }) async {
    final token = getAuthToken();

    if (token == null) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/promotions/api/vendor/apply/coupon'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'customerId': customerId,
        'couponCode': couponCode,
        'amount': amount,
        'usageType': 'CAMPAIGN',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Invalid coupon');
    }
  }

  Future<Map<String, dynamic>> createCampaign(
    Map<String, dynamic> payload,
    File? mediaFile,
  ) async {
    final token = getAuthToken();

    if (token == null) {
      throw Exception('Authentication required');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/promotions/api/user/create/campaign'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Add campaign data as JSON
    request.fields['campaign'] = json.encode(payload);

    // Add media file if present
    if (mediaFile != null) {
      final extension = mediaFile.path.split('.').last;
      final mimeType = extension == 'mp4' ? 'video/mp4' : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'creative',
          mediaFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to create campaign: $responseBody');
    }
  }
}
