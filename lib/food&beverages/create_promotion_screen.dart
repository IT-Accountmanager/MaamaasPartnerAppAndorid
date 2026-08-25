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
import '../../API/Apiclient.dart';
import '../../API/Promotion_authservice.dart';
import '../Api/Promotion_services.dart';
import '../Models/food&beverages/CampaignRequest.dart';

// ========== EMPTY SCREEN ==========
class EmptyScreen extends StatelessWidget {
  const EmptyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discarded'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: const Center(
        child: Text(
          'This is an empty screen.\nYour promotion creation was discarded.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ========== CAMPAIGN DETAIL SCREEN ==========
class CampaignDetailScreen extends StatelessWidget {
  final CampaignRequest campaign;

  const CampaignDetailScreen({Key? key, required this.campaign})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.campaignName),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campaign.imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      campaign.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _buildSection('Campaign Info', [
                _buildDetailRow(Icons.title, 'Name', campaign.campaignName),
                _buildDetailRow(
                  Icons.description,
                  'Description',
                  campaign.description ?? 'N/A',
                ),
                _buildDetailRow(Icons.flag, 'Goal', campaign.goal),
                _buildDetailRow(Icons.devices, 'Medium', campaign.medium),
              ]),
              const SizedBox(height: 16),
              _buildSection('Schedule', [
                _buildDetailRow(
                  Icons.calendar_today,
                  'Start Date',
                  _formatDate(campaign.startDate),
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  'End Date',
                  _formatDate(campaign.endDate),
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Created At',
                  _formatDate(campaign.createdAt),
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('Status & Payment', [
                _buildDetailRow(
                  Icons.payment,
                  'Payment Status',
                  campaign.paymentStatus ?? 'PENDING',
                ),
                _buildDetailRow(
                  Icons.money,
                  'Total Budget',
                  campaign.totalBudget?.toString() ?? 'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('Location', [
                _buildDetailRow(
                  Icons.location_city,
                  'City',
                  campaign.city ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.pin_drop,
                  'Center Latitude',
                  campaign.centerLatitude?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.pin_drop,
                  'Center Longitude',
                  campaign.centerLongitude?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.radar,
                  'Radius (km)',
                  campaign.radiusKm?.toString() ?? 'N/A',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('Interests', [
                _buildDetailRow(
                  Icons.interests,
                  'Interests',
                  campaign.interests?.join(', ') ?? 'None',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSection('Additional Info', [
                _buildDetailRow(
                  Icons.screen_rotation,
                  'Add Display Position      ',
                  campaign.addDisplayPosition ?? 'Not Specified',
                ),
                _buildDetailRow(
                  Icons.high_quality,
                  'Resolution',
                  campaign.resolution ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.link,
                  'Deep Link',
                  campaign.deepLink ?? 'N/A',
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepOrange),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}

// ========== CAMPAIGN LIST SCREEN WITH FULL PAYMENT FLOW ==========
class CampaignListScreen extends StatefulWidget {
  final List<CampaignRequest> campaigns;

  const CampaignListScreen({Key? key, required this.campaigns})
    : super(key: key);

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  late Razorpay _razorpay;
  final Set<int?> _payingCampaignIds = {};
  final _storage = const FlutterSecureStorage();

  final Map<String, Map<String, dynamic>> _paymentContext = {};

  static const String _paymentMethod = 'Online_Payment';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    debugPrint('🚀 Razorpay initialized');
  }

  @override
  void dispose() {
    _razorpay.clear();
    debugPrint('🧹 Razorpay disposed');
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('✅✅✅ PAYMENT SUCCESS EVENT RECEIVED');
    debugPrint('   paymentId: ${response.paymentId}');
    debugPrint('   orderId: ${response.orderId}');
    debugPrint('   signature: ${response.signature}');

    final orderId = response.orderId;
    if (orderId == null) {
      debugPrint('❌❌❌ No orderId in response – cannot proceed');
      _showError('Payment succeeded but order ID missing');
      return;
    }

    final contextData = _paymentContext[orderId];
    if (contextData == null) {
      debugPrint('❌❌❌ No payment context found for orderId: $orderId');
      debugPrint('   Available contexts: ${_paymentContext.keys}');
      _showError('Payment succeeded but campaign details missing');
      return;
    }

    final campaignId = contextData['campaignId'] as int;
    final customerId = contextData['customerId'] as String;
    final amount = contextData['amount'] as double;
    final paymentId = response.paymentId!;
    debugPrint(
      '📦 Context retrieved: campaignId=$campaignId, customerId=$customerId, amount=$amount',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording payment...'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      debugPrint('💰 Attempting to capture payment...');
      final captured = await _capturePayment(paymentId, amount);
      if (!captured) {
        debugPrint('⚠️ Capture failed, but continuing to record payment');
      } else {
        debugPrint('✅ Capture successful');
      }

      debugPrint('📝 Creating payment record via api/user/paymenets...');
      final recorded = await _createPaymentRecord(
        campaignId: campaignId,
        customerId: customerId,
        amount: amount,
        transactionId: paymentId,
        paymentMethod: _paymentMethod,
      );

      if (recorded) {
        debugPrint('✅✅✅ Payment record created successfully');
        _showSuccess('Payment recorded successfully');
      } else {
        debugPrint('❌❌❌ Payment record creation FAILED');
        _showError(
          'Payment succeeded but failed to record. Please contact support.',
        );
      }
    } catch (e, stack) {
      debugPrint('🔥🔥🔥 Post-payment exception: $e');
      debugPrint('Stack trace: $stack');
      _showError('Payment succeeded but post-processing failed: $e');
    } finally {
      _paymentContext.remove(orderId);
      debugPrint('🧹 Removed payment context for orderId: $orderId');
      setState(() {
        _payingCampaignIds.remove(campaignId);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌❌❌ PAYMENT ERROR EVENT');
    debugPrint('   code: ${response.code}');
    debugPrint('   message: ${response.message}');
    _showError('Payment failed: ${response.message}');
    setState(() {
      _payingCampaignIds.clear();
    });
    _paymentContext.clear();
    debugPrint('🧹 Cleared all payment contexts due to error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('🔁 External wallet selected: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Processing with ${response.walletName}...')),
    );
  }

  Future<String?> _createOrder(double amount) async {
    debugPrint('📤 Creating order for amount: ₹$amount');
    try {
      const endpoint = "/api/payments/create-order/user";
      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };
      debugPrint('   Request body: $body');
      final res = await ApiClient.post(endpoint, body, service: "promotion");
      debugPrint(
        '📥 CreateOrder Response: status=${res.statusCode}, body=${res.body}',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final orderId = data["orderId"] ?? data["id"];
        debugPrint('✅ Order created successfully, orderId: $orderId');
        return orderId;
      }
      debugPrint('❌ Order creation failed: ${res.body}');
      return null;
    } catch (e, stack) {
      debugPrint('⚠️ Exception in createOrder: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  Future<bool> _capturePayment(String paymentId, double amount) async {
    debugPrint('💰 Capturing payment: paymentId=$paymentId, amount=$amount');
    try {
      const endpoint = "api/payments/capture";
      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for campaign payment",
      };
      debugPrint('   Request body: $body');
      final res = await ApiClient.post(endpoint, body, service: "promotion");
      debugPrint(
        '📥 Capture Response: status=${res.statusCode}, body=${res.body}',
      );
      return res.statusCode == 200;
    } catch (e, stack) {
      debugPrint('❌ Capture API Exception: $e');
      debugPrint('Stack: $stack');
      return false;
    }
  }

  Future<bool> _createPaymentRecord({
    required int campaignId,
    required String customerId,
    required double amount,
    required String transactionId,
    required String paymentMethod,
  }) async {
    debugPrint('📝 Creating payment record for campaign $campaignId');
    try {
      const endpoint = "api/user/paymenets";
      final body = {
        "campaignId": campaignId,
        "customerId": customerId,
        "amount": amount,
        "paymentMethod": paymentMethod,
        "transactionId": transactionId,
        "paymentStatus": "PAID",
        "paymentDate": DateTime.now().toIso8601String(),
      };
      debugPrint('   Request body: $body');
      final res = await ApiClient.post(endpoint, body, service: "promotion");
      debugPrint(
        '📥 Payment Record Response: status=${res.statusCode}, body=${res.body}',
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e, stack) {
      debugPrint('❌ Payment record creation exception: $e');
      debugPrint('Stack: $stack');
      return false;
    }
  }

  Future<void> _startPayment(CampaignRequest campaign) async {
    final campaignId = campaign.id;

    if (campaignId == null) {
      debugPrint(
        '❌ Campaign ID missing for campaign: ${campaign.campaignName}',
      );
      _showError('Campaign ID missing');
      return;
    }

    debugPrint(
      '🚀 Starting payment for campaign: ${campaign.campaignName} (id=$campaignId)',
    );

    setState(() {
      _payingCampaignIds.add(campaignId);
    });

    try {
      final amount = campaign.totalBudget ?? 0.0;

      if (amount <= 0) {
        debugPrint('❌ Invalid amount: $amount');
        _showError('Invalid amount');
        return;
      }

      debugPrint('💰 Amount: ₹$amount');

      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString('customerId');

      if (customerId == null || customerId.isEmpty) {
        debugPrint('❌ Customer ID not found in SharedPreferences');
        _showError('Customer ID not found');
        return;
      }

      debugPrint('👤 Customer ID: $customerId');

      final orderId = await _createOrder(amount);

      if (orderId == null) {
        _showError('Failed to create order');
        return;
      }

      _paymentContext[orderId] = {
        'campaignId': campaignId,
        'customerId': customerId,
        'amount': amount,
      };

      debugPrint('📦 Stored payment context for orderId: $orderId');

      var options = {
        'key': 'rzp_live_TJDvykibQEsCuN',
        'amount': (amount * 100).toInt(),
        'name': 'Maamaas App',
        'description': 'Campaign Payment',
        'order_id': orderId,
        'prefill': {'contact': '9999999999', 'email': 'customer@email.com'},
        'currency': 'INR',
      };

      debugPrint('🔧 Razorpay Options: $options');

      _razorpay.open(options);

      debugPrint('✅ Razorpay checkout opened');
    } catch (e, stack) {
      debugPrint('🔥🔥🔥 Payment start error: $e');
      debugPrint('Stack: $stack');

      _showError('Error: $e');

      setState(() {
        _payingCampaignIds.remove(campaignId);
      });
    }
  }

  void _showError(String message) {
    debugPrint('❌ Snackbar error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    debugPrint('✅ Snackbar success: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Campaigns'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('🔙 Navigate back from campaign list');
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Colors.white],
          ),
        ),
        child: widget.campaigns.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign,
                      size: 80,
                      color: Colors.deepOrange.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No campaigns found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create one by going back',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = widget.campaigns[index];
                  return _buildCampaignCard(context, campaign);
                },
              ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, CampaignRequest campaign) {
    final isPaid = campaign.paymentStatus == 'PAID';
    final isPaying = _payingCampaignIds.contains(campaign.id);

    debugPrint(
      '📇 Building card for campaign ${campaign.id}: ${campaign.campaignName}, isPaid=$isPaid, isPaying=$isPaying',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isPaid ? Colors.green.shade50 : Colors.orange.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          debugPrint(
            '👆 Tapped campaign: ${campaign.campaignName} (id=${campaign.id})',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaign: campaign),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: campaign.imageUrl != null
                        ? Image.network(
                            campaign.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              debugPrint(
                                '⚠️ Failed to load image for campaign ${campaign.id}',
                              );
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.deepOrange,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              color: Colors.deepOrange,
                              size: 40,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.campaignName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${campaign.goal} • ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                campaign.city ?? 'No city',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Start: ${_formatDate(campaign.startDate)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'End: ${_formatDate(campaign.endDate)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      campaign.paymentStatus ?? 'PENDING',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!isPaid)
                    isPaying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.deepOrange,
                              strokeWidth: 2,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              debugPrint(
                                '💰 Pay Now tapped for campaign ${campaign.id}',
                              );
                              _startPayment(campaign);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Pay Now'),
                          ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}

// ========== MAIN PROMOTION CREATION SCREEN ==========
class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  int currentStep = 0;

  List<CampaignRequest> _campaigns = [];

  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _deepLinkController = TextEditingController();
  // 👇 Resolution controller removed

  String? _goalValue;
  String? _mediumValue;
  String? _addDisplayPositionValue;

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

  DateTime? _startDate;
  DateTime? _endDate;

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _locationLoaded = false;
  double _radiusKm = 10.0;
  Set<Circle> _circles = {};

  // Media
  File? imageFile;
  File? videoFile;
  VideoPlayerController? videoController;
  final ImagePicker picker = ImagePicker();
  String? _selectedMediaType = 'image'; // 'image' or 'video'

  final _storage = const FlutterSecureStorage();

  String _displayInterest(String enumValue) {
    return enumValue
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _displayPosition(String enumValue) {
    return enumValue
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserCampaigns();
    });
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _deepLinkController.dispose();
    videoController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCampaigns() async {
    debugPrint('🚀 _fetchUserCampaigns() STARTED');
    try {
      final campaigns = await PromotionAuthService.fetchUserCampaigns();
      setState(() {
        _campaigns = campaigns;
      });
      if (campaigns.isEmpty) {
        _showErrorSnackBar('No campaigns found');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${campaigns.length} campaigns'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
    debugPrint('🚀 _fetchUserCampaigns() FINISHED');
  }

  // Unified media picker based on selected type
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
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar('Please enable location services');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar('Location permissions are permanently denied');
      return;
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
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      List<Location> locations = await locationFromAddress(cityName);
      Navigator.pop(context);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentPosition = newPosition;
          _locationLoaded = true;
          _updateCircle();
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 13),
          ),
        );
      } else {
        _showErrorSnackBar('City "$cityName" not found');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Error finding city: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _updateCircle() {
    if (_currentPosition == null) return;
    setState(() {
      if (_radiusKm > 0) {
        _circles = {
          Circle(
            circleId: const CircleId('target_radius'),
            center: _currentPosition!,
            radius: _radiusKm * 1000,
            fillColor: Colors.deepOrange.withOpacity(0.2),
            strokeColor: Colors.deepOrange,
            strokeWidth: 2,
          ),
        };
      } else {
        _circles = {};
      }
    });
  }

  // 👇 Helper to get resolution enum from dimensions
  String? _getResolutionFromDimensions(int width, int height) {
    // Check for 720p (720x1280)
    if (width == 720 && height == 1280) return 'R_720P';
    // Check for 1080p (1080x1350)
    if (width == 1080 && height == 1350) return 'R_1080P';
    // Check for 4K (3840x2160)
    if (width == 3840 && height == 2160) return 'R_4K';
    return null;
  }

  // 👇 Validate media dimensions and return resolution
  Future<String?> _validateMediaAndGetResolution() async {
    if (_selectedMediaType == 'image' && imageFile != null) {
      try {
        final bytes = await imageFile!.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final width = frame.image.width;
        final height = frame.image.height;

        final resolution = _getResolutionFromDimensions(width, height);
        if (resolution == null) {
          _showErrorSnackBar(
            'Image dimensions ($width x $height) are not supported. Please use 720x1280, 1080x1350, or 3840x2160.',
          );
        }
        return resolution;
      } catch (e) {
        _showErrorSnackBar('Error reading image dimensions: $e');
        return null;
      }
    } else if (_selectedMediaType == 'video' &&
        videoController != null &&
        videoController!.value.isInitialized) {
      final width = videoController!.value.size.width.toInt();
      final height = videoController!.value.size.height.toInt();

      final resolution = _getResolutionFromDimensions(width, height);
      if (resolution == null) {
        _showErrorSnackBar(
          'Video dimensions ($width x $height) are not supported. Please use 720x1280, 1080x1350, or 3840x2160.',
        );
      }
      return resolution;
    }
    return null;
  }

  Future<void> _submitPromotion() async {
    debugPrint('🚀 _submitPromotion() called');

    if (_campaignNameController.text.isEmpty) {
      _showErrorSnackBar('Campaign name is required');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showErrorSnackBar('Description is required');
      return;
    }

    if (_goalValue == null ||
        _mediumValue == null ||
        _selectedInterests.isEmpty ||
        _cityController.text.isEmpty ||
        _currentPosition == null ||
        _startDate == null ||
        _endDate == null ||
        _addDisplayPositionValue == null ||
        (imageFile == null && videoFile == null)) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showErrorSnackBar('End date must be after start date');
      return;
    }

    // 👇 Validate media dimensions and get resolution
    final resolution = await _validateMediaAndGetResolution();
    if (resolution == null) {
      return; // error already shown
    }

    final campaignData = {
      'campaignName': _campaignNameController.text,
      'description': _descriptionController.text,
      'goal': _goalValue,
      'medium': _mediumValue,
      'mediaType': _selectedMediaType == 'image'
          ? 'IMAGE'
          : 'VIDEO', // 👈 never null
      'resolution': resolution, // 👈 auto-detected from dimensions
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'city': _cityController.text,
      'centerLatitude': _currentPosition!.latitude,
      'centerLongitude': _currentPosition!.longitude,
      'radiusKm': _radiusKm,
      'interests': _selectedInterests,
      'addDisplayPosition': _addDisplayPositionValue,
      'deepLink': _deepLinkController.text,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await PromotionAuthService.createPromotion(
        campaignData: campaignData,
        imageFile: imageFile,
        videoFile: videoFile,
      );

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promotion created successfully!')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepOrange,
        title: const Text(
          "Create Promotion",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              debugPrint(
                '🔚 Discard icon tapped – navigating to CampaignListScreen with ${_campaigns.length} campaigns',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CampaignListScreen(campaigns: _campaigns),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentStep == 0 ? _stepOne() : _stepTwo(),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _stepOne() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _dropdown(
            "Goal",
            ["BRANDING", "DISCOUNT", "LEADS", "EVENTS", "SPONSORSHIP"],
            _goalValue,
            (val) => setState(() => _goalValue = val),
          ),
          _dropdown(
            "Medium",
            ["APP", "DIGITAL", "PHYSICAL"],
            _mediumValue,
            (val) => setState(() => _mediumValue = val),
          ),
          _dropdownWithDisplay(
            label: "Add Display Position",
            items: [
              "ADD_SCREEN",
              "HOMEPAGE_BANNER",
              "PRODUCT_PAGE",
              "CHECKOUT_PAGE",
              "IN_APP_POPUP",
            ],
            selectedValue: _addDisplayPositionValue,
            onChanged: (val) => setState(() => _addDisplayPositionValue = val),
            displayFunction: _displayPosition,
          ),
          // 👇 Resolution text field REMOVED
          _textFieldWithController("Campaign Name", _campaignNameController),
          _textFieldWithController(
            "Description",
            _descriptionController,
            maxLines: 3,
          ),
          _textFieldWithController(
            "Deep Link (optional)",
            _deepLinkController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _dateCard(),
          const SizedBox(height: 24),
          _sectionHeader("Campaign Media", Icons.photo_library),
          const SizedBox(height: 12),

          // Radio buttons for media type selection
          Row(
            children: [
              const SizedBox(width: 16),
              Row(
                children: [
                  Radio<String>(
                    value: 'image',
                    groupValue: _selectedMediaType,
                    onChanged: (value) {
                      setState(() {
                        _selectedMediaType = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  const Text('Image'),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Radio<String>(
                    value: 'video',
                    groupValue: _selectedMediaType,
                    onChanged: (value) {
                      setState(() {
                        _selectedMediaType = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  const Text('Video'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 👇 Note about supported resolutions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Supported resolutions:\n• 720p: 720×1280\n• 1080p: 1080×1350\n• 4K: 3840×2160',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Single media box
          GestureDetector(
            onTap: _pickMedia,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMediaPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedMediaType == 'image' && imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(imageFile!, fit: BoxFit.cover),
      );
    } else if (_selectedMediaType == 'video' &&
        videoController != null &&
        videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: videoController!.value.aspectRatio,
              child: VideoPlayer(videoController!),
            ),
            Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedMediaType == 'image' ? Icons.image : Icons.videocam,
              size: 48,
              color: Colors.deepOrange.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload $_selectedMediaType',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  Widget _stepTwo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Audience & Location", Icons.people),
          const SizedBox(height: 12),

          const Text(
            "Interests",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableInterests.map((enumValue) {
              final isSelected = _selectedInterests.contains(enumValue);
              return FilterChip(
                label: Text(_displayInterest(enumValue)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(enumValue);
                    } else {
                      _selectedInterests.remove(enumValue);
                    }
                  });
                },
                selectedColor: Colors.deepOrange.withOpacity(0.2),
                checkmarkColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepOrange : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepOrange),
                  onPressed: () => _goToCity(_cityController.text),
                ),
              ),
              onSubmitted: _goToCity,
            ),
          ),

          _radiusCard(),
        ],
      ),
    );
  }

  // ---------- Reusable widgets ----------
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepOrange, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _textFieldWithController(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdownWithDisplay({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required String Function(String) displayFunction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: items.map((e) {
          return DropdownMenuItem(value: e, child: Text(displayFunction(e)));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _radiusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: _currentPosition!, zoom: 13),
                        ),
                      );
                      _updateCircle();
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? const LatLng(17.3850, 78.4867),
                    zoom: 13,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  circles: _circles,
                ),
              ),
              if (!_locationLoaded)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Target Radius",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_radiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _radiusKm,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: Colors.deepOrange,
            onChanged: (value) {
              setState(() {
                _radiusKm = value;
                _updateCircle();
              });
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_currentPosition == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location not available yet')),
                  );
                  return;
                }
                final result = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullMapScreen(
                      initialRadius: _radiusKm,
                      center: _currentPosition!,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _radiusKm = result;
                    _updateCircle();
                  });
                }
              },
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              label: const Text('Show Full Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              _startDate == null
                  ? "Start Date"
                  : "Start: ${DateFormat('dd MMM yyyy').format(_startDate!)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              _endDate == null
                  ? "End Date"
                  : "End: ${DateFormat('dd MMM yyyy').format(_endDate!)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep == 1)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => currentStep = 0);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(color: Colors.deepOrange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Previous"),
                ),
              ),
            if (currentStep == 1) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (currentStep == 0) {
                    setState(() => currentStep = 1);
                  } else {
                    _submitPromotion();
                  }
                },
                child: Text(currentStep == 0 ? "Next" : "Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Full Map Screen ----------
class FullMapScreen extends StatefulWidget {
  final double initialRadius;
  final LatLng center;

  const FullMapScreen({
    Key? key,
    required this.initialRadius,
    required this.center,
  }) : super(key: key);

  @override
  _FullMapScreenState createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  late double _radiusKm;
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.initialRadius;
    _updateCircle();
  }

  void _updateCircle() {
    setState(() {
      if (_radiusKm > 0) {
        _circles = {
          Circle(
            circleId: const CircleId('target_radius'),
            center: widget.center,
            radius: _radiusKm * 1000,
            fillColor: Colors.deepOrange.withOpacity(0.2),
            strokeColor: Colors.deepOrange,
            strokeWidth: 2,
          ),
        };
      } else {
        _circles = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Target Radius'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.center,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Radius',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_radiusKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _radiusKm,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: Colors.deepOrange,
                      onChanged: (value) {
                        setState(() {
                          _radiusKm = value;
                          _updateCircle();
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _radiusKm);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
