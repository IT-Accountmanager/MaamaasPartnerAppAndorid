// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../Registration01/screens/FoodRegistrationIntro.dart';
// import 'ModelLoginDialog.dart';
// import 'service.dart';
//
// class LoginDialog extends StatefulWidget {
//   final VoidCallback onClose;
//   final VoidCallback? onSignUpClick;
//
//   const LoginDialog({super.key, required this.onClose, this.onSignUpClick});
//
//   @override
//   State<LoginDialog> createState() => _LoginDialogState();
// }
//
// class _LoginDialogState extends State<LoginDialog>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _emailController;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     );
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeOutCubic,
//           ),
//         );
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, {bool isError = true}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleLogin() async {
//     final email = _emailController.text.trim();
//
//     if (email.isEmpty) {
//       _showSnackBar('Please enter your email');
//       return;
//     }
//
//     if (!RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
//     ).hasMatch(email)) {
//       _showSnackBar('Please enter a valid email');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       // 🔎 Check whether a vendor already exists for this email
//       final VendorModelLoginDialog? vendor =
//           await VendorService.getVendorByEmail(email);
//
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//
//       if (vendor != null) {
//         // ✅ Email exists -> close this dialog and move to the
//         // Food Registration Intro screen, carrying the vendor over.
//         widget.onClose();
//
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => FoodRegistrationIntro(
//               onBeginRegistration: () {
//                 print('Starting registration for: ${vendor.email}');
//               },
//             ),
//           ),
//         );
//       } else {
//         // ❌ No vendor found for this email
//         _showSnackBar(
//           'No account found with this email. Please sign up to continue.',
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//
//       final message = e is VendorServiceException
//           ? e.message
//           : 'Something went wrong. Please try again.';
//       _showSnackBar(message);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               // Background overlay
//               GestureDetector(
//                 onTap: widget.onClose,
//                 child: Opacity(
//                   opacity: _fadeAnimation.value,
//                   child: Container(color: Colors.black.withOpacity(0.6)),
//                 ),
//               ),
//               // Dialog content
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: Container(
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         constraints: BoxConstraints(
//                           maxWidth: 400,
//                           maxHeight: MediaQuery.of(context).size.height * 0.6,
//                         ),
//                         margin: const EdgeInsets.symmetric(horizontal: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 30,
//                               offset: Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Close button
//                             Align(
//                               alignment: Alignment.topRight,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: GestureDetector(
//                                   onTap: widget.onClose,
//                                   child: const Icon(
//                                     Icons.close,
//                                     size: 24,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             // Welcome back text
//                             const Text(
//                               'Welcome Back ',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1A0A2E),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               'Login with your registered email',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF6B5E7A),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             // Email input
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                               ),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: const Color(0xFFE0E0E0),
//                                     width: 1.5,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: TextField(
//                                   controller: _emailController,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: const InputDecoration(
//                                     hintText: 'Enter your Email',
//                                     hintStyle: TextStyle(
//                                       fontSize: 14,
//                                       color: Color(0xFF999999),
//                                     ),
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 14,
//                                     ),
//                                   ),
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Color(0xFF000000),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Login button
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                               ),
//                               child: SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: _isLoading ? null : _handleLogin,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFFE66D33),
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 14,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: _isLoading
//                                       ? const SizedBox(
//                                           height: 20,
//                                           width: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Colors.white,
//                                           ),
//                                         )
//                                       : const Text(
//                                           'Check & Continue →',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Sign up link
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text(
//                                   "Don't have an account?",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Color(0xFF666666),
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     widget.onClose();
//                                     widget.onSignUpClick?.call();
//                                   },
//                                   style: TextButton.styleFrom(
//                                     padding: EdgeInsets.zero,
//                                   ),
//                                   child: const Text(
//                                     ' Sign up here',
//                                     style: TextStyle(
//                                       color: Color(0xFFE66D33),
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Registration01/screens/FoodRegistrationIntro.dart';
import '../Registration01/screens/food_registration_screen.dart';
import 'ModelLoginDialog.dart';
import 'service.dart';

class LoginDialog extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onSignUpClick;

  const LoginDialog({super.key, required this.onClose, this.onSignUpClick});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _emailController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
    ).hasMatch(email)) {
      _showSnackBar('Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔎 Check whether a vendor already exists for this email
      final VendorModelLoginDialog? vendor =
          await VendorService.getVendorByEmail(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (vendor != null) {
        final prefs = await SharedPreferences.getInstance();
        if (vendor.vendorId != null) {
          await prefs.setInt('vendorId', vendor.vendorId!);
        }

        widget.onClose();

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FoodRegistrationScreen01()),
        );
      } else {
        // ❌ No vendor found for this email
        _showSnackBar(
          'No account found with this email. Please sign up to continue.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final message = e is VendorServiceException
          ? e.message
          : 'Something went wrong. Please try again.';
      _showSnackBar(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SafeArea(
          child: Stack(
            children: [
              // Background overlay
              GestureDetector(
                onTap: widget.onClose,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              // Dialog content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: GestureDetector(
                                  onTap: widget.onClose,
                                  child: const Icon(
                                    Icons.close,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Welcome back text
                            const Text(
                              'Welcome Back ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A0A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Login with your registered email',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B5E7A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Email input
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your Email',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF999999),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Login button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE66D33),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Check & Continue →',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    widget.onClose();
                                    widget.onSignUpClick?.call();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    ' Sign up here',
                                    style: TextStyle(
                                      color: Color(0xFFE66D33),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
