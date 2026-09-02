import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class Location {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> j) => Location(
    placeId: j['placeId'] ?? '',
    name: j['name'] ?? '',
    latitude: (j['latitude'] ?? j['lat'] ?? 0).toDouble(),
    longitude: (j['longitude'] ?? j['lng'] ?? 0).toDouble(),
  );
}

class MenuItem {
  final int id;
  final String name;
  final String category;
  final bool selected;
  final String discountValue;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.selected,
    required this.discountValue,
  });
}

class DiscountConfig {
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? timeCategory;
  final String? discountType;
  final String? discountTarget;
  final String? discountValue;
  final String? couponCode;
  final String? couponType;
  final String? minimumOrderValue;
  final List<MenuItem> selectedItems;

  DiscountConfig({
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.timeCategory,
    this.discountType,
    this.discountTarget,
    this.discountValue,
    this.couponCode,
    this.couponType,
    this.minimumOrderValue,
    this.selectedItems = const [],
  });
}

class LeadsConfig {
  final List<Location> locations;
  final List<String> interests;
  final String? gender;
  final List<int> ageRange;
  final String? contactMobile;
  final double radiusKm;

  LeadsConfig({
    this.locations = const [],
    this.interests = const [],
    this.gender,
    this.ageRange = const [0, 65],
    this.contactMobile,
    this.radiusKm = 1000,
  });
}

class CampaignFormData {
  final String? goal;
  final String? subGoal;
  final String? campaignName;
  final String? name;
  final String? callToAction;
  final List<String> mediums;
  final List<String> appTypes;
  final List<dynamic> placements;
  final List<String> mediaTypes;
  final List<String> images;
  final String? videoFile;
  final String? websiteUrl;
  final Map<String, String> mediaDescriptions;
  final Map<String, int> mediaDurations;
  final int? durationSeconds;
  final double investment;
  final String? couponCode;
  final String? startDate;
  final String? endDate;
  final List<String> audience;
  final DiscountConfig? discount;
  final LeadsConfig? leads;

  CampaignFormData({
    this.goal,
    this.subGoal,
    this.campaignName,
    this.name,
    this.callToAction,
    this.mediums = const [],
    this.appTypes = const [],
    this.placements = const [],
    this.mediaTypes = const [],
    this.images = const [],
    this.videoFile,
    this.websiteUrl,
    this.mediaDescriptions = const {},
    this.mediaDurations = const {},
    this.durationSeconds,
    this.investment = 0,
    this.couponCode,
    this.startDate,
    this.endDate,
    this.audience = const [],
    this.discount,
    this.leads,
  });
}

// ─────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────

class CampaignApiService {
  static const String _base = 'http://staging.maamaas.com:8080/promotions/api';

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ??
        prefs.getString('token') ??
        prefs.getString('accessToken');
  }

  static Future<Map<String, dynamic>?> getBillingData() async {
    final token = await _token();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('$_base/user/get/billing'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<Map<String, dynamic>?> getVendorDetails(String vendorId) async {
    final token = await _token();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('$_base/vendor/$vendorId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required double amount,
  }) async {
    final token = await _token();
    if (token == null) throw Exception('Not logged in');
    final res = await http.post(
      Uri.parse('$_base/vendor/apply/coupon'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'customerId': 'VEN140520263',
        'couponCode': couponCode,
        'amount': amount,
        'usageType': 'CAMPAIGN',
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Invalid Coupon');
  }

  static Future<Map<String, dynamic>> createOrder(double amount) async {
    final token = await _token();
    if (token == null) throw Exception('Not logged in');
    final res = await http.post(
      Uri.parse('$_base/payments/create-order/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount, 'currency': 'INR'}),
    );
    return jsonDecode(res.body);
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────

class AdPreviewScreen extends StatefulWidget {
  final CampaignFormData? formData;
  final bool showPayment;
  final List<MenuItem> menuItems;
  final String? discountValue;
  final String? discountMode;

  const AdPreviewScreen({
    super.key,
    this.formData, // ← now optional; defaults to empty below
    this.showPayment = false,
    this.menuItems = const [],
    this.discountValue,
    this.discountMode,
  });

  @override
  State<AdPreviewScreen> createState() => _AdPreviewScreenState();
}

class _AdPreviewScreenState extends State<AdPreviewScreen>
    with TickerProviderStateMixin {
  int _adFormatIndex = 0;
  bool _captionExpanded = false;
  Map<String, dynamic>? _billingData;
  double _couponDiscount = 0;
  bool _couponApplied = false;
  bool _loadingBilling = false;
  bool _processingPayment = false;
  final _couponController = TextEditingController();
  late TabController _tabController;

  final List<String> _adFormats = [
    'Facebook',
    'Instagram Feed',
    'Instagram Story',
  ];
  final List<IconData> _adFormatIcons = [
    Icons.facebook,
    Icons.photo_camera,
    Icons.camera_alt_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _adFormatIndex = _tabController.index);
    });
    if (widget.showPayment) _fetchBilling();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _fetchBilling() async {
    setState(() => _loadingBilling = true);
    try {
      final data = await CampaignApiService.getBillingData();
      setState(() => _billingData = data);
    } catch (_) {
    } finally {
      setState(() => _loadingBilling = false);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      _showSnack('Please enter a coupon code', isError: true);
      return;
    }
    try {
      final data = await CampaignApiService.applyCoupon(
        couponCode: code,
        amount: _fd.investment,
      );
      final discount =
          (data['discountAmount'] ?? data['data']?['discountAmount'] ?? 0)
              .toDouble();
      setState(() {
        _couponDiscount = discount;
        _couponApplied = true;
      });
      _showSnack('✅ Coupon applied! You saved ₹${discount.toStringAsFixed(2)}');
    } catch (e) {
      setState(() {
        _couponDiscount = 0;
        _couponApplied = false;
      });
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Safe accessor (formData is optional; falls back to empty CampaignFormData) ──
  CampaignFormData get _fd => widget.formData ?? CampaignFormData();

  // ── Billing Calculations ──────────────────────
  double get _investment => _fd.investment;

  double _calcTotal() {
    final fd = _fd;
    if (fd.goal == 'discount' && fd.subGoal != 'coupons') {
      return _discountTotal();
    } else if (fd.subGoal == 'coupons') {
      final base =
          _investment + (_billingData?['couponCharge'] ?? 0).toDouble();
      return base + base * 0.18;
    } else {
      return _investment + _investment * 0.18;
    }
  }

  double _discountTotal() {
    final disc = _fd.discount;
    final start = disc?.startDate != null
        ? DateTime.tryParse(disc!.startDate!)
        : null;
    final end = disc?.endDate != null
        ? DateTime.tryParse(disc!.endDate!)
        : null;
    final days = (start != null && end != null)
        ? end.difference(start).inDays + 1
        : 1;
    final perItem = (_billingData?['menuChargePerItem'] ?? 0).toDouble();
    final isOverall = disc?.discountTarget == 'overall';
    final count = isOverall
        ? widget.menuItems.length
        : disc?.selectedItems.length ?? 0;
    final sub = count * perItem * days;
    return sub + sub * 0.18;
  }

  double get _grandTotal =>
      _couponApplied ? _calcTotal() - _couponDiscount : _calcTotal();

  // ── Helpers ──────────────────────────────────
  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '';
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String get _initials {
    final name = _fd.campaignName ?? _fd.name ?? 'YB';
    if (name == 'YB') return 'YB';
    return name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .substring(0, name.split(' ').length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  String get _displayName => _fd.campaignName ?? _fd.name ?? 'Your Business';
  bool get _hasMedia => _fd.images.isNotEmpty || _fd.videoFile != null;
  String? get _safeMedia =>
      _fd.videoFile ?? (_fd.images.isNotEmpty ? _fd.images.last : null);
  bool get _isVideo => _fd.videoFile != null;
  String get _captionText =>
      _fd.mediaDescriptions['image'] ?? _fd.mediaDescriptions['video'] ?? '';

  String _subGoalLabel() {
    final g = _fd.goal;
    final sg = _fd.subGoal;
    if (g == 'discount') {
      return {
            'advertisement': 'Advertisement',
            'menu': 'Menu',
            'coupons': 'Coupons',
          }[sg] ??
          '';
    }
    return sg ?? '';
  }

  String _timeCategoryLabel(String? tc) {
    const map = {
      'PEAK_HOURS': '🔥 Peak Hours',
      'RAINING_TIME': '🌧️ Raining Time',
      'HAPPY_HOURS': '🎉 Happy Hours',
      'LUNCH_TIME': '🍽️ Lunch Time',
      'DINNER_TIME': '🌙 Dinner Time',
      'EARLY_MORNING': '🌅 Early Morning',
      'LATE_NIGHT': '🌃 Late Night',
      'WEEKEND_SPECIAL': '🎊 Weekend Special',
    };
    return map[tc] ?? tc ?? '';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Ad Preview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            if (_hasMedia) ...[
              _buildAdFormatTabs(),
              const SizedBox(height: 12),
              _buildAdPreview(),
              const SizedBox(height: 16),
            ],
            if (!_hasMedia && _fd.goal == null) _buildEmptyState(),
            if (widget.showPayment) _buildPaymentSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUMMARY CARD
  // ─────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final fd = _fd;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('📋 Campaign Summary'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (fd.goal != null)
                  _summaryRow(
                    'Goal',
                    fd.goal!.toUpperCase(),
                    const Color(0xFFEFF6FF),
                    const Color(0xFF185FA5),
                  ),
                if (fd.campaignName != null || fd.name != null)
                  _summaryRow(
                    'Campaign',
                    _displayName,
                    const Color(0xFFEFF6FF),
                    const Color(0xFF185FA5),
                  ),
                if (fd.subGoal != null)
                  _summaryRow(
                    'Sub Goal',
                    _subGoalLabel(),
                    const Color(0xFFF0FDF4),
                    const Color(0xFF3B6D11),
                  ),
                _buildDiscountDetails(),
                _buildCouponDetails(),
                _buildTimeSlot(),
                _buildDateRange(),
                _buildTimeCategory(),
                _buildMedium(),
                _buildPlacements(),
                _buildLocations(),
                _buildLeadsSection(),
                _buildStartEndDates(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color bg, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountDetails() {
    final fd = _fd;
    final disc = fd.discount;
    if (fd.goal != 'discount' ||
        fd.subGoal != 'menu' ||
        disc?.discountTarget == null)
      return const SizedBox();
    final isOverall = disc!.discountTarget == 'overall';
    return Column(
      children: [
        _summaryRow(
          'Discount Type',
          isOverall ? '🍽️ Overall Menu' : '🎯 Specific Items',
          isOverall ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
          isOverall ? const Color(0xFF0369A1) : const Color(0xFF92400E),
        ),
        if (isOverall && disc.discountValue != null)
          _summaryRow(
            'Discount',
            '🔥 ${disc.discountValue}% OFF',
            const Color(0xFFECFDF5),
            const Color(0xFF065F46),
          ),
        if (!isOverall && disc.selectedItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: disc.selectedItems
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.name}${item.discountValue.isNotEmpty ? " (${item.discountValue}%)" : ""}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCouponDetails() {
    final fd = _fd;
    if (fd.goal != 'discount' || fd.subGoal != 'coupons')
      return const SizedBox();
    final disc = fd.discount;
    return Column(
      children: [
        if (disc?.couponCode != null)
          _summaryRow(
            'Coupon Code',
            '🎟️ ${disc!.couponCode}',
            const Color(0xFFEFF6FF),
            const Color(0xFF1D4ED8),
          ),
        if (widget.discountValue != null)
          _summaryRow(
            'Discount Value',
            widget.discountMode == 'percentage'
                ? '🔥 ${widget.discountValue}% OFF'
                : '💰 ₹${widget.discountValue} OFF',
            const Color(0xFFECFDF5),
            const Color(0xFF065F46),
          ),
        if (disc?.discountType != null)
          _summaryRow(
            'Discount Type',
            disc!.discountType == 'PERCENTAGE'
                ? '📊 Percentage'
                : '💰 Fixed Amount',
            const Color(0xFFFEF3C7),
            const Color(0xFF92400E),
          ),
        if (disc?.couponType != null)
          _summaryRow(
            'Coupon Type',
            disc!.couponType == 'FLAT' ? '🏷️ Flat' : '⬆️ Upto',
            const Color(0xFFECFDF5),
            const Color(0xFF065F46),
          ),
        if (disc?.minimumOrderValue != null)
          _summaryRow(
            'Min. Order',
            '💰 ₹ ${disc!.minimumOrderValue}',
            const Color(0xFFECFDF5),
            const Color(0xFF065F46),
          ),
      ],
    );
  }

  Widget _buildTimeSlot() {
    final disc = _fd.discount;
    if (disc?.startTime == null || disc?.endTime == null)
      return const SizedBox();
    return _summaryRow(
      'Time',
      '⏰ ${disc!.startTime} - ${disc.endTime}',
      const Color(0xFFF3F4F6),
      const Color(0xFF374151),
    );
  }

  Widget _buildDateRange() {
    final disc = _fd.discount;
    if (disc?.startDate == null || disc?.endDate == null)
      return const SizedBox();
    return _summaryRow(
      'Date',
      '${_formatDate(disc!.startDate)} → ${_formatDate(disc.endDate)}',
      const Color(0xFFEFF6FF),
      const Color(0xFF1D4ED8),
    );
  }

  Widget _buildTimeCategory() {
    final tc = _fd.discount?.timeCategory;
    if (tc == null || tc.isEmpty) return const SizedBox();
    return _summaryRow(
      'Category',
      _timeCategoryLabel(tc),
      const Color(0xFFF0FDF4),
      const Color(0xFF3B6D11),
    );
  }

  Widget _buildMedium() {
    final fd = _fd;
    if (fd.mediums.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text(
              'Medium',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            children: fd.mediums
                .map(
                  (m) => _chip(
                    m.toUpperCase(),
                    const Color(0xFFEFF6FF),
                    const Color(0xFF185FA5),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacements() {
    final fd = _fd;
    if (fd.placements.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 110,
            child: Text(
              'Placements',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: fd.placements
                  .map(
                    (p) => _chip(
                      '📍 $p',
                      const Color(0xFFECFEFF),
                      const Color(0xFF0E7490),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocations() {
    final locs = _fd.leads?.locations ?? [];
    if (locs.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 110,
            child: Text(
              'Locations',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: locs
                  .map(
                    (l) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '📍 ${l.name}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsSection() {
    final fd = _fd;
    if (fd.goal != 'leads') return const SizedBox();
    final leads = fd.leads;
    return Column(
      children: [
        if (leads?.gender != null)
          _summaryRow(
            'Gender',
            leads!.gender!.toUpperCase(),
            const Color(0xFFF3F4F6),
            const Color(0xFF374151),
          ),
        if (leads?.ageRange != null && leads!.ageRange.length >= 2)
          _summaryRow(
            'Age Range',
            '${leads.ageRange[0]} – ${leads.ageRange[1]} yrs',
            const Color(0xFFF3F4F6),
            const Color(0xFF374151),
          ),
        if (leads?.contactMobile != null)
          _summaryRow(
            'Mobile',
            '📞 ${leads!.contactMobile}',
            const Color(0xFFF3F4F6),
            const Color(0xFF6B7280),
          ),
        if (leads?.interests.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    'Audience',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: leads!.interests
                        .map(
                          (i) => _chip(
                            i,
                            const Color(0xFFF0FDF4),
                            const Color(0xFF3B6D11),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStartEndDates() {
    final fd = _fd;
    if (fd.startDate == null && fd.endDate == null) return const SizedBox();
    return Row(
      children: [
        Expanded(child: _dateBox('Start Date', fd.startDate)),
        const SizedBox(width: 12),
        Expanded(child: _dateBox('End Date', fd.endDate)),
      ],
    );
  }

  Widget _dateBox(String label, String? date) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        Text(
          date ?? '—',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
      ],
    ),
  );

  Widget _chip(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
    ),
  );

  // ─────────────────────────────────────────────
  // AD FORMAT TABS
  // ─────────────────────────────────────────────
  Widget _buildAdFormatTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: _adFormats
            .asMap()
            .entries
            .map(
              (e) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_adFormatIcons[e.key], size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(e.value, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AD PREVIEW
  // ─────────────────────────────────────────────
  Widget _buildAdPreview() {
    switch (_adFormatIndex) {
      case 0:
        return _buildFacebookPreview();
      case 1:
        return _buildInstagramFeedPreview();
      case 2:
        return _buildInstagramStoryPreview();
      default:
        return const SizedBox();
    }
  }

  Widget _mediaWidget({double height = 200}) {
    if (!_hasMedia) {
      return Container(
        height: height,
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white38,
            size: 40,
          ),
        ),
      );
    }
    if (_isVideo) {
      return Container(
        height: height,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
        ),
      );
    }
    return Image.network(
      _safeMedia!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _ctaButton({bool dark = false}) {
    const label = 'Visit Page';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1877F2) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: dark ? null : Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _captionWidget({Color textColor = const Color(0xFF111827)}) {
    if (_captionText.isEmpty) return const SizedBox();
    final displayText = _captionExpanded || _captionText.length <= 100
        ? _captionText
        : '${_captionText.substring(0, 100)}...';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: TextStyle(fontSize: 12, color: textColor, height: 1.5),
          ),
          if (_captionText.length > 100)
            GestureDetector(
              onTap: () => setState(() => _captionExpanded = !_captionExpanded),
              child: Text(
                _captionExpanded ? 'see less' : 'see more',
                style: const TextStyle(
                  color: Color(0xFF185FA5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Facebook Preview
  Widget _buildFacebookPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _avatarCircle(32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Text(
                        'Ad · 🌐',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Color(0xFF6B7280)),
              ],
            ),
          ),
          _mediaWidget(height: 220),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
                _ctaButton(dark: true),
              ],
            ),
          ),
          _captionWidget(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Row(
            children: ['Like', 'Comment', 'Share']
                .map(
                  (label) => Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        label == 'Like'
                            ? Icons.thumb_up_outlined
                            : label == 'Comment'
                            ? Icons.chat_bubble_outline
                            : Icons.share_outlined,
                        size: 16,
                        color: const Color(0xFF6B7280),
                      ),
                      label: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Instagram Feed Preview
  Widget _buildInstagramFeedPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _mediaWidget(height: 260),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _avatarCircle(28),
                    const SizedBox(width: 8),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                _ctaButton(),
              ],
            ),
          ),
          _captionWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 22),
                    const SizedBox(width: 14),
                    const Icon(Icons.chat_bubble_outline, size: 22),
                    const SizedBox(width: 14),
                    const Icon(Icons.send_outlined, size: 22),
                  ],
                ),
                const Icon(Icons.bookmark_border, size: 22),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ad',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Instagram Story Preview
  Widget _buildInstagramStoryPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _mediaWidget(height: 400),
          // Top gradient + header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE8523A),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Sponsored',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Right side icons
          Positioned(
            right: 10,
            bottom: 80,
            child: Column(
              children: [
                _storyIcon(Icons.favorite_border, '1.2K'),
                const SizedBox(height: 16),
                _storyIcon(Icons.chat_bubble_outline, '340'),
                const SizedBox(height: 16),
                _storyIcon(Icons.send_outlined, ''),
                const SizedBox(height: 16),
                _storyIcon(Icons.bookmark_border, ''),
              ],
            ),
          ),
          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 40, 12, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Visit Page',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyIcon(IconData icon, String label) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      if (label.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    ],
  );

  Widget _avatarCircle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFE8523A),
    ),
    child: Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _buildEmptyState() => Container(
    margin: const EdgeInsets.symmetric(vertical: 24),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF1F5F9),
          ),
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xFF9CA3AF),
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Nothing selected yet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your selections will appear here',
          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  // PAYMENT SECTION
  // ─────────────────────────────────────────────
  Widget _buildPaymentSection() {
    if (_loadingBilling) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final fd = _fd;
    String title = '💳 Payment Summary';
    if (fd.goal == 'discount' && fd.subGoal != 'coupons')
      title = '🧾 Discount Billing';
    if (fd.subGoal == 'coupons') title = '💳 Coupon Summary';
    if (fd.goal == 'branding' && fd.mediums.contains('digital'))
      title = '📺 Digital Branding';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _cardHeader(title),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBillingRows(),
                const SizedBox(height: 12),
                _buildCouponInput(),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF93C5FD), height: 1),
                const SizedBox(height: 12),
                _billRow(
                  'Grand Total',
                  '₹ ${_grandTotal.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                const SizedBox(height: 16),
                _buildPayNowButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRows() {
    final fd = _fd;
    final inv = fd.investment;
    final gst = _calcTotal() - (_calcTotal() / 1.18);

    if (fd.goal == 'discount' && fd.subGoal != 'coupons') {
      final disc = fd.discount;
      final perItem = (_billingData?['menuChargePerItem'] ?? 0).toDouble();
      final isOverall = disc?.discountTarget == 'overall';
      final count = isOverall
          ? widget.menuItems.length
          : disc?.selectedItems.length ?? 0;
      final sub = count * perItem;
      return Column(
        children: [
          _billRow(
            'Discount Type',
            isOverall ? '🍽️ Overall Menu' : '🎯 Specific Items',
          ),
          _billRow(
            'Items × ₹${perItem.toStringAsFixed(0)}/item',
            '$count items',
          ),
          _billRow('Sub Total', '₹ ${sub.toStringAsFixed(2)}'),
          _billRow('GST (18%)', '₹ ${(sub * 0.18).toStringAsFixed(2)}'),
          if (_couponApplied)
            _billRow(
              'Coupon Discount',
              '- ₹ ${_couponDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
        ],
      );
    }

    if (fd.subGoal == 'coupons') {
      final charge = (_billingData?['couponCharge'] ?? 0).toDouble();
      final base = inv + charge;
      return Column(
        children: [
          _billRow('Budget', '₹ ${inv.toStringAsFixed(2)}'),
          _billRow('Coupon Charges', '₹ ${charge.toStringAsFixed(2)}'),
          _billRow('Sub Total', '₹ ${base.toStringAsFixed(2)}'),
          _billRow('GST (18%)', '₹ ${(base * 0.18).toStringAsFixed(2)}'),
          if (_couponApplied)
            _billRow(
              'Coupon Discount',
              '- ₹ ${_couponDiscount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
        ],
      );
    }

    return Column(
      children: [
        _billRow('Budget', '₹ ${inv.toStringAsFixed(2)}'),
        _billRow('Sub Total', '₹ ${inv.toStringAsFixed(2)}'),
        _billRow('GST (18%)', '₹ ${(inv * 0.18).toStringAsFixed(2)}'),
        if (_couponApplied)
          _billRow(
            'Coupon Discount',
            '- ₹ ${_couponDiscount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
      ],
    );
  }

  Widget _billRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF374151),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? const Color(0xFF2563EB)
                  : isDiscount
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF1E40AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coupon Code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF97316),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF97316),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEA580C),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _couponApplied
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        if (_couponApplied)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '🎉 You saved ₹${_couponDiscount.toStringAsFixed(2)}!',
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPayNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _processingPayment ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _processingPayment
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay Now  ₹${_grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _processingPayment = true);
    try {
      final orderData = await CampaignApiService.createOrder(_grandTotal);
      final orderId = orderData['orderId'] ?? orderData['id'];
      // ── Integrate your Razorpay Flutter plugin here ──
      // Example with razorpay_flutter package:
      //
      // final razorpay = Razorpay();
      // razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      // razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      // razorpay.open({
      //   'key': 'rzp_test_TJECsclCivENpY',
      //   'amount': (_grandTotal * 100).round(),
      //   'currency': 'INR',
      //   'name': 'Maamaas',
      //   'order_id': orderId,
      //   'description': 'Campaign Payment',
      // });
      _showSnack(
        'Order created: $orderId — integrate Razorpay plugin to complete',
      );
    } catch (e) {
      _showSnack('Payment failed: $e', isError: true);
    } finally {
      setState(() => _processingPayment = false);
    }
  }
}
