// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../API/Auth_service.dart';
// import 'login_page.dart';
//
// class OTPVerificationPage extends StatefulWidget {
//   // final String email;
//   final String mobileNumber;
//   // final String? userId; // Add if your API returns user ID
//
//   const OTPVerificationPage({
//     super.key,
//     // required this.email,
//     required this.mobileNumber,
//     // this.userId,
//   });
//
//   @override
//   State<OTPVerificationPage> createState() => _OTPVerificationPageState();
// }
//
// class _OTPVerificationPageState extends State<OTPVerificationPage> {
//   final AuthService _authService = AuthService();
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _otpFocusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );
//   bool _isLoading = false;
//   bool _isResendLoading = false;
//   int _resendTimer = 60;
//   bool _canResend = false;
//
//   final Color _primaryColor = const Color(0xFF6C63FF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//
//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//
//     // Auto-focus first OTP field
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
//     });
//   }
//
//   void _startResendTimer() {
//     _canResend = false;
//     _resendTimer = 60;
//
//     Future.delayed(Duration.zero, () {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           if (_resendTimer > 0) {
//             _resendTimer--;
//           } else {
//             _canResend = true;
//             timer.cancel();
//           }
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   Future<void> _verifyOTP() async {
//     String otp = _otpControllers.map((controller) => controller.text).join();
//
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Please enter complete 6-digit OTP"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     // Call your OTP verification API
//     final success = await _authService.verifyOTP(
//       mobile: widget.mobileNumber,
//       otp: otp,
//     );
//
//     setState(() => _isLoading = false);
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("OTP verified successfully!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       // Redirect to login page or home page
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Invalid OTP. Please try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//
//       // Clear OTP fields on failure
//       for (var controller in _otpControllers) {
//         controller.clear();
//       }
//       FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
//     }
//   }
//
//   // Future<void> _resendOTP() async {
//   //   if (!_canResend) return;
//   //
//   //   setState(() => _isResendLoading = true);
//   //
//   //   // Call your resend OTP API
//   //   final success = await _authService.resendOTP(
//   //     email: widget.email,
//   //     mobileNumber: widget.mobileNumber,
//   //   );
//   //
//   //   setState(() => _isResendLoading = false);
//   //
//   //   if (success) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text("OTP sent successfully!"),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     _startResendTimer();
//   //
//   //     // Clear OTP fields
//   //     for (var controller in _otpControllers) {
//   //       controller.clear();
//   //     }
//   //     FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text("Failed to resend OTP. Please try again."),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   }
//   // }
//
//   // void _handleOtpInput(String value, int index) {
//   //   if (value.isNotEmpty && index < 5) {
//   //     FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
//   //   }
//   //
//   //   // Auto verify if last digit is entered
//   //   if (index == 5 && value.isNotEmpty) {
//   //     String fullOtp = _otpControllers.map((c) => c.text).join();
//   //     if (fullOtp.length == 6) {
//   //       _verifyOTP();
//   //     }
//   //   }
//   // }
//
//   void _handleOtpInput(String value, int index) {
//     if (value.isNotEmpty && index < 5) {
//       FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
//     }
//   }
//
//   void _handleBackspace(String value, int index) {
//     if (value.isEmpty && index > 0) {
//       FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var node in _otpFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Column(
//               children: [
//                 // Back Button
//                 SizedBox(height: 20.h),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back, size: 24.sp),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 SizedBox(height: 40.h),
//
//                 // Header Section
//                 _buildHeader(),
//                 SizedBox(height: 40.h),
//
//                 // OTP Input Section
//                 _buildOtpInputSection(),
//                 SizedBox(height: 30.h),
//
//                 // Verify Button
//                 _buildVerifyButton(),
//                 SizedBox(height: 20.h),
//
//                 // Resend OTP Section
//                 // _buildResendSection(),
//                 SizedBox(height: 30.h),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           width: 100.w,
//           height: 100.h,
//           decoration: BoxDecoration(
//             color: _primaryColor,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: _primaryColor.withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Icon(Icons.verified_user, color: Colors.white, size: 50.sp),
//         ),
//         SizedBox(height: 24.h),
//         Text(
//           "Verify OTP",
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2D3748),
//           ),
//         ),
//         SizedBox(height: 12.h),
//         Text(
//           "Enter the 6-digit code sent to",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           widget.mobileNumber,
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF2D3748),
//           ),
//         ),
//         // SizedBox(height: 4.h),
//         // Text(
//         //   widget.email,
//         //   style: TextStyle(
//         //     fontSize: 14.sp,
//         //     color: Colors.grey[600],
//         //   ),
//         // ),
//       ],
//     );
//   }
//
//   Widget _buildOtpInputSection() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (index) {
//             return SizedBox(
//               width: 45.w,
//               child: TextField(
//                 controller: _otpControllers[index],
//                 focusNode: _otpFocusNodes[index],
//                 textAlign: TextAlign.center,
//                 keyboardType: TextInputType.number,
//                 maxLength: 1,
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF2D3748),
//                 ),
//                 decoration: InputDecoration(
//                   counterText: "",
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide: BorderSide(color: _primaryColor, width: 2),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 onChanged: (value) {
//                   if (value.isNotEmpty) {
//                     _handleOtpInput(value, index);
//                   } else {
//                     _handleBackspace(value, index);
//                   }
//                 },
//               ),
//             );
//           }),
//         ),
//         SizedBox(height: 16.h),
//         Text(
//           "Enter the 6-digit verification code",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVerifyButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _verifyOTP,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 4,
//           shadowColor: _primaryColor.withOpacity(0.3),
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: _isLoading
//             ? SizedBox(
//                 height: 20.h,
//                 width: 20.h,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 "Verify OTP",
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//       ),
//     );
//   }
//
//   // Widget _buildResendSection() {
//   //   return Column(
//   //     children: [
//   //       Text(
//   //         "Didn't receive the code?",
//   //         style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//   //       ),
//   //       SizedBox(height: 8.h),
//   //       _isResendLoading
//   //           ? CircularProgressIndicator(
//   //         color: _primaryColor,
//   //         strokeWidth: 2,
//   //       )
//   //           : TextButton(
//   //         onPressed: _canResend ? _resendOTP : null,
//   //         child: Text(
//   //           _canResend ? "Resend OTP" : "Resend in $_resendTimer seconds",
//   //           style: TextStyle(
//   //             fontSize: 14.sp,
//   //             color: _canResend ? _primaryColor : Colors.grey,
//   //             fontWeight: FontWeight.w600,
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
// }
