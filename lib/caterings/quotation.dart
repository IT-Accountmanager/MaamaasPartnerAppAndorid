import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../API/Authservice.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _cBg = Color(0xFFF7F8FC);
const _cWhite = Color(0xFFFFFFFF);
const _cBorder = Color(0xFFEEEFF5);
const _cAccent = Color(0xFFE66D33);
const _cAccentLt = Color(0xFFFFF0E8);
const _cText1 = Color(0xFF111827);
const _cText2 = Color(0xFF6B7280);
const _cText3 = Color(0xFFB0B3C1);
const _cGreen = Color(0xFF10B981);
const _cGreenLt = Color(0xFFD1FAE5);
const _cRed = Color(0xFFEF4444);
const _cRedLt = Color(0xFFFEE2E2);
const _cAmber = Color(0xFFF59E0B);
const _cAmberLt = Color(0xFFFEF3C7);
const _cPurple = Color(0xFFb15cd6);
const _cPurpleLt = Color(0xFFF3E8FF);
const _cShadow = Color(0x0A000000);

const _kGrad = LinearGradient(
  colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Models (unchanged) ────────────────────────────────────────────────────────
class LeadDetailsResponse {
  final bool success;
  final String message;
  final LeadData data;
  final String timestamp;
  final String? errorCode;
  LeadDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
    this.errorCode,
  });
  factory LeadDetailsResponse.fromJson(Map<String, dynamic> json) =>
      LeadDetailsResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: LeadData.fromJson(json['data'] ?? {}),
        timestamp: json['timestamp'] ?? '',
        errorCode: json['errorCode'],
      );
}

class LeadData {
  final int id, userId;
  final int? customerId;
  final String fullName, email, phoneNumber;
  final String? companyName;
  final String eventType, eventDate, eventTime;
  final String? fromDate, toDate;
  final String fullAddress, city, state, country;
  final double latitude, longitude;
  final int pincode, addressId;
  final int? vegPlates, nonVegPlates, mixedPlates;
  final String additionalRequests, leadStatus, createdAt, event, accessMessage;
  final Map<String, dynamic> items;
  final List<AddOn> addOns;
  final bool masked, accessible;
  final double leadPrice;

  LeadData({
    required this.id,
    required this.userId,
    this.customerId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.companyName,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    this.fromDate,
    this.toDate,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.addressId,
    this.vegPlates,
    this.nonVegPlates,
    this.mixedPlates,
    required this.additionalRequests,
    required this.leadStatus,
    required this.createdAt,
    required this.items,
    required this.addOns,
    required this.event,
    required this.masked,
    required this.accessible,
    required this.leadPrice,
    required this.accessMessage,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
    id: json['id'] ?? 0,
    userId: json['userId'] ?? 0,
    customerId: json['customerId'],
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    companyName: json['companyName'],
    eventType: json['eventType'] ?? '',
    eventDate: json['eventDate'] ?? '',
    eventTime: json['eventTime'] ?? '',
    fromDate: json['fromDate'],
    toDate: json['toDate'],
    fullAddress: json['fullAddress'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    country: json['country'] ?? '',
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    pincode: json['pincode'] ?? 0,
    addressId: json['addressId'] ?? 0,
    vegPlates: json['vegPlates'],
    nonVegPlates: json['nonVegPlates'],
    mixedPlates: json['mixedPlates'],
    additionalRequests: json['additionalRequests'] ?? '',
    leadStatus: json['leadStatus'] ?? '',
    createdAt: json['createdAt'] ?? '',
    items: json['items'] ?? {},
    addOns: (json['addOns'] as List? ?? [])
        .map((i) => AddOn.fromJson(i))
        .toList(),
    event: json['event'] ?? '',
    masked: json['masked'] ?? false,
    accessible: json['accessible'] ?? false,
    leadPrice: (json['leadPrice'] ?? 0.0).toDouble(),
    accessMessage: json['accessMessage'] ?? '',
  );

  int get totalPlates =>
      (vegPlates ?? 0) + (nonVegPlates ?? 0) + (mixedPlates ?? 0);
}

class AddOn {
  final int id, quantity;
  final String addOnType;
  final bool selected;
  AddOn({
    required this.id,
    required this.addOnType,
    required this.quantity,
    required this.selected,
  });
  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    id: json['id'] ?? 0,
    addOnType: json['addOnType'] ?? '',
    quantity: json['quantity'] ?? 1,
    selected: json['selected'] ?? false,
  );
  bool get isSelected => selected;
}

// ─── API Service (unchanged logic) ────────────────────────────────────────────
class LeadApiService {
  final String baseUrl = 'http://staging.maamaas.com:8080/catering/api';
  String? _authToken;
  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<LeadDetailsResponse> fetchLeadDetails({
    required int leadId,
    required int vendorId,
    String? token,
  }) async {
    final authToken = token ?? _authToken;
    if (authToken == null || authToken.isEmpty)
      throw Exception('Authentication token is required');
    final response = await http.get(
      Uri.parse('$baseUrl/vendor/$leadId/$vendorId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200)
      return LeadDetailsResponse.fromJson(json.decode(response.body));
    throw Exception('Failed to load lead details: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> sendQuotation({
    required int leadId,
    required int vendorId,
    double? vegPerPlatePrice,
    double? nonVegPerPlatePrice,
    double? mixedPerPlatePrice,
    required List<Map<String, dynamic>> addOnPrices,
    String? quotationDetails,
    double? totalAmount,
    String? token,
  }) async {
    final authToken = token ?? _authToken;
    if (authToken == null || authToken.isEmpty)
      throw Exception('Authentication token is required');
    final body = <String, dynamic>{};
    if (vegPerPlatePrice != null && vegPerPlatePrice > 0)
      body['vegPerPlatePrice'] = vegPerPlatePrice;
    if (nonVegPerPlatePrice != null && nonVegPerPlatePrice > 0)
      body['nonVegPerPlatePrice'] = nonVegPerPlatePrice;
    if (mixedPerPlatePrice != null && mixedPerPlatePrice > 0)
      body['mixedPerPlatePrice'] = mixedPerPlatePrice;
    if (addOnPrices.isNotEmpty) body['addOnPrices'] = addOnPrices;
    if (totalAmount != null && totalAmount > 0)
      body['totalAmount'] = totalAmount;
    if (quotationDetails != null && quotationDetails.isNotEmpty)
      body['quotationDetails'] = quotationDetails;
    final response = await http.post(
      Uri.parse('$baseUrl/vendor/lead/quotation/$leadId/$vendorId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201)
      return json.decode(response.body);
    throw Exception('Failed to send quotation: ${response.statusCode}');
  }
}

// ─── Quotation Screen ─────────────────────────────────────────────────────────
class QuotationScreen extends StatefulWidget {
  final Map<String, dynamic>? order;
  final int? vendorId;
  const QuotationScreen({super.key, this.order, this.vendorId});
  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final _vegCtrl = TextEditingController();
  final _nonVegCtrl = TextEditingController();
  final _mixedCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final Map<int, TextEditingController> _addOnCtrls = {};

  bool _isSending = false;
  bool _hasExisting = false;
  bool _showConfirm = false;
  bool _isLoading = true;
  bool _isAmountManual = false;
  String? _error;

  LeadData? _lead;
  List<AddOn> _selectedAddOns = [];
  double _addOnsTotal = 0.0;
  double _total = 0.0;

  final _api = LeadApiService();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _vegCtrl.dispose();
    _nonVegCtrl.dispose();
    _mixedCtrl.dispose();
    _detailsCtrl.dispose();
    _amountCtrl.dispose();
    for (final c in _addOnCtrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token;
      for (final k in [
        'auth_token',
        'token',
        'authToken',
        'access_token',
        'jwt_token',
      ]) {
        token = prefs.getString(k);
        if (token != null) break;
      }
      setState(() => _token = token);
      if (token == null) {
        _useFallback();
        return;
      }
      _api.setAuthToken(token);
      _fetchLead();
    } catch (_) {
      _useFallback();
    }
  }

  void _useFallback() {
    final order = widget.order ?? {};
    final mock = LeadData(
      id: order['id'] ?? order['leadId'] ?? order['orderId'] ?? 0,
      userId: 0,
      customerId: null,
      fullName: order['fullName'] ?? order['name'] ?? 'Customer',
      email: order['email'] ?? '',
      phoneNumber: order['phoneNumber'] ?? '',
      companyName: null,
      eventType: order['eventType'] ?? 'EVENT',
      eventDate: order['eventDate'] ?? '',
      eventTime: order['eventTime'] ?? '',
      fromDate: null,
      toDate: null,
      fullAddress: order['fullAddress'] ?? order['address'] ?? '',
      city: order['city'] ?? '',
      state: order['state'] ?? '',
      country: '',
      latitude: 0,
      longitude: 0,
      pincode: 0,
      addressId: 0,
      vegPlates: order['vegPlates'],
      nonVegPlates: order['nonVegPlates'],
      mixedPlates: order['mixedPlates'],
      additionalRequests: order['additionalRequests'] ?? '',
      leadStatus: 'ASSIGNED',
      createdAt: '',
      items: order['items'] ?? {},
      addOns: (order['addOns'] as List? ?? []).map((i) {
        if (i is Map<String, dynamic>) return AddOn.fromJson(i);
        return AddOn(
          id: 0,
          addOnType: i.toString(),
          quantity: 1,
          selected: true,
        );
      }).toList(),
      event: 'EVENT',
      masked: false,
      accessible: true,
      leadPrice: 0,
      accessMessage: '',
    );
    setState(() {
      _lead = mock;
      _selectedAddOns = mock.addOns.where((a) => a.selected).toList();
      _isLoading = false;
      _initControllers();
    });
  }

  Future<void> _fetchLead() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final leadId = widget.order != null
          ? (widget.order!['id'] ??
                widget.order!['leadId'] ??
                widget.order!['orderId'] ??
                0)
          : 0;

      // Get Vendor ID
      int vendorId = widget.vendorId ?? 0;

      if (vendorId == 0) {
        final prefs = await SharedPreferences.getInstance();

        // Correct key is 'vendorId'
        vendorId = prefs.getInt('vendorId') ?? 0;

        if (vendorId == 0) {
          vendorId = await Authservice.getVendorId() ?? 0;
        }
      }

      print("Lead ID: $leadId");
      print("Vendor ID: $vendorId");
      print("Token: ${_token != null}");

      if (leadId == 0 || vendorId == 0 || _token == null) {
        print("Invalid LeadId or VendorId");
        _useFallback();
        return;
      }

      final resp = await _api.fetchLeadDetails(
        leadId: leadId,
        vendorId: vendorId,
        token: _token!,
      );

      print("API Success: ${resp.success}");
      print("AddOns Count: ${resp.data.addOns.length}");

      for (final addon in resp.data.addOns) {
        print(
          "Addon -> ${addon.addOnType}, "
          "Qty: ${addon.quantity}, "
          "Selected: ${addon.selected}",
        );
      }

      if (resp.success) {
        final selected = resp.data.addOns.where((a) => a.selected).toList();

        setState(() {
          _lead = resp.data;
          _selectedAddOns = selected;
          _isLoading = false;
        });

        _initControllers();
      } else {
        _useFallback();
      }
    } catch (e, stackTrace) {
      print("Fetch Lead Error: $e");
      print(stackTrace);

      _useFallback();
    }
  }

  void _initControllers() {
    if (_lead == null) return;
    for (final a in _selectedAddOns) {
      _addOnCtrls[a.id] = TextEditingController(text: '');
    }
    _vegCtrl.addListener(_calcTotal);
    _nonVegCtrl.addListener(_calcTotal);
    _mixedCtrl.addListener(_calcTotal);
    for (final c in _addOnCtrls.values) c.addListener(_calcTotal);
    _calcTotal();
  }

  void _calcTotal() {
    if (_lead == null) return;
    double plates = 0;
    if (_hasVeg)
      plates += (double.tryParse(_vegCtrl.text) ?? 0) * _lead!.vegPlates!;
    if (_hasNonVeg)
      plates += (double.tryParse(_nonVegCtrl.text) ?? 0) * _lead!.nonVegPlates!;
    if (_hasMixed)
      plates += (double.tryParse(_mixedCtrl.text) ?? 0) * _lead!.mixedPlates!;
    _addOnsTotal = 0;
    for (final a in _selectedAddOns) {
      final c = _addOnCtrls[a.id];

      if (c != null) {
        final price = double.tryParse(c.text) ?? 0;
        _addOnsTotal += price * a.quantity;
      }
    }
    _total = plates + _addOnsTotal;
    if (!_isAmountManual)
      _amountCtrl.text = _total > 0 ? _total.toStringAsFixed(2) : '';
    setState(() {});
  }

  bool get _hasVeg => _lead?.vegPlates != null && _lead!.vegPlates! > 0;
  bool get _hasNonVeg =>
      _lead?.nonVegPlates != null && _lead!.nonVegPlates! > 0;
  bool get _hasMixed => _lead?.mixedPlates != null && _lead!.mixedPlates! > 0;

  List<Map<String, dynamic>> _prepareAddOns() {
    return _selectedAddOns
        .map((a) {
          final c = _addOnCtrls[a.id];
          final price = double.tryParse(c?.text ?? '') ?? 0;

          if (price <= 0) return null;

          return {'addOnId': a.id, 'quantity': a.quantity, 'price': price};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _sendQuotation() async {
    try {
      if (_lead == null) throw Exception('No lead data');
      final leadId = _lead!.id;
      int vendorId = widget.vendorId ?? 0;
      if (vendorId == 0) {
        final prefs = await SharedPreferences.getInstance();
        vendorId = prefs.getInt('vendorId') ?? 0;
      }
      if (leadId == 0) throw Exception('Invalid lead ID');
      final vegPrice = _hasVeg ? double.tryParse(_vegCtrl.text) : null;
      final nvPrice = _hasNonVeg ? double.tryParse(_nonVegCtrl.text) : null;
      final mxPrice = _hasMixed ? double.tryParse(_mixedCtrl.text) : null;
      final addOns = _prepareAddOns();
      if ((vegPrice == null || vegPrice <= 0) &&
          (nvPrice == null || nvPrice <= 0) &&
          (mxPrice == null || mxPrice <= 0) &&
          addOns.isEmpty)
        throw Exception('Please enter at least one price');
      await _api.sendQuotation(
        leadId: leadId,
        vendorId: vendorId,
        vegPerPlatePrice: vegPrice,
        nonVegPerPlatePrice: nvPrice,
        mixedPerPlatePrice: mxPrice,
        addOnPrices: addOns,
        quotationDetails: _detailsCtrl.text.isNotEmpty
            ? _detailsCtrl.text
            : null,
        totalAmount: _total,
        token: _token,
      );
      if (mounted) {
        setState(() => _isSending = false);
        _snack('Quotation sent successfully!', _cGreen);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _snack(
          'Failed to send quotation: ${e.toString().replaceAll('Exception: ', '')}',
          _cRed,
        );
      }
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _addOnName(String type) {
    const m = {
      'SERVICE_BOYS': 'Service Boys',
      'PAPER_PLATES': 'Paper Plates',
      'WATER_BOTTLES': 'Water Bottles',
      'DISPOSABLE_CUPS': 'Disposable Cups',
      'TISSUE_PAPER': 'Tissue Paper',
    };
    return m[type] ??
        type
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) => w.isNotEmpty
                  ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                  : '',
            )
            .join(' ');
  }

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '';
    try {
      return DateFormat('dd MMMM yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtTime(String? s) {
    if (s == null || s.isEmpty) return '';
    try {
      final p = s.split(':');
      return '${p[0]}:${p[1]}';
    } catch (_) {
      return s;
    }
  }

  String _fmtCurrency(double v) {
    if (v == 0) return '';
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(v);
  }

  String _eventLabel(String t) => t
      .split('_')
      .map(
        (w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '',
      )
      .join(' ');

  // ─── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _cBg,
      // ── SafeArea: NO AppBar present → SafeArea on body handles status bar + home indicator ──
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _cAccent,
                            strokeWidth: 2,
                          ),
                        )
                      : _error != null
                      ? _buildErrorState()
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            24 + MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderSummary(),
                              const SizedBox(height: 16),
                              if (_hasVeg || _hasNonVeg || _hasMixed) ...[
                                _buildPlateCounts(),
                                const SizedBox(height: 16),
                              ],
                              _buildPriceInputs(),
                              if (_selectedAddOns.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildAddOnsSection(),
                              ],
                              if (_total > 0) ...[
                                const SizedBox(height: 16),
                                _buildTotalAmount(),
                              ],
                              const SizedBox(height: 16),
                              _buildDetailsField(),
                              const SizedBox(height: 24),
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            if (_showConfirm) _buildConfirmModal(),
            if (_isSending) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // ── White header (same style as Order Management) ─────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: _cWhite,
        border: Border(bottom: BorderSide(color: _cBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _cBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _cText1,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasExisting
                      ? 'Quotation #${_lead?.id ?? ''}'
                      : 'Create Quotation',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _cText1,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_lead != null)
                  Text(
                    'Lead #${_lead!.id}',
                    style: const TextStyle(fontSize: 12, color: _cText2),
                  ),
              ],
            ),
          ),
          if (_lead?.leadPrice != null && _lead!.leadPrice > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _cPurpleLt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _cPurple.withOpacity(0.3)),
              ),
              child: Text(
                _fmtCurrency(_lead!.leadPrice),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _cPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Order summary card ─────────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    if (_lead == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer',
                      style: TextStyle(fontSize: 12, color: _cText2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lead!.fullName.isNotEmpty
                          ? _lead!.fullName
                          : 'Not provided',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _cText1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: _kGrad,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _eventLabel(_lead!.eventType),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_lead!.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.phone_rounded, 'Phone', _lead!.phoneNumber),
          ],
          if (_lead!.email.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.email_outlined, 'Email', _lead!.email),
          ],
          if (_lead!.fullAddress.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_rounded, 'Address', _lead!.fullAddress),
          ],
          if (_lead!.eventDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.calendar_today_rounded,
              'Event Date',
              _fmtDate(_lead!.eventDate),
            ),
          ],
          if (_lead!.eventTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.access_time_rounded,
              'Event Time',
              _fmtTime(_lead!.eventTime),
            ),
          ],
          if (_lead!.totalPlates > 0) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.people_rounded,
              'Total Guests',
              '${_lead!.totalPlates}',
            ),
          ],
          if (_lead!.additionalRequests.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: _cBorder, height: 1),
            const SizedBox(height: 10),
            const Text(
              'Additional Requests',
              style: TextStyle(fontSize: 12, color: _cText2),
            ),
            const SizedBox(height: 4),
            Text(
              _lead!.additionalRequests,
              style: const TextStyle(
                fontSize: 14,
                color: _cText1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _cText3),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _cText2)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: _cText1,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Plate counts ──────────────────────────────────────────────────────────────
  Widget _buildPlateCounts() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (_hasVeg) _plateCount('Veg', _lead!.vegPlates!, _cGreen),
          if (_hasVeg && _hasNonVeg)
            Container(height: 36, width: 1, color: _cBorder),
          if (_hasNonVeg) _plateCount('Non-Veg', _lead!.nonVegPlates!, _cRed),
          if ((_hasVeg || _hasNonVeg) && _hasMixed)
            Container(height: 36, width: 1, color: _cBorder),
          if (_hasMixed) _plateCount('Mixed', _lead!.mixedPlates!, _cAmber),
        ],
      ),
    );
  }

  Widget _plateCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: _cText2)),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text('plates', style: TextStyle(fontSize: 10, color: _cText3)),
      ],
    );
  }

  // ── Price inputs ──────────────────────────────────────────────────────────────
  Widget _buildPriceInputs() {
    return Column(
      children: [
        if (_hasVeg)
          _priceField(
            'Veg Plate Price',
            '${_lead!.vegPlates} plates',
            _cGreen,
            'VEG',
            _vegCtrl,
          ),
        if (_hasVeg) const SizedBox(height: 12),
        if (_hasNonVeg)
          _priceField(
            'Non-Veg Plate Price',
            '${_lead!.nonVegPlates} plates',
            _cRed,
            'NON-VEG',
            _nonVegCtrl,
          ),
        if (_hasNonVeg) const SizedBox(height: 12),
        if (_hasMixed)
          _priceField(
            'Mixed Plate Price',
            '${_lead!.mixedPlates} plates',
            _cAmber,
            'MIXED',
            _mixedCtrl,
          ),
      ],
    );
  }

  Widget _priceField(
    String title,
    String sub,
    Color color,
    String badge,
    TextEditingController ctrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _cText1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(sub, style: const TextStyle(fontSize: 12, color: _cText2)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            enabled: !_hasExisting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _hasExisting ? _cText3 : color,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _hasExisting ? _cText3 : _cText1,
              ),
              hintText: 'Enter price per plate',
              hintStyle: const TextStyle(
                color: _cText3,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: _hasExisting ? const Color(0xFFF5F5F5) : _cBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _cBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _cBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Add-ons section ──────────────────────────────────────────────────────────
  Widget _buildAddOnsSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(color: _cShadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cPurpleLt.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_circle_outline_rounded,
                  color: _cPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Selected Add-ons',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _cText1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _cWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cPurple.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_selectedAddOns.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _cPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_selectedAddOns.length, (i) {
            final a = _selectedAddOns[i];
            final ctrl = _addOnCtrls[a.id] ?? TextEditingController();
            final price = double.tryParse(ctrl.text) ?? 0;
            final tot = price * (_lead?.totalPlates ?? 0) * a.quantity;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _cPurpleLt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: _cPurple,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _addOnName(a.addOnType),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _cText1,
                                    ),
                                  ),
                                ),
                                if (a.quantity > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _cPurpleLt,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '×${a.quantity}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _cPurple,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: ctrl,
                                    enabled: !_hasExisting,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (_) => _calcTotal(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _cPurple,
                                    ),
                                    decoration: InputDecoration(
                                      prefixText: '₹ ',
                                      prefixStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _cPurple,
                                      ),
                                      hintText: 'Price',
                                      hintStyle: const TextStyle(
                                        color: _cText3,
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: _cBg,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: _cBorder),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: _cBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: _cPurple,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _selectedAddOns.length - 1)
                  const Divider(height: 1, color: _cBorder, indent: 14),
              ],
            );
          }),
          if (_addOnsTotal > 0)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _cBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add-ons Total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _cText2,
                    ),
                  ),
                  Text(
                    _fmtCurrency(_addOnsTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _cPurple,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Total amount ──────────────────────────────────────────────────────────────
  Widget _buildTotalAmount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cPurpleLt.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Quoted Amount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _cText1,
                      ),
                    ),
                    Text(
                      'Tap to edit manually',
                      style: TextStyle(fontSize: 11, color: _cPurple),
                    ),
                  ],
                ),
              ),
              if (_isAmountManual)
                GestureDetector(
                  onTap: () => setState(() {
                    _isAmountManual = false;
                    _calcTotal();
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _cWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: _cPurple,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            enabled: !_hasExisting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => setState(() {
              _isAmountManual = true;
              _total = double.tryParse(v) ?? 0;
            }),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _cPurple,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _cPurple,
              ),
              hintText: '0.00',
              hintStyle: const TextStyle(fontSize: 20, color: _cText3),
              filled: true,
              fillColor: _cWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _cPurple.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _cPurple.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _cPurple, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Details field ─────────────────────────────────────────────────────────────
  Widget _buildDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quotation Details (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _cText1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _detailsCtrl,
          maxLines: 4,
          enabled: !_hasExisting,
          decoration: InputDecoration(
            hintText: 'Add terms, notes or special conditions...',
            hintStyle: const TextStyle(color: _cText3, fontSize: 13),
            filled: true,
            fillColor: _cWhite,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _cBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _cBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _cPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    final canSend = !_hasExisting && _total > 0;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _cBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cBorder),
              ),
              child: const Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _cText2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: canSend ? () => setState(() => _showConfirm = true) : null,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: canSend
                    ? const LinearGradient(
                        colors: [_cGreen, Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: canSend ? null : _cText3,
                borderRadius: BorderRadius.circular(12),
                boxShadow: canSend
                    ? [
                        BoxShadow(
                          color: _cGreen.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _hasExisting ? 'Quotation Already Sent' : 'Send Quotation',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: _cRedLt,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _cRed,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              style: const TextStyle(color: _cText2, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: _kGrad,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirmation modal ────────────────────────────────────────────────────────
  Widget _buildConfirmModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _cAmberLt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: _cAmber,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirm Quotation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _cText1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Once sent, you cannot modify the amount.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _cText2, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cBorder),
                    ),
                    child: Column(
                      children: [
                        if (_hasVeg &&
                            (double.tryParse(_vegCtrl.text) ?? 0) > 0)
                          _confirmRow(
                            _cGreen,
                            'Veg (${_lead!.vegPlates} plates)',
                            double.tryParse(_vegCtrl.text)! * _lead!.vegPlates!,
                          ),
                        if (_hasNonVeg &&
                            (double.tryParse(_nonVegCtrl.text) ?? 0) > 0)
                          _confirmRow(
                            _cRed,
                            'Non-Veg (${_lead!.nonVegPlates} plates)',
                            double.tryParse(_nonVegCtrl.text)! *
                                _lead!.nonVegPlates!,
                          ),
                        if (_hasMixed &&
                            (double.tryParse(_mixedCtrl.text) ?? 0) > 0)
                          _confirmRow(
                            _cAmber,
                            'Mixed (${_lead!.mixedPlates} plates)',
                            double.tryParse(_mixedCtrl.text)! *
                                _lead!.mixedPlates!,
                          ),
                        const Divider(color: _cBorder, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _cText1,
                              ),
                            ),
                            Text(
                              _fmtCurrency(_total),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _cPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showConfirm = false),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: _cBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _cBorder),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _cText2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              _showConfirm = false;
                              _isSending = true;
                            });
                            await _sendQuotation();
                          },
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_cGreen, Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _cGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Send',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(Color color, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: _cText2),
            ),
          ),
          Text(
            _fmtCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() => Positioned.fill(
    child: Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    ),
  );
}
