import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../API/Apiclient.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const shadowMd = Color(0x14000000);

  static const gradient = LinearGradient(
    colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  // ── Inline error state ────────────────────────────────────────────────────────
  // null  = no error shown
  // String = error message shown below the field
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = "Email is required");
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final response = await ApiClient.post(
        'api/auth/forgot-password', // 🔁 change if needed
        {"email": email},
        service: 'subscription',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() => _isSuccess = true);
      } else {
        setState(() => _emailError = "Failed to send reset link");
      }
    } catch (e) {
      setState(() => _emailError = "Something went wrong");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCurrentLocation(Map<String, dynamic> loginData) async {
    try {
      // ── Validate customerId ───────────────────────────────────────────────
      final String customerId = (loginData['customerId'] ?? '').toString();

      if (customerId.isEmpty) {
        debugPrint("⚠️ Missing customerId — skipping location update");
        return;
      }

      // ── Check location services ───────────────────────────────────────────
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("📍 Location services disabled — skipping");
        return;
      }

      // ── Handle permissions ────────────────────────────────────────────────
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("📍 Location permission denied — skipping");
        return;
      }

      // ── Get current position ──────────────────────────────────────────────
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String address = '';
      String city = '';

      // ── Reverse geocoding ─────────────────────────────────────────────────
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final parts = [
            place.street,
            place.subLocality,
          ].where((e) => e != null && e.trim().isNotEmpty);

          address = parts.join(', ');
          city = place.locality ?? place.administrativeArea ?? '';
        }
      } catch (e) {
        debugPrint("📍 Reverse geocode failed: $e");
      }

      // ── Build payload ─────────────────────────────────────────────────────
      final Map<String, dynamic> payload = {
        "customerId": customerId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address,
        "city": city,
      };

      debugPrint("📍 Sending location update → $payload");

      // ── API Call via ApiClient (handles token + refresh) ──────────────────
      final response = await ApiClient.post(
        'api/user/current/location/update',
        payload,
        service: 'subscription',
        // requiresAuth defaults to true → correct here
      );

      // ── Handle response ───────────────────────────────────────────────────
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ Location updated successfully");
      } else {
        debugPrint("❌ Location update failed → ${response.statusCode}");
        debugPrint("❌ Response body → ${response.body}");
      }
    } catch (e, stackTrace) {
      // Non-fatal — do NOT break login flow
      debugPrint("⚠️ Location update failed: $e");
      debugPrint("📍 StackTrace: $stackTrace");
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Whether the email field should appear in error state
    final hasError = _emailError != null;

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  20 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Lock icon ─────────────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _C.accentLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _C.accentDark.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: _C.accentDark,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Reset your password',
                        style: TextStyle(
                          fontSize: 13,
                          color: _C.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Card ──────────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _C.shadowMd,
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Success banner ──────────────────────────────────────
                          if (_isSuccess) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _C.green.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: _C.green,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email Sent!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: _C.green,
                                          ),
                                        ),
                                        Text(
                                          'Check ${_emailController.text.trim()} for your reset link.',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF065F46),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── Email label ─────────────────────────────────────────
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.text1,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Email field — red border when error ─────────────────
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hasError ? _C.redLight : _C.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasError ? _C.red : _C.border,
                                width: hasError ? 1.5 : 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              // Clear error as the user starts correcting their input
                              onChanged: (_) {
                                if (_emailError != null)
                                  setState(() => _emailError = null);
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                color: _C.text1,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your registered email',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: _C.text3,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: hasError ? _C.red : _C.text3,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.fromLTRB(
                                  4,
                                  14,
                                  14,
                                  14,
                                ),
                              ),
                            ),
                          ),

                          // ── Inline error message below field ────────────────────
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _emailError != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 14,
                                          color: _C.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _emailError!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: _C.red,
                                              fontWeight: FontWeight.w500,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 22),

                          // ── Send Reset Link button ──────────────────────────────
                          GestureDetector(
                            onTap: _isLoading ? null : _resetPassword,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: _isLoading ? null : _C.gradient,
                                color: _isLoading
                                    ? _C.accentDark.withOpacity(0.55)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isLoading
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: _C.accentDark.withOpacity(
                                            0.35,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Send Reset Link',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Back to Login ───────────────────────────────────────
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  size: 12,
                                  color: _C.accentDark,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _C.accentDark,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _C.accentDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── White header — identical to Order Management _buildHeader() ───────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _C.text1,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.text1,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
