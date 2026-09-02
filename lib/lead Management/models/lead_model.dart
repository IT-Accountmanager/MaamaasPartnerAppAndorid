import 'add_on_model.dart';
import 'quotation_model.dart';

class LeadModel {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final String eventType;
  final String? eventDate;
  final String? fromDate;
  final String? toDate;
  final String? eventTime;
  final String city;
  final String state;
  final int vegPlates;
  final int nonVegPlates;
  final int mixedPlates;
  final double leadPrice;
  final Map<String, dynamic> items;
  final List<AddOnModel> addOns;
  final bool masked;
  final String accessMessage;
  final String? createdAt;
  final String leadStatus;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final String? pincode;
  final String additionalRequests;
  final String event;
  final double? paymentAmount;
  final String? paymentMethod;
  final String? transactionId;

  // Quotation info (merged in after a second API call, mirrors the JS pattern)
  final String? quotationStatus;
  final int? quotationId;
  final bool hasQuotation;
  final QuotationModel? quotationData;

  LeadModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.eventType,
    this.eventDate,
    this.fromDate,
    this.toDate,
    this.eventTime,
    required this.city,
    required this.state,
    required this.vegPlates,
    required this.nonVegPlates,
    required this.mixedPlates,
    required this.leadPrice,
    required this.items,
    required this.addOns,
    required this.masked,
    required this.accessMessage,
    this.createdAt,
    required this.leadStatus,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    this.pincode,
    required this.additionalRequests,
    required this.event,
    this.paymentAmount,
    this.paymentMethod,
    this.transactionId,
    this.quotationStatus,
    this.quotationId,
    this.hasQuotation = false,
    this.quotationData,
  });

  int get totalPlates => vegPlates + nonVegPlates + mixedPlates;

  /// Parses a masked or full lead JSON object into a [LeadModel].
  /// Mirrors the inline `.map()` transform repeated in every screen's JSX.
  factory LeadModel.fromJson(Map<String, dynamic> lead) {
    return LeadModel(
      id: lead['id'] is int
          ? lead['id']
          : int.tryParse(lead['id']?.toString() ?? '') ?? 0,
      name: lead['fullName']?.toString() ?? 'Unknown',
      mobile: lead['phoneNumber']?.toString() ?? 'N/A',
      email: lead['email']?.toString() ?? 'N/A',
      eventType: lead['eventType']?.toString() ?? 'OTHER',
      eventDate: lead['eventDate']?.toString() ?? lead['fromDate']?.toString(),
      fromDate: lead['fromDate']?.toString(),
      toDate: lead['toDate']?.toString(),
      eventTime: lead['eventTime']?.toString(),
      city: lead['city']?.toString() ?? 'N/A',
      state: lead['state']?.toString() ?? 'N/A',
      vegPlates: _toInt(lead['vegPlates']),
      nonVegPlates: _toInt(lead['nonVegPlates']),
      mixedPlates: _toInt(lead['mixedPlates']),
      leadPrice: _toDouble(lead['leadPrice']),
      items: (lead['items'] is Map)
          ? Map<String, dynamic>.from(lead['items'])
          : {},
      addOns: (lead['addOns'] as List<dynamic>? ?? [])
          .map((e) => AddOnModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      masked: lead['masked'] is bool ? lead['masked'] : true,
      accessMessage: lead['accessMessage']?.toString() ??
          'Payment required for full details',
      createdAt: lead['createdAt']?.toString() ?? lead['createdDate']?.toString(),
      leadStatus: lead['leadStatus']?.toString() ?? 'NEW',
      fullAddress: lead['fullAddress']?.toString() ?? '',
      latitude: lead['latitude'] is num ? (lead['latitude'] as num).toDouble() : null,
      longitude: lead['longitude'] is num ? (lead['longitude'] as num).toDouble() : null,
      pincode: lead['pincode']?.toString(),
      additionalRequests: lead['additionalRequests']?.toString() ?? '',
      event: lead['event']?.toString() ?? 'EVENT',
      paymentAmount: lead['paymentAmount'] is num
          ? (lead['paymentAmount'] as num).toDouble()
          : null,
      paymentMethod: lead['paymentMethod']?.toString(),
      transactionId: lead['transactionId']?.toString(),
    );
  }

  /// Returns a copy with quotation info merged in, mirroring the
  /// `Promise.all(fullLeads.map(async lead => ({...lead, quotationStatus...})))`
  /// pattern used in AssignedLeads.jsx / PaidLeads.jsx / Quotations.jsx.
  LeadModel withQuotation(QuotationModel? quotation) {
    return LeadModel(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      eventType: eventType,
      eventDate: eventDate,
      fromDate: fromDate,
      toDate: toDate,
      eventTime: eventTime,
      city: city,
      state: state,
      vegPlates: vegPlates,
      nonVegPlates: nonVegPlates,
      mixedPlates: mixedPlates,
      leadPrice: leadPrice,
      items: items,
      addOns: addOns,
      masked: masked,
      accessMessage: accessMessage,
      createdAt: createdAt,
      leadStatus: leadStatus,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      pincode: pincode,
      additionalRequests: additionalRequests,
      event: event,
      paymentAmount: paymentAmount ?? leadPrice,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      quotationStatus: quotation?.status,
      quotationId: quotation?.id,
      hasQuotation: quotation != null,
      quotationData: quotation,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}
