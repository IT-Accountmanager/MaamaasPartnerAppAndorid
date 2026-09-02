import 'dart:convert';
import '../../API/APIclient.dart';
import '../models/lead_model.dart';
import '../models/quotation_model.dart';

/// Everything the vendor Leads module needs from the `catering` service.
/// Endpoint shapes are ported 1:1 from `leadService.js` and the inline
/// `fetch()` calls scattered through Lead.jsx / AssignedLeads.jsx /
/// PaidLeads.jsx / LeadsHistory.jsx / Quotations.jsx / LeadsDashboard.jsx.
class LeadService {
  /// GET catering/vendor/{vendorId}
  /// Returns the raw `{ success, data: { fullLeads, maskedLeads } }` map.
  static Future<Map<String, dynamic>> _fetchVendorLeadsRaw(
    String vendorId,
  ) async {
    final response = await ApiClient.get(
      'vendor/$vendorId',
      service: 'catering',
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP error! status: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Masked (unpurchased) leads — used by the "Leads" tab.
  static Future<List<LeadModel>> getMaskedLeads(String vendorId) async {
    final result = await _fetchVendorLeadsRaw(vendorId);
    final maskedLeads = (result['data']?['maskedLeads'] as List<dynamic>?) ?? [];
    return maskedLeads
        .map((e) => LeadModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Full (purchased) leads — used by PaidLeads / AssignedLeads / History /
  /// Quotations / Dashboard. Mirrors `leadService.getFullLeads`.
  static Future<List<LeadModel>> getFullLeads(String vendorId) async {
    final result = await _fetchVendorLeadsRaw(vendorId);
    final fullLeads = (result['data']?['fullLeads'] as List<dynamic>?) ?? [];
    return fullLeads
        .map((e) => LeadModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Both lists at once (used by the Dashboard so it only hits the API once).
  static Future<({List<LeadModel> full, List<LeadModel> masked})>
      getAllLeads(String vendorId) async {
    final result = await _fetchVendorLeadsRaw(vendorId);
    final fullLeads = (result['data']?['fullLeads'] as List<dynamic>?) ?? [];
    final maskedLeads = (result['data']?['maskedLeads'] as List<dynamic>?) ?? [];
    return (
      full: fullLeads
          .map((e) => LeadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      masked: maskedLeads
          .map((e) => LeadModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// GET catering/vendor/quotations/{vendorId}
  /// Returns every quotation the vendor has ever submitted, keyed by leadId
  /// for O(1) lookups (the JS version calls this endpoint once per lead,
  /// which this Dart version avoids by caching the whole list — call
  /// [getVendorQuotationsMap] once per screen load instead).
  static Future<Map<int, QuotationModel>> getVendorQuotationsMap(
    String vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'vendor/quotations/$vendorId',
        service: 'catering',
      );

      if (response.statusCode != 200) return {};

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (result['success'] != true || result['data'] == null) return {};

      final list = (result['data'] as List<dynamic>)
          .map((e) => QuotationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final map = <int, QuotationModel>{};
      for (final q in list) {
        if (q.leadId != null) map[q.leadId!] = q;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Convenience wrapper matching `leadService.getQuotationByLeadId`.
  static Future<QuotationModel?> getQuotationByLeadId(
    String vendorId,
    int leadId,
  ) async {
    final map = await getVendorQuotationsMap(vendorId);
    return map[leadId];
  }

  /// POST catering/vendor/lead/quotation/{leadId}/{vendorId}
  static Future<Map<String, dynamic>> sendQuotation(
    int leadId,
    String vendorId,
    QuotationModel quotation,
  ) async {
    final response = await ApiClient.post(
      'vendor/lead/quotation/$leadId/$vendorId',
      quotation.toPayload(),
      service: 'catering',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Failed to send quotation';
      try {
        final err = jsonDecode(response.body);
        message = err['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// PUT catering/vendor/quotation/status/{quotationId}/{status}
  static Future<Map<String, dynamic>> updateQuotationStatus(
    int quotationId,
    String status,
  ) async {
    final response = await ApiClient.put(
      'vendor/quotation/status/$quotationId/$status',
      {},
      service: 'catering',
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP error! status: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// AssignedLeads.jsx calls `leadService.getLeadById(lead.id)` before
  /// closing a lead, to build the PUT payload without clobbering fields it
  /// doesn't know about. That method wasn't included in the leadService.js
  /// you shared, so this re-fetches the vendor's full-lead list and picks
  /// the matching raw record — same net effect, one extra list fetch.
  static Future<Map<String, dynamic>> getLeadById(
    String vendorId,
    int leadId,
  ) async {
    final result = await _fetchVendorLeadsRaw(vendorId);
    final fullLeads = (result['data']?['fullLeads'] as List<dynamic>?) ?? [];
    final match = fullLeads.firstWhere(
      (e) => (e['id']?.toString() ?? '') == leadId.toString(),
      orElse: () => <String, dynamic>{},
    );
    return Map<String, dynamic>.from(match as Map);
  }

  /// PUT catering/update/{leadId} — used to mark a lead CLOSED.
  static Future<Map<String, dynamic>> closeLead(
    int leadId,
    String vendorId,
  ) async {
    final fullLeadData = await getLeadById(vendorId, leadId);

    final payload = {
      ...fullLeadData,
      'leadStatus': 'CLOSED',
      'vendorId': int.tryParse(vendorId) ?? vendorId,
    };

    final response = await ApiClient.put(
      'update/$leadId',
      payload,
      service: 'catering',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Failed to complete lead';
      try {
        final err = jsonDecode(response.body);
        message = err['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// POST catering/vendor/payment/initiate?leadId=&vendorId=&amount=&orderid=
  /// Records a successful Razorpay payment against a masked lead so it
  /// becomes a full lead. See [RazorpayPaymentService] for the full flow.
  static Future<bool> savePaymentInitiation({
    required int leadId,
    required String vendorId,
    required double amount,
    required String razorpayOrderId,
  }) async {
    final response = await ApiClient.post(
      'vendor/payment/initiate'
      '?leadId=$leadId&vendorId=$vendorId&amount=$amount&orderid=$razorpayOrderId',
      null,
      service: 'catering',
      sendJson: false,
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
