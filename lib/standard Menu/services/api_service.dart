// // // // import 'dart:convert';
// // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import '../models/models.dart';
// // // //
// // // // const String _baseUrl = 'http://staging.maamaas.com:8080';
// // // // const String _subscriptionBase = 'http://staging.maamaas.com:8080/subscription';
// // // // const _secureStorage = FlutterSecureStorage();
// // // //
// // // // // ─── Token helpers (mirrors Authservice exactly) ──────────────────────────────
// // // //
// // // // /// Reads token from FlutterSecureStorage first, falls back to SharedPreferences.
// // // // Future<String> _getToken() async {
// // // //   String? token = await _secureStorage.read(key: 'token');
// // // //   if (token == null || token.isEmpty) {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     token = prefs.getString('token');
// // // //   }
// // // //   return token ?? '';
// // // // }
// // // //
// // // // Future<String> _getVendorId() async {
// // // //   String? id = await _secureStorage.read(key: 'vendorId');
// // // //   if (id == null || id.isEmpty) {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     final intId = prefs.getInt('vendorId');
// // // //     id = intId?.toString();
// // // //   }
// // // //   return id ?? '';
// // // // }
// // // //
// // // // Future<String?> _refreshAccessToken() async {
// // // //   try {
// // // //     final refreshToken = await _secureStorage.read(key: 'refreshToken');
// // // //     if (refreshToken == null || refreshToken.isEmpty) return null;
// // // //
// // // //     final response = await http.post(
// // // //       Uri.parse(
// // // //         '$_subscriptionBase/api/auth/refresh?refreshTokenmobile=$refreshToken',
// // // //       ),
// // // //       headers: {
// // // //         'Content-Type': 'application/json',
// // // //         'Accept': 'application/json',
// // // //       },
// // // //     );
// // // //
// // // //     if (response.statusCode == 200) {
// // // //       final data = jsonDecode(response.body);
// // // //       final newToken = data['token'] as String?;
// // // //       final newRefreshToken = data['refreshToken'] as String?;
// // // //
// // // //       if (newToken != null && newToken.isNotEmpty) {
// // // //         await _secureStorage.write(key: 'token', value: newToken);
// // // //         final prefs = await SharedPreferences.getInstance();
// // // //         await prefs.setString('token', newToken);
// // // //       }
// // // //       if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
// // // //         await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
// // // //         final prefs = await SharedPreferences.getInstance();
// // // //         await prefs.setString('refreshToken', newRefreshToken);
// // // //       }
// // // //       return newToken;
// // // //     }
// // // //     return null;
// // // //   } catch (_) {
// // // //     return null;
// // // //   }
// // // // }
// // // //
// // // // /// Builds headers with fresh token from storage.
// // // // Future<Map<String, String>> _buildHeaders() async {
// // // //   final token = await _getToken();
// // // //   return {
// // // //     'Content-Type': 'application/json',
// // // //     'Accept': 'application/json',
// // // //     'Authorization': 'Bearer $token',
// // // //   };
// // // // }
// // // //
// // // // /// Wraps any http call and retries once with a refreshed token on 401/403.
// // // // Future<http.Response> _withRefreshRetry(
// // // //   Future<http.Response> Function(Map<String, String> headers) request,
// // // // ) async {
// // // //   final headers = await _buildHeaders();
// // // //   http.Response response = await request(headers);
// // // //
// // // //   if (response.statusCode == 401 || response.statusCode == 403) {
// // // //     final newToken = await _refreshAccessToken();
// // // //     if (newToken != null) {
// // // //       final retryHeaders = Map<String, String>.from(headers)
// // // //         ..['Authorization'] = 'Bearer $newToken';
// // // //       response = await request(retryHeaders);
// // // //     }
// // // //   }
// // // //   return response;
// // // // }
// // // //
// // // // /// Sends a multipart PUT and retries once on 401/403.
// // // // /// [imageBytes] optional image to attach as "image" field.
// // // // Future<void> _multipartPut({
// // // //   required String url,
// // // //   required String bodyJson,
// // // //   String fieldName = 'dishData',
// // // //   String errorMsg = 'Request failed',
// // // //   List<int>? imageBytes,
// // // //   String imageFileName = 'image.jpg',
// // // // }) async {
// // // //   final token = await _getToken();
// // // //   final uri = Uri.parse(url);
// // // //
// // // //   Future<http.StreamedResponse> send(String tok) async {
// // // //     final req = http.MultipartRequest('PUT', uri)
// // // //       ..headers['Authorization'] = 'Bearer $tok'
// // // //       ..headers['Accept'] = 'application/json'
// // // //       ..files.add(
// // // //         http.MultipartFile.fromString(
// // // //           fieldName,
// // // //           bodyJson,
// // // //           contentType: http.MediaType('application', 'json'),
// // // //         ),
// // // //       );
// // // //     if (imageBytes != null) {
// // // //       req.files.add(
// // // //         http.MultipartFile.fromBytes(
// // // //           'image',
// // // //           imageBytes,
// // // //           filename: imageFileName,
// // // //           contentType: http.MediaType('image', 'jpeg'),
// // // //         ),
// // // //       );
// // // //     }
// // // //     return req.send();
// // // //   }
// // // //
// // // //   http.StreamedResponse streamed = await send(token);
// // // //
// // // //   if (streamed.statusCode == 401 || streamed.statusCode == 403) {
// // // //     final newToken = await _refreshAccessToken();
// // // //     if (newToken == null)
// // // //       throw Exception('Session expired — please log in again');
// // // //     streamed = await send(newToken);
// // // //   }
// // // //   if (streamed.statusCode >= 300) {
// // // //     final body = await streamed.stream.bytesToString();
// // // //     throw Exception('$errorMsg (HTTP ${streamed.statusCode}): $body');
// // // //   }
// // // // }
// // // //
// // // // /// Sends a multipart POST and retries once on 401/403.
// // // // /// [imageBytes] optional image to attach as "image" field.
// // // // Future<void> _multipartPost({
// // // //   required String url,
// // // //   required String bodyJson,
// // // //   String fieldName = 'dishData',
// // // //   String errorMsg = 'Request failed',
// // // //   List<int>? imageBytes,
// // // //   String imageFileName = 'image.jpg',
// // // // }) async {
// // // //   final token = await _getToken();
// // // //   final uri = Uri.parse(url);
// // // //
// // // //   Future<http.StreamedResponse> send(String tok) async {
// // // //     final req = http.MultipartRequest('POST', uri)
// // // //       ..headers['Authorization'] = 'Bearer $tok'
// // // //       ..headers['Accept'] = 'application/json'
// // // //       ..files.add(
// // // //         http.MultipartFile.fromString(
// // // //           fieldName,
// // // //           bodyJson,
// // // //           contentType: http.MediaType('application', 'json'),
// // // //         ),
// // // //       );
// // // //     if (imageBytes != null) {
// // // //       req.files.add(
// // // //         http.MultipartFile.fromBytes(
// // // //           'image',
// // // //           imageBytes,
// // // //           filename: imageFileName,
// // // //           contentType: http.MediaType('image', 'jpeg'),
// // // //         ),
// // // //       );
// // // //     }
// // // //     return req.send();
// // // //   }
// // // //
// // // //   http.StreamedResponse streamed = await send(token);
// // // //
// // // //   if (streamed.statusCode == 401 || streamed.statusCode == 403) {
// // // //     final newToken = await _refreshAccessToken();
// // // //     if (newToken == null)
// // // //       throw Exception('Session expired — please log in again');
// // // //     streamed = await send(newToken);
// // // //   }
// // // //   if (streamed.statusCode >= 300) {
// // // //     final body = await streamed.stream.bytesToString();
// // // //     throw Exception('$errorMsg (HTTP ${streamed.statusCode}): $body');
// // // //   }
// // // // }
// // // //
// // // // void _assertOk(
// // // //   http.Response response,
// // // //   String action, {
// // // //   bool allowNoContent = false,
// // // // }) {
// // // //   if (allowNoContent && response.statusCode == 204) return;
// // // //   if (response.statusCode >= 200 && response.statusCode < 300) return;
// // // //   if (response.statusCode == 401 || response.statusCode == 403) {
// // // //     throw Exception('Session expired — please log in again');
// // // //   }
// // // //   throw Exception(
// // // //     'Failed to $action (HTTP ${response.statusCode}): ${response.body}',
// // // //   );
// // // // }
// // // //
// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // // // ApiService
// // // // // ─────────────────────────────────────────────────────────────────────────────
// // // //
// // // // class ApiService {
// // // //   // ==================== MENU ====================
// // // //
// // // //   static Future<List<MenuCategory>> fetchMenu() async {
// // // //     final vendorId = await _getVendorId();
// // // //     if (vendorId.isEmpty) {
// // // //       throw Exception('Not logged in — vendorId not found in storage');
// // // //     }
// // // //
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.get(
// // // //         Uri.parse('$_baseUrl/food/api/dish/getbyvendor/$vendorId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'fetch menu');
// // // //
// // // //     final List<dynamic> dishData = jsonDecode(response.body);
// // // //     final parents = dishData
// // // //         .where((d) => d['parentId'] == 0 || d['parentId'] == null)
// // // //         .toList();
// // // //
// // // //     return parents.map((cat) {
// // // //       final subs = dishData
// // // //           .where((d) => d['parentId'] == cat['dishId'])
// // // //           .map((s) => SubDish.fromJson(s))
// // // //           .toList();
// // // //       return MenuCategory(
// // // //         dishId: cat['dishId'],
// // // //         category: cat['dishName'] ?? '',
// // // //         image: cat['dishImage'],
// // // //         menuStatus: cat['menuStatus'] ?? 'Enable',
// // // //         subcategories: subs,
// // // //       );
// // // //     }).toList();
// // // //   }
// // // //
// // // //   static Future<void> addCategory({
// // // //     required String name,
// // // //     List<int>? imageBytes,
// // // //     String imageFileName = 'category.jpg',
// // // //   }) async {
// // // //     final vendorId = await _getVendorId();
// // // //     await _multipartPost(
// // // //       url: '$_baseUrl/food/api/dish/add/$vendorId',
// // // //       bodyJson: jsonEncode({
// // // //         'dishId': 0,
// // // //         'price': 0,
// // // //         'dishName': name,
// // // //         'parentId': 0,
// // // //         'stockQuantity': 0,
// // // //         'gst': 0,
// // // //         'packingCharges': 0,
// // // //       }),
// // // //       fieldName: 'dishData',
// // // //       errorMsg: 'Failed to add category',
// // // //       imageBytes: imageBytes,
// // // //       imageFileName: imageFileName,
// // // //     );
// // // //   }
// // // //
// // // //   static Future<void> editCategory({
// // // //     required int dishId,
// // // //     required String name,
// // // //     List<int>? imageBytes,
// // // //     String imageFileName = 'category.jpg',
// // // //   }) async {
// // // //     await _multipartPut(
// // // //       url: '$_baseUrl/food/api/dish/edit/$dishId',
// // // //       bodyJson: jsonEncode({'dishName': name}),
// // // //       fieldName: 'dishData',
// // // //       errorMsg: 'Failed to edit category',
// // // //       imageBytes: imageBytes,
// // // //       imageFileName: imageFileName,
// // // //     );
// // // //   }
// // // //
// // // //   static Future<void> deleteCategory(int dishId) async {
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.delete(
// // // //         Uri.parse('$_baseUrl/food/api/dish/delete/$dishId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'delete category', allowNoContent: true);
// // // //   }
// // // //
// // // //   static Future<void> addSubDish({
// // // //     required SubDish sub,
// // // //     required int parentId,
// // // //     List<int>? imageBytes,
// // // //     String imageFileName = 'dish.jpg',
// // // //   }) async {
// // // //     final vendorId = await _getVendorId();
// // // //     await _multipartPost(
// // // //       url: '$_baseUrl/food/api/dish/add/$vendorId',
// // // //       bodyJson: jsonEncode({
// // // //         'dishId': 0,
// // // //         'price': sub.price,
// // // //         'dishName': sub.subName,
// // // //         'parentId': parentId,
// // // //         'stockQuantity': sub.stockQuantity,
// // // //         'gst': sub.gst,
// // // //         'packingCharges': sub.packingCharges,
// // // //         'discount': sub.discount,
// // // //         'tag': sub.tag,
// // // //         'stock': 'In_Stock',
// // // //         'menuStatus': 'Enable',
// // // //         'description': sub.description,
// // // //         'chefType': sub.chefType,
// // // //       }),
// // // //       fieldName: 'dishData',
// // // //       errorMsg: 'Failed to add dish',
// // // //       imageBytes: imageBytes,
// // // //       imageFileName: imageFileName,
// // // //     );
// // // //   }
// // // //
// // // //   static Future<void> editSubDish(
// // // //     SubDish sub, {
// // // //     List<int>? imageBytes,
// // // //     String imageFileName = 'dish.jpg',
// // // //   }) async {
// // // //     await _multipartPut(
// // // //       url: '$_baseUrl/food/api/dish/edit/${sub.dishId}',
// // // //       bodyJson: jsonEncode({
// // // //         'dishName': sub.subName,
// // // //         'price': sub.price,
// // // //         'stockQuantity': sub.stockQuantity,
// // // //         'gst': sub.gst,
// // // //         'packingCharges': sub.packingCharges,
// // // //         'discount': sub.discount,
// // // //         'tag': sub.tag,
// // // //         'chefType': sub.chefType,
// // // //         'description': sub.description,
// // // //       }),
// // // //       fieldName: 'dishData',
// // // //       errorMsg: 'Failed to edit dish',
// // // //       imageBytes: imageBytes,
// // // //       imageFileName: imageFileName,
// // // //     );
// // // //   }
// // // //
// // // //   static Future<void> deleteSubDish(int dishId) async {
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.delete(
// // // //         Uri.parse('$_baseUrl/food/api/dish/delete/$dishId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'delete dish', allowNoContent: true);
// // // //   }
// // // //
// // // //   static Future<void> toggleMenuStatus(int dishId, String newStatus) async {
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.put(
// // // //         Uri.parse('$_baseUrl/food/api/dish/editmenu/$dishId'),
// // // //         headers: h,
// // // //         body: jsonEncode({'menuStatus': newStatus}),
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'toggle menu status');
// // // //   }
// // // //
// // // //   // ==================== PACKAGES ====================
// // // //
// // // //   static Future<List<MenuPackage>> fetchPackages() async {
// // // //     final vendorId = await _getVendorId();
// // // //     if (vendorId.isEmpty) {
// // // //       throw Exception('Not logged in — vendorId not found in storage');
// // // //     }
// // // //
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.get(
// // // //         Uri.parse('$_baseUrl/catering/api/package/$vendorId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'fetch packages');
// // // //
// // // //     final List<dynamic> data = jsonDecode(response.body);
// // // //     return data.map((p) => MenuPackage.fromJson(p)).toList();
// // // //   }
// // // //
// // // //   static Future<void> addPackage({required MenuPackage pkg}) async {
// // // //     final vendorId = await _getVendorId();
// // // //     await _multipartPost(
// // // //       url: '$_baseUrl/catering/api/vendor/$vendorId/package',
// // // //       bodyJson: jsonEncode({
// // // //         'id': 0,
// // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // //         'packageName': pkg.packageName,
// // // //         'packageType': pkg.packageType,
// // // //         'items': pkg.items
// // // //             .map((i) => {'id': 0, 'itemName': i.itemName, 'price': i.price})
// // // //             .toList(),
// // // //         'totalPrice': pkg.computedTotal,
// // // //       }),
// // // //       fieldName: 'packageData',
// // // //       errorMsg: 'Failed to add package',
// // // //     );
// // // //   }
// // // //
// // // //   static Future<void> deletePackage(int packageId) async {
// // // //     final vendorId = await _getVendorId();
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.delete(
// // // //         Uri.parse('$_baseUrl/catering/api/vendor/$vendorId/$packageId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'delete package', allowNoContent: true);
// // // //   }
// // // //
// // // //   static Future<void> updatePackageItem(PackageItem item, int packageId) async {
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.put(
// // // //         Uri.parse('$_baseUrl/catering/api/vendor/$packageId/items/${item.id}'),
// // // //         headers: h,
// // // //         body: jsonEncode({
// // // //           'id': item.id,
// // // //           'itemName': item.itemName,
// // // //           'price': item.price,
// // // //         }),
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'update package item');
// // // //   }
// // // //
// // // //   static Future<void> deletePackageItem(int itemId, int packageId) async {
// // // //     final response = await _withRefreshRetry(
// // // //       (h) => http.delete(
// // // //         Uri.parse('$_baseUrl/catering/api/vendor/items/$packageId/$itemId'),
// // // //         headers: h,
// // // //       ),
// // // //     );
// // // //     _assertOk(response, 'delete package item', allowNoContent: true);
// // // //   }
// // // // }
// // // import 'dart:convert';
// // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import '../models/models.dart';
// // //
// // // const String _baseUrl = 'http://staging.maamaas.com:8080';
// // // const String _subscriptionBase = 'http://staging.maamaas.com:8080/subscription';
// // // const _secureStorage = FlutterSecureStorage();
// // //
// // // // ─── Token helpers (mirrors Authservice exactly) ──────────────────────────────
// // //
// // // /// Reads token from FlutterSecureStorage first, falls back to SharedPreferences.
// // // Future<String> _getToken() async {
// // //   String? token = await _secureStorage.read(key: 'token');
// // //   if (token == null || token.isEmpty) {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     token = prefs.getString('token');
// // //   }
// // //   return token ?? '';
// // // }
// // //
// // // Future<String> _getVendorId() async {
// // //   String? id = await _secureStorage.read(key: 'vendorId');
// // //   if (id == null || id.isEmpty) {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final intId = prefs.getInt('vendorId');
// // //     id = intId?.toString();
// // //   }
// // //   return id ?? '';
// // // }
// // //
// // // Future<String?> _refreshAccessToken() async {
// // //   try {
// // //     final refreshToken = await _secureStorage.read(key: 'refreshToken');
// // //     if (refreshToken == null || refreshToken.isEmpty) return null;
// // //
// // //     final response = await http.post(
// // //       Uri.parse(
// // //         '$_subscriptionBase/api/auth/refresh?refreshTokenmobile=$refreshToken',
// // //       ),
// // //       headers: {
// // //         'Content-Type': 'application/json',
// // //         'Accept': 'application/json',
// // //       },
// // //     );
// // //
// // //     if (response.statusCode == 200) {
// // //       final data = jsonDecode(response.body);
// // //       final newToken = data['token'] as String?;
// // //       final newRefreshToken = data['refreshToken'] as String?;
// // //
// // //       if (newToken != null && newToken.isNotEmpty) {
// // //         await _secureStorage.write(key: 'token', value: newToken);
// // //         final prefs = await SharedPreferences.getInstance();
// // //         await prefs.setString('token', newToken);
// // //       }
// // //       if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
// // //         await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
// // //         final prefs = await SharedPreferences.getInstance();
// // //         await prefs.setString('refreshToken', newRefreshToken);
// // //       }
// // //       return newToken;
// // //     }
// // //     return null;
// // //   } catch (_) {
// // //     return null;
// // //   }
// // // }
// // //
// // // /// Builds headers with fresh token from storage.
// // // Future<Map<String, String>> _buildHeaders() async {
// // //   final token = await _getToken();
// // //   return {
// // //     'Content-Type': 'application/json',
// // //     'Accept': 'application/json',
// // //     'Authorization': 'Bearer $token',
// // //   };
// // // }
// // //
// // // /// Wraps any http call and retries once with a refreshed token on 401/403.
// // // Future<http.Response> _withRefreshRetry(
// // //   Future<http.Response> Function(Map<String, String> headers) request,
// // // ) async {
// // //   final headers = await _buildHeaders();
// // //   http.Response response = await request(headers);
// // //
// // //   if (response.statusCode == 401 || response.statusCode == 403) {
// // //     final newToken = await _refreshAccessToken();
// // //     if (newToken != null) {
// // //       final retryHeaders = Map<String, String>.from(headers)
// // //         ..['Authorization'] = 'Bearer $newToken';
// // //       response = await request(retryHeaders);
// // //     }
// // //   }
// // //   return response;
// // // }
// // //
// // // /// Sends a multipart PUT and retries once on 401/403.
// // // /// [imageBytes] optional image to attach as "image" field.
// // // Future<void> _multipartPut({
// // //   required String url,
// // //   required String bodyJson,
// // //   String fieldName = 'dishData',
// // //   String errorMsg = 'Request failed',
// // //   List<int>? imageBytes,
// // //   String imageFileName = 'image.jpg',
// // // }) async {
// // //   final token = await _getToken();
// // //   final uri = Uri.parse(url);
// // //
// // //   Future<http.StreamedResponse> send(String tok) async {
// // //     final req = http.MultipartRequest('PUT', uri)
// // //       ..headers['Authorization'] = 'Bearer $tok'
// // //       ..headers['Accept'] = 'application/json'
// // //       ..files.add(
// // //         http.MultipartFile.fromString(
// // //           fieldName,
// // //           bodyJson,
// // //           contentType: http.MediaType('application', 'json'),
// // //         ),
// // //       );
// // //     if (imageBytes != null) {
// // //       req.files.add(
// // //         http.MultipartFile.fromBytes(
// // //           'image',
// // //           imageBytes,
// // //           filename: imageFileName,
// // //           contentType: http.MediaType('image', 'jpeg'),
// // //         ),
// // //       );
// // //     }
// // //     return req.send();
// // //   }
// // //
// // //   http.StreamedResponse streamed = await send(token);
// // //
// // //   if (streamed.statusCode == 401 || streamed.statusCode == 403) {
// // //     final newToken = await _refreshAccessToken();
// // //     if (newToken == null)
// // //       throw Exception('Session expired — please log in again');
// // //     streamed = await send(newToken);
// // //   }
// // //   if (streamed.statusCode >= 300) {
// // //     final body = await streamed.stream.bytesToString();
// // //     throw Exception('$errorMsg (HTTP ${streamed.statusCode}): $body');
// // //   }
// // // }
// // //
// // // /// Sends a multipart POST and retries once on 401/403.
// // // /// [imageBytes] optional image to attach as "image" field.
// // // Future<void> _multipartPost({
// // //   required String url,
// // //   required String bodyJson,
// // //   String fieldName = 'dishData',
// // //   String errorMsg = 'Request failed',
// // //   List<int>? imageBytes,
// // //   String imageFileName = 'image.jpg',
// // // }) async {
// // //   final token = await _getToken();
// // //   final uri = Uri.parse(url);
// // //
// // //   Future<http.StreamedResponse> send(String tok) async {
// // //     final req = http.MultipartRequest('POST', uri)
// // //       ..headers['Authorization'] = 'Bearer $tok'
// // //       ..headers['Accept'] = 'application/json'
// // //       ..files.add(
// // //         http.MultipartFile.fromString(
// // //           fieldName,
// // //           bodyJson,
// // //           contentType: http.MediaType('application', 'json'),
// // //         ),
// // //       );
// // //     if (imageBytes != null) {
// // //       req.files.add(
// // //         http.MultipartFile.fromBytes(
// // //           'image',
// // //           imageBytes,
// // //           filename: imageFileName,
// // //           contentType: http.MediaType('image', 'jpeg'),
// // //         ),
// // //       );
// // //     }
// // //     return req.send();
// // //   }
// // //
// // //   http.StreamedResponse streamed = await send(token);
// // //
// // //   if (streamed.statusCode == 401 || streamed.statusCode == 403) {
// // //     final newToken = await _refreshAccessToken();
// // //     if (newToken == null)
// // //       throw Exception('Session expired — please log in again');
// // //     streamed = await send(newToken);
// // //   }
// // //   if (streamed.statusCode >= 300) {
// // //     final body = await streamed.stream.bytesToString();
// // //     throw Exception('$errorMsg (HTTP ${streamed.statusCode}): $body');
// // //   }
// // // }
// // //
// // // void _assertOk(
// // //   http.Response response,
// // //   String action, {
// // //   bool allowNoContent = false,
// // // }) {
// // //   if (allowNoContent && response.statusCode == 204) return;
// // //   if (response.statusCode >= 200 && response.statusCode < 300) return;
// // //   if (response.statusCode == 401 || response.statusCode == 403) {
// // //     throw Exception('Session expired — please log in again');
// // //   }
// // //   throw Exception(
// // //     'Failed to $action (HTTP ${response.statusCode}): ${response.body}',
// // //   );
// // // }
// // //
// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // ApiService
// // // // ─────────────────────────────────────────────────────────────────────────────
// // //
// // // class MenuService {
// // //   // ==================== MENU ====================
// // //
// // //   static Future<List<MenuCategory>> fetchMenu() async {
// // //     final vendorId = await _getVendorId();
// // //     if (vendorId.isEmpty) {
// // //       throw Exception('Not logged in — vendorId not found in storage');
// // //     }
// // //
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.get(
// // //         Uri.parse('$_baseUrl/food/api/dish/getbyvendor/$vendorId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'fetch menu');
// // //
// // //     final List<dynamic> dishData = jsonDecode(response.body);
// // //     final parents = dishData
// // //         .where((d) => d['parentId'] == 0 || d['parentId'] == null)
// // //         .toList();
// // //
// // //     return parents.map((cat) {
// // //       final subs = dishData
// // //           .where((d) => d['parentId'] == cat['dishId'])
// // //           .map((s) => SubDish.fromJson(s))
// // //           .toList();
// // //       return MenuCategory(
// // //         dishId: cat['dishId'],
// // //         category: cat['dishName'] ?? '',
// // //         image: cat['dishImage'],
// // //         menuStatus: cat['menuStatus'] ?? 'Enable',
// // //         subcategories: subs,
// // //       );
// // //     }).toList();
// // //   }
// // //
// // //   static Future<void> addCategory({
// // //     required String name,
// // //     List<int>? imageBytes,
// // //     String imageFileName = 'category.jpg',
// // //   }) async {
// // //     final vendorId = await _getVendorId();
// // //     await _multipartPost(
// // //       url: '$_baseUrl/food/api/dish/add/$vendorId',
// // //       bodyJson: jsonEncode({
// // //         'dishId': 0,
// // //         'price': 0,
// // //         'dishName': name,
// // //         'parentId': 0,
// // //         'stockQuantity': 0,
// // //         'gst': 0,
// // //         'packingCharges': 0,
// // //       }),
// // //       fieldName: 'dishData',
// // //       errorMsg: 'Failed to add category',
// // //       imageBytes: imageBytes,
// // //       imageFileName: imageFileName,
// // //     );
// // //   }
// // //
// // //   static Future<void> editCategory({
// // //     required int dishId,
// // //     required String name,
// // //     List<int>? imageBytes,
// // //     String imageFileName = 'category.jpg',
// // //   }) async {
// // //     await _multipartPut(
// // //       url: '$_baseUrl/food/api/dish/edit/$dishId',
// // //       bodyJson: jsonEncode({'dishName': name}),
// // //       fieldName: 'dishData',
// // //       errorMsg: 'Failed to edit category',
// // //       imageBytes: imageBytes,
// // //       imageFileName: imageFileName,
// // //     );
// // //   }
// // //
// // //   static Future<void> deleteCategory(int dishId) async {
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.delete(
// // //         Uri.parse('$_baseUrl/food/api/dish/delete/$dishId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'delete category', allowNoContent: true);
// // //   }
// // //
// // //   static Future<void> addSubDish({
// // //     required SubDish sub,
// // //     required int parentId,
// // //     List<int>? imageBytes,
// // //     String imageFileName = 'dish.jpg',
// // //   }) async {
// // //     final vendorId = await _getVendorId();
// // //     await _multipartPost(
// // //       url: '$_baseUrl/food/api/dish/add/$vendorId',
// // //       bodyJson: jsonEncode({
// // //         'dishId': 0,
// // //         'price': sub.price,
// // //         'dishName': sub.subName,
// // //         'parentId': parentId,
// // //         'stockQuantity': sub.stockQuantity,
// // //         'gst': sub.gst,
// // //         'packingCharges': sub.packingCharges,
// // //         'discount': sub.discount,
// // //         'tag': sub.tag,
// // //         'stock': 'In_Stock',
// // //         'menuStatus': 'Enable',
// // //         'description': sub.description,
// // //         'chefType': sub.chefType,
// // //       }),
// // //       fieldName: 'dishData',
// // //       errorMsg: 'Failed to add dish',
// // //       imageBytes: imageBytes,
// // //       imageFileName: imageFileName,
// // //     );
// // //   }
// // //
// // //   static Future<void> editSubDish(
// // //     SubDish sub, {
// // //     List<int>? imageBytes,
// // //     String imageFileName = 'dish.jpg',
// // //   }) async {
// // //     await _multipartPut(
// // //       url: '$_baseUrl/food/api/dish/edit/${sub.dishId}',
// // //       bodyJson: jsonEncode({
// // //         'dishName': sub.subName,
// // //         'price': sub.price,
// // //         'stockQuantity': sub.stockQuantity,
// // //         'gst': sub.gst,
// // //         'packingCharges': sub.packingCharges,
// // //         'discount': sub.discount,
// // //         'tag': sub.tag,
// // //         'chefType': sub.chefType,
// // //         'description': sub.description,
// // //       }),
// // //       fieldName: 'dishData',
// // //       errorMsg: 'Failed to edit dish',
// // //       imageBytes: imageBytes,
// // //       imageFileName: imageFileName,
// // //     );
// // //   }
// // //
// // //   static Future<void> deleteSubDish(int dishId) async {
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.delete(
// // //         Uri.parse('$_baseUrl/food/api/dish/delete/$dishId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'delete dish', allowNoContent: true);
// // //   }
// // //
// // //   static Future<void> toggleMenuStatus(int dishId, String newStatus) async {
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.put(
// // //         Uri.parse('$_baseUrl/food/api/dish/editmenu/$dishId'),
// // //         headers: h,
// // //         body: jsonEncode({'menuStatus': newStatus}),
// // //       ),
// // //     );
// // //     _assertOk(response, 'toggle menu status');
// // //   }
// // //
// // //   // ==================== PACKAGES ====================
// // //
// // //   static Future<List<MenuPackage>> fetchPackages() async {
// // //     final vendorId = await _getVendorId();
// // //     if (vendorId.isEmpty) {
// // //       throw Exception('Not logged in — vendorId not found in storage');
// // //     }
// // //
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.get(
// // //         Uri.parse('http://staging.maamaas.com:8080/catering/api/package/$vendorId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'fetch packages');
// // //
// // //     final List<dynamic> data = jsonDecode(response.body);
// // //     return data.map((p) => MenuPackage.fromJson(p)).toList();
// // //   }
// // //
// // //   static Future<void> addPackage({
// // //     required MenuPackage pkg,
// // //     List<int>? imageBytes,
// // //     String imageFileName = 'package.jpg',
// // //   }) async {
// // //     final vendorId = await _getVendorId();
// // //     await _multipartPost(
// // //       url: 'http://staging.maamaas.com:8080/catering/api/vendor/$vendorId/package',
// // //       bodyJson: jsonEncode({
// // //         'id': 0,
// // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // //         'packageName': pkg.packageName,
// // //         'packageType': pkg.packageType,
// // //         'items': pkg.items
// // //             .map((i) => {'id': 0, 'itemName': i.itemName, 'price': i.price})
// // //             .toList(),
// // //         'totalPrice': pkg.computedTotal,
// // //       }),
// // //       fieldName: 'packageData',
// // //       errorMsg: 'Failed to add package',
// // //       imageBytes: imageBytes,
// // //       imageFileName: imageFileName,
// // //     );
// // //   }
// // //
// // //   static Future<void> deletePackage(int packageId) async {
// // //     final vendorId = await _getVendorId();
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.delete(
// // //         Uri.parse('http://staging.maamaas.com:8080/catering/api/vendor/$vendorId/$packageId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'delete package', allowNoContent: true);
// // //   }
// // //
// // //   static Future<void> updatePackageItem(PackageItem item, int packageId) async {
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.put(
// // //         Uri.parse('http://staging.maamaas.com:8080/catering/api/vendor/$packageId/items/${item.id}'),
// // //         headers: h,
// // //         body: jsonEncode({
// // //           'id': item.id,
// // //           'itemName': item.itemName,
// // //           'price': item.price,
// // //         }),
// // //       ),
// // //     );
// // //     _assertOk(response, 'update package item');
// // //   }
// // //
// // //   static Future<void> deletePackageItem(int itemId, int packageId) async {
// // //     final response = await _withRefreshRetry(
// // //       (h) => http.delete(
// // //         Uri.parse('http://staging.maamaas.com:8080/catering/api/vendor/items/$packageId/$itemId'),
// // //         headers: h,
// // //       ),
// // //     );
// // //     _assertOk(response, 'delete package item', allowNoContent: true);
// // //   }
// // // }
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import '../../API/Apiclient.dart';
// // import '../../widgets_helper/ImageCompressor.dart';
// // import '../models/models.dart';
// //
// // const _secureStorage = FlutterSecureStorage();
// //
// // class MenuService {
// //   // ─────────────────────────────────────────────
// //   // Helpers
// //   // ─────────────────────────────────────────────
// //
// //   static Future<String> _getVendorId() async {
// //     final id = await _secureStorage.read(key: 'vendorId');
// //     if (id == null || id.isEmpty) {
// //       throw Exception('Vendor not logged in');
// //     }
// //     return id;
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // MENU
// //   // ─────────────────────────────────────────────
// //
// //   static Future<List<MenuCategory>> fetchMenu() async {
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.get(
// //       "api/dish/getbyvendor/$vendorId",
// //       service: "food",
// //     );
// //
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to fetch menu: ${response.body}");
// //     }
// //
// //     final List<dynamic> dishData = jsonDecode(response.body);
// //
// //     final parents = dishData
// //         .where((d) => d['parentId'] == 0 || d['parentId'] == null)
// //         .toList();
// //
// //     return parents.map((cat) {
// //       final subs = dishData
// //           .where((d) => d['parentId'] == cat['dishId'])
// //           .map((s) => SubDish.fromJson(s))
// //           .toList();
// //
// //       return MenuCategory(
// //         dishId: cat['dishId'],
// //         category: cat['dishName'] ?? '',
// //         image: cat['dishImage'],
// //         menuStatus: cat['menuStatus'] ?? 'Enable',
// //         subcategories: subs,
// //       );
// //     }).toList();
// //   }
// //
// //   // static Future<void> addCategory({
// //   //   required String name,
// //   //   File? imageFile,
// //   // }) async {
// //   //   final vendorId = await _getVendorId();
// //   //
// //   //   final response = await ApiClient.sendMultipartRequest(
// //   //     endpoint: "api/dish/add/$vendorId",
// //   //     method: "POST",
// //   //     service: "food",
// //   //     data: {
// //   //       "dishData": jsonEncode({
// //   //         'dishId': 0,
// //   //         'price': 0,
// //   //         'dishName': name,
// //   //         'parentId': 0,
// //   //         'stockQuantity': 0,
// //   //         'gst': 0,
// //   //         'packingCharges': 0,
// //   //       }),
// //   //     },
// //   //     files: imageFile != null ? {"image": imageFile} : null,
// //   //   );
// //   //
// //   //   if (response.statusCode >= 300) {
// //   //     throw Exception("Failed to add category: ${response.body}");
// //   //   }
// //   // }
// //
// //   static Future<void> addCategory({
// //     required String name,
// //     File? imageFile,
// //   }) async {
// //     imageFile = await ImageCompressor.compress(imageFile);
// //
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.sendMultipartRequest(
// //       endpoint: "api/dish/add/$vendorId",
// //       method: "POST",
// //       service: "food",
// //       data: {
// //         "dishData": jsonEncode({
// //           'dishId': 0,
// //           'price': 0,
// //           'dishName': name,
// //           'parentId': 0,
// //           'stockQuantity': 0,
// //           'gst': 0,
// //           'packingCharges': 0,
// //         }),
// //       },
// //       files: imageFile != null ? {"image": imageFile} : null,
// //     );
// //   }
// //
// //   static Future<void> editCategory({
// //     required int dishId,
// //     required String name,
// //     File? imageFile,
// //   }) async {
// //     imageFile = await ImageCompressor.compress(imageFile);
// //     final response = await ApiClient.sendMultipartRequest(
// //       endpoint: "api/dish/edit/$dishId",
// //       method: "PUT",
// //       service: "food",
// //       data: {
// //         "dishData": jsonEncode({'dishName': name}),
// //       },
// //       files: imageFile != null ? {"image": imageFile} : null,
// //     );
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to edit category: ${response.body}");
// //     }
// //   }
// //
// //   static Future<void> deleteCategory(int dishId) async {
// //     final response = await ApiClient.delete(
// //       "api/dish/delete/$dishId",
// //       service: "food",
// //     );
// //
// //     if (response.statusCode != 200 && response.statusCode != 204) {
// //       throw Exception("Failed to delete category");
// //     }
// //   }
// //
// //   static Future<void> addSubDish({
// //     required SubDish sub,
// //     required int parentId,
// //     File? imageFile,
// //   }) async {
// //     imageFile = await ImageCompressor.compress(imageFile);
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.sendMultipartRequest(
// //       endpoint: "api/dish/add/$vendorId",
// //       method: "POST",
// //       service: "food",
// //       data: {
// //         "dishData": jsonEncode({
// //           'dishId': 0,
// //           'price': sub.price,
// //           'dishName': sub.subName,
// //           'parentId': parentId,
// //           'stockQuantity': sub.stockQuantity,
// //           'gst': sub.gst,
// //           'packingCharges': sub.packingCharges,
// //           'discount': sub.discount,
// //           'tag': sub.tag,
// //           'stock': 'In_Stock',
// //           'menuStatus': 'Enable',
// //           'description': sub.description,
// //           'chefType': sub.chefType,
// //           'code': sub.code,
// //         }),
// //       },
// //       files: imageFile != null ? {"image": imageFile} : null,
// //     );
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to add dish: ${response.body}");
// //     }
// //   }
// //
// //   static Future<void> editSubDish(SubDish sub, {File? imageFile}) async {
// //     imageFile = await ImageCompressor.compress(imageFile);
// //     final response = await ApiClient.sendMultipartRequest(
// //       endpoint: "api/dish/edit/${sub.dishId}",
// //       method: "PUT",
// //       service: "food",
// //       data: {
// //         "dishData": jsonEncode({
// //           'dishName': sub.subName,
// //           'price': sub.price,
// //           'stockQuantity': sub.stockQuantity,
// //           'gst': sub.gst,
// //           'packingCharges': sub.packingCharges,
// //           'discount': sub.discount,
// //           'tag': sub.tag,
// //           'chefType': sub.chefType,
// //           'code': sub.code,
// //           'description': sub.description,
// //         }),
// //       },
// //       files: imageFile != null ? {"image": imageFile} : null,
// //     );
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to edit dish: ${response.body}");
// //     }
// //   }
// //
// //   static Future<void> deleteSubDish(int dishId) async {
// //     final response = await ApiClient.delete(
// //       "api/dish/delete/$dishId",
// //       service: "food",
// //     );
// //
// //     if (response.statusCode != 200 && response.statusCode != 204) {
// //       throw Exception("Failed to delete dish");
// //     }
// //   }
// //
// //   static Future<void> toggleMenuStatus(int dishId, String newStatus) async {
// //     final response = await ApiClient.put("api/dish/editmenu/$dishId", {
// //       "menuStatus": newStatus,
// //     }, service: "food");
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to update menu status");
// //     }
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // PACKAGES
// //   // ─────────────────────────────────────────────
// //
// //   static Future<List<MenuPackage>> fetchPackages() async {
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.get(
// //       "api/package/$vendorId",
// //       service: "catering",
// //     );
// //
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to fetch packages");
// //     }
// //
// //     final List<dynamic> data = jsonDecode(response.body);
// //     return data.map((p) => MenuPackage.fromJson(p)).toList();
// //   }
// //
// //   static Future<void> addPackage({
// //     required MenuPackage pkg,
// //     File? imageFile,
// //   }) async {
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.sendMultipartRequest(
// //       endpoint: "api/vendor/$vendorId/package",
// //       method: "POST",
// //       service: "catering",
// //       data: {
// //         "packageData": jsonEncode({
// //           'id': 0,
// //           'vendorId': int.tryParse(vendorId) ?? 0,
// //           'packageName': pkg.packageName,
// //           'packageType': pkg.packageType,
// //           'items': pkg.items
// //               .map((i) => {'id': 0, 'itemName': i.itemName, 'price': i.price})
// //               .toList(),
// //           'totalPrice': pkg.computedTotal,
// //         }),
// //       },
// //       files: imageFile != null ? {"image": imageFile} : null,
// //     );
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to add package");
// //     }
// //   }
// //
// //   static Future<void> deletePackage(int packageId) async {
// //     final vendorId = await _getVendorId();
// //
// //     final response = await ApiClient.delete(
// //       "api/vendor/$vendorId/$packageId",
// //       service: "catering",
// //     );
// //
// //     if (response.statusCode != 200 && response.statusCode != 204) {
// //       throw Exception("Failed to delete package");
// //     }
// //   }
// //
// //   static Future<void> updatePackageItem(PackageItem item, int packageId) async {
// //     final response = await ApiClient.put(
// //       "api/vendor/$packageId/items/${item.id}",
// //       {'id': item.id, 'itemName': item.itemName, 'price': item.price},
// //       service: "catering",
// //     );
// //
// //     if (response.statusCode >= 300) {
// //       throw Exception("Failed to update package item");
// //     }
// //   }
// //
// //   static Future<void> deletePackageItem(int itemId, int packageId) async {
// //     final response = await ApiClient.delete(
// //       "api/vendor/items/$packageId/$itemId",
// //       service: "catering",
// //     );
// //
// //     if (response.statusCode != 200 && response.statusCode != 204) {
// //       throw Exception("Failed to delete package item");
// //     }
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../API/Apiclient.dart';
// import '../../widgets_helper/ImageCompressor.dart';
// import '../models/models.dart';
//
// const _secureStorage = FlutterSecureStorage();
//
// class MenuService {
//   // ─────────────────────────────────────────────
//   // Helpers
//   // ─────────────────────────────────────────────
//
//   static Future<String> _getVendorId() async {
//     final id = await _secureStorage.read(key: 'vendorId');
//     if (id == null || id.isEmpty) {
//       throw Exception('Vendor not logged in');
//     }
//     return id;
//   }
//
//   // ─────────────────────────────────────────────
//   // MENU
//   // ─────────────────────────────────────────────
//
//   // static Future<List<MenuCategory>> fetchMenu() async {
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.get(
//   //     "api/dish/getbyvendor/$vendorId",
//   //     service: "food",
//   //   );
//   //
//   //   if (response.statusCode != 200) {
//   //     throw Exception("Failed to fetch menu: ${response.body}");
//   //   }
//   //
//   //   final List<dynamic> dishData = jsonDecode(response.body);
//   //
//   //   final parents = dishData
//   //       .where((d) => d['parentId'] == 0 || d['parentId'] == null)
//   //       .toList();
//   //
//   //   return parents.map((cat) {
//   //     final subs = dishData
//   //         .where((d) => d['parentId'] == cat['dishId'])
//   //         .map((s) => SubDish.fromJson(s))
//   //         .toList();
//   //
//   //     return MenuCategory(
//   //       dishId: cat['dishId'],
//   //       category: cat['dishName'] ?? '',
//   //       image: cat['dishImage'],
//   //       menuStatus: cat['menuStatus'] ?? 'Enable',
//   //       subcategories: subs,
//   //     );
//   //   }).toList();
//   // }
//
//   // static Future<List<MenuCategory>> fetchMenu() async {
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.get(
//   //     "api/dish/getbyvendor/$vendorId",
//   //     service: "food",
//   //   );
//   //
//   //   if (response.statusCode != 200) {
//   //     throw Exception("Failed to fetch menu: ${response.body}");
//   //   }
//   //
//   //   final List<dynamic> dishData = jsonDecode(response.body);
//   //
//   //   // ── Level 1: root categories (parentId null or 0) ──────────────────────
//   //   final level1 = dishData
//   //       .where((d) => d['parentId'] == 0 || d['parentId'] == null)
//   //       .toList();
//   //
//   //   // ── Level 2: subcategories whose parentId matches a level-1 dishId ─────
//   //   final level1Ids = level1.map((d) => d['dishId'] as int).toSet();
//   //
//   //   final level2 = dishData
//   //       .where(
//   //         (d) =>
//   //             d['parentId'] != null &&
//   //             d['parentId'] != 0 &&
//   //             level1Ids.contains(d['parentId'] as int),
//   //       )
//   //       .toList();
//   //
//   //   final level2Ids = level2.map((d) => d['dishId'] as int).toSet();
//   //
//   //   // ── Level 3: actual dishes whose parentId matches a level-2 dishId ─────
//   //   final level3 = dishData
//   //       .where(
//   //         (d) =>
//   //             d['parentId'] != null &&
//   //             d['parentId'] != 0 &&
//   //             level2Ids.contains(d['parentId'] as int),
//   //       )
//   //       .toList();
//   //
//   //   // ── Build the tree ──────────────────────────────────────────────────────
//   //   return level1.map((cat) {
//   //     final catId = cat['dishId'] as int;
//   //
//   //     final subCats = level2.where((sc) => sc['parentId'] == catId).map((sc) {
//   //       final scId = sc['dishId'] as int;
//   //       final dishes = level3
//   //           .where((d) => d['parentId'] == scId)
//   //           .map((d) => SubDish.fromJson(d))
//   //           .toList();
//   //
//   //       return SubCategory(
//   //         dishId: scId,
//   //         name: sc['dishName'] ?? '',
//   //         image: sc['dishImage'],
//   //         menuStatus: sc['menuStatus'] ?? 'Enable',
//   //         dishes: dishes,
//   //       );
//   //     }).toList();
//   //
//   //     return MenuCategory(
//   //       dishId: catId,
//   //       category: cat['dishName'] ?? '',
//   //       image: cat['dishImage'],
//   //       menuStatus: cat['menuStatus'] ?? 'Enable',
//   //       subcategories: subCats,
//   //     );
//   //   }).toList();
//   // }
//
//   static Future<List<MenuCategory>> fetchMenu() async {
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.get(
//       "api/dish/getbyvendor/$vendorId",
//       service: "food",
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to fetch menu: ${response.body}");
//     }
//
//     final List<dynamic> dishData = jsonDecode(response.body);
//
//     // ── Level 1: root categories (parentId null or 0) ──────────────────────
//     final level1 = dishData
//         .where((d) => d['parentId'] == 0 || d['parentId'] == null)
//         .toList();
//
//     final level1Ids = level1.map((d) => d['dishId'] as int).toSet();
//
//     // ── Level 2: subcategories whose parentId matches a level-1 dishId ─────
//     final level2 = dishData
//         .where(
//           (d) =>
//               d['parentId'] != null &&
//               d['parentId'] != 0 &&
//               level1Ids.contains(d['parentId'] as int),
//         )
//         .toList();
//
//     final level2Ids = level2.map((d) => d['dishId'] as int).toSet();
//
//     // ── Level 3: actual dishes whose parentId matches a level-2 dishId ─────
//     final level3 = dishData
//         .where(
//           (d) =>
//               d['parentId'] != null &&
//               d['parentId'] != 0 &&
//               level2Ids.contains(d['parentId'] as int),
//         )
//         .toList();
//
//     // ── Orphan dishes: parentId points directly at a level-1 category ─────
//     // (skips the subcategory layer entirely, e.g. dishId 714/715 above)
//     final orphanDishes = dishData
//         .where(
//           (d) =>
//               d['parentId'] != null &&
//               d['parentId'] != 0 &&
//               level1Ids.contains(d['parentId'] as int),
//         )
//         .toList();
//
//     // ── Build the tree ──────────────────────────────────────────────────────
//     return level1.map((cat) {
//       final catId = cat['dishId'] as int;
//
//       final subCats = level2.where((sc) => sc['parentId'] == catId).map((sc) {
//         final scId = sc['dishId'] as int;
//         final dishes = level3
//             .where((d) => d['parentId'] == scId)
//             .map((d) => SubDish.fromJson(d))
//             .toList();
//
//         return SubCategory(
//           dishId: scId,
//           name: sc['dishName'] ?? '',
//           image: sc['dishImage'],
//           menuStatus: sc['menuStatus'] ?? 'Enable',
//           approvalStatus: sc['approvalStatus'] as String?,
//           rejectionReason: sc['rejectionReason'] as String?,
//           dishes: dishes,
//         );
//       }).toList();
//
//       final directDishes = orphanDishes
//           .where((d) => d['parentId'] == catId)
//           .map((d) => SubDish.fromJson(d))
//           .toList();
//
//       return MenuCategory(
//         dishId: catId,
//         category: cat['dishName'] ?? '',
//         image: cat['dishImage'],
//         menuStatus: cat['menuStatus'] ?? 'Enable',
//         approvalStatus: cat['approvalStatus'] as String?,
//         rejectionReason: cat['rejectionReason'] as String?,
//         subcategories: subCats,
//       );
//     }).toList();
//   }
//
//   static Future<void> addSubCategory({
//     required String name,
//     required int parentCategoryId,
//     required int categoryId,
//     File? imageFile,
//   }) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/add/$vendorId",
//       method: "POST",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({
//           'dishId': 0,
//           'price': 0,
//           'dishName': name,
//           'parentId': parentCategoryId,
//           'categoryId': categoryId,
//           'stockQuantity': 0,
//           'gst': 0,
//           'packingCharges': 0,
//         }),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to add subcategory: ${response.body}");
//     }
//   }
//
//   // ─── editSubCategory: updates a level-2 node ─────────────────────────────────
//   static Future<void> editSubCategory({
//     required int dishId,
//     required String name,
//     File? imageFile,
//   }) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/edit/$dishId",
//       method: "PUT",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({'dishName': name}),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to edit subcategory: ${response.body}");
//     }
//   }
//
//   static Future<void> addCategory({
//     required String name,
//     File? imageFile,
//   }) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/add/$vendorId",
//       method: "POST",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({
//           'dishId': 0,
//           'price': 0,
//           'dishName': name,
//           'parentId': 0,
//           'stockQuantity': 0,
//           'gst': 0,
//           'packingCharges': 0,
//         }),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//   }
//
//   static Future<void> editCategory({
//     required int dishId,
//     required String name,
//     File? imageFile,
//   }) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/edit/$dishId",
//       method: "PUT",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({'dishName': name}),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to edit category: ${response.body}");
//     }
//   }
//
//   static Future<void> deleteCategory(int dishId) async {
//     final response = await ApiClient.delete(
//       "api/dish/delete/$dishId",
//       service: "food",
//     );
//
//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception("Failed to delete category");
//     }
//   }
//
//   // static Future<void> addSubDish({
//   //   required SubDish sub,
//   //   required int parentId,
//   //   required int categoryId,
//   //   File? imageFile,
//   // }) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/add/$vendorId",
//   //     method: "POST",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishId': 0,
//   //         'price': sub.price,
//   //         'dishName': sub.subName,
//   //         'parentId': parentId,
//   //         'categoryId': categoryId,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'stock': 'In_Stock',
//   //         'menuStatus': 'Enable',
//   //         'description': sub.description,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to add dish: ${response.body}");
//   //   }
//   // }
//   //
//   // static Future<void> addSubDish({
//   //   required SubDish sub,
//   //   required int parentId,
//   //   required int categoryId,
//   //   File? imageFile,
//   // }) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/add/$vendorId",
//   //     method: "POST",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishId': 0,
//   //         'price': sub.price,
//   //         'dishName': sub.subName,
//   //         'parentId': parentId,
//   //         'categoryId': categoryId,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'stock': 'In_Stock',
//   //         'menuStatus': 'Enable',
//   //         'description': sub.description,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //         'addons': sub.addons.map((a) => a.toJson()).toList(),
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to add dish: ${response.body}");
//   //   }
//   // }
//
//   // static Future<void> addSubDish({
//   //   required SubDish sub,
//   //   required int parentId,
//   //   required int categoryId,
//   //   File? imageFile,
//   // }) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/add/$vendorId",
//   //     method: "POST",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishId': 0,
//   //         'price': sub.price,
//   //         'dishName': sub.subName,
//   //         'parentId': parentId,
//   //         'categoryId': categoryId,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'stock': 'In_Stock',
//   //         'menuStatus': 'Enable',
//   //         'description': sub.description,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //         'addons': sub.addons.map((a) => a.toJson()).toList(),
//   //         'resetQuantity': sub.resetQuantity, // <-- new
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to add dish: ${response.body}");
//   //   }
//   // }
//
//   // static Future<void> addSubDish({
//   //   required SubDish sub,
//   //   required int parentId,
//   //   required int categoryId,
//   //   File? imageFile,
//   // }) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //   final vendorId = await _getVendorId();
//   //
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/add/$vendorId",
//   //     method: "POST",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishId': 0,
//   //         'price': sub.price,
//   //         'dishName': sub.subName,
//   //         'parentId': parentId,
//   //         'categoryId': categoryId,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'packingGst': sub.packingGst,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'deliveryGst': sub.deliveryGst,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'stock': 'In_Stock',
//   //         'menuStatus': 'Enable',
//   //         'description': sub.description,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //         'addons': sub.addons.map((a) => a.toJson()).toList(),
//   //         'resetQuantity': sub.resetQuantity,
//   //         'unlimited': sub.unlimited,
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to add dish: ${response.body}");
//   //   }
//   // }
//
//   static Future<void> addSubDish({
//     required SubDish sub,
//     required int parentId,
//     required int categoryId,
//     File? imageFile,
//   }) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/add/$vendorId",
//       method: "POST",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({
//           'dishId': 0,
//           'price': sub.price,
//           'dishName': sub.subName,
//           'parentId': parentId,
//           'categoryId': categoryId,
//           'stockQuantity': sub.stockQuantity,
//           'gst': sub.gst,
//           'includeGst': sub.includeGst,
//           'packingCharges': sub.packingCharges,
//           'packingGst': sub.packingGst,
//           'deliveryPrice': sub.deliveryPrice,
//           'deliveryGst': sub.deliveryGst,
//           'discount': sub.discount,
//           'tag': sub.tag,
//           'stock': 'In_Stock',
//           'menuStatus': 'Enable',
//           'description': sub.description,
//           'chefType': sub.chefType,
//           'code': sub.code,
//           'addons': sub.addons.map((a) => a.toJson()).toList(),
//           'resetQuantity': sub.resetQuantity,
//           'unlimited': sub.unlimited,
//           'metrics': sub.metrics,
//           'metricQuantity': sub.metricQuantity,
//         }),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to add dish: ${response.body}");
//     }
//   }
//
//   static Future<void> editAddon(Addon addon) async {
//     final response = await ApiClient.put(
//       "api/dish/addon/edit/${addon.addonId}",
//       addon.toJson(),
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to update addon: ${response.body}");
//     }
//   }
//
//   // static Future<void> editSubDish(SubDish sub, {File? imageFile}) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/edit/${sub.dishId}",
//   //     method: "PUT",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishName': sub.subName,
//   //         'price': sub.price,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //         'description': sub.description,
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to edit dish: ${response.body}");
//   //   }
//   // }
//
//   static Future<void> addAddon({
//     required Addon addon,
//     required int dishId,
//   }) async {
//     final response = await ApiClient.post("api/dish/dish/$dishId/addon", {
//       'addonId': 0,
//       'addonName': addon.addonName,
//       'addonPrice': addon.addonPrice,
//       'available': addon.available,
//     }, service: "food");
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to add addon: ${response.body}");
//     }
//   }
//
//   static Future<void> deleteAddon(int addonId) async {
//     final response = await ApiClient.delete(
//       "api/dish/addon/delete/$addonId",
//       service: "food",
//     );
//
//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception("Failed to delete addon: ${response.body}");
//     }
//   }
//
//   // static Future<void> editSubDish(SubDish sub, {File? imageFile}) async {
//   //   imageFile = await ImageCompressor.compress(imageFile);
//   //
//   //   final response = await ApiClient.sendMultipartRequest(
//   //     endpoint: "api/dish/edit/${sub.dishId}",
//   //     method: "PUT",
//   //     service: "food",
//   //     data: {
//   //       "dishData": jsonEncode({
//   //         'dishId': sub.dishId,
//   //         'dishName': sub.subName,
//   //         'price': sub.price,
//   //         'gst': sub.gst,
//   //         'includeGst': sub.includeGst,
//   //         'packingCharges': sub.packingCharges,
//   //         'deliveryPrice': sub.deliveryPrice,
//   //         'discount': sub.discount,
//   //         'tag': sub.tag,
//   //         'menuStatus': sub.menuStatus,
//   //         'stockQuantity': sub.stockQuantity,
//   //         'description': sub.description,
//   //         'chefType': sub.chefType,
//   //         'code': sub.code,
//   //         'addons': sub.addons.map((a) => a.toJson()).toList(),
//   //         'resetQuantity': sub.resetQuantity,
//   //       }),
//   //     },
//   //     files: imageFile != null ? {"image": imageFile} : null,
//   //   );
//   //
//   //   if (response.statusCode >= 300) {
//   //     throw Exception("Failed to edit dish: ${response.body}");
//   //   }
//   // }
//
//   static Future<void> editSubDish(SubDish sub, {File? imageFile}) async {
//     imageFile = await ImageCompressor.compress(imageFile);
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/dish/edit/${sub.dishId}",
//       method: "PUT",
//       service: "food",
//       data: {
//         "dishData": jsonEncode({
//           'dishId': sub.dishId,
//           'dishName': sub.subName,
//           'price': sub.price,
//           'gst': sub.gst,
//           'includeGst': sub.includeGst,
//           'packingCharges': sub.packingCharges,
//           'packingGst': sub.packingGst,
//           'deliveryPrice': sub.deliveryPrice,
//           'deliveryGst': sub.deliveryGst,
//           'discount': sub.discount,
//           'tag': sub.tag,
//
//           'menuStatus': sub.menuStatus,
//           'stockQuantity': sub.stockQuantity,
//           'description': sub.description,
//           'chefType': sub.chefType,
//           // 'effectivePrice': sub.effectivePrice,
//           'code': sub.code,
//           'addons': sub.addons.map((a) => a.toJson()).toList(),
//           'resetQuantity': sub.resetQuantity,
//           'unlimited': sub.unlimited,
//           'metrics': sub.metrics,
//           'metricQuantity': sub.metricQuantity,
//         }),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to edit dish: ${response.body}");
//     }
//   }
//
//   static Future<void> deleteSubDish(int dishId) async {
//     final response = await ApiClient.delete(
//       "api/dish/delete/$dishId",
//       service: "food",
//     );
//
//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception("Failed to delete dish");
//     }
//   }
//
//   static Future<void> toggleMenuStatus(int dishId, String newStatus) async {
//     final response = await ApiClient.put("api/dish/editmenu/$dishId", {
//       "menuStatus": newStatus,
//     }, service: "food");
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to update menu status");
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // PACKAGES
//   // ─────────────────────────────────────────────
//
//   static Future<List<MenuPackage>> fetchPackages() async {
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.get(
//       "api/package/$vendorId",
//       service: "catering",
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to fetch packages");
//     }
//
//     final List<dynamic> data = jsonDecode(response.body);
//     return data.map((p) => MenuPackage.fromJson(p)).toList();
//   }
//
//   static Future<void> addPackage({
//     required MenuPackage pkg,
//     File? imageFile,
//   }) async {
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.sendMultipartRequest(
//       endpoint: "api/vendor/$vendorId/package",
//       method: "POST",
//       service: "catering",
//       data: {
//         "packageData": jsonEncode({
//           'id': 0,
//           'vendorId': int.tryParse(vendorId) ?? 0,
//           'packageName': pkg.packageName,
//           'packageType': pkg.packageType,
//           'items': pkg.items
//               .map((i) => {'id': 0, 'itemName': i.itemName, 'price': i.price})
//               .toList(),
//           'totalPrice': pkg.computedTotal,
//         }),
//       },
//       files: imageFile != null ? {"image": imageFile} : null,
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to add package");
//     }
//   }
//
//   static Future<void> deletePackage(int packageId) async {
//     final vendorId = await _getVendorId();
//
//     final response = await ApiClient.delete(
//       "api/vendor/$vendorId/$packageId",
//       service: "catering",
//     );
//
//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception("Failed to delete package");
//     }
//   }
//
//   static Future<void> updatePackageItem(PackageItem item, int packageId) async {
//     final response = await ApiClient.put(
//       "api/vendor/$packageId/items/${item.id}",
//       {'id': item.id, 'itemName': item.itemName, 'price': item.price},
//       service: "catering",
//     );
//
//     if (response.statusCode >= 300) {
//       throw Exception("Failed to update package item");
//     }
//   }
//
//   static Future<void> deletePackageItem(int itemId, int packageId) async {
//     final response = await ApiClient.delete(
//       "api/vendor/items/$packageId/$itemId",
//       service: "catering",
//     );
//
//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception("Failed to delete package item");
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../API/Apiclient.dart';
import '../../widgets_helper/ImageCompressor.dart';
import '../models/models.dart';

const _secureStorage = FlutterSecureStorage();

class MenuService {
  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  static Future<String> _getVendorId() async {
    final id = await _secureStorage.read(key: 'vendorId');
    if (id == null || id.isEmpty) {
      throw Exception('Vendor not logged in');
    }
    return id;
  }

  // ─────────────────────────────────────────────
  // MENU
  // ─────────────────────────────────────────────

  static Future<List<MenuCategory>> fetchMenu() async {
    final vendorId = await _getVendorId();

    final response = await ApiClient.get(
      "api/dish/getbyvendor/$vendorId",
      service: "food",
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch menu: ${response.body}");
    }

    final List<dynamic> dishData = jsonDecode(response.body);

    // ── Level 1: root categories (parentId null or 0) ──────────────────────
    final level1 = dishData
        .where((d) => d['parentId'] == 0 || d['parentId'] == null)
        .toList();

    final level1Ids = level1.map((d) => d['dishId'] as int).toSet();

    // ── Level 2: subcategories whose parentId matches a level-1 dishId ─────
    final level2 = dishData
        .where(
          (d) =>
              d['parentId'] != null &&
              d['parentId'] != 0 &&
              level1Ids.contains(d['parentId'] as int),
        )
        .toList();

    final level2Ids = level2.map((d) => d['dishId'] as int).toSet();

    // ── Level 3: actual dishes whose parentId matches a level-2 dishId ─────
    final level3 = dishData
        .where(
          (d) =>
              d['parentId'] != null &&
              d['parentId'] != 0 &&
              level2Ids.contains(d['parentId'] as int),
        )
        .toList();

    // ── Orphan dishes: parentId points directly at a level-1 category ─────
    // (skips the subcategory layer entirely, e.g. dishId 714/715 above)
    final orphanDishes = dishData
        .where(
          (d) =>
              d['parentId'] != null &&
              d['parentId'] != 0 &&
              level1Ids.contains(d['parentId'] as int),
        )
        .toList();

    // ── Build the tree ──────────────────────────────────────────────────────
    return level1.map((cat) {
      final catId = cat['dishId'] as int;

      final subCats = level2.where((sc) => sc['parentId'] == catId).map((sc) {
        final scId = sc['dishId'] as int;
        final dishes = level3
            .where((d) => d['parentId'] == scId)
            .map((d) => SubDish.fromJson(d))
            .toList();

        return SubCategory(
          dishId: scId,
          name: sc['dishName'] ?? '',
          image: sc['dishImage'],
          menuStatus: sc['menuStatus'] ?? 'Enable',
          approvalStatus: sc['approvalStatus'] as String?,
          rejectionReason: sc['rejectionReason'] as String?,
          dishes: dishes,
        );
      }).toList();

      final directDishes = orphanDishes
          .where((d) => d['parentId'] == catId)
          .map((d) => SubDish.fromJson(d))
          .toList();

      return MenuCategory(
        dishId: catId,
        category: cat['dishName'] ?? '',
        image: cat['dishImage'],
        menuStatus: cat['menuStatus'] ?? 'Enable',
        approvalStatus: cat['approvalStatus'] as String?,
        rejectionReason: cat['rejectionReason'] as String?,
        subcategories: subCats,
      );
    }).toList();
  }

  static Future<void> addSubCategory({
    required String name,
    required int parentCategoryId,
    required int categoryId,
    File? imageFile,
  }) async {
    imageFile = await ImageCompressor.compress(imageFile);
    final vendorId = await _getVendorId();

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/add/$vendorId",
      method: "POST",
      service: "food",
      data: {
        "dishData": jsonEncode({
          'dishId': 0,
          'price': 0,
          'dishName': name,
          'parentId': parentCategoryId,
          'categoryId': categoryId,
          'stockQuantity': 0,
          'gst': 0,
          'packingCharges': 0,
        }),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to add subcategory: ${response.body}");
    }
  }

  // ─── editSubCategory: updates a level-2 node ─────────────────────────────────
  static Future<void> editSubCategory({
    required int dishId,
    required String name,
    File? imageFile,
  }) async {
    imageFile = await ImageCompressor.compress(imageFile);

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/edit/$dishId",
      method: "PUT",
      service: "food",
      data: {
        "dishData": jsonEncode({'dishName': name}),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to edit subcategory: ${response.body}");
    }
  }

  static Future<void> addCategory({
    required String name,
    File? imageFile,
  }) async {
    imageFile = await ImageCompressor.compress(imageFile);

    final vendorId = await _getVendorId();

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/add/$vendorId",
      method: "POST",
      service: "food",
      data: {
        "dishData": jsonEncode({
          'dishId': 0,
          'price': 0,
          'dishName': name,
          'parentId': 0,
          'stockQuantity': 0,
          'gst': 0,
          'packingCharges': 0,
        }),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );
  }

  static Future<void> editCategory({
    required int dishId,
    required String name,
    File? imageFile,
  }) async {
    imageFile = await ImageCompressor.compress(imageFile);
    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/edit/$dishId",
      method: "PUT",
      service: "food",
      data: {
        "dishData": jsonEncode({'dishName': name}),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to edit category: ${response.body}");
    }
  }

  static Future<void> deleteCategory(int dishId) async {
    final response = await ApiClient.delete(
      "api/dish/delete/$dishId",
      service: "food",
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete category");
    }
  }

  static Future<void> addSubDish({
    required SubDish sub,
    required int parentId,
    required int categoryId,
    File? imageFile,
  }) async {
    imageFile = await ImageCompressor.compress(imageFile);
    final vendorId = await _getVendorId();

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/add/$vendorId",
      method: "POST",
      service: "food",
      data: {
        "dishData": jsonEncode({
          'dishId': 0,
          'price': sub.price,
          'dishName': sub.subName,
          'parentId': parentId,
          'categoryId': categoryId,
          'stockQuantity': sub.stockQuantity,
          'gst': sub.gst,
          'includeGst': sub.includeGst,
          'packingCharges': sub.packingCharges,
          'packingGst': sub.packingGst,
          'deliveryPrice': sub.deliveryPrice,
          'deliveryGst': sub.deliveryGst,
          'deliveryIncludeGst': sub.deliveryIncludeGst, // NEW
          'discount': sub.discount,
          'tag': sub.tag,
          'stock': 'In_Stock',
          'menuStatus': 'Enable',
          'description': sub.description,
          'chefType': sub.chefType,
          'code': sub.code,
          'addons': sub.addons.map((a) => a.toJson()).toList(),
          'resetQuantity': sub.resetQuantity,
          'unlimited': sub.unlimited,
          'metrics': sub.metrics,
          'metricQuantity': sub.metricQuantity,
        }),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to add dish: ${response.body}");
    }
  }

  static Future<void> editAddon(Addon addon) async {
    final response = await ApiClient.put(
      "api/dish/addon/edit/${addon.addonId}",
      addon.toJson(),
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to update addon: ${response.body}");
    }
  }

  static Future<void> addAddon({
    required Addon addon,
    required int dishId,
  }) async {
    final response = await ApiClient.post("api/dish/dish/$dishId/addon", {
      'addonId': 0,
      'addonName': addon.addonName,
      'addonPrice': addon.addonPrice,
      'available': addon.available,
    }, service: "food");

    if (response.statusCode >= 300) {
      throw Exception("Failed to add addon: ${response.body}");
    }
  }

  static Future<void> deleteAddon(int addonId) async {
    final response = await ApiClient.delete(
      "api/dish/addon/delete/$addonId",
      service: "food",
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete addon: ${response.body}");
    }
  }

  static Future<void> editSubDish(SubDish sub, {File? imageFile}) async {
    imageFile = await ImageCompressor.compress(imageFile);

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/dish/edit/${sub.dishId}",
      method: "PUT",
      service: "food",
      data: {
        "dishData": jsonEncode({
          'dishId': sub.dishId,
          'dishName': sub.subName,
          'price': sub.price,
          'gst': sub.gst,
          'includeGst': sub.includeGst,
          'packingCharges': sub.packingCharges,
          'packingGst': sub.packingGst,
          'deliveryPrice': sub.deliveryPrice,
          'deliveryGst': sub.deliveryGst,
          'deliveryIncludeGst': sub.deliveryIncludeGst, // NEW
          'discount': sub.discount,
          'tag': sub.tag,

          'menuStatus': sub.menuStatus,
          'stockQuantity': sub.stockQuantity,
          'description': sub.description,
          'chefType': sub.chefType,
          // 'effectivePrice': sub.effectivePrice,
          'code': sub.code,
          'addons': sub.addons.map((a) => a.toJson()).toList(),
          'resetQuantity': sub.resetQuantity,
          'unlimited': sub.unlimited,
          'metrics': sub.metrics,
          'metricQuantity': sub.metricQuantity,
        }),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to edit dish: ${response.body}");
    }
  }

  static Future<void> deleteSubDish(int dishId) async {
    final response = await ApiClient.delete(
      "api/dish/delete/$dishId",
      service: "food",
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete dish");
    }
  }

  static Future<void> toggleMenuStatus(int dishId, String newStatus) async {
    final response = await ApiClient.put("api/dish/editmenu/$dishId", {
      "menuStatus": newStatus,
    }, service: "food");

    if (response.statusCode >= 300) {
      throw Exception("Failed to update menu status");
    }
  }

  // ─────────────────────────────────────────────
  // PACKAGES
  // ─────────────────────────────────────────────

  static Future<List<MenuPackage>> fetchPackages() async {
    final vendorId = await _getVendorId();

    final response = await ApiClient.get(
      "api/package/$vendorId",
      service: "catering",
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch packages");
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((p) => MenuPackage.fromJson(p)).toList();
  }

  static Future<void> addPackage({
    required MenuPackage pkg,
    File? imageFile,
  }) async {
    final vendorId = await _getVendorId();

    final response = await ApiClient.sendMultipartRequest(
      endpoint: "api/vendor/$vendorId/package",
      method: "POST",
      service: "catering",
      data: {
        "packageData": jsonEncode({
          'id': 0,
          'vendorId': int.tryParse(vendorId) ?? 0,
          'packageName': pkg.packageName,
          'packageType': pkg.packageType,
          'items': pkg.items
              .map((i) => {'id': 0, 'itemName': i.itemName, 'price': i.price})
              .toList(),
          'totalPrice': pkg.computedTotal,
        }),
      },
      files: imageFile != null ? {"image": imageFile} : null,
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to add package");
    }
  }

  static Future<void> deletePackage(int packageId) async {
    final vendorId = await _getVendorId();

    final response = await ApiClient.delete(
      "api/vendor/$vendorId/$packageId",
      service: "catering",
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete package");
    }
  }

  static Future<void> updatePackageItem(PackageItem item, int packageId) async {
    final response = await ApiClient.put(
      "api/vendor/$packageId/items/${item.id}",
      {'id': item.id, 'itemName': item.itemName, 'price': item.price},
      service: "catering",
    );

    if (response.statusCode >= 300) {
      throw Exception("Failed to update package item");
    }
  }

  static Future<void> deletePackageItem(int itemId, int packageId) async {
    final response = await ApiClient.delete(
      "api/vendor/items/$packageId/$itemId",
      service: "catering",
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete package item");
    }
  }
}
