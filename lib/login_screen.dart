import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maamaaspartner/API/Authservice.dart';
import 'package:maamaaspartner/widgets_helper/BookDemoScreen.dart';
import 'package:maamaaspartner/widgets_helper/ForgotPasswordScreen.dart';
import 'package:maamaaspartner/widgets_helper/Home_screen_1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API/Apiclient.dart';
import 'Api/notifcation_authservice.dart';
import 'SUB01/screens/main_screen.dart';

class _L {
  static const bg = Color(0xFFFBF9FF);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEECF5);
  static const primary = Color(0xFF2A0947);
  static const accent = Color(0xFFB15DC6);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const gold = Color(0xFFFBF9FF);
  static const goldLight = Color(0xFFFFF8E1);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const text1 = Color(0xFF1A0A2E);
  static const text2 = Color(0xFF6B5E7A);
  static const text3 = Color(0xFFB0A3C0);
  static const shadow = Color(0x0D000000);
  static const shadowMd = Color(0x1A000000);

  static const gradientColors = [
    Color(0xFFE66D33),
    Color(0xFFE66D33),
    Color(0xFFE66D33),
  ];
  static LinearGradient get gradient => const LinearGradient(
    colors: [Color(0xFFE66D33), Color(0xFFE66D33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── LoginPage1 ───────────────────────────────────────────────────────────────
class LoginPage1 extends StatefulWidget {
  const LoginPage1({super.key});
  @override
  State<LoginPage1> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage1> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _referralCodeController = TextEditingController(); // ← NEW

  bool _obscurePassword = true;
  bool _obscureSignIn = true;
  bool _isLoading = false;
  AnimationController? _heroAnim;
  Animation<double>? _heroFade;
  bool _isCTASectionOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _heroAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
      _heroFade = CurvedAnimation(parent: _heroAnim!, curve: Curves.easeOut);
      _heroAnim!.forward();
      if (mounted) setState(() {});
    });
  }

  void _showCTASection() {
    setState(() {
      _isCTASectionOpen = true;
    });
  }

  void _closeCTASection() {
    setState(() {
      _isCTASectionOpen = false;
    });
  }

  void _showSignInSheetFromCTA() {
    _showSignInSheet();
  }

  @override
  void dispose() {
    _heroAnim?.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _referralCodeController.dispose(); // ← NEW
    super.dispose();
  }

  // ── API ──────────────────────────────────────────────────────────────────────
  Future<bool> _submitDemoEnquiry(BuildContext ctx) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _mobileController.text.trim();
    final city = _cityController.text.trim();
    final referralCode = _referralCodeController.text.trim(); // ← NEW

    if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
      _snack(ctx, 'Please fill all fields', _L.gold);
      return false;
    }

    final body = {
      "name": name,
      "email": email,
      "mobileNumber": phone,
      "vendorId": null,
      "city": city,
      "parentId": null,
      "companyName": null,
      "username": null,
      "password": null,
      "enabled": true,
      "role": "ROLE_VENDOR",
      "businessVerticals": ["FOOD_AND_BEVERAGES"],
      "registerTime": DateTime.now().toUtc().toIso8601String(),
      "employeRole": null,
      "businessModules": [],
      "accountNonLocked": true,
      "credentialsNonExpired": true,
      "accountNonExpired": true,
      // ── NEW ──
      "referralCodeUsed": referralCode.isEmpty
          ? null
          : referralCode.toUpperCase(),
    };

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        'api/vendor/enquiry',
        body,
        service: 'subscription',
      );

      debugPrint("📨 Enquiry status: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("vendorId", data["vendorId"] ?? 0);

        _snack(ctx, 'Enquiry submitted successfully!', _L.green);

        _nameController.clear();
        _emailController.clear();
        _mobileController.clear();
        _cityController.clear();
        _referralCodeController.clear(); // ← NEW

        return true;
      } else {
        _snack(ctx, 'Submission failed. Try again.', Colors.red);
        return false;
      }
    } catch (e) {
      _snack(ctx, 'Network error: $e', Colors.red);
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _snack(context, 'Please enter all fields', _L.gold);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE66D33)),
                ),
                SizedBox(height: 16),
                Text(
                  'Signing in...',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await Authservice.login(
      identifier: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    Navigator.of(context).pop();

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE66D33),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Logging into your account...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // final fcmToken = await FirebaseMessaging.instance.getToken();
      // if (fcmToken != null && fcmToken.isNotEmpty) {
      //   await Notification_authService.registerFcmToken(fcmToken);
      // }
      //
      // await _updateCurrentLocation(result['data']);

      debugPrint('🔥 STEP 1: Login successful');

      debugPrint('🔥 STEP 2: Getting FCM token...');
      final fcmToken = await FirebaseMessaging.instance.getToken();

      debugPrint('🔥 STEP 3: FCM getToken completed');
      debugPrint('🔥 FCM token is null: ${fcmToken == null}');
      debugPrint('🔥 FCM token length: ${fcmToken?.length ?? 0}');

      if (fcmToken != null && fcmToken.isNotEmpty) {
        debugPrint('🔥 STEP 4: Calling registerFcmToken()');

        await Notification_authService.registerFcmToken(fcmToken);

        debugPrint('🔥 STEP 5: registerFcmToken() completed');
      } else {
        debugPrint('❌ STEP 4: FCM token is NULL or EMPTY');
      }

      debugPrint('🔥 STEP 6: Updating location...');
      await _updateCurrentLocation(result['data']);

      debugPrint('🔥 STEP 7: Location update completed');

      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeWrapper()),
      );
    } else {
      _snack(context, result['message'], Colors.red);
    }
  }

  Future<void> _updateCurrentLocation(Map<String, dynamic> loginData) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("📍 Location services disabled — skipping location update");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("📍 Location permission denied — skipping location update");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String address = '';
      String city = '';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street ?? ''}, ${place.subLocality ?? ''}'
              .trim()
              .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          city = place.locality ?? place.administrativeArea ?? '';
        }
      } catch (e) {
        debugPrint("📍 Reverse geocode failed: $e");
      }

      final String customerId = loginData['customerId'] ?? '';

      final payload = {
        "customerId": customerId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address,
        "city": city,
      };

      debugPrint("📍 Sending location update → $payload");

      final response = await ApiClient.post(
        'api/user/curret/location/update',
        payload,
        service: 'subscription',
      );

      debugPrint(
        "📍 Location update response → ${response.statusCode}: ${response.body}",
      );
    } catch (e) {
      debugPrint("⚠️ Location update failed: $e");
    }
  }

  void _openForgotPassword(BuildContext sheetCtx) {
    Navigator.pop(sheetCtx);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _L.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHero(),
                      _buildStatsStrip(),
                      _buildWhatWeOfferSection(),
                      _buildFeaturesGrid(),
                      _buildHowItWorksSection(),
                      _buildIndustriesSection(),
                      _buildServicesSection(),
                      _buildContactSection(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_isCTASectionOpen)
            CTASection(
              isOpen: _isCTASectionOpen,
              onClose: _closeCTASection,
              onLoginClick: _showSignInSheetFromCTA,
              parentContext: context,
            ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _L.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _L.accent.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "MAAMAA'S",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showSignInSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _L.gold,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _L.gold.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color(0xFF2A0947),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return FadeTransition(
      opacity: _heroFade ?? const AlwaysStoppedAnimation(1.0),
      child: SizedBox(
        height: 320,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/imagebanner.webp', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      _L.primary.withOpacity(0.85),
                      _L.accent.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _L.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _L.gold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _L.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Trusted by 1000+ vendors',
                          style: TextStyle(
                            color: _L.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PARTNER WITH MAAMAAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fast Delivery · Best Discounts · 100% Secure',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showCTASection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: _L.gradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _L.accent.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Book a Demo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showSignInSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
    );
  }

  // ── Stats Strip ───────────────────────────────────────────────────────────────
  Widget _buildStatsStrip() {
    final stats = [
      {'label': '1000+', 'sub': 'Vendors'},
      {'label': '0%', 'sub': 'Commission'},
      {'label': '24/7', 'sub': 'Support'},
      {'label': '5 min', 'sub': 'Setup'},
    ];
    return Container(
      color: _L.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (s) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s['label']!,
                    style: const TextStyle(
                      color: _L.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    s['sub']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // ── What We Offer ─────────────────────────────────────────────────────────────
  Widget _buildWhatWeOfferSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      color: _L.white,
      child: Column(
        children: [
          _sectionLabel('PLATFORM'),
          const SizedBox(height: 8),
          const Text(
            'What Maamaas Brings\nto Your Business',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _L.text1,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Transform your business with powerful digital solutions designed to elevate your brand and deliver measurable growth.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: _L.text2, height: 1.6),
          ),
          const SizedBox(height: 32),
          _buildThreeCards(),
        ],
      ),
    );
  }

  Widget _buildThreeCards() {
    final cards = [
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Higher Profit',
        'desc':
            'Zero commission model. One flat yearly subscription. Keep every rupee you earn.',
        'color': _L.green,
      },
      {
        'icon': Icons.devices_rounded,
        'title': 'Smarter Growth',
        'desc':
            'Real-time analytics and data insights help you plan your next move with confidence.',
        'color': _L.accent,
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Digital Identity',
        'desc':
            'Professional storefront. No website needed. No app building. Ready from Day 1.',
        'color': _L.gold,
      },
    ];

    return Column(
      children: cards.map((c) {
        final color = c['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _L.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _L.border),
            boxShadow: [
              BoxShadow(
                color: _L.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _L.text1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['desc'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _L.text2,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Features Grid ─────────────────────────────────────────────────────────────
  Widget _buildFeaturesGrid() {
    final features = [
      {
        'n': '1',
        'title': 'Trusted Digital Presence',
        'icon': Icons.verified_rounded,
        'desc':
            'Compete with big brands without heavy investment. Your own digital storefront, ready on day 1.',
      },
      {
        'n': '2',
        'title': "Your Revenue, Your Rules",
        'icon': Icons.account_balance_wallet_rounded,
        'desc':
            'Zero commission. Flat yearly plan. Your hard work stays yours.',
      },
      {
        'n': '3',
        'title': 'Clear & Cost-Effective',
        'icon': Icons.paid_rounded,
        'desc':
            'No complicated charges, no fluctuating costs. One subscription, complete control.',
      },
      {
        'n': '4',
        'title': 'Digital Billing',
        'icon': Icons.receipt_long_rounded,
        'desc':
            'Paperless billing, live payments, and accurate records — all automated.',
      },
      {
        'n': '5',
        'title': 'Instant Order Alerts',
        'icon': Icons.notifications_active_rounded,
        'desc':
            'Never miss an order. Get alerts online or offline for every customer moment.',
      },
      {
        'n': '6',
        'title': 'Real Reviews & Reputation',
        'icon': Icons.star_rate_rounded,
        'desc':
            'Positive reviews build trust, boost visibility, and drive more customers to you.',
      },
      {
        'n': '7',
        'title': 'Business Analytics',
        'icon': Icons.bar_chart_rounded,
        'desc':
            'Understand behavior, track KPIs, and make confident decisions with real-time data.',
      },
      {
        'n': '8',
        'title': 'Secure Payments',
        'icon': Icons.lock_rounded,
        'desc':
            'UPI, cards, wallets, net banking — every transaction is fast and fully secure.',
      },
      {
        'n': '9',
        'title': 'Multi-User Access',
        'icon': Icons.group_rounded,
        'desc':
            'Assign tasks, monitor performance, and control your team from one dashboard.',
      },
      {
        'n': '10',
        'title': 'Customer Loyalty Tools',
        'icon': Icons.loyalty_rounded,
        'desc':
            'Personalized engagement and seamless experiences that keep customers coming back.',
      },
      {
        'n': '11',
        'title': 'Marketing Boost',
        'icon': Icons.campaign_rounded,
        'desc': 'Get noticed locally. More customers, less marketing spend.',
      },
      {
        'n': '12',
        'title': 'No Hardware Needed',
        'icon': Icons.cloud_done_rounded,
        'desc': 'Run your entire business from any device, anywhere, anytime.',
      },
    ];

    return Container(
      color: _L.bg,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        children: [
          _sectionLabel('12 REASONS TO JOIN'),
          const SizedBox(height: 8),
          const Text(
            'Everything You Need\nOne Platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _L.text1,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: features.length,
            itemBuilder: (_, i) {
              final f = features[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _L.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _L.border),
                  boxShadow: [
                    BoxShadow(
                      color: _L.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: _L.gradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              f['n'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(f['icon'] as IconData, color: _L.accent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      f['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _L.text1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f['desc'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _L.text2,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── How It Works ──────────────────────────────────────────────────────────────
  Widget _buildHowItWorksSection() {
    final steps = [
      {
        'n': '1',
        'title': 'Sign Up',
        'desc': 'Register your business with basic details',
        'icon': Icons.person_add_rounded,
      },
      {
        'n': '2',
        'title': 'Setup',
        'desc': 'Configure your menu, pricing, and delivery zones',
        'icon': Icons.settings_rounded,
      },
      {
        'n': '3',
        'title': 'Go Live',
        'desc': 'Start accepting orders and payments instantly',
        'icon': Icons.rocket_launch_rounded,
      },
      {
        'n': '4',
        'title': 'Grow',
        'desc': 'Analyze data and optimize your business',
        'icon': Icons.trending_up_rounded,
      },
    ];

    return Container(
      color: _L.white,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          _sectionLabel('PROCESS'),
          const SizedBox(height: 8),
          const Text(
            'How It Works',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _L.text1,
            ),
          ),
          const SizedBox(height: 28),
          ...steps.asMap().entries.map((e) {
            final step = e.value;
            final isLast = e.key == steps.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: _L.gradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _L.accent.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        if (!isLast)
                          Container(width: 2, height: 40, color: _L.border),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _L.accentLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Step ${step['n']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _L.accentDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _L.text1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['desc'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _L.text2,
                              ),
                            ),
                            if (!isLast) const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 28),
          _gradientButton('Get Started Today', _showCTASection),
        ],
      ),
    );
  }

  // ── Industries ────────────────────────────────────────────────────────────────
  Widget _buildIndustriesSection() {
    final industries = [
      {'label': 'Restaurants & Cafes', 'icon': Icons.restaurant_rounded},
      {'label': 'Bakeries', 'icon': Icons.cake_rounded},
      {'label': 'Food Trucks', 'icon': Icons.local_shipping_rounded},
      {'label': 'Grocery Stores', 'icon': Icons.store_rounded},
      {'label': 'Cloud Kitchens', 'icon': Icons.cloud_rounded},
      {'label': 'Catering TableServices', 'icon': Icons.room_service_rounded},
    ];

    return Container(
      color: _L.bg,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
      child: Column(
        children: [
          _sectionLabel('WHO WE SERVE'),
          const SizedBox(height: 8),
          const Text(
            'Industries We Serve',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _L.text1,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: industries
                .map(
                  (ind) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _L.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _L.border),
                      boxShadow: [
                        BoxShadow(
                          color: _L.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ind['icon'] as IconData,
                          color: _L.accentDark,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ind['label'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _L.text1,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Services ──────────────────────────────────────────────────────────────────
  Widget _buildServicesSection() {
    final services = [
      {
        'icon': Icons.point_of_sale_rounded,
        'title': 'Complete POS System',
        'desc':
            'Manage orders, billing, inventory, and customer data in one integrated platform.',
      },
      {
        'icon': Icons.shopping_cart_rounded,
        'title': 'Online Ordering',
        'desc':
            'Accept orders from your own website, mobile app, and social media channels.',
      },
      {
        'icon': Icons.delivery_dining_rounded,
        'title': 'Delivery Management',
        'desc':
            'Track deliveries in real-time, optimize routes, and manage delivery partners.',
      },
    ];

    return Container(
      color: _L.white,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
      child: Column(
        children: [
          _sectionLabel('SOLUTIONS'),
          const SizedBox(height: 8),
          const Text(
            'Our Comprehensive TableServices',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _L.text1,
            ),
          ),
          const SizedBox(height: 24),
          ...services.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _L.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _L.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _L.gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _L.accentDark.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _L.text1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['desc'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _L.text2,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _gradientButton('Get Started Today', _showBookDemoDialog),
        ],
      ),
    );
  }

  // ── Contact ───────────────────────────────────────────────────────────────────
  Widget _buildContactSection() {
    return Container(
      color: _L.bg,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
      child: Column(
        children: [
          _sectionLabel('CONTACT'),
          const SizedBox(height: 8),
          const Text(
            'Get In Touch',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _L.text1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ready to transform your business? Contact us today!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _L.text2),
          ),
          const SizedBox(height: 24),
          _contactRow(Icons.phone_rounded, '+91 9154949220'),
          const SizedBox(height: 10),

          _gradientButton('Contact Us Now', _showBookDemoDialog),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: _L.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _L.border),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _L.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _L.accentDark, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _L.text1,
          ),
        ),
      ],
    ),
  );

  // ── Footer ────────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_L.primary, _L.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Maamaas Partner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Empowering Local Businesses with Digital Solutions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            '© ${DateTime.now().year} Maamaas. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: _L.accentLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _L.accentDark.withOpacity(0.2)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: _L.accentDark,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _gradientButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: _L.gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _L.accentDark.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    ),
  );

  Widget _inputField(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _L.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _L.border),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 14,
          color: _L.text1,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: _L.text2),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _L.text3,
                    size: 18,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }

  // ── Sign In Bottom Sheet ──────────────────────────────────────────────────────
  void _showSignInSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: _L.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: _L.shadowMd,
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _L.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: _L.gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: _L.text1,
                              ),
                            ),
                            const Text(
                              "Sign in to MAAMAA'S",
                              style: TextStyle(fontSize: 11, color: _L.text2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _inputField(_emailController, 'User ID / Email'),
                    StatefulBuilder(
                      builder: (_, setSt) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _L.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _L.border),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscureSignIn,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _L.text1,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              color: _L.text2,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(
                              14,
                              12,
                              14,
                              12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureSignIn
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: _L.text3,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setSt(() => _obscureSignIn = !_obscureSignIn),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _openForgotPassword(sheetCtx),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE66D33),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _handleSignIn();
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: _L.gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _L.accentDark.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Book Demo Dialog ──────────────────────────────────────────────────────────
  void _showBookDemoDialog() {
    final outerCtx = context;
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _L.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _L.shadowMd,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: _L.gradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book a Demo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _L.text1,
                              ),
                            ),
                            const Text(
                              "It's free & takes 2 minutes",
                              style: TextStyle(fontSize: 10, color: _L.text2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(outerCtx).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _L.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _L.border),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: _L.text2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _inputField(_nameController, 'Full Name'),
                _inputField(
                  _mobileController,
                  'Phone Number',
                  type: TextInputType.phone,
                ),
                _inputField(
                  _emailController,
                  'Email Address',
                  type: TextInputType.emailAddress,
                ),
                _inputField(_cityController, 'City'),
                // ── NEW: Referral Code field ──
                _inputField(
                  _referralCodeController,
                  'Referral Code (Optional)',
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () async {
                            final success = await _submitDemoEnquiry(ctx);
                            if (success) {
                              Navigator.of(outerCtx).pop();
                              Navigator.push(
                                outerCtx,
                                MaterialPageRoute(
                                  builder: (_) => const MainScreen1(),
                                ),
                              );
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _L.gradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _L.accentDark.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Submit Enquiry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Helpers ─────────────────────────────────────────────────────────
class ImageWidget extends StatelessWidget {
  final String path;
  final double size;
  const ImageWidget(this.path, this.size, {super.key});
  @override
  Widget build(BuildContext context) =>
      Image.asset(path, width: size, height: size);
}

class SectionTitle extends StatelessWidget {
  final String primaryText;
  final String accentText;
  const SectionTitle({
    super.key,
    required this.primaryText,
    required this.accentText,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        primaryText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        accentText,
        style: const TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
    ],
  );
}
