// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/support_models.dart';
//
// const String _food = 'http://staging.maamaas.com:8080/food/api';
// const String _promo = 'https://backend.maamaas.com/promotions';
//
// class SupportService {
//   static Future<String> _token() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getString('token') ??
//         p.getString('authToken') ??
//         p.getString('auth_token') ??
//         '';
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ??
//         int.tryParse(p.getString('vendorId') ?? '') ??
//         0;
//   }
//
//   static Map<String, String> _jsonH(String tok) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $tok',
//   };
//
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('🎫 [$tag] $msg');
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // INTERNAL TICKETS  (dashboardService)
//   // ════════════════════════════════════════════════════════════════════════════
//
//   // GET /food/api/chef/issues/{vendorId}
//   static Future<List<InternalIssue>> getIssues() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_food/chef/issues/$vid';
//     _log('GET_ISSUES', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _jsonH(tok));
//       _log('GET_ISSUES', 'status=${res.statusCode}');
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(InternalIssue.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_ISSUES', 'ERROR: $e');
//     }
//     return [];
//   }
//
//   // POST /food/api/chef/issues/{vendorId}
//   // body: { id, title, description, priority, status, raisedBy, createdAt }
//   static Future<bool> createIssue(InternalIssue issue) async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_food/chef/issues/$vid';
//     _log('CREATE_ISSUE', 'POST $url');
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _jsonH(tok),
//         body: jsonEncode(issue.toJson(null)),
//       );
//       _log('CREATE_ISSUE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CREATE_ISSUE', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // PUT /food/api/chef/issues/{vendorId}/{id}
//   static Future<bool> updateIssue(int id, InternalIssue issue) async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_food/chef/issues/$vid/$id';
//     _log('UPDATE_ISSUE', 'PUT $url');
//     try {
//       final res = await http.put(
//         Uri.parse(url),
//         headers: _jsonH(tok),
//         body: jsonEncode(issue.toJson(id)),
//       );
//       _log('UPDATE_ISSUE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('UPDATE_ISSUE', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // DELETE /food/api/vendor/chef/issues/{vendorId}/{id}
//   static Future<bool> deleteIssue(int id) async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_food/vendor/chef/issues/$vid/$id';
//     _log('DELETE_ISSUE', 'DELETE $url');
//     try {
//       final res = await http.delete(Uri.parse(url), headers: _jsonH(tok));
//       _log('DELETE_ISSUE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('DELETE_ISSUE', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // PLATFORM TICKETS  (PromotionsService)
//   // ════════════════════════════════════════════════════════════════════════════
//
//   // GET /promotions/api/user/helpdesk/vendor/{vendorId}
//   static Future<List<PlatformTicket>> getPlatformTickets() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_promo/api/user/helpdesk/vendor/$vid';
//     _log('GET_TICKETS', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _jsonH(tok));
//       _log('GET_TICKETS', 'status=${res.statusCode}');
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(PlatformTicket.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_TICKETS', 'ERROR: $e');
//     }
//     return [];
//   }
//
//   // POST /promotions/api/user/helpdesk/create
//   // Multipart: ticket (JSON blob, application/json) + optional attachmentUrl (file)
//   // Mirrors: new Blob([JSON.stringify(ticketData)], { type: "application/json" })
//   static Future<bool> createPlatformTicket(
//     PlatformTicket ticket, {
//     File? attachment,
//   }) async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_promo/api/user/helpdesk/create';
//
//     final body = {...ticket.toJson(), 'vendorId': vid};
//     _log('CREATE_TICKET', 'POST $url  body=${jsonEncode(body)}');
//
//     try {
//       final req = http.MultipartRequest('POST', Uri.parse(url));
//       req.headers['Authorization'] = 'Bearer $tok';
//
//       // ticket JSON blob — exactly like React: new Blob([JSON.stringify(data)], { type: "application/json" })
//       req.files.add(
//         http.MultipartFile.fromBytes(
//           'ticket',
//           utf8.encode(jsonEncode(body)),
//           contentType: MediaType('application', 'json'),
//         ),
//       );
//
//       if (attachment != null) {
//         final ext = attachment.path.split('.').last.toLowerCase();
//         final mime = ext == 'pdf'
//             ? MediaType('application', 'pdf')
//             : ext == 'png'
//             ? MediaType('image', 'png')
//             : MediaType('image', 'jpeg');
//         req.files.add(
//           await http.MultipartFile.fromPath(
//             'attachmentUrl',
//             attachment.path,
//             contentType: mime,
//           ),
//         );
//       }
//
//       final streamed = await req.send();
//       _log('CREATE_TICKET', 'status=${streamed.statusCode}');
//       return streamed.statusCode >= 200 && streamed.statusCode < 300;
//     } catch (e) {
//       _log('CREATE_TICKET', 'ERROR: $e');
//       return false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/support_models.dart';

const _ss = FlutterSecureStorage();

class SupportService {
  // ─── Helpers ────────────────────────────────────────────────────────────
  static Future<int> _vendorId() async {
    String? v = await _ss.read(key: 'vendorId');

    if (v == null || v.isEmpty) {
      final p = await SharedPreferences.getInstance();
      v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
    }

    final vid = int.tryParse(v ?? '') ?? 0;
    debugPrint('🏪 vendorId=$vid');
    return vid;
  }

  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('🎫 [$tag] $msg');
  }




  static Future<List<InternalIssue>> getIssues() async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.get(
        'api/chef/issues/$vid',
        service: 'food',
      );

      _log('GET_ISSUES', 'status=${response.statusCode}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final list = jsonDecode(response.body) as List;

        return list
            .whereType<Map<String, dynamic>>()
            .map(InternalIssue.fromJson)
            .toList();
      }
    } catch (e) {
      _log('GET_ISSUES', 'ERROR: $e');
    }

    return [];
  }


  static Future<bool> createIssue(InternalIssue issue) async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.post(
        'api/chef/issues/$vid',
        issue.toJson(null),
        service: 'food',
      );

      _log('CREATE_ISSUE', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('CREATE_ISSUE', 'ERROR: $e');
      return false;
    }
  }


  static Future<bool> updateIssue(int id, InternalIssue issue) async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.put(
        'api/chef/issues/$vid/$id',
        issue.toJson(id),
        service: 'food',
      );

      _log('UPDATE_ISSUE', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('UPDATE_ISSUE', 'ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteIssue(int id) async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.delete(
        'api/vendor/chef/issues/$vid/$id',
        service: 'food',
      );

      _log('DELETE_ISSUE', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('DELETE_ISSUE', 'ERROR: $e');
      return false;
    }
  }




  static Future<List<PlatformTicket>> getPlatformTickets() async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.get(
        'api/user/helpdesk/vendor/$vid',
        service: 'promotions',
      );

      _log('GET_TICKETS', 'status=${response.statusCode}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final list = jsonDecode(response.body) as List;

        return list
            .whereType<Map<String, dynamic>>()
            .map(PlatformTicket.fromJson)
            .toList();
      }
    } catch (e) {
      _log('GET_TICKETS', 'ERROR: $e');
    }

    return [];
  }

  // POST multipart ticket
  static Future<bool> createPlatformTicket(
      PlatformTicket ticket, {
        File? attachment,
      }) async {
    try {
      final vid = await _vendorId();

      final payload = {
        ...ticket.toJson(),
        'vendorId': vid,
      };

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/user/helpdesk/create',
        method: 'POST',
        service: 'promotions',
        data: {
          'ticket': jsonEncode(payload), // JSON blob
        },
        files: attachment != null ? {'attachmentUrl': attachment} : null,
      );

      _log('CREATE_TICKET', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('CREATE_TICKET', 'ERROR: $e');
      return false;
    }
  }
}