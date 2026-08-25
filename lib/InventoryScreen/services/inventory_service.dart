// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/inv_models.dart';
//
// const String _inv = 'http://staging.maamaas.com:8080/food/api/vendor/inventory';
// const String _proc =
//     'http://staging.maamaas.com:8080/food/api/vendor/procurement';
// const String _po =
//     'http://staging.maamaas.com:8080/food/api/vendor/purchase-order';
//
// class InventoryService {
//   static Future<String> _token() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getString('token') ?? p.getString('authToken') ?? '';
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ??
//         int.tryParse(p.getString('vendorId') ?? '') ??
//         0;
//   }
//
//   static Map<String, String> _h(String tok) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $tok',
//   };
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('📦 [Inv/$tag] $msg');
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // INVENTORY ITEMS
//
//   static Future<List<InvItem>> fetchItems() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_inv/get/$vid';
//     _log('GET_ITEMS', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _h(tok));
//       _log('GET_ITEMS', 'status=${res.statusCode}');
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(InvItem.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_ITEMS', 'ERROR: $e');
//     }
//     return [];
//   }
//
//
//   static Future<bool> addItem(Map<String, dynamic> body) async {
//     final tok = await _token();
//     _log('ADD_ITEM', 'POST $_inv');
//     try {
//       final res = await http.post(
//         Uri.parse(_inv),
//         headers: _h(tok),
//         body: jsonEncode(body),
//       );
//       _log('ADD_ITEM', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('ADD_ITEM', 'ERROR: $e');
//       return false;
//     }
//   }
//
//
//   static Future<bool> updateItem(int id, Map<String, dynamic> body) async {
//     final tok = await _token();
//     final url = '$_inv/update/$id';
//     _log('UPDATE_ITEM', 'PUT $url');
//     try {
//       final res = await http.put(
//         Uri.parse(url),
//         headers: _h(tok),
//         body: jsonEncode(body),
//       );
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('UPDATE_ITEM', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   static Future<bool> deleteItem(int id) async {
//     final tok = await _token();
//     final url = '$_inv/delete/$id';
//     _log('DELETE_ITEM', 'DELETE $url');
//     try {
//       final res = await http.delete(Uri.parse(url), headers: _h(tok));
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('DELETE_ITEM', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // CONSUMPTION LOGS
//
//   static Future<List<ConsumptionLog>> fetchConsumptionLogs() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_inv/consumption/$vid';
//     _log('GET_LOGS', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _h(tok));
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(ConsumptionLog.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_LOGS', 'ERROR: $e');
//     }
//     return [];
//   }
//
//
//   static Future<bool> addConsumptionLog(Map<String, dynamic> body) async {
//     final tok = await _token();
//     final url = '$_inv/consumption';
//     _log('ADD_LOG', 'POST $url');
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _h(tok),
//         body: jsonEncode(body),
//       );
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('ADD_LOG', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // PROCUREMENT
//
//   static Future<List<ProcurementSuggestion>>
//   fetchProcurementSuggestions() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_proc/$vid';
//     _log('GET_PROC', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _h(tok));
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .toList()
//             .asMap()
//             .entries
//             .map((e) => ProcurementSuggestion.fromJson(e.value, e.key))
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_PROC', 'ERROR: $e');
//     }
//     return [];
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // PURCHASE ORDERS
//
//   static Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
//     final tok = await _token();
//     final vid = await _vid();
//     final url = '$_po/$vid';
//     _log('GET_PO', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _h(tok));
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(PurchaseOrder.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('GET_PO', 'ERROR: $e');
//     }
//     return [];
//   }
//
//
//   static Future<bool> createPurchaseOrder(Map<String, dynamic> body) async {
//     final tok = await _token();
//     _log('CREATE_PO', 'POST $_po');
//     try {
//       final res = await http.post(
//         Uri.parse(_po),
//         headers: _h(tok),
//         body: jsonEncode(body),
//       );
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CREATE_PO', 'ERROR: $e');
//       return false;
//     }
//   }
//
//
//   static Future<bool> acceptPurchaseOrder(
//     int poId, {
//     required double receivedQty,
//     required String quality,
//     required String remarks,
//   }) async {
//     final tok = await _token();
//     final url = '$_po/accept/$poId';
//     _log('ACCEPT_PO', 'PUT $url');
//     try {
//       final body = {
//         'receivedQty':
//             receivedQty,
//         'quality': quality,
//         'remarks': remarks,
//       };
//       _log('ACCEPT_PO', 'Sending body: $body');
//       final res = await http.put(
//         Uri.parse(url),
//         headers: _h(tok),
//         body: jsonEncode(body),
//       );
//       _log('ACCEPT_PO', 'status=${res.statusCode}, body=${res.body}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('ACCEPT_PO', 'ERROR: $e');
//       return false;
//     }
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/inv_models.dart';

class InventoryService {
  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('📦 [Inv/$tag] $msg');
  }

  // ═══════════════════════════════════════════════════════════════
  // INVENTORY ITEMS
  // ═══════════════════════════════════════════════════════════════

  static Future<List<InvItem>> fetchItems() async {
    final vid = await _getVendorId();
    final endpoint = 'api/vendor/inventory/get/$vid';

    _log('GET_ITEMS', endpoint);

    final res = await ApiClient.get(endpoint, service: 'food');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list
          .whereType<Map<String, dynamic>>()
          .map(InvItem.fromJson)
          .toList();
    }

    return [];
  }

  static Future<bool> addItem(Map<String, dynamic> body) async {
    const endpoint = 'api/vendor/inventory';

    _log('ADD_ITEM', endpoint);

    final res = await ApiClient.post(endpoint, body, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> updateItem(int id, Map<String, dynamic> body) async {
    final endpoint = 'api/vendor/inventory/update/$id';

    _log('UPDATE_ITEM', endpoint);

    final res = await ApiClient.put(endpoint, body, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> deleteItem(int id) async {
    final endpoint = 'api/vendor/inventory/delete/$id';

    _log('DELETE_ITEM', endpoint);

    final res = await ApiClient.delete(endpoint, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ═══════════════════════════════════════════════════════════════
  // CONSUMPTION LOGS
  // ═══════════════════════════════════════════════════════════════

  static Future<List<ConsumptionLog>> fetchConsumptionLogs() async {
    final vid = await _getVendorId();
    final endpoint = 'api/vendor/inventory/consumption/$vid';

    _log('GET_LOGS', endpoint);

    final res = await ApiClient.get(endpoint, service: 'food');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list
          .whereType<Map<String, dynamic>>()
          .map(ConsumptionLog.fromJson)
          .toList();
    }

    return [];
  }

  static Future<bool> addConsumptionLog(Map<String, dynamic> body) async {
    const endpoint = 'api/vendor/inventory/consumption';

    _log('ADD_LOG', endpoint);

    final res = await ApiClient.post(endpoint, body, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ═══════════════════════════════════════════════════════════════
  // PROCUREMENT
  // ═══════════════════════════════════════════════════════════════

  static Future<List<ProcurementSuggestion>>
  fetchProcurementSuggestions() async {
    final vid = await _getVendorId();
    final endpoint = 'api/vendor/procurement/$vid';

    _log('GET_PROC', endpoint);

    final res = await ApiClient.get(endpoint, service: 'food');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list
          .whereType<Map<String, dynamic>>()
          .toList()
          .asMap()
          .entries
          .map((e) => ProcurementSuggestion.fromJson(e.value, e.key))
          .toList();
    }

    return [];
  }

  // ═══════════════════════════════════════════════════════════════
  // PURCHASE ORDERS
  // ═══════════════════════════════════════════════════════════════

  static Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    final vid = await _getVendorId();
    final endpoint = 'api/vendor/purchase-order/$vid';

    _log('GET_PO', endpoint);

    final res = await ApiClient.get(endpoint, service: 'food');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;

      return list
          .whereType<Map<String, dynamic>>()
          .map(PurchaseOrder.fromJson)
          .toList();
    }

    return [];
  }

  static Future<bool> createPurchaseOrder(Map<String, dynamic> body) async {
    const endpoint = 'api/vendor/purchase-order';

    _log('CREATE_PO', endpoint);

    final res = await ApiClient.post(endpoint, body, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> acceptPurchaseOrder(
    int poId, {
    required double receivedQty,
    required String quality,
    required String remarks,
  }) async {
    final endpoint = 'api/vendor/purchase-order/accept/$poId';

    final body = {
      'receivedQty': receivedQty,
      'quality': quality,
      'remarks': remarks,
    };

    _log('ACCEPT_PO', '$endpoint body=$body');

    final res = await ApiClient.put(endpoint, body, service: 'food');

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER
  // ═══════════════════════════════════════════════════════════════

  static Future<int> _getVendorId() async {
    // ApiClient uses secure storage, but we fallback safely
    final p = await SharedPreferences.getInstance();

    return p.getInt('vendorId') ??
        int.tryParse(p.getString('vendorId') ?? '') ??
        0;
  }
}
