import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../API/Apiclient.dart';
import '../API/food_authservice.dart';
import '../CampaignModel/CampaignRequest.dart';
import '../CampaignService/Promotion_authservice.dart';
import '../Models/food&beverages/dish.dart';
import '../food&beverages/Deals.dart';
import '../widgets_helper/Home_screen_1.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _T {
  static const Color brand = Color(0xFFE85D26);
  static const Color brandSoft = Color(0xFFFFF3EE);
  static const Color brandMid = Color(0xFFFFDDD0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF8F6F3);
  static const Color textPri = Color(0xFF1A1208);
  static const Color textSec = Color(0xFF7A7068);
  static const Color textHint = Color(0xFFB5AFA8);
  static const Color border = Color(0xFFEDEAE5);
  static const Color success = Color(0xFF28A566);
  static const Color successSoft = Color(0xFFEBF8F2);

  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;

  static TextStyle get h1 => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPri,
    letterSpacing: -0.5,
  );
  static TextStyle get h2 => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPri,
    letterSpacing: -0.3,
  );
  static TextStyle get h3 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPri,
  );
  static TextStyle get body => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPri,
    height: 1.5,
  );
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSec,
  );
  static TextStyle get label => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSec,
    letterSpacing: 0.5,
  );
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _SectionLabel(this.text, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: _T.brand),
            const SizedBox(width: 6),
          ],
          Text(text.toUpperCase(), style: _T.label),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r16),
        border: Border.all(color: _T.border, width: 1),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const _Pill(
    this.label, {
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _T.brand : _T.surface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? _T.brand : _T.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : _T.textSec),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _T.textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String? hint;
  final Widget? suffix;
  const _FieldBox(
    this.label,
    this.controller, {
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _T.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: _T.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _T.textHint, fontSize: 14),
            filled: true,
            fillColor: _T.bg,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.brand, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String Function(String)? display;
  const _SelectField(
    this.label,
    this.items,
    this.value,
    this.onChanged, {
    this.display,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _T.label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          style: _T.body,
          dropdownColor: _T.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: _T.bg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_T.r12),
              borderSide: BorderSide(color: _T.brand, width: 1.5),
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(display != null ? display!(e) : e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? trailingIcon;
  const _PrimaryButton(
    this.label, {
    this.onTap,
    this.loading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: (loading || onTap == null)
              ? _T.brand.withOpacity(0.5)
              : _T.brand,
          borderRadius: BorderRadius.circular(_T.r16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, color: Colors.white, size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  const _OutlineButton(this.label, {this.onTap, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r16),
          border: Border.all(color: _T.border, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: _T.textSec, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: _T.textSec,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _gap(double h) => SizedBox(height: h);
Widget _divider() => Divider(color: _T.border, height: 1, thickness: 1);

String _humanize(String s) => s
    .split('_')
    .map(
      (w) => w.isNotEmpty
          ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
          : '',
    )
    .join(' ');

// ─────────────────────────────────────────────
// CAMPAIGN DETAIL SCREEN
// ─────────────────────────────────────────────
class CampaignDetailScreen extends StatelessWidget {
  final CampaignRequest campaign;
  const CampaignDetailScreen({Key? key, required this.campaign})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _T.textPri,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(campaign.campaignName, style: _T.h2),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(_T.r20),
                child: Image.network(
                  campaign.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: _T.border,
                      borderRadius: BorderRadius.circular(_T.r20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: _T.textHint,
                      ),
                    ),
                  ),
                ),
              ),
              _gap(20),
            ],
            _detailSection('Campaign Info', [
              _detailRow(Icons.title_rounded, 'Name', campaign.campaignName),
              _detailRow(
                Icons.notes_rounded,
                'Description',
                campaign.description ?? 'N/A',
              ),
              _detailRow(Icons.flag_outlined, 'Goal', campaign.goal),
              _detailRow(
                Icons.outlined_flag_rounded,
                'Sub Goal',
                campaign.subGoal ?? 'N/A',
              ),
              _detailRow(Icons.devices_outlined, 'Medium', campaign.medium),
              _detailRow(
                Icons.touch_app_outlined,
                'Call to Action',
                campaign.callToAction ?? 'N/A',
              ),
            ]),
            _gap(12),
            _detailSection('Schedule', [
              _detailRow(
                Icons.calendar_today_outlined,
                'Start Date',
                _fmt(campaign.startDate),
              ),
              _detailRow(
                Icons.event_outlined,
                'End Date',
                _fmt(campaign.endDate),
              ),
              _detailRow(
                Icons.access_time_outlined,
                'Created At',
                _fmt(campaign.createdAt),
              ),
            ]),
            _gap(12),
            _detailSection('Status & Payment', [
              _detailRow(
                Icons.payment_outlined,
                'Payment Status',
                campaign.paymentStatus ?? 'PENDING',
              ),
              _detailRow(
                Icons.currency_rupee_rounded,
                'Total Budget',
                campaign.totalBudget?.toString() ?? 'N/A',
              ),
            ]),
            _gap(12),
            _detailSection('Target Audience', [
              _detailRow(
                Icons.person_outline_rounded,
                'Gender',
                campaign.gender ?? 'ALL',
              ),
              _detailRow(
                Icons.cake_outlined,
                'Min Age',
                campaign.minAge?.toString() ?? 'N/A',
              ),
              _detailRow(
                Icons.cake_outlined,
                'Max Age',
                campaign.maxAge?.toString() ?? 'N/A',
              ),
              _detailRow(
                Icons.people_outline_rounded,
                'Audience',
                campaign.targetAudience?.join(', ') ?? 'Users',
              ),
            ]),
            _gap(12),
            _detailSection('Location', [
              _detailRow(
                Icons.location_city_outlined,
                'City',
                campaign.city ?? 'N/A',
              ),
              _detailRow(
                Icons.my_location_rounded,
                'Latitude',
                campaign.centerLatitude?.toString() ?? 'N/A',
              ),
              _detailRow(
                Icons.my_location_rounded,
                'Longitude',
                campaign.centerLongitude?.toString() ?? 'N/A',
              ),
              _detailRow(
                Icons.radar_rounded,
                'Radius (km)',
                campaign.radiusKm?.toString() ?? 'N/A',
              ),
            ]),
            _gap(12),
            _detailSection('Interests', [
              _detailRow(
                Icons.favorite_border_rounded,
                'Interests',
                campaign.interests?.join(', ') ?? 'None',
              ),
            ]),
            _gap(12),
            _detailSection('Additional Info', [
              _detailRow(
                Icons.grid_view_rounded,
                'Display Position',
                campaign.addDisplayPosition ?? 'Not Specified',
              ),
              _detailRow(
                Icons.high_quality_rounded,
                'Resolution',
                campaign.resolution ?? 'N/A',
              ),
              _detailRow(
                Icons.timer_outlined,
                'Time Category',
                campaign.timeCategory ?? 'N/A',
              ),
              _detailRow(
                Icons.link_rounded,
                'Deep Link',
                campaign.deepLink ?? 'N/A',
              ),
              _detailRow(
                Icons.apps_rounded,
                'App Type',
                campaign.appType ?? 'N/A',
              ),
            ]),
            _gap(32),
          ],
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _T.h3),
          _gap(12),
          _divider(),
          _gap(12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _T.brand),
          const SizedBox(width: 10),
          SizedBox(width: 110, child: Text(label, style: _T.caption)),
          Expanded(child: Text(value, style: _T.body)),
        ],
      ),
    );
  }

  String _fmt(String s) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }
}

// ─────────────────────────────────────────────
// CAMPAIGN LIST SCREEN
// ─────────────────────────────────────────────
class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({Key? key}) : super(key: key);

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  List<CampaignRequest> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final c = await PromotionAuthService.fetchUserCampaigns();
      setState(() {
        _campaigns = c;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('My Campaigns', style: _T.h2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePromotionScreen(),
                ),
              ),
              icon: Icon(Icons.add_rounded, color: _T.brand, size: 18),
              label: Text(
                'New',
                style: TextStyle(color: _T.brand, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _T.brand))
          : _campaigns.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _campaigns.length,
              itemBuilder: (_, i) => _campaignCard(_campaigns[i]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _T.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_outlined, size: 36, color: _T.brand),
          ),
          _gap(16),
          Text('No campaigns yet', style: _T.h2),
          _gap(6),
          Text(
            'Create your first campaign to get started',
            style: _T.caption.copyWith(fontSize: 14),
          ),
          _gap(24),
          SizedBox(
            width: 180,
            child: _PrimaryButton(
              'Create Campaign',
              trailingIcon: Icons.arrow_forward_ios_rounded,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePromotionScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campaignCard(CampaignRequest c) {
    final isPaid = c.paymentStatus == 'PAID';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: c)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r20),
          border: Border.all(color: _T.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: c.imageUrl != null
                    ? Image.network(
                        c.imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: _T.brandSoft,
                        child: Icon(Icons.campaign_outlined, color: _T.brand),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.campaignName,
                      style: _T.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _gap(3),
                    Text(
                      '${c.goal}  ·  ${c.city ?? 'No city'}',
                      style: _T.caption,
                    ),
                    _gap(4),
                    Text(
                      '₹${c.totalBudget?.toStringAsFixed(2) ?? '0'}',
                      style: _T.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _T.brand,
                      ),
                    ),
                  ],
                ),
              ),
              _gap(10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isPaid ? _T.successSoft : _T.brandSoft,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  c.paymentStatus ?? 'PENDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPaid ? _T.success : _T.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REVIEW SCREEN
// ─────────────────────────────────────────────
class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> campaignData;
  final File? imageFile;
  final File? videoFile;
  final double calculatedBudget;
  final Map<String, dynamic> chargeBreakdown;

  const ReviewScreen({
    Key? key,
    required this.campaignData,
    required this.imageFile,
    required this.videoFile,
    required this.calculatedBudget,
    required this.chargeBreakdown,
  }) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _createdOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<String?> _createOrder(double amount) async {
    try {
      const endpoint = "/api/payments/create-order/user";
      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {
          "campaign": widget.campaignData['campaignName'] ?? 'Unknown',
          "customerId": widget.campaignData['customerId'] ?? 'Unknown',
        },
      };
      final res = await ApiClient.post(endpoint, body, service: "promotions");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["orderId"] ?? data["id"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _capturePayment(String paymentId, double amount) async {
    try {
      const endpoint = "api/payments/capture";
      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for campaign payment",
      };
      final res = await ApiClient.post(endpoint, body, service: "promotions");
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            Center(child: CircularProgressIndicator(color: _T.brand)),
      );
    }
    try {
      await _capturePayment(response.paymentId!, widget.calculatedBudget);
      final campaignDataWithPayment =
          Map<String, dynamic>.from(widget.campaignData)
            ..['paymentId'] = response.paymentId
            ..['razorpayOrderId'] = response.orderId
            ..['transactionId'] = response.paymentId
            ..['paymentMethod'] = "Online_Payment"
            ..['paymentStatus'] = 'PAID'
            ..['status'] = 'ACTIVE'
            ..['paymentDate'] = DateTime.now().toIso8601String();

      final result = await PromotionAuthService.createCampaignWithPayment(
        campaignData: campaignDataWithPayment,
        imageFile: widget.imageFile,
        videoFile: widget.videoFile,
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeWrapper()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Campaign error: ${result?['message']}'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeWrapper()),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ReelsScreen()),
        (_) => false,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _processPayment() async {
    setState(() => _isProcessing = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: _T.brand)),
    );
    try {
      final orderId = await _createOrder(widget.calculatedBudget);
      if (!mounted) return;
      Navigator.pop(context);
      if (orderId != null && orderId.isNotEmpty) {
        _createdOrderId = orderId;
        var options = {
          'key': 'rzp_test_TJECsclCivENpY',
          'amount': (widget.calculatedBudget * 100).toInt(),
          'name': 'Maamaas App',
          'description':
              'Campaign Payment: ${widget.campaignData['campaignName']}',
          'order_id': orderId,
          'prefill': {'contact': '9999999999', 'email': 'customer@email.com'},
          'currency': 'INR',
        };
        _razorpay.open(options);
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create payment order.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double targetCharge =
        widget.chargeBreakdown['targetAudiencesCharge']?.toDouble() ?? 0.0;
    double mediaCharge =
        widget.chargeBreakdown['mediaTypeCharge']?.toDouble() ?? 0.0;
    double displayCharge =
        widget.chargeBreakdown['displaypPositionCharge']?.toDouble() ?? 0.0;
    double promotionCharge =
        widget.chargeBreakdown['promotionCharge']?.toDouble() ?? 0.0;
    double menuItemsCharge =
        widget.chargeBreakdown['menuItemsCharge']?.toDouble() ?? 0.0;
    double couponCharge =
        widget.chargeBreakdown['couponCharge']?.toDouble() ?? 0.0;
    double total =
        widget.chargeBreakdown['total']?.toDouble() ?? widget.calculatedBudget;
    double digitalScreenCharge =
        widget.chargeBreakdown['digitalScreenCharge']?.toDouble() ?? 0.0;
    double digitalSecondsCharge =
        widget.chargeBreakdown['digitalScreenSecondsCharge']?.toDouble() ?? 0.0;
    int durationSeconds =
        widget.chargeBreakdown['durationSeconds']?.toInt() ?? 0;
    bool isOverallMenu = widget.campaignData['applyDiscountToAll'] == true;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _T.textPri,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review & Pay', style: _T.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageFile != null || widget.videoFile != null) ...[
              _mediaPreview(),
              _gap(16),
            ],
            _reviewSection('Campaign Details', [
              _reviewRow(
                'Campaign Name',
                widget.campaignData['campaignName'] ?? '',
              ),
              _reviewRow(
                'Description',
                widget.campaignData['description'] ?? 'Not provided',
              ),
              _reviewRow('Goal', widget.campaignData['goal'] ?? ''),
              _reviewRow('Sub Goal', widget.campaignData['subGoal'] ?? ''),
              _reviewRow('Medium', widget.campaignData['medium'] ?? 'APP'),
              _reviewRow(
                'Call to Action',
                widget.campaignData['callToAction'] ?? 'N/A',
              ),
            ]),
            _gap(12),
            _reviewSection('Schedule', [
              _reviewRow(
                'Start Date',
                widget.campaignData['startDate'] != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(widget.campaignData['startDate']))
                    : 'N/A',
              ),
              _reviewRow(
                'End Date',
                widget.campaignData['endDate'] != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(widget.campaignData['endDate']))
                    : 'N/A',
              ),
              if (widget.campaignData['timeCategory'] != null)
                _reviewRow(
                  'Time Category',
                  widget.campaignData['timeCategory'] ?? 'N/A',
                ),
            ]),
            _gap(12),
            if (isOverallMenu)
              _Card(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _T.successSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_offer_outlined,
                        color: _T.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.campaignData['discountPercentage'] ?? 0}% discount applied to ALL menu items',
                        style: _T.body.copyWith(
                          color: _T.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if ((widget.campaignData['selectedMenuItems'] as List?)
                        ?.isNotEmpty ==
                    true &&
                (widget.campaignData['selectedMenuItems'] as List).first
                    is Map &&
                (widget.campaignData['selectedMenuItems'] as List).first
                    .containsKey('dishId'))
              _reviewSection(
                'Selected Menu Items',
                (widget.campaignData['selectedMenuItems'] as List)
                    .where((i) => i != null && i['dishId'] != null)
                    .map<Widget>((i) => _menuItemRow(i))
                    .toList(),
              ),
            _gap(12),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Charge Breakdown', style: _T.h3),
                  _gap(14),
                  _divider(),
                  _gap(14),
                  if (digitalScreenCharge > 0) ...[
                    _breakdownRow('Digital Screen Charge', digitalScreenCharge),
                    _gap(8),
                  ],
                  if (digitalSecondsCharge > 0) ...[
                    _breakdownRow(
                      'Duration Charge ($durationSeconds sec)',
                      digitalSecondsCharge,
                    ),
                    _gap(8),
                  ],
                  if (digitalScreenCharge == 0 &&
                      digitalSecondsCharge == 0) ...[
                    if (menuItemsCharge > 0) ...[
                      _breakdownRow('Menu Items Charge', menuItemsCharge),
                      _gap(8),
                    ],
                    if (targetCharge > 0) ...[
                      _breakdownRow('Target Audience', targetCharge),
                      _gap(8),
                    ],
                    if (mediaCharge > 0) ...[
                      _breakdownRow('Media Type', mediaCharge),
                      _gap(8),
                    ],
                    if (displayCharge > 0) ...[
                      _breakdownRow('Display Position', displayCharge),
                      _gap(8),
                    ],
                    _breakdownRow('Promotion Charge', promotionCharge),
                    _gap(8),
                  ],
                  if (couponCharge > 0) ...[
                    _breakdownRow('Coupon Charge', couponCharge),
                    _gap(8),
                  ],
                  _divider(),
                  _gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: _T.h2),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: _T.h1.copyWith(color: _T.brand),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _gap(24),
            _PrimaryButton(
              'Pay ₹${total.toStringAsFixed(2)}',
              loading: _isProcessing,
              trailingIcon: Icons.lock_outline_rounded,
              onTap: _processPayment,
            ),
            _gap(12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security_outlined, size: 13, color: _T.textHint),
                  const SizedBox(width: 5),
                  Text(
                    'Secured by Razorpay',
                    style: _T.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            _gap(32),
          ],
        ),
      ),
    );
  }

  Widget _mediaPreview() {
    if (widget.imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_T.r20),
        child: Image.file(
          widget.imageFile!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.videoFile != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(_T.r20),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            size: 56,
            color: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _reviewSection(String title, List<Widget> children) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _T.h3),
          _gap(12),
          _divider(),
          _gap(12),
          ...children,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: _T.caption)),
          Expanded(child: Text(value, style: _T.body)),
        ],
      ),
    );
  }

  Widget _menuItemRow(Map<String, dynamic> item) {
    double price =
        (item['finalPrice'] ??
                item['discountedPrice'] ??
                item['originalPrice'] ??
                0)
            .toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 14, color: _T.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['dishName'] ?? item['name'] ?? 'Unknown',
              style: _T.body,
            ),
          ),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: _T.body.copyWith(
              fontWeight: FontWeight.w600,
              color: _T.brand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? _T.h3 : _T.body.copyWith(color: _T.textSec),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: isTotal ? _T.h3.copyWith(color: _T.brand) : _T.body,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MENU SELECTION SCREEN
// ─────────────────────────────────────────────
class MenuSelectionScreen extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onMenuSelected;
  const MenuSelectionScreen({Key? key, required this.onMenuSelected})
    : super(key: key);

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Dish> _allDishes = [];
  Map<String, List<Dish>> _groupedDishes = {};
  List<String> _categories = [];
  Set<Dish> _selectedDishes = {};
  Map<int, Map<String, dynamic>> _specialDiscounts = {};
  double _globalDiscountPercent = 0;
  final TextEditingController _globalDiscountController =
      TextEditingController();
  Set<String> _expandedCategories = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  final List<String> _discountTypes = ['% Off', 'Fixed Off', 'BOGO'];

  List<Dish> get _filteredDishes {
    if (_selectedCategory == 'All' && _searchQuery.isEmpty) return _allDishes;
    return _allDishes.where((d) {
      if (_selectedCategory != 'All' &&
          (d.tag ?? 'Uncategorized') != _selectedCategory)
        return false;
      if (_searchQuery.isNotEmpty &&
          !d.dishName.toLowerCase().contains(_searchQuery.toLowerCase()))
        return false;
      return true;
    }).toList();
  }

  Set<String> get _availableCategories => {
    'All',
    ..._allDishes.map((e) => e.tag ?? 'Uncategorized').toSet(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDishes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _globalDiscountController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dishes = await food_authservice.fetchDishes(
        filterByMenuStatus: true,
      );
      final Map<String, List<Dish>> grouped = {};
      for (var d in dishes) {
        final c = d.tag ?? 'Uncategorized';
        grouped.putIfAbsent(c, () => []).add(d);
      }
      setState(() {
        _allDishes = dishes;
        _groupedDishes = grouped;
        _categories = grouped.keys.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load menu: $e';
      });
    }
  }

  void _toggleCategory(String category) => setState(() {
    _expandedCategories.contains(category)
        ? _expandedCategories.remove(category)
        : _expandedCategories.add(category);
  });

  void _applyGlobalDiscountToAll() {
    double p = double.tryParse(_globalDiscountController.text) ?? 0;
    if (p <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid percentage')));
      return;
    }
    setState(() {
      _globalDiscountPercent = p;
      _specialDiscounts.clear();
      _selectedDishes.clear();
      for (var d in _allDishes) {
        _specialDiscounts[d.dishId] = {
          'discountType': '% Off',
          'discountValue': p,
          'finalPrice': d.price * (1 - p / 100),
        };
        _selectedDishes.add(d);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${p}% to all ${_allDishes.length} items'),
        backgroundColor: _T.success,
      ),
    );
    _globalDiscountController.clear();
  }

  void _clearAllDiscounts() {
    setState(() {
      _specialDiscounts.clear();
      _selectedDishes.clear();
      _globalDiscountPercent = 0;
      _globalDiscountController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All discounts cleared'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _toggleDishSelection(Dish dish) => setState(() {
    if (_selectedDishes.contains(dish)) {
      _selectedDishes.remove(dish);
      _specialDiscounts.remove(dish.dishId);
    } else {
      _selectedDishes.add(dish);
    }
  });

  void _updateSpecialDiscount(
    Dish dish,
    String discountType,
    double discountValue,
  ) {
    double finalPrice = dish.price;
    if (discountType == '% Off')
      finalPrice = dish.price * (1 - discountValue / 100);
    else if (discountType == 'Fixed Off')
      finalPrice = (dish.price - discountValue).clamp(0, double.infinity);
    else if (discountType == 'BOGO')
      finalPrice = dish.price / 2;
    setState(() {
      _specialDiscounts[dish.dishId] = {
        'discountType': discountType,
        'discountValue': discountValue,
        'finalPrice': finalPrice,
      };
      if (!_selectedDishes.contains(dish)) _selectedDishes.add(dish);
    });
  }

  double _getEffectivePrice(Dish dish) {
    if (_specialDiscounts.containsKey(dish.dishId))
      return _specialDiscounts[dish.dishId]!['finalPrice'];
    if (dish.discount != null && dish.discount! > 0) return dish.effectivePrice;
    return dish.price;
  }

  void _confirmSelection() {
    bool isOverallMenuApplyToAll =
        (_selectedDishes.length == _allDishes.length &&
        _globalDiscountPercent > 0);
    List<Map<String, dynamic>> selectedMenuData = [];
    if (isOverallMenuApplyToAll) {
      selectedMenuData = [
        {
          'applyToAll': true,
          'discountPercentage': _globalDiscountPercent,
          'totalDishesCount': _allDishes.length,
        },
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_globalDiscountPercent}% applied to ALL ${_allDishes.length} items',
          ),
          backgroundColor: _T.success,
        ),
      );
    } else {
      selectedMenuData = _selectedDishes.map((dish) {
        final fp = _getEffectivePrice(dish);
        final sd = _specialDiscounts[dish.dishId];
        return {
          'dishId': dish.dishId,
          'dishName': dish.dishName,
          'category': dish.tag ?? 'Uncategorized',
          'originalPrice': dish.price,
          'effectivePrice': dish.effectivePrice,
          'finalPrice': fp,
          'discountType':
              sd?['discountType'] ??
              (dish.discount != null && dish.discount! > 0
                  ? 'EXISTING'
                  : 'NONE'),
          'discountValue': sd?['discountValue'] ?? dish.discount ?? 0,
        };
      }).toList();
    }
    widget.onMenuSelected(selectedMenuData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _T.textPri,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Menu Items', style: _T.h2),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text(
              'Done (${_selectedDishes.length})',
              style: TextStyle(color: _T.brand, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _T.brand,
          labelColor: _T.brand,
          unselectedLabelColor: _T.textSec,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Overall Menu'),
            Tab(text: 'Special Menu'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _T.brand))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.red,
                  ),
                  _gap(12),
                  Text(_errorMessage!),
                  _gap(12),
                  ElevatedButton(
                    onPressed: _loadDishes,
                    style: ElevatedButton.styleFrom(backgroundColor: _T.brand),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildOverallMenuTab(), _buildSpecialMenuTab()],
            ),
    );
  }

  Widget _buildOverallMenuTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.r16),
            border: Border.all(color: _T.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apply discount to all items', style: _T.h3),
              _gap(12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _globalDiscountController,
                      keyboardType: TextInputType.number,
                      style: _T.body,
                      decoration: InputDecoration(
                        hintText: 'Enter %',
                        hintStyle: TextStyle(color: _T.textHint),
                        filled: true,
                        fillColor: _T.bg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_T.r12),
                          borderSide: BorderSide(color: _T.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_T.r12),
                          borderSide: BorderSide(color: _T.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_T.r12),
                          borderSide: BorderSide(color: _T.brand, width: 1.5),
                        ),
                      ),
                      onChanged: (v) => setState(
                        () => _globalDiscountPercent = double.tryParse(v) ?? 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _applyGlobalDiscountToAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: _T.brand,
                        borderRadius: BorderRadius.circular(_T.r12),
                      ),
                      child: const Text(
                        'Apply All',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: _T.surface,
            decoration: InputDecoration(
              filled: true,
              fillColor: _T.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              prefixIcon: Icon(
                Icons.category_outlined,
                color: _T.brand,
                size: 18,
              ),
            ),
            items: _availableCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
        ),
        _gap(8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: _T.brandSoft,
            borderRadius: BorderRadius.circular(_T.r12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Item / Category',
                  style: _T.label.copyWith(color: _T.brand),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Original',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Discounted',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        _gap(4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final category = _categories[i];
              var dishes = _groupedDishes[category] ?? [];
              if (_selectedCategory != 'All' && _selectedCategory != category)
                return const SizedBox.shrink();
              final isExpanded = _expandedCategories.contains(category);
              final selCount = dishes
                  .where((d) => _selectedDishes.contains(d))
                  .length;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _T.surface,
                  borderRadius: BorderRadius.circular(_T.r16),
                  border: Border.all(color: _T.border),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleCategory(category),
                      borderRadius: BorderRadius.circular(_T.r16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: _T.brand,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(category, style: _T.h3)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _T.brandSoft,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '$selCount/${dishes.length}',
                                style: _T.caption.copyWith(
                                  color: _T.brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      ...dishes.map((dish) {
                        final isSelected = _selectedDishes.contains(dish);
                        final ep = _getEffectivePrice(dish);
                        final hasDiscount = ep < dish.price;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: _T.border)),
                          ),
                          child: InkWell(
                            onTap: () => _toggleDishSelection(dish),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 14,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          _toggleDishSelection(dish),
                                      activeColor: _T.brand,
                                      side: BorderSide(
                                        color: _T.border,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      dish.dishName,
                                      style: _T.body,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${dish.price.toStringAsFixed(0)}',
                                      style: _T.caption.copyWith(
                                        decoration: hasDiscount
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${ep.toStringAsFixed(0)}',
                                      style: _T.body.copyWith(
                                        color: hasDiscount
                                            ? _T.brand
                                            : _T.textPri,
                                        fontWeight: hasDiscount
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialMenuTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            style: _T.body,
            decoration: InputDecoration(
              hintText: 'Search items...',
              hintStyle: TextStyle(color: _T.textHint),
              filled: true,
              fillColor: _T.surface,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _T.textSec,
                size: 18,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _T.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _T.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _T.brand, width: 1.5),
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: _T.surface,
            decoration: InputDecoration(
              filled: true,
              fillColor: _T.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              prefixIcon: Icon(
                Icons.category_outlined,
                color: _T.brand,
                size: 18,
              ),
            ),
            items: _availableCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
        ),
        _gap(8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: _T.brandSoft,
            borderRadius: BorderRadius.circular(_T.r12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Item', style: _T.label.copyWith(color: _T.brand)),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Price',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Type',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Value',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Final',
                  style: _T.label.copyWith(color: _T.brand),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        _gap(4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final category = _categories[i];
              var dishes = _groupedDishes[category] ?? [];
              if (_selectedCategory != 'All' && _selectedCategory != category)
                return const SizedBox.shrink();
              if (_searchQuery.isNotEmpty)
                dishes = dishes
                    .where(
                      (d) => d.dishName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
              if (dishes.isEmpty) return const SizedBox.shrink();
              final isExpanded = _expandedCategories.contains(category);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _T.surface,
                  borderRadius: BorderRadius.circular(_T.r16),
                  border: Border.all(color: _T.border),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleCategory(category),
                      borderRadius: BorderRadius.circular(_T.r16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: _T.brand,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(category, style: _T.h3)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _T.bg,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '${dishes.length} items',
                                style: _T.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      ...dishes.map((dish) {
                        final sd = _specialDiscounts[dish.dishId];
                        final isSelected = _selectedDishes.contains(dish);
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: _T.border)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          _toggleDishSelection(dish),
                                      activeColor: _T.brand,
                                      side: BorderSide(
                                        color: _T.border,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      dish.dishName,
                                      style: _T.body,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '₹${dish.price.toStringAsFixed(0)}',
                                      style: _T.caption,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: isSelected
                                        ? DropdownButton<String>(
                                            value:
                                                sd?['discountType'] ?? '% Off',
                                            underline: const SizedBox.shrink(),
                                            style: _T.caption.copyWith(
                                              fontSize: 11,
                                            ),
                                            items: _discountTypes
                                                .map(
                                                  (t) => DropdownMenuItem(
                                                    value: t,
                                                    child: Text(
                                                      t,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (v) =>
                                                _updateSpecialDiscount(
                                                  dish,
                                                  v!,
                                                  sd?['discountValue'] ?? 0,
                                                ),
                                          )
                                        : Text(
                                            '-',
                                            style: _T.caption,
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child:
                                        isSelected &&
                                            sd?['discountType'] != 'BOGO'
                                        ? SizedBox(
                                            height: 32,
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    sd?['discountType'] ==
                                                        '% Off'
                                                    ? '%'
                                                    : '₹',
                                                filled: true,
                                                fillColor: _T.bg,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: _T.border,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: _T.border,
                                                      ),
                                                    ),
                                              ),
                                              onChanged: (v) =>
                                                  _updateSpecialDiscount(
                                                    dish,
                                                    sd?['discountType'] ??
                                                        '% Off',
                                                    double.tryParse(v) ?? 0,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            sd?['discountType'] == 'BOGO'
                                                ? 'BOGO'
                                                : '-',
                                            style: _T.caption,
                                            textAlign: TextAlign.center,
                                          ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      sd != null
                                          ? '₹${sd['finalPrice'].toStringAsFixed(0)}'
                                          : '₹${dish.price.toStringAsFixed(0)}',
                                      style: _T.body.copyWith(
                                        color: sd != null
                                            ? _T.brand
                                            : _T.textPri,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected &&
                                  sd != null &&
                                  (sd['discountValue'] ?? 0) > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _T.successSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${sd['discountType']}: ${sd['discountValue']}${sd['discountType'] == '% Off' ? '%' : ''} off → ₹${sd['finalPrice'].toStringAsFixed(2)}',
                                    style: _T.caption.copyWith(
                                      color: _T.success,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CREATE PROMOTION SCREEN (4 STEPS)
// ─────────────────────────────────────────────
class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  late double _menuChargePerItem;
  late double _couponCharge;
  String? _durationSeconds;
  String? _period;
  int _currentStep = 0;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _availableScreens = [];
  int? _selectedScreenId;
  bool _isLoadingScreens = false;

  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _deepLinkController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String? _discountTypeValue;
  String? _couponTypeValue;

  String? _goalValue;
  String? _subGoalValue;
  String? _mediumValue;
  String? _addDisplayPositionValue;
  String? _callToActionValue;
  String? _genderValue;
  String? _timeCategoryValue;
  String? _appTypeValue;
  String? _selectedMediaType = 'image';

  List<Map<String, dynamic>> _selectedMenuItems = [];
  int _totalDishesCount = 0;

  double _targetAudiencesCharge = 0.0;
  double _mediaTypeCharge = 0.0;
  double _displaypPositionCharge = 0.0;
  double _promotionCharge = 0.0;
  double _baseReach = 0.0;
  double _currentReach = 0.0;
  double _digitalScreenChargeImage = 0.0;
  double _digitalScreenChargeVideo = 0.0;
  double _digitalScreenSecondsCharge = 0.0;
  double _baseBudget = 0.0;
  double _investmentAmount = 0.0;
  double _budgetMultiplier = 1.0;
  bool _isBudgetIncreased = false;
  double _calculatedBudget = 0.0;
  bool _isCalculatingBudget = false;
  TimeOfDay? _couponStartTime;
  TimeOfDay? _couponEndTime;
  Map<String, dynamic> _chargeBreakdown = {};

  final List<String> _availableInterests = [
    "JOBS",
    "FOOD",
    "EDUCATION",
    "OFFERS",
    "REAL_ESTATE",
    "ONLINE_COURSES",
    "BAKERY",
    "HEALTH",
    "TRAVEL",
    "ENTERTAINMENT",
  ];
  List<String> _selectedInterests = [];
  final List<String> _availableTargetAudience = ["Users", "Vendors", "Movers"];
  List<String> _selectedTargetAudience = ["Users"];

  DateTime? _startDate;
  DateTime? _endDate;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _locationLoaded = false;
  double _radiusKm = 10.0;
  Set<Circle> _circles = {};

  File? imageFile;
  File? videoFile;
  VideoPlayerController? videoController;
  final ImagePicker picker = ImagePicker();

  final List<String> _callToActionEnums = [
    "APPLY_NOW",
    "BOOK_NOW",
    "CONTACT_US",
    "SHOP_NOW",
    "SIGN_UP",
    "WATCH_MORE",
    "SEND_MESSAGE",
    "GET_QUOTE",
    "GET_DIRECTIONS",
  ].toSet().toList();

  final List<String> _appTypeEnums = [
    "FOOD_AND_BEVERAGES",
    "CATERINGS_SERVICES",
  ];
  final List<String> _timeCategoryEnums = [
    "PEAK_HOURS",
    "RAINING_TIME",
    "HAPPY_HOURS",
    "LUNCH_TIME",
    "DINNER_TIME",
    "EARLY_MORNING",
    "LATE_NIGHT",
    "WEEKEND_SPECIAL",
  ];
  final List<String> _displayPositionEnums = [
    "ADD_SCREEN",
    "HOMEPAGE_BANNER",
    "CHECKOUT_PAGE",
    "IN_APP_POPUP",
  ];

  @override
  void initState() {
    super.initState();
    _fetchBillingRates();
    _fetchScreens();
    _investmentController.addListener(() {
      double value = double.tryParse(_investmentController.text) ?? 0;
      if (value > 0 && value != _investmentAmount)
        _updateBudgetAndIncrease(value);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _investmentController.dispose();
    _campaignNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _deepLinkController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _couponCodeController.dispose();
    _discountController.dispose();
    videoController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchScreens() async {
    setState(() {
      _isLoadingScreens = true;
      _selectedScreenId = null;
    });
    try {
      final screens = await PromotionAuthService.fetchScreens();
      setState(() => _availableScreens = screens);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load screens: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      setState(() => _isLoadingScreens = false);
    }
  }

  Future<void> _fetchBillingRates() async {
    try {
      final result = await PromotionAuthService.fetchBillingRates();
      if (result != null) {
        if (!result.containsKey('menuChargePerItem'))
          throw Exception('menuChargePerItem not returned from backend');
        setState(() {
          _targetAudiencesCharge = result['targetAudiencesCharge'];
          _mediaTypeCharge = result['mediaTypeCharge'];
          _displaypPositionCharge = result['displaypPositionCharge'];
          _promotionCharge = result['promotionCharge'];
          _baseReach = result['reach'];
          _menuChargePerItem = result['menuChargePerItem'];
          _couponCharge = result['couponCharge'] ?? 0.0;
          _digitalScreenChargeImage = result['digitalScreenChargeImage'];
          _digitalScreenChargeVideo = result['digitalScreenChargeVideo'];
          _digitalScreenSecondsCharge = result['digitalScreenSecondsCharge'];
          _currentReach = _baseReach;
        });
        await _calculateTotalBudget();
      } else {
        throw Exception('Failed to fetch billing rates from backend');
      }
    } catch (e) {
      debugPrint('❌ Error fetching billing rates: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading billing rates: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _updateBudgetAndIncrease(double newInvestment) async {
    setState(() {
      _investmentAmount = newInvestment;
      _isBudgetIncreased = true;
      _budgetMultiplier = _baseBudget > 0 ? newInvestment / _baseBudget : 1.0;
      _currentReach = newInvestment;
      _investmentController.text = newInvestment.toStringAsFixed(0);
    });
    await _calculateTotalBudget();
  }

  Future<void> _calculateTotalBudget() async {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    bool isDigital = (_mediumValue == "DIGITAL");

    if (isDiscountMenu) {
      setState(() => _isCalculatingBudget = true);
      try {
        bool isOverallMenu =
            (_selectedMenuItems.isNotEmpty &&
            _selectedMenuItems.first.containsKey('applyToAll'));
        int numberOfMenuItems = isOverallMenu
            ? _totalDishesCount
            : _selectedMenuItems.length;
        double menuItemsCharge = numberOfMenuItems * _menuChargePerItem;
        double finalBudget = menuItemsCharge + _promotionCharge;
        setState(() {
          _calculatedBudget = finalBudget;
          _chargeBreakdown = {
            'targetAudiencesCharge': 0.0,
            'mediaTypeCharge': 0.0,
            'displaypPositionCharge': 0.0,
            'menuItemsCharge': menuItemsCharge,
            'menuChargePerItem': _menuChargePerItem,
            'promotionCharge': _promotionCharge,
            'numberOfMenuItems': numberOfMenuItems,
            'reach': _currentReach,
            'investmentAmount': _investmentAmount,
            'isBudgetIncreased': _isBudgetIncreased,
            'budgetMultiplier': _budgetMultiplier,
            'total': finalBudget,
          };
        });
      } catch (e) {
        debugPrint('❌ Error: $e');
      } finally {
        setState(() => _isCalculatingBudget = false);
      }
      return;
    }

    if (isDigital) {
      if (_durationSeconds == null ||
          _period == null ||
          _selectedScreenId == null ||
          _selectedMediaType == null)
        return;
      setState(() => _isCalculatingBudget = true);
      try {
        double fixedCharge = (_selectedMediaType == 'image')
            ? _digitalScreenChargeImage
            : _digitalScreenChargeVideo;
        double secondsCharge = _digitalScreenSecondsCharge;
        double baseTotal = fixedCharge + secondsCharge;
        if (_baseBudget == 0.0) _baseBudget = baseTotal;
        double finalBudget =
            baseTotal + (_isBudgetIncreased ? _investmentAmount : 0);
        setState(() {
          _calculatedBudget = finalBudget;
          _chargeBreakdown = {
            'digitalScreenCharge': fixedCharge,
            'digitalScreenSecondsCharge': secondsCharge,
            'durationSeconds': int.parse(_durationSeconds!),
            'baseTotal': baseTotal,
            'investmentAmount': _investmentAmount,
            'isBudgetIncreased': _isBudgetIncreased,
            'total': finalBudget,
          };
        });
      } catch (e) {
        debugPrint('❌ Error: $e');
      } finally {
        setState(() => _isCalculatingBudget = false);
      }
      return;
    }

    if (_goalValue == "BRANDING" || _goalValue == "LEADS") {
      if (_selectedTargetAudience.isEmpty ||
          _selectedMediaType == null ||
          _addDisplayPositionValue == null)
        return;
      setState(() => _isCalculatingBudget = true);
      try {
        double targetCharge =
            _targetAudiencesCharge * _selectedTargetAudience.length;
        double baseTotal =
            targetCharge +
            _mediaTypeCharge +
            _displaypPositionCharge +
            _promotionCharge;
        if (_baseBudget == 0.0) _baseBudget = baseTotal;
        double finalBudget =
            baseTotal + (_isBudgetIncreased ? _investmentAmount : 0);
        setState(() {
          _calculatedBudget = finalBudget;
          _chargeBreakdown = {
            'targetAudiencesCharge': targetCharge,
            'mediaTypeCharge': _mediaTypeCharge,
            'displaypPositionCharge': _displaypPositionCharge,
            'promotionCharge': _promotionCharge,
            'baseTotal': baseTotal,
            'investmentAmount': _investmentAmount,
            'isBudgetIncreased': _isBudgetIncreased,
            'total': finalBudget,
          };
        });
      } catch (e) {
        debugPrint('❌ Error: $e');
      } finally {
        setState(() => _isCalculatingBudget = false);
      }
      return;
    }

    if (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS") {
      if (_selectedTargetAudience.isEmpty ||
          _selectedMediaType == null ||
          _addDisplayPositionValue == null)
        return;
      setState(() => _isCalculatingBudget = true);
      try {
        double targetCharge =
            _targetAudiencesCharge * _selectedTargetAudience.length;
        double baseTotal =
            targetCharge +
            _mediaTypeCharge +
            _displaypPositionCharge +
            _promotionCharge +
            _couponCharge;
        if (_baseBudget == 0.0) _baseBudget = baseTotal;
        double finalBudget =
            baseTotal + (_isBudgetIncreased ? _investmentAmount : 0);
        setState(() {
          _calculatedBudget = finalBudget;
          _chargeBreakdown = {
            'targetAudiencesCharge': targetCharge,
            'mediaTypeCharge': _mediaTypeCharge,
            'displaypPositionCharge': _displaypPositionCharge,
            'promotionCharge': _promotionCharge,
            'couponCharge': _couponCharge,
            'baseTotal': baseTotal,
            'investmentAmount': _investmentAmount,
            'isBudgetIncreased': _isBudgetIncreased,
            'total': finalBudget,
          };
        });
      } catch (e) {
        debugPrint('❌ Error: $e');
      } finally {
        setState(() => _isCalculatingBudget = false);
      }
      return;
    }

    setState(() {
      _calculatedBudget = 0.0;
      _chargeBreakdown = {'total': 0.0};
    });
  }

  Future<void> _pickMedia() async {
    if (_selectedMediaType == 'image') {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          imageFile = File(file.path);
          videoController?.dispose();
          videoFile = null;
          videoController = null;
        });
        await _calculateTotalBudget();
      }
    } else {
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        videoController?.dispose();
        videoController = VideoPlayerController.file(File(file.path))
          ..initialize().then((_) => setState(() {}));
        setState(() {
          videoFile = File(file.path);
          imageFile = null;
        });
        await _calculateTotalBudget();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _err('Please enable location services');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _err('Location permission denied');
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
      _updateCircle();
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 13),
      ),
    );
  }

  Future<void> _goToCity(String cityName) async {
    if (cityName.isEmpty) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            Center(child: CircularProgressIndicator(color: _T.brand)),
      );
      List<Location> locations = await locationFromAddress(cityName);
      Navigator.pop(context);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _currentPosition = LatLng(location.latitude, location.longitude);
          _locationLoaded = true;
          _updateCircle();
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 13),
          ),
        );
        await _calculateTotalBudget();
      } else {
        _err('City "$cityName" not found');
      }
    } catch (e) {
      Navigator.pop(context);
      _err('Error finding city: $e');
    }
  }

  void _err(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));

  void _updateCircle() {
    if (_currentPosition == null) return;
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('target_radius'),
          center: _currentPosition!,
          radius: _radiusKm * 1000,
          fillColor: _T.brand.withOpacity(0.15),
          strokeColor: _T.brand,
          strokeWidth: 2,
        ),
      };
    });
  }

  String? _getResolutionFromDimensions(int width, int height) {
    if (width == 720 && height == 1280) return 'R_720P';
    if ((width == 1080 && height == 1350) || (width == 1080 && height == 1920))
      return 'R_1080P';
    if (width == 3840 && height == 2160) return 'R_4K';
    if (width == 1000 && height == 800) return 'R_720P';
    return null;
  }

  Future<String?> _validateMediaAndGetResolution() async {
    if (_selectedMediaType == 'image' && imageFile != null) {
      final bytes = await imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final resolution = _getResolutionFromDimensions(
        frame.image.width,
        frame.image.height,
      );
      if (resolution == null) _err('Image dimensions not supported');
      return resolution;
    } else if (_selectedMediaType == 'video' &&
        videoController != null &&
        videoController!.value.isInitialized) {
      final resolution = _getResolutionFromDimensions(
        videoController!.value.size.width.toInt(),
        videoController!.value.size.height.toInt(),
      );
      if (resolution == null) _err('Video dimensions not supported');
      return resolution;
    }
    return null;
  }

  void _openMenuSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuSelectionScreen(
          onMenuSelected: (selectedItems) {
            setState(() {
              _selectedMenuItems = selectedItems;
              if (selectedItems.isNotEmpty &&
                  selectedItems.first.containsKey('applyToAll')) {
                _totalDishesCount =
                    selectedItems.first['totalDishesCount'] ?? 0;
              } else {
                _totalDishesCount = 0;
              }
            });
            _calculateTotalBudget();
          },
        ),
      ),
    );
  }

  bool _isStep1Valid() {
    if (_goalValue == null || _subGoalValue == null) return false;
    if (_goalValue != "DISCOUNT" && _campaignNameController.text.isEmpty)
      return false;
    return true;
  }

  bool _isStep2Valid() {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    if (isDiscountMenu) return true;
    if (_mediumValue == "DIGITAL") {
      if (_durationSeconds == null ||
          _period == null ||
          _selectedScreenId == null)
        return false;
      if (imageFile == null && videoFile == null) return false;
      return true;
    }
    if (_mediumValue == null ||
        _addDisplayPositionValue == null ||
        _selectedTargetAudience.isEmpty)
      return false;
    bool shouldHideCallToAction =
        (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");
    if (!shouldHideCallToAction && _callToActionValue == null) return false;
    if (imageFile == null && videoFile == null) return false;
    if (_callToActionValue == "CONTACT_US" &&
        _mobileNumberController.text.isEmpty)
      return false;
    return true;
  }

  bool _isStep3Valid() {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    if (isDiscountMenu) return _timeCategoryValue != null;
    if (_mediumValue == "DIGITAL") {
      if (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS") {
        if (_couponCodeController.text.isEmpty ||
            _discountController.text.isEmpty ||
            _discountTypeValue == null ||
            _couponTypeValue == null)
          return false;
      }
      return true;
    }
    if (_genderValue == null ||
        _minAgeController.text.isEmpty ||
        _maxAgeController.text.isEmpty)
      return false;
    if (_selectedInterests.isEmpty ||
        _cityController.text.isEmpty ||
        _currentPosition == null)
      return false;
    if (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS") {
      if (_couponCodeController.text.isEmpty ||
          _discountController.text.isEmpty ||
          _discountTypeValue == null ||
          _couponTypeValue == null)
        return false;
    }
    return true;
  }

  bool _isStep4Valid() {
    if (_startDate == null || _endDate == null) return false;
    if (_endDate!.isBefore(_startDate!)) return false;

    // Validate coupon times
    bool isCoupons = (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");
    if (isCoupons) {
      if (_couponStartTime == null || _couponEndTime == null) return false;
    }

    return true;
  }

  void _nextStep() {
    bool isValid = [
      _isStep1Valid,
      _isStep2Valid,
      _isStep3Valid,
      _isStep4Valid,
    ][_currentStep]();
    if (!isValid) {
      _err('Please fill all required fields');
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToReview();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _goToReview() async {
    String campaignName = _campaignNameController.text;
    bool shouldHideCallToAction =
        (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");

    if (_goalValue != "DISCOUNT" && campaignName.isEmpty) {
      _err('Campaign name is required');
      return;
    }
    if (_goalValue == null || _subGoalValue == null) {
      _err('Please select goal and sub goal');
      return;
    }

    if (!isDiscountMenu) {
      if (_mediumValue == null) {
        _err('Please select medium');
        return;
      }
      if (_mediumValue != "DIGITAL") {
        if (_selectedInterests.isEmpty) {
          _err('Please select at least one interest');
          return;
        }
        if (_cityController.text.isEmpty || _currentPosition == null) {
          _err('Please select location');
          return;
        }
        if (_addDisplayPositionValue == null || _genderValue == null) {
          _err('Please fill all required fields');
          return;
        }
        if (!shouldHideCallToAction && _callToActionValue == null) {
          _err('Please select Call to Action');
          return;
        }
        if (_appTypeValue == null) {
          _err('Please select App Type');
          return;
        }
      }
      if (imageFile == null && videoFile == null) {
        _err('Please upload media');
        return;
      }
    }

    if (_startDate == null || _endDate == null) {
      _err('Please select start and end dates');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _err('End date must be after start date');
      return;
    }
    if (_goalValue == "DISCOUNT" && _subGoalValue == "MENU") {
      if (_timeCategoryValue == null) {
        _err('Please select Time Category');
        return;
      }
      if (_selectedMenuItems.isEmpty) {
        _err('Please select menu items for discount');
        return;
      }
    }
    if (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS")
      _timeCategoryValue = null;

    String? resolution;
    if (!isDiscountMenu && _mediumValue != "DIGITAL") {
      resolution = await _validateMediaAndGetResolution();
      if (resolution == null) return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');
    final int? vendorId = prefs.getInt('vendorId');
    if (customerId == null || customerId.isEmpty) {
      _err('Customer ID not found. Please login again.');
      return;
    }
    if (vendorId == null) {
      _err('Vendor ID not found. Please login again.');
      return;
    }

    bool isOverallMenu =
        (_selectedMenuItems.isNotEmpty &&
        _selectedMenuItems.first.containsKey('applyToAll'));
    double globalDiscount = isOverallMenu
        ? (_selectedMenuItems.first['discountPercentage'] ?? 0)
        : 0.0;

    List<int> dishIds = [];
    List<double> dishDiscountsList = [];

    if (!isOverallMenu) {
      for (var item in _selectedMenuItems) {
        int dishId = item['dishId'] ?? 0;
        double discountPercentage = 0;
        if (item['discountType'] == '% Off')
          discountPercentage = item['discountValue'] ?? 0;
        else if (item['discountType'] == 'Fixed Off') {
          double op = item['originalPrice'] ?? 0;
          double da = item['discountValue'] ?? 0;
          if (op > 0) discountPercentage = (da / op) * 100;
        } else if (item['discountType'] == 'BOGO')
          discountPercentage = 50;
        else if (item['discountType'] == 'EXISTING')
          discountPercentage = item['discount'] ?? 0;
        if (dishId != 0) {
          dishIds.add(dishId);
          dishDiscountsList.add(discountPercentage);
        }
      }
    }

    Map<String, dynamic>? vendorCouponRequest;
    if (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS") {
      // Debug prints before building the request
      debugPrint('🕒 Debug: _couponStartTime = $_couponStartTime');
      debugPrint('🕒 Debug: _couponEndTime = $_couponEndTime');

      final String? startTimeStr = _couponStartTime != null
          ? "${_couponStartTime!.hour.toString().padLeft(2, '0')}:${_couponStartTime!.minute.toString().padLeft(2, '0')}:00"
          : null;
      final String? endTimeStr = _couponEndTime != null
          ? "${_couponEndTime!.hour.toString().padLeft(2, '0')}:${_couponEndTime!.minute.toString().padLeft(2, '0')}:00"
          : null;

      debugPrint('🕒 Formatted startTime: $startTimeStr');
      debugPrint('🕒 Formatted endTime: $endTimeStr');

      vendorCouponRequest = {
        "couponCode": _couponCodeController.text,
        "discount": double.tryParse(_discountController.text) ?? 0,
        "discountType": _discountTypeValue ?? "PERCENTAGE",
        "couponType": _couponTypeValue ?? "FLAT",
        "startTime": startTimeStr,
        "endTime": endTimeStr,
      };

      debugPrint('📦 vendorCouponRequest with times: $vendorCouponRequest');
    }
    Map<String, dynamic> campaignData = {};

    if (isDiscountMenu) {
      campaignData = {
        'campaignName': campaignName,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        'goal': _goalValue,
        'subGoal': _subGoalValue,
        'medium': "APP",
        'mediaType': "IMAGE",
        'totalBudget': _calculatedBudget,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'timeCategory': _timeCategoryValue,
        'customerId': customerId,
        'vendorId': vendorId,
        'created_at': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'selectedMenuItems': _selectedMenuItems,
        'paymentStatus': 'PAID',
      };
      if (isOverallMenu) {
        campaignData['discountPercentage'] = globalDiscount;
        campaignData['applyDiscountToAll'] = true;
      } else {
        campaignData['dishIds'] = dishIds;
        campaignData['dishDiscounts'] = dishDiscountsList;
        campaignData['discountPercentage'] = dishDiscountsList.isNotEmpty
            ? dishDiscountsList.first
            : null;
      }
    } else {
      campaignData = {
        'campaignName': campaignName,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        'goal': _goalValue,
        'subGoal': _subGoalValue,
        'medium': _mediumValue,
        'mediaType': _selectedMediaType == 'image' ? 'IMAGE' : 'VIDEO',
        'totalBudget': _calculatedBudget,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'customerId': customerId,
        'vendorId': vendorId,
        'reach': _currentReach,
        'isBudgetIncreased': _isBudgetIncreased,
        'investmentAmount': _investmentAmount,
        'budgetMultiplier': _budgetMultiplier,
        'created_at': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'selectedMenuItems': _selectedMenuItems,
        if (vendorCouponRequest != null)
          'vendorCouponRequest': vendorCouponRequest,
      };
      if (_mediumValue != "DIGITAL") {
        campaignData.addAll({
          'callToAction': _callToActionValue,
          'gender': _genderValue,
          'minAge': int.tryParse(_minAgeController.text) ?? 18,
          'maxAge': int.tryParse(_maxAgeController.text) ?? 60,
          'targetAudience': _selectedTargetAudience,
          'interests': _selectedInterests,
          'city': _cityController.text,
          'centerLatitude': _currentPosition!.latitude,
          'centerLongitude': _currentPosition!.longitude,
          'radiusKm': _radiusKm,
          'addDisplayPosition': _addDisplayPositionValue,
          'appType': _appTypeValue,
          'deepLink': _deepLinkController.text.isNotEmpty
              ? _deepLinkController.text
              : null,
          'resolution': resolution,
        });
        if (_goalValue == "DISCOUNT" && _subGoalValue != "COUPONS")
          campaignData['timeCategory'] = _timeCategoryValue;
        if (_callToActionValue == "CONTACT_US" &&
            _mobileNumberController.text.isNotEmpty)
          campaignData['mobileNumber'] = _mobileNumberController.text;
      }
      if (_mediumValue == "DIGITAL" &&
          _durationSeconds != null &&
          _period != null) {
        int duration = int.parse(_durationSeconds!);
        campaignData['durationSeconds'] = duration;
        campaignData['screenRequest'] = {
          'durationSeconds': duration,
          'loops': 0,
          'period': _period,
          'screenIds': [_selectedScreenId!],
        };
      }
      if (isOverallMenu && globalDiscount > 0) {
        campaignData['discountPercentage'] = globalDiscount;
        campaignData['applyDiscountToAll'] = true;
      } else if (!isOverallMenu && dishIds.isNotEmpty) {
        campaignData['dishIds'] = dishIds;
        campaignData['dishDiscounts'] = dishDiscountsList;
        campaignData['discountPercentage'] = dishDiscountsList.isNotEmpty
            ? dishDiscountsList.first
            : null;
      }
    }

    campaignData.removeWhere((key, value) => value == null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          campaignData: campaignData,
          imageFile: imageFile,
          videoFile: videoFile,
          calculatedBudget: _calculatedBudget,
          chargeBreakdown: _chargeBreakdown,
        ),
      ),
    );
  }

  // ─── STEP BUILDERS ───
  Widget _buildCouponTimePicker() {
    return _Card(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          _timeRow(
            'Coupon Start Time',
            _couponStartTime,
            Icons.access_time_outlined,
            () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _couponStartTime ?? TimeOfDay.now(),
                builder: (_, child) => Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(primary: _T.brand),
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: _T.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (t != null) setState(() => _couponStartTime = t);
            },
          ),
          _divider(),
          _timeRow(
            'Coupon End Time',
            _couponEndTime,
            Icons.access_time_outlined,
            () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _couponEndTime ?? TimeOfDay.now(),
                builder: (_, child) => Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(primary: _T.brand),
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: _T.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (t != null) setState(() => _couponEndTime = t);
            },
          ),
        ],
      ),
    );
  }

  Widget _timeRow(
    String label,
    TimeOfDay? time,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: _T.brand, size: 20),
      title: Text(label, style: _T.caption),
      subtitle: Text(
        time == null ? 'Tap to select time' : time.format(context),
        style: _T.body.copyWith(
          fontWeight: time != null ? FontWeight.w600 : FontWeight.w400,
          color: time != null ? _T.textPri : _T.textHint,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: _T.textHint, size: 20),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Campaign Goal', icon: Icons.flag_outlined),
          _gap(6),
          _SelectField(
            'Select Your Goal',
            ["BRANDING", "DISCOUNT", "LEADS"],
            _goalValue,
            (val) {
              setState(() {
                _goalValue = val;
                _subGoalValue = null;
                _couponStartTime = null;
                _couponEndTime = null;
                if (val != "DISCOUNT") _timeCategoryValue = null;
              });
            },
          ),
          if (_goalValue != null) ...[_gap(16), _buildSubGoalSelector()],
          if (_goalValue != "DISCOUNT") ...[
            _gap(16),
            _SectionLabel('Campaign Details', icon: Icons.campaign_outlined),
            _gap(6),
            _FieldBox(
              'Campaign Name',
              _campaignNameController,
              hint: 'e.g. Summer Special Offer',
            ),
          ],
          if (_goalValue == "DISCOUNT" && _subGoalValue == "MENU") ...[
            _gap(16),
            _SectionLabel(
              'Menu Discount',
              icon: Icons.restaurant_menu_outlined,
            ),
            _gap(6),
            _menuSelectionCard(),
          ],
          _gap(24),
          _primaryAndBackButtons(),
          _gap(32),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    bool shouldHideCallToAction =
        (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");

    if (isDiscountMenu) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(_T.r20),
                border: Border.all(color: _T.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: _T.success, size: 52),
                  _gap(12),
                  Text(
                    'No additional details needed',
                    style: _T.h3.copyWith(color: _T.textSec),
                  ),
                  _gap(4),
                  Text(
                    'Proceed to Time Category →',
                    style: _T.caption.copyWith(color: _T.brand),
                  ),
                ],
              ),
            ),
            _gap(24),
            _primaryAndBackButtons(),
            _gap(32),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_goalValue == "BRANDING") ...[
            _SectionLabel('Medium', icon: Icons.devices_outlined),
            _gap(6),
            Wrap(
              spacing: 10,
              children: [
                _Pill(
                  'APP',
                  selected: _mediumValue == 'APP',
                  onTap: () => setState(() => _mediumValue = 'APP'),
                  icon: Icons.phone_iphone_rounded,
                ),
                _Pill(
                  'DIGITAL',
                  selected: _mediumValue == 'DIGITAL',
                  onTap: () => setState(() => _mediumValue = 'DIGITAL'),
                  icon: Icons.tv_rounded,
                ),
              ],
            ),
          ] else ...[
            _SectionLabel('Medium', icon: Icons.devices_outlined),
            _gap(6),
            _Pill(
              'APP',
              selected: _mediumValue == 'APP',
              onTap: () => setState(() => _mediumValue = 'APP'),
              icon: Icons.phone_iphone_rounded,
            ),
          ],
          _gap(20),

          if (_mediumValue == "DIGITAL") ...[
            _SectionLabel('Duration (seconds)', icon: Icons.timer_outlined),
            _gap(6),
            Wrap(
              spacing: 10,
              children: ["5", "10", "15", "20"]
                  .map(
                    (sec) => _Pill(
                      sec,
                      selected: _durationSeconds == sec,
                      onTap: () => setState(() => _durationSeconds = sec),
                    ),
                  )
                  .toList(),
            ),
            _gap(20),
            _SectionLabel('Period', icon: Icons.calendar_month_outlined),
            _gap(6),
            Wrap(
              spacing: 10,
              children: [
                _Pill(
                  'Per Day',
                  selected: _period == "PER_DAY",
                  onTap: () => setState(() => _period = "PER_DAY"),
                ),
                _Pill(
                  'Per Week',
                  selected: _period == "PER_WEEK",
                  onTap: () => setState(() => _period = "PER_WEEK"),
                ),
              ],
            ),
            _gap(20),
            _SectionLabel('Screen', icon: Icons.monitor_rounded),
            _gap(6),
            if (_isLoadingScreens)
              Center(child: CircularProgressIndicator(color: _T.brand))
            else if (_availableScreens.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: _T.surface,
                  borderRadius: BorderRadius.circular(_T.r12),
                  border: Border.all(color: _T.border),
                ),
                child: DropdownButtonFormField<int>(
                  value: _selectedScreenId,
                  isExpanded: true,
                  hint: Text(
                    'Select a screen',
                    style: _T.body.copyWith(color: _T.textHint),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: InputBorder.none,
                  ),
                  items: _availableScreens.map((screen) {
                    return DropdownMenuItem<int>(
                      value: screen['id'] as int,
                      child: Text(
                        '${screen['name']} (${screen['location']})',
                        style: _T.body,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newId) {
                    setState(() {
                      _selectedScreenId = newId;
                      _calculateTotalBudget(); // Recalculate budget when screen changes
                    });
                  },
                ),
              )
            else
              Text(
                'No screens available',
                style: _T.body.copyWith(color: Colors.red),
              ),
            _gap(20),
          ],

          if (_mediumValue != "DIGITAL") ...[
            _SectionLabel('Display Position', icon: Icons.grid_view_outlined),
            _gap(6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _displayPositionEnums
                  .map(
                    (p) => _Pill(
                      _humanize(p),
                      selected: _addDisplayPositionValue == p,
                      onTap: () {
                        setState(() => _addDisplayPositionValue = p);
                        _calculateTotalBudget();
                      },
                    ),
                  )
                  .toList(),
            ),
            _gap(20),
            _SectionLabel(
              'Target Audience',
              icon: Icons.people_outline_rounded,
            ),
            _gap(6),
            Wrap(
              spacing: 8,
              children: _availableTargetAudience
                  .map(
                    (a) => _Pill(
                      a,
                      selected: _selectedTargetAudience.contains(a),
                      onTap: () {
                        setState(() {
                          if (_selectedTargetAudience.contains(a))
                            _selectedTargetAudience.remove(a);
                          else
                            _selectedTargetAudience.add(a);
                        });
                        _calculateTotalBudget();
                      },
                    ),
                  )
                  .toList(),
            ),
            _gap(6),
            Text(
              'Selected: ${_selectedTargetAudience.join(', ')}',
              style: _T.caption,
            ),
            _gap(20),
          ],

          _SectionLabel('Campaign Media', icon: Icons.photo_library_outlined),
          _gap(6),
          Row(
            children: [
              _Pill(
                'Image',
                selected: _selectedMediaType == 'image',
                icon: Icons.image_outlined,
                onTap: () {
                  setState(() => _selectedMediaType = 'image');
                  _calculateTotalBudget();
                },
              ),
              const SizedBox(width: 10),
              _Pill(
                'Video',
                selected: _selectedMediaType == 'video',
                icon: Icons.videocam_outlined,
                onTap: () {
                  setState(() => _selectedMediaType = 'video');
                  _calculateTotalBudget();
                },
              ),
            ],
          ),
          _gap(12),
          _mediaPicker(),
          _gap(16),
          _FieldBox(
            'Description (Optional)',
            _descriptionController,
            maxLines: 3,
            hint: 'Brief description of your campaign',
          ),
          _gap(16),

          if (_mediumValue != "DIGITAL" && !shouldHideCallToAction) ...[
            _SectionLabel('Call to Action', icon: Icons.touch_app_outlined),
            _gap(6),
            _buildCallToActionDropdown(),
            if (_callToActionValue == "CONTACT_US") ...[
              _gap(12),
              _FieldBox(
                'Mobile Number',
                _mobileNumberController,
                keyboardType: TextInputType.phone,
                hint: 'e.g. 9876543210',
              ),
            ],
          ],

          _gap(24),
          _primaryAndBackButtons(),
          _gap(32),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    bool shouldShowCouponFields =
        (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");
    bool shouldShowTimeCategory =
        (_goalValue == "DISCOUNT" && _subGoalValue != "COUPONS");

    if (isDiscountMenu) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Time Category', icon: Icons.timer_outlined),
            _gap(6),
            _SelectField(
              'Select Time Category',
              _timeCategoryEnums,
              _timeCategoryValue,
              (v) => setState(() => _timeCategoryValue = v),
              display: _humanize,
            ),
            _gap(24),
            _primaryAndBackButtons(),
            _gap(32),
          ],
        ),
      );
    }

    if (_mediumValue == "DIGITAL") {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shouldShowCouponFields) ...[
              _SectionLabel(
                'Coupon Configuration',
                icon: Icons.local_offer_outlined,
              ),
              _gap(6),
              _buildCouponFields(),
              _gap(20),
            ],
            if (shouldShowTimeCategory) ...[
              _SectionLabel('Time Category', icon: Icons.timer_outlined),
              _gap(6),
              _SelectField(
                'Select Time Category',
                _timeCategoryEnums,
                _timeCategoryValue,
                (v) => setState(() => _timeCategoryValue = v),
                display: _humanize,
              ),
              _gap(20),
            ],
            _primaryAndBackButtons(),
            _gap(32),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Demographics', icon: Icons.person_outline_rounded),
          _gap(6),
          _SelectField(
            'Gender',
            ["MALE", "FEMALE", "OTHER", "ALL"],
            _genderValue,
            (v) => setState(() => _genderValue = v),
          ),
          _gap(12),
          Row(
            children: [
              Expanded(
                child: _FieldBox(
                  'Min Age',
                  _minAgeController,
                  keyboardType: TextInputType.number,
                  hint: '18',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FieldBox(
                  'Max Age',
                  _maxAgeController,
                  keyboardType: TextInputType.number,
                  hint: '60',
                ),
              ),
            ],
          ),
          _gap(20),
          _SectionLabel('Interests', icon: Icons.favorite_border_rounded),
          _gap(6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests
                .map(
                  (interest) => _Pill(
                    _humanize(interest),
                    selected: _selectedInterests.contains(interest),
                    onTap: () => setState(() {
                      if (_selectedInterests.contains(interest))
                        _selectedInterests.remove(interest);
                      else
                        _selectedInterests.add(interest);
                    }),
                  ),
                )
                .toList(),
          ),
          _gap(20),
          if (shouldShowCouponFields) ...[
            _SectionLabel(
              'Coupon Configuration',
              icon: Icons.local_offer_outlined,
            ),
            _gap(6),
            _buildCouponFields(),
            _gap(20),
          ],
          _SectionLabel('Location', icon: Icons.location_on_outlined),
          _gap(6),
          TextField(
            controller: _cityController,
            style: _T.body,
            decoration: InputDecoration(
              hintText: 'Enter city name',
              hintStyle: TextStyle(color: _T.textHint),
              filled: true,
              fillColor: _T.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_T.r12),
                borderSide: BorderSide(color: _T.brand, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.search_rounded, color: _T.brand),
                onPressed: () => _goToCity(_cityController.text),
              ),
            ),
            onSubmitted: _goToCity,
          ),
          _gap(12),
          _buildMapCard(),
          _gap(16),
          _SectionLabel('App Type', icon: Icons.apps_rounded),
          _gap(6),
          Wrap(
            spacing: 8,
            children: _appTypeEnums
                .map(
                  (t) => _Pill(
                    _humanize(t),
                    selected: _appTypeValue == t,
                    onTap: () {
                      setState(() => _appTypeValue = t);
                      _calculateTotalBudget();
                    },
                  ),
                )
                .toList(),
          ),
          _gap(16),
          if (shouldShowTimeCategory) ...[
            _SectionLabel('Time Category', icon: Icons.timer_outlined),
            _gap(6),
            _SelectField(
              'Select Time Category',
              _timeCategoryEnums,
              _timeCategoryValue,
              (v) => setState(() => _timeCategoryValue = v),
              display: _humanize,
            ),
            _gap(16),
          ],
          _FieldBox(
            'Link (optional)',
            _deepLinkController,
            keyboardType: TextInputType.url,
            hint: 'https://yourwebsite.com',
          ),
          _gap(24),
          _primaryAndBackButtons(),
          _gap(32),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    bool isDiscountMenu = (_goalValue == "DISCOUNT" && _subGoalValue == "MENU");
    bool isCoupons = (_goalValue == "DISCOUNT" && _subGoalValue == "COUPONS");

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDiscountMenu) ...[_buildInvestmentCard(), _gap(20)],
          _SectionLabel(
            'Campaign Schedule',
            icon: Icons.calendar_today_outlined,
          ),
          _gap(6),
          _buildDateCard(),
          // 👇 Time pickers only for coupons
          if (isCoupons) ...[_gap(16), _buildCouponTimePicker()],
          _gap(24),
          _primaryAndBackButtons(),
          _gap(32),
        ],
      ),
    );
  }

  // ─── SUB COMPONENTS ───

  Widget _primaryAndBackButtons() {
    return Row(
      children: [
        Expanded(
          child: _OutlineButton(
            'Back',
            // leadingIcon: Icons.arrow_back_ios_new_rounded,
            onTap: _prevStep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrimaryButton(
            _currentStep == 3 ? 'Review & Pay' : 'Continue',
            // trailingIcon: Icons.arrow_forward_ios_rounded,
            onTap: _nextStep,
          ),
        ),
      ],
    );
  }

  Widget _buildSubGoalSelector() {
    List<Map<String, dynamic>> options = [];

    if (_goalValue == "BRANDING") {
      options = [
        {
          'value': 'BRAND_AWARENESS',
          'label': 'Brand Awareness',
          'icon': Icons.visibility_outlined,
        },
        {
          'value': 'BRAND_RECALL',
          'label': 'Brand Recall',
          'icon': Icons.psychology_outlined,
        },
        {
          'value': 'PREMIUM_POSTING',
          'label': 'Premium Posting',
          'icon': Icons.star_border_rounded,
        },
      ];
    } else if (_goalValue == "DISCOUNT") {
      options = [
        {
          'value': 'MENU',
          'label': 'Menu Discount',
          'icon': Icons.restaurant_menu_outlined,
        },
        {
          'value': 'COUPONS',
          'label': 'Coupons',
          'icon': Icons.local_offer_outlined,
        },
      ];
    } else if (_goalValue == "LEADS") {
      options = [
        {
          'value': 'GET_MORE_CALLS',
          'label': 'Get More Calls',
          'icon': Icons.call_outlined,
        },
        {
          'value': 'GET_MORE_WHATSAPP_MESSAGE',
          'label': 'WhatsApp Leads',
          'icon': Icons.chat_outlined,
        },
        {
          'value': 'GET_MORE_LEADS',
          'label': 'More Leads',
          'icon': Icons.leaderboard_outlined,
        },
        {
          'value': 'GET_MORE_WEBSITE_VISITORS',
          'label': 'Website Visitors',
          'icon': Icons.language_outlined,
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Sub Goal', icon: Icons.subdirectory_arrow_right_rounded),
        _gap(8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSelected = _subGoalValue == opt['value'];
            return GestureDetector(
              onTap: () => setState(() {
                _subGoalValue = opt['value'];
                _couponStartTime = null;
                _couponEndTime = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _T.brand : _T.surface,
                  borderRadius: BorderRadius.circular(_T.r16),
                  border: Border.all(
                    color: isSelected ? _T.brand : _T.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : _T.textSec,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      opt['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : _T.textSec,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _menuSelectionCard() {
    return GestureDetector(
      onTap: _openMenuSelection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r16),
          border: Border.all(
            color: _selectedMenuItems.isEmpty ? _T.border : _T.brand,
            width: _selectedMenuItems.isEmpty ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _T.brandSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: _T.brand,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Menu Items', style: _T.h3),
                  _gap(2),
                  Text(
                    _selectedMenuItems.isEmpty
                        ? 'Tap to select dishes for discount'
                        : '${_selectedMenuItems.length} items selected',
                    style: _T.caption.copyWith(
                      color: _selectedMenuItems.isEmpty
                          ? _T.textHint
                          : _T.success,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _T.brand, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponFields() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldBox(
            'Coupon Code',
            _couponCodeController,
            hint: 'e.g. SAVE20, WELCOME10',
          ),
          _gap(12),
          _SelectField(
            'Discount Type',
            ["PERCENTAGE", "FIXED_AMOUNT"],
            _discountTypeValue,
            (v) => setState(() => _discountTypeValue = v),
          ),
          _gap(12),
          _FieldBox(
            _discountTypeValue == "PERCENTAGE"
                ? 'Discount (%)'
                : 'Discount Amount (₹)',
            _discountController,
            keyboardType: TextInputType.number,
            hint: _discountTypeValue == "PERCENTAGE" ? 'e.g. 20' : 'e.g. 100',
          ),
          _gap(12),
          _SelectField(
            'Coupon Type',
            ["FLAT", "UPTO"],
            _couponTypeValue,
            (v) => setState(() => _couponTypeValue = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionDropdown() {
    final List<String> leadsCtaList = [
      "APPLY_NOW",
      "BOOK_NOW",
      "CONTACT_US",
      "SHOP_NOW",
      "GET_DIRECTIONS",
      "WATCH_MORE",
      "SEND_MESSAGE",
      "GET_QUOTE",
      "ENQUIRE_NOW",
    ];
    final List<String> brandingCtaList = _callToActionEnums
        .where((i) => i != "SIGN_UP")
        .toList();
    List<String> ctaList = _goalValue == "LEADS"
        ? leadsCtaList
        : (_goalValue == "BRANDING" ? brandingCtaList : _callToActionEnums);

    return _SelectField(
      'Call to Action',
      ctaList,
      _callToActionValue,
      (v) => setState(() => _callToActionValue = v),
      display: _humanize,
    );
  }

  Widget _mediaPicker() {
    return GestureDetector(
      onTap: _pickMedia,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _T.bg,
          borderRadius: BorderRadius.circular(_T.r16),
          border: Border.all(color: _T.border, width: 1.5),
        ),
        child: _selectedMediaType == 'image' && imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(_T.r16),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              )
            : _selectedMediaType == 'video' &&
                  videoController != null &&
                  videoController!.value.isInitialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(_T.r16),
                child: VideoPlayer(videoController!),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _T.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedMediaType == 'image'
                          ? Icons.add_photo_alternate_outlined
                          : Icons.video_call_outlined,
                      size: 28,
                      color: _T.brand,
                    ),
                  ),
                  _gap(10),
                  Text(
                    'Tap to upload ${_selectedMediaType == 'image' ? 'image' : 'video'}',
                    style: _T.body.copyWith(color: _T.textSec),
                  ),
                  _gap(4),
                  Text('Tap to browse your gallery', style: _T.caption),
                ],
              ),
      ),
    );
  }

  Widget _buildInvestmentCard() {
    bool isDigital = (_mediumValue == "DIGITAL");
    if (!isDigital && _baseBudget == 0.0) return const SizedBox.shrink();

    double minInvestment = _baseBudget;
    double maxInvestment = 1000000;
    double currentInvestment = _isBudgetIncreased
        ? _investmentAmount
        : _baseBudget;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: _T.brand),
              const SizedBox(width: 8),
              Text('Boost Your Campaign', style: _T.h3),
            ],
          ),
          _gap(4),
          Text('Increase investment to reach more people', style: _T.caption),
          _gap(16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _T.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _T.border),
                ),
                child: Text(
                  '₹',
                  style: _T.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _investmentController,
                  keyboardType: TextInputType.number,
                  style: _T.body,
                  decoration: InputDecoration(
                    hintText: 'Custom amount',
                    hintStyle: TextStyle(color: _T.textHint),
                    filled: true,
                    fillColor: _T.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_T.r12),
                      borderSide: BorderSide(color: _T.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_T.r12),
                      borderSide: BorderSide(color: _T.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_T.r12),
                      borderSide: BorderSide(color: _T.brand, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.check_rounded,
                        color: _T.brand,
                        size: 20,
                      ),
                      onPressed: () {
                        double customValue =
                            double.tryParse(_investmentController.text) ?? 0;
                        if (customValue >= minInvestment)
                          _updateBudgetAndIncrease(customValue);
                        else
                          _err(
                            'Investment must be at least ₹${minInvestment.toStringAsFixed(0)}',
                          );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          _gap(12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _T.brand,
              inactiveTrackColor: _T.border,
              thumbColor: _T.brand,
              overlayColor: _T.brand.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: currentInvestment.clamp(minInvestment, maxInvestment),
              min: minInvestment,
              max: maxInvestment,
              divisions: 100,
              onChanged: (value) {
                _investmentController.text = value.toStringAsFixed(0);
                _updateBudgetAndIncrease(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${minInvestment.toStringAsFixed(0)}', style: _T.caption),
              Text(
                '₹${currentInvestment.toStringAsFixed(0)}',
                style: _T.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _T.brand,
                ),
              ),
              Text('₹${maxInvestment.toStringAsFixed(0)}', style: _T.caption),
            ],
          ),
          _gap(14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _T.brandSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Reach',
                  style: _T.body.copyWith(color: _T.brand),
                ),
                Text(
                  '${_currentReach.toInt()} people',
                  style: _T.h3.copyWith(color: _T.brand),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r16),
        border: Border.all(color: _T.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                onMapCreated: (c) {
                  _mapController = c;
                  if (_currentPosition != null)
                    c.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _currentPosition!, zoom: 13),
                      ),
                    );
                  else
                    _getCurrentLocation();
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? const LatLng(17.3850, 78.4867),
                  zoom: 13,
                ),
                myLocationEnabled: true,
                circles: _circles,
              ),
            ),
          ),
          _gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target Radius', style: _T.h3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _T.brandSoft,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${_radiusKm.toStringAsFixed(1)} km',
                  style: _T.caption.copyWith(
                    color: _T.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _T.brand,
              inactiveTrackColor: _T.border,
              thumbColor: _T.brand,
              overlayColor: _T.brand.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: _radiusKm,
              min: 0,
              max: 100,
              onChanged: (v) {
                setState(() {
                  _radiusKm = v;
                  _updateCircle();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return _Card(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          _dateRow(
            'Start Date',
            _startDate,
            Icons.calendar_today_outlined,
            () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (_, child) => Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(primary: _T.brand),
                  ),
                  child: child!,
                ),
              );
              if (d != null) setState(() => _startDate = d);
            },
          ),
          _divider(),
          _dateRow('End Date', _endDate, Icons.event_outlined, () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: _startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (_, child) => Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(primary: _T.brand),
                ),
                child: child!,
              ),
            );
            if (d != null) setState(() => _endDate = d);
          }),
        ],
      ),
    );
  }

  Widget _dateRow(
    String label,
    DateTime? date,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: _T.brand, size: 20),
      title: Text(label, style: _T.caption),
      subtitle: Text(
        date == null ? 'Tap to select' : DateFormat('dd MMM yyyy').format(date),
        style: _T.body.copyWith(
          fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
          color: date != null ? _T.textPri : _T.textHint,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: _T.textHint, size: 20),
    );
  }

  // ─── STEP INDICATOR ───

  Widget _stepIndicator(int step, String label) {
    bool isActive = _currentStep + 1 >= step;
    bool isCompleted = _currentStep + 1 > step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? _T.brand : _T.bg,
            border: Border.all(
              color: isActive ? _T.brand : _T.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : _T.textHint,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        _gap(5),
        Text(
          label,
          style: _T.caption.copyWith(
            color: isActive ? _T.brand : _T.textHint,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _stepConnector(int step) {
    bool isActive = _currentStep + 1 > step;
    return Expanded(
      child: Container(
        height: 1.5,
        color: isActive ? _T.brand : _T.border,
        margin: const EdgeInsets.only(bottom: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _T.textPri,
            size: 20,
          ),
          onPressed: _prevStep,
        ),
        title: Text('Create Promotion', style: _T.h2),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(78),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _stepIndicator(1, 'Goal'),
                    _stepConnector(1),
                    _stepIndicator(2, 'Media'),
                    _stepConnector(2),
                    _stepIndicator(3, 'Targeting'),
                    _stepConnector(3),
                    _stepIndicator(4, 'Budget'),
                  ],
                ),
                _gap(10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    minHeight: 3,
                    backgroundColor: _T.border,
                    color: _T.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4()],
      ),
    );
  }
}
