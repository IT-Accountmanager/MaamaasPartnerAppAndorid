import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/models.dart';

// const _food = 'http://staging.maamaas.com:8080/food/api';
// const _subsc = 'http://staging.maamaas.com:8080/subscription/api';

const _ss = FlutterSecureStorage();

Future<String> _token() async {
  String? t = await _ss.read(key: 'token');
  if (t == null || t.isEmpty) {
    final p = await SharedPreferences.getInstance();
    t = p.getString('token') ?? p.getString('authToken');
  }
  debugPrint(
    '🔑 token=${t != null && t.isNotEmpty ? t.substring(0, 20) : "MISSING"}',
  );
  return t ?? '';
}

Future<String> _vendorId() async {
  String? v = await _ss.read(key: 'vendorId');
  if (v == null || v.isEmpty) {
    final p = await SharedPreferences.getInstance();
    v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
  }
  debugPrint('🏪 vendorId=$v');
  return v ?? '';
}

Future<Map<String, String>> _h() async => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer ${await _token()}',
};

class RestaurantStatusApi {
  static Future<void> setOnline() async {
    final vid = await _vendorId();

    final res = await ApiClient.put("api/vendors/Restaurent-stauts/$vid", {
      'online': true,
    }, service: "food");

    if (res.statusCode >= 300) {
      throw Exception('setOnline failed ${res.statusCode}: ${res.body}');
    }
  }

  static Future<void> setOffline(List<String> reasons) async {
    final vid = await _vendorId();

    final body = {
      'online': false,
      if (reasons.isNotEmpty) 'offlineReasons': reasons,
    };

    final res = await ApiClient.put(
      "api/vendors/Restaurent-stauts/$vid",
      body,
      service: "food",
    );

    if (res.statusCode >= 300) {
      throw Exception('setOffline failed ${res.statusCode}: ${res.body}');
    }
  }

  static Future<bool> fetchStatus() async {
    final vid = await _vendorId();

    final res = await ApiClient.get("api/vendors/$vid", service: "food");

    if (res.statusCode == 200) {
      final d = jsonDecode(res.body);
      final v = d['online'] ?? d['status'];
      return v == true || v == 'ONLINE';
    }

    return false;
  }
}

class TimingsApi {
  static Future<List<DayTiming>> fetchAll() async {
    final vid = await _vendorId();

    final res = await ApiClient.get(
      "api/timings/get/timings/$vid",
      service: "food",
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final d = jsonDecode(res.body);
      if (d is List) {
        return d.map((e) => DayTiming.fromJson(e)).toList();
      }
    }

    return [];
  }

  static Future<DayTiming> add(DayTiming t) async {
    final vid = await _vendorId();

    final res = await ApiClient.post("api/timings/daytimings/$vid", {
      'day': t.day,
      'startTime': t.startTimeApi,
      'lastTime': t.lastTimeApi,
      'restaurantStatus': 'Open',
    }, service: "food");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return DayTiming.fromJson(jsonDecode(res.body));
    }

    throw Exception('addTiming failed ${res.statusCode}');
  }

  static Future<DayTiming> update(DayTiming t) async {
    final res = await ApiClient.put("api/timings/edit/timings/${t.id}", {
      'id': t.id,
      'day': t.day,
      'startTime': t.startTimeApi,
      'lastTime': t.lastTimeApi,
      'restaurantStatus': 'Open',
    }, service: "food");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        return DayTiming.fromJson(jsonDecode(res.body));
      } catch (_) {
        return t;
      }
    }

    throw Exception('updateTiming failed ${res.statusCode}');
  }

  static Future<DayTiming> save(DayTiming t) =>
      t.id != null ? update(t) : add(t);
}

class BillingApi {
  static Future<BillingConfig?> fetch() async {
    final vid = await _vendorId();

    final res = await ApiClient.get("api/billing/get/$vid", service: "food");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final d = jsonDecode(res.body);

      final j = d is List ? (d.isNotEmpty ? d.first : null) : d;

      if (j != null) return BillingConfig.fromJson(j);
    }

    return null;
  }

  static Future<void> saveOrderTypes(List<String> orderTypes) async {
    final vid = await _vendorId();

    final res = await ApiClient.put(
      "api/billing/vendor/$vid/order-types",
      orderTypes,
      service: "food",
    );

    if (res.statusCode >= 300) {
      throw Exception('saveOrderTypes failed ${res.statusCode}');
    }
  }

  static Future<void> save(BillingConfig config) async {
    final vid = await _vendorId();
    final vidInt = int.tryParse(vid) ?? 0;

    final existing = await fetch();

    if (existing?.id != null) {
      final payload = config.toApiPayload(vidInt)..['id'] = existing!.id;

      final res = await ApiClient.put(
        "api/billing/edit/${existing.id}",
        payload,
        service: "food",
      );

      if (res.statusCode >= 300) {
        throw Exception('billing PUT failed');
      }
    } else {
      final payload = config.toApiPayload(vidInt)..remove('id');

      final res = await ApiClient.post(
        "api/billing/add/charges/$vid",
        payload,
        service: "food",
      );

      if (res.statusCode >= 300) {
        throw Exception('billing POST failed');
      }
    }

    await saveOrderTypes(config.orderTypes);
  }
}

// class EmployeeApi {
//   static Future<List<EmployeeModule>> fetchAll() async {
//     final vid = await _vendorId();
//
//     final res = await ApiClient.get(
//       "get-employees/enquiry/$vid",
//       service: "subscription",
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final d = jsonDecode(res.body);
//       if (d is List) {
//         return d.map((e) => EmployeeModule.fromJson(e)).toList();
//       }
//     }
//
//     return [];
//   }
//
//   static Future<void> updateModules(
//     int empVendorId,
//     List<String> modules,
//     List<String> subs,
//   ) async {
//     final res = await ApiClient.put("edit/enquiry/$empVendorId", {
//       'businessModules': modules,
//       'subModules': subs,
//     }, service: "subscription");
//
//     if (res.statusCode >= 300) {
//       throw Exception('updateModules failed ${res.statusCode}');
//     }
//   }
//
//   static Future<void> updateStatus(int empVendorId, bool enabled) async {
//     final res = await ApiClient.put("edit/enquiry/$empVendorId", {
//       'enabled': enabled,
//     }, service: "subscription");
//
//     if (res.statusCode >= 300) {
//       throw Exception('updateStatus failed ${res.statusCode}');
//     }
//   }
// }

class EmployeeApi {
  static Future<List<EmployeeModule>> fetchAll() async {
    final vid = await _vendorId();
    final res = await ApiClient.get(
      'api/get-employees/enquiry/$vid',
      service: 'subscription',
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final d = jsonDecode(res.body);

      if (d is List) {
        return d
            .map((j) => EmployeeModule.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  static Future<void> updateModules(
    int empVendorId,
    List<String> modules,
    List<String> subs,
  ) async {
    final res = await ApiClient.put('api/edit/enquiry/$empVendorId', {
      'businessModules': modules,
      'subModules': subs,
    }, service: 'subscription');

    if (res.statusCode >= 300) {
      throw Exception('updateModules failed ${res.statusCode}: ${res.body}');
    }
  }

  static Future<void> updateStatus(int empVendorId, bool enabled) async {
    final res = await ApiClient.put('api/edit/enquiry/$empVendorId', {
      'enabled': enabled,
    }, service: 'subscription');

    if (res.statusCode >= 300) {
      throw Exception('updateStatus failed ${res.statusCode}: ${res.body}');
    }
  }
}
//
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../models/models.dart';
//
// const _ss = FlutterSecureStorage();
//
// class _Helper {
//   static Future<String> token() async {
//     String? t = await _ss.read(key: 'token');
//
//     if (t == null || t.isEmpty) {
//       final p = await SharedPreferences.getInstance();
//       t = p.getString('token') ?? p.getString('authToken');
//     }
//
//     debugPrint(
//       '🔑 token=${t != null && t.isNotEmpty ? t.substring(0, 20) : "MISSING"}',
//     );
//
//     return t ?? '';
//   }
//
//   static Future<String> vendorId() async {
//     String? v = await _ss.read(key: 'vendorId');
//
//     if (v == null || v.isEmpty) {
//       final p = await SharedPreferences.getInstance();
//       v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
//     }
//
//     debugPrint('🏪 vendorId=$v');
//     return v ?? '';
//   }
// }
//
// class RestaurantStatusApi {
//   static Future<void> setOnline() async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.put('api/vendors/Restaurent-stauts/$vid', {
//       'online': true,
//     }, service: 'food');
//
//     if (res.statusCode >= 300) {
//       throw Exception('setOnline failed ${res.statusCode}: ${res.body}');
//     }
//   }
//
//   static Future<void> setOffline(List<String> reasons) async {
//     final vid = await _Helper.vendorId();
//
//     final body = {'online': false};
//     if (reasons.isNotEmpty) body['offlineReasons'] = reasons as bool;
//     final res = await ApiClient.put(
//       'api/vendors/Restaurent-stauts/$vid',
//       body,
//       service: 'food',
//     );
//
//     if (res.statusCode >= 300) {
//       throw Exception('setOffline failed ${res.statusCode}: ${res.body}');
//     }
//   }
//
//   static Future<bool> fetchStatus() async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.get('api/vendors/status/$vid', service: 'food');
//
//     if (res.statusCode == 200 && res.body.isNotEmpty) {
//       final d = jsonDecode(res.body);
//
//       if (d is Map) {
//         final v = d['online'] ?? d['status'];
//         return v == true || v == 'ONLINE';
//       }
//     }
//
//     return true;
//   }
// }
//
// class TimingsApi {
//   static Future<List<DayTiming>> fetchAll() async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.get(
//       'api/timings/get/timings/$vid',
//       service: 'food',
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final d = jsonDecode(res.body);
//
//       if (d is List) {
//         return d
//             .map((j) => DayTiming.fromJson(j as Map<String, dynamic>))
//             .toList();
//       }
//     }
//
//     return [];
//   }
//
//   static Future<DayTiming> add(DayTiming t) async {
//     final vid = await _Helper.vendorId();
//
//     final body = {
//       'day': t.day,
//       'startTime': t.startTimeApi,
//       'lastTime': t.lastTimeApi,
//       'restaurantStatus': 'Open',
//     };
//
//     final res = await ApiClient.post(
//       'api/timings/daytimings/$vid',
//       body,
//       service: 'food',
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final d = jsonDecode(res.body);
//
//       if (d is Map<String, dynamic>) {
//         return DayTiming.fromJson(d);
//       }
//     }
//
//     throw Exception('addTiming failed ${res.statusCode}: ${res.body}');
//   }
//
//   static Future<DayTiming> update(DayTiming t) async {
//     final body = {
//       'id': t.id,
//       'day': t.day,
//       'startTime': t.startTimeApi,
//       'lastTime': t.lastTimeApi,
//       'restaurantStatus': 'Open',
//     };
//
//     final res = await ApiClient.put(
//       'api/timings/edit/timings/${t.id}',
//       body,
//       service: 'food',
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       try {
//         final d = jsonDecode(res.body);
//         if (d is Map<String, dynamic>) {
//           return DayTiming.fromJson(d);
//         }
//       } catch (_) {}
//
//       return t;
//     }
//
//     throw Exception('updateTiming failed ${res.statusCode}: ${res.body}');
//   }
//
//   static Future<DayTiming> save(DayTiming t) {
//     return t.id != null ? update(t) : add(t);
//   }
// }
//
// class BillingApi {
//   static Future<BillingConfig?> fetch() async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.get('api/billing/get/$vid', service: 'food');
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final d = jsonDecode(res.body);
//
//       final j = d is List
//           ? (d.isNotEmpty ? d.first as Map<String, dynamic> : null)
//           : d as Map<String, dynamic>?;
//
//       if (j != null) {
//         return BillingConfig.fromJson(j);
//       }
//     }
//
//     return null;
//   }
//
//   static Future<void> saveOrderTypes(List<String> orderTypes) async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.put(
//       'api/billing/vendor/$vid/order-types',
//       orderTypes,
//       service: 'food',
//     );
//
//     if (res.statusCode >= 300) {
//       throw Exception('saveOrderTypes failed ${res.statusCode}: ${res.body}');
//     }
//   }
//
//   static Future<void> save(BillingConfig config) async {
//     final vid = await _Helper.vendorId();
//     final vidInt = int.tryParse(vid) ?? 0;
//
//     BillingConfig? existing;
//
//     try {
//       existing = await fetch();
//     } catch (_) {}
//
//     if (existing != null && existing.id != null) {
//       final payload = config.toApiPayload(vidInt);
//       payload['id'] = existing.id;
//
//       final res = await ApiClient.put(
//         'api/billing/edit/${existing.id}',
//         payload,
//         service: 'food',
//       );
//
//       if (res.statusCode >= 300) {
//         throw Exception('billing PUT failed ${res.statusCode}: ${res.body}');
//       }
//     } else {
//       final payload = config.toApiPayload(vidInt);
//       payload.remove('id');
//
//       final res = await ApiClient.post(
//         'api/billing/add/charges/$vid',
//         payload,
//         service: 'food',
//       );
//
//       if (res.statusCode >= 300) {
//         throw Exception('billing POST failed ${res.statusCode}: ${res.body}');
//       }
//     }
//
//     await saveOrderTypes(config.orderTypes);
//   }
// }
//
// class EmployeeApi {
//   static Future<List<EmployeeModule>> fetchAll() async {
//     final vid = await _Helper.vendorId();
//
//     final res = await ApiClient.get(
//       'api/get-employees/enquiry/$vid',
//       service: 'subscription',
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final d = jsonDecode(res.body);
//
//       if (d is List) {
//         return d
//             .map((j) => EmployeeModule.fromJson(j as Map<String, dynamic>))
//             .toList();
//       }
//     }
//
//     return [];
//   }
//
//   static Future<void> updateModules(
//     int empVendorId,
//     List<String> modules,
//     List<String> subs,
//   ) async {
//     final res = await ApiClient.put('api/edit/enquiry/$empVendorId', {
//       'businessModules': modules,
//       'subModules': subs,
//     }, service: 'subscription');
//
//     if (res.statusCode >= 300) {
//       throw Exception('updateModules failed ${res.statusCode}: ${res.body}');
//     }
//   }
//
//   static Future<void> updateStatus(int empVendorId, bool enabled) async {
//     final res = await ApiClient.put('api/edit/enquiry/$empVendorId', {
//       'enabled': enabled,
//     }, service: 'subscription');
//
//     if (res.statusCode >= 300) {
//       throw Exception('updateStatus failed ${res.statusCode}: ${res.body}');
//     }
//   }
// }
