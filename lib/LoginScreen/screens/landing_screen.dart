// import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Api/notifcation_authservice.dart';
// import '../../widgets_helper/Home_screen_1.dart';
// import '../services/auth_service.dart';
// import '../widgets/theme.dart';
// import 'enquiry_screen.dart';
// import 'reset_password_screen.dart';
//
// class LandingScreen extends StatefulWidget {
//   const LandingScreen({super.key});
//   @override State<LandingScreen> createState() => _LandingScreenState();
// }
//
// class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
//   // ── Banners ──────────────────────────────────────────────────────────────────
//   List<BannerItem> _banners = [];
//   int _currentBanner = 0;
//   Timer? _bannerTimer;
//   final PageController _pageCtrl = PageController();
//
//   // ── Login form ────────────────────────────────────────────────────────────────
//   final _userCtrl   = TextEditingController();
//   final _passCtrl   = TextEditingController();
//   final _emailCtrl  = TextEditingController();
//   bool _showPass    = false;
//   bool _isLoading   = false;
//   bool _isForgot    = false;
//   String? _error;
//
//   // ── Modals ────────────────────────────────────────────────────────────────────
//   bool _showLogin   = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBanners();
//   }
//
//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageCtrl.dispose();
//     _userCtrl.dispose();
//     _passCtrl.dispose();
//     _emailCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchBanners() async {
//     final banners = await AuthService.fetchBanners();
//     if (mounted) {
//       setState(() => _banners = banners);
//       if (banners.length > 1) {
//         _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
//           if (!mounted) return;
//           final next = (_currentBanner + 1) % _banners.length;
//           setState(() => _currentBanner = next);
//           _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//         });
//       }
//     }
//   }
//
//   // ── Login ─────────────────────────────────────────────────────────────────────
//   Future<void> _login() async {
//     final id = _userCtrl.text.trim();
//     final pw = _passCtrl.text.trim();
//     if (id.isEmpty || pw.isEmpty) {
//       setState(() => _error = 'Enter username and password');
//       return;
//     }
//     setState(() { _isLoading = true; _error = null; });
//     try {
//       final data = await AuthService.login(identifier: id, password: pw);
//       await AuthService.saveLoginData(data, id);
//
//       // ── Save role info to SharedPrefs (mirrors Document 1 pattern) ──────────
//       final prefs = await SharedPreferences.getInstance();
//       final role       = data['role']        as String? ?? '';
//       final employeRole = data['employeRole'] as String? ?? '';
//       final vendorId   = data['vendorId'];
//
//       await prefs.setString('role', role);
//       await prefs.setString('employeRole', employeRole);
//       if (vendorId != null) await prefs.setInt('vendorId', vendorId);
//
//       // ── Register FCM token (same as Document 1) ──────────────────────────────
//       final fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null && fcmToken.isNotEmpty) {
//         await Notification_authService.registerFcmToken(fcmToken);
//       }
//
//       if (mounted) {
//         setState(() => _showLogin = false);
//
//         // ── Employee condition: route based on role ───────────────────────────
//         final isEmployee = employeRole.isNotEmpty ||
//             role == 'ROLE_EMPLOYEE' ||
//             role == 'ROLE_STAFF';
//
//         mlSnack(
//           context,
//           isEmployee
//               ? 'Welcome back, ${data['name'] ?? 'Team Member'}!'
//               : 'Login successful! Welcome back.',
//         );
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const HomeWrapper(),  // ← remove isEmployee
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // ── Forgot password ───────────────────────────────────────────────────────────
//   Future<void> _sendResetEmail() async {
//     final email = _emailCtrl.text.trim();
//     if (email.isEmpty) { setState(() => _error = 'Enter your email'); return; }
//     setState(() { _isLoading = true; _error = null; });
//     try {
//       final msg = await AuthService.resetPasswordRequest(email);
//       if (mounted) {
//         setState(() { _isForgot = false; _showLogin = false; });
//         _emailCtrl.clear();
//         mlSnack(context, '✅ $msg');
//       }
//     } catch (e) {
//       setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // ─── BUILD ────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: mlBg,
//     body: Stack(children: [
//       // ── Hero banner section + content ─────────────────────────────────────
//       SingleChildScrollView(
//         child: Column(children: [
//           _buildHeroBanner(),
//           _buildInfoSection(),
//         ]),
//       ),
//
//       // ── Sticky nav bar ────────────────────────────────────────────────────
//       _buildNavBar(),
//
//       // ── Login modal overlay ───────────────────────────────────────────────
//       if (_showLogin) _buildLoginOverlay(),
//     ]),
//   );
//
//   // ── Nav bar ───────────────────────────────────────────────────────────────────
//   Widget _buildNavBar() => SafeArea(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(colors: [Color(0xCC000000), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
//       ),
//       child: Row(children: [
//         // Logo
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(color: mlAccent, borderRadius: BorderRadius.circular(8)),
//           child: const Text('MAAMAAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
//         ),
//         const Spacer(),
//         // Sign In
//         GestureDetector(
//           onTap: () => setState(() { _showLogin = true; _isForgot = false; _error = null; }),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.4))),
//             child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Explore
//         GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnquiryScreen())),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(color: mlAccent, borderRadius: BorderRadius.circular(8)),
//             child: const Text('Explore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
//           ),
//         ),
//       ]),
//     ),
//   );
//
//   // ── Hero banner ───────────────────────────────────────────────────────────────
//   Widget _buildHeroBanner() => SizedBox(
//     height: MediaQuery.of(context).size.height * 0.5,
//     child: Stack(children: [
//       // Banner slider
//       _banners.isEmpty
//           ? Container(
//               color: Colors.grey[900],
//               child: const Center(child: CircularProgressIndicator(color: mlAccent, strokeWidth: 2)),
//             )
//           : PageView.builder(
//               controller: _pageCtrl,
//               itemCount: _banners.length,
//               onPageChanged: (i) => setState(() => _currentBanner = i),
//               itemBuilder: (_, i) {
//                 final b = _banners[i];
//                 return Stack(fit: StackFit.expand, children: [
//                   Image.network(b.imageUrl, fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(color: Colors.grey[800])),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.black.withOpacity(0.55), Colors.transparent],
//                         begin: Alignment.bottomCenter, end: Alignment.topCenter,
//                       ),
//                     ),
//                   ),
//                   if (b.companyName.isNotEmpty || b.description.isNotEmpty)
//                     Positioned(left: 20, bottom: 56, right: 20, child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       if (b.companyName.isNotEmpty)
//                         Text(b.companyName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 6)])),
//                       if (b.description.isNotEmpty)
//                         Padding(padding: const EdgeInsets.only(top: 4), child: Text(b.description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
//                     ])),
//                 ]);
//               },
//             ),
//
//       // Dot indicators
//       if (_banners.length > 1)
//         Positioned(bottom: 16, left: 0, right: 0, child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(_banners.length, (i) => GestureDetector(
//             onTap: () { _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); setState(() => _currentBanner = i); },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               width: i == _currentBanner ? 22 : 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 color: i == _currentBanner ? mlAccent : Colors.white.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           )),
//         )),
//     ]),
//   );
//
//   // ── Info section ──────────────────────────────────────────────────────────────
//   Widget _buildInfoSection() => Container(
//     color: mlBg,
//     padding: const EdgeInsets.all(24),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Text('Power Your Food Business', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: mlText1, letterSpacing: -0.5)),
//       const SizedBox(height: 8),
//       const Text('Complete restaurant management — orders, menu, analytics & more.', style: TextStyle(color: mlText2, fontSize: 14, height: 1.5)),
//       const SizedBox(height: 24),
//       // Feature pills
//       Wrap(spacing: 10, runSpacing: 10, children: [
//         for (final f in ['📋 Order Mgmt','🍽️ Menu','📊 Reports','👨‍🍳 Chef KOT','💳 Payments','📱 Delivery'])
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(color: mlCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: mlBorder)),
//             child: Text(f, style: const TextStyle(fontSize: 12, color: mlText1, fontWeight: FontWeight.w600)),
//           ),
//       ]),
//       const SizedBox(height: 28),
//       // CTA
//       Row(children: [
//         Expanded(child: GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnquiryScreen())),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(colors: [mlAccent, Color(0xFFD45A2A)]),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [BoxShadow(color: mlAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
//             ),
//             child: const Center(child: Text('Book Free Demo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
//           ),
//         )),
//         const SizedBox(width: 12),
//         Expanded(child: GestureDetector(
//           onTap: () => setState(() { _showLogin = true; _isForgot = false; _error = null; }),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(color: mlCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: mlBorder)),
//             child: const Center(child: Text('Partner Login', style: TextStyle(color: mlText1, fontWeight: FontWeight.w700, fontSize: 15))),
//           ),
//         )),
//       ]),
//       const SizedBox(height: 20),
//     ]),
//   );
//
//   // ── Login modal overlay ───────────────────────────────────────────────────────
//   Widget _buildLoginOverlay() => Stack(children: [
//     // Dim backdrop
//     GestureDetector(
//       onTap: () => setState(() { _showLogin = false; _isForgot = false; _error = null; }),
//       child: Container(color: Colors.black.withOpacity(0.55)),
//     ),
//     // Modal card
//     Center(child: SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30)]),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             // Close
//             Align(alignment: Alignment.centerRight, child: GestureDetector(
//               onTap: () => setState(() { _showLogin = false; _isForgot = false; _error = null; }),
//               child: Container(width: 30, height: 30, decoration: BoxDecoration(color: mlBg, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 16, color: mlText2)),
//             )),
//             const SizedBox(height: 4),
//
//             // Header
//             Text(
//               _isForgot ? 'Reset Password' : 'Welcome Back 👋',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: mlAccent, letterSpacing: -0.3),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _isForgot ? 'Enter your registered email' : 'Login to continue',
//               style: const TextStyle(fontSize: 13, color: mlText2),
//             ),
//             const SizedBox(height: 20),
//
//             if (!_isForgot) ...[
//               // ── LOGIN FORM ─────────────────────────────────────────────────
//               _inputField(
//                 ctrl: _userCtrl, hint: 'Username / Email',
//                 icon: Icons.person_outline_rounded,
//               ),
//               const SizedBox(height: 12),
//               _inputField(
//                 ctrl: _passCtrl, hint: 'Password',
//                 icon: Icons.lock_outline_rounded,
//                 obscure: !_showPass,
//                 suffix: GestureDetector(
//                   onTap: () => setState(() => _showPass = !_showPass),
//                   child: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: mlText3),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Align(alignment: Alignment.centerRight, child: GestureDetector(
//                 onTap: () => setState(() { _isForgot = true; _error = null; }),
//                 child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: Color(0xFF667EEA), fontWeight: FontWeight.w600)),
//               )),
//               if (_error != null) ...[
//                 const SizedBox(height: 8),
//                 _errorBox(_error!),
//               ],
//               const SizedBox(height: 16),
//               _bigButton(
//                 label: _isLoading ? 'Logging in...' : 'LOGIN',
//                 loading: _isLoading,
//                 onTap: _isLoading ? null : _login,
//               ),
//             ] else ...[
//               // ── FORGOT FORM ────────────────────────────────────────────────
//               _inputField(
//                 ctrl: _emailCtrl, hint: 'Enter your email',
//                 icon: Icons.email_outlined,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               if (_error != null) ...[
//                 const SizedBox(height: 8),
//                 _errorBox(_error!),
//               ],
//               const SizedBox(height: 16),
//               _bigButton(
//                 label: _isLoading ? 'Sending...' : 'Send Reset Link',
//                 loading: _isLoading,
//                 onTap: _isLoading ? null : _sendResetEmail,
//               ),
//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () => setState(() { _isForgot = false; _error = null; }),
//                 child: const Text('← Back to Login', style: TextStyle(color: Color(0xFF667EEA), fontSize: 13, fontWeight: FontWeight.w600)),
//               ),
//             ],
//
//             const SizedBox(height: 16),
//             // Switch to enquiry
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               const Text("New to Maamaas? ", style: TextStyle(fontSize: 12, color: mlText2)),
//               GestureDetector(
//                 onTap: () {
//                   setState(() => _showLogin = false);
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const EnquiryScreen()));
//                 },
//                 child: const Text('Book a Demo', style: TextStyle(fontSize: 12, color: mlAccent, fontWeight: FontWeight.w700)),
//               ),
//             ]),
//           ]),
//         ),
//       ),
//     )),
//   ]);
//
//   Widget _inputField({
//     required TextEditingController ctrl,
//     required String hint,
//     required IconData icon,
//     bool obscure = false,
//     Widget? suffix,
//     TextInputType keyboardType = TextInputType.text,
//   }) => Container(
//     decoration: BoxDecoration(color: mlBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: mlBorder)),
//     child: Row(children: [
//       const SizedBox(width: 14),
//       Icon(icon, size: 18, color: mlText3),
//       const SizedBox(width: 8),
//       Expanded(child: TextField(
//         controller: ctrl,
//         obscureText: obscure,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: mlText3, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
//         style: const TextStyle(fontSize: 13, color: mlText1),
//       )),
//       if (suffix != null) Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
//     ]),
//   );
//
//   Widget _bigButton({required String label, required bool loading, VoidCallback? onTap}) => GestureDetector(
//     onTap: onTap,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 180),
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         gradient: onTap != null
//             ? const LinearGradient(colors: [mlAccent, Color(0xFFD45A2A)])
//             : null,
//         color: onTap == null ? mlBorder : null,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: onTap != null ? [BoxShadow(color: mlAccent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))] : null,
//       ),
//       child: loading
//           ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
//           : Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
//     ),
//   );
//
//   Widget _errorBox(String msg) => Container(
//     padding: const EdgeInsets.all(10),
//     decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
//     child: Row(children: [
//       const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
//       const SizedBox(width: 8),
//       Expanded(child: Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
//     ]),
//   );
// }
