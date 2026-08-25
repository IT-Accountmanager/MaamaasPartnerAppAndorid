// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../API/Auth_service.dart';
// import 'login_page.dart';
//
// class ForgetPasswordScreen extends StatefulWidget {
//   const ForgetPasswordScreen({super.key});
//
//   @override
//   State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
// }
//
// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isLoading = false;
//
//   Future<void> _handleForgotPassword() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final result = await AuthService.forgotPassword(
//         _emailController.text.trim(),
//       );
//
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//
//       if (result['success'] == true) {
//         _showSuccessSnackBar(result['message']);
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => LoginPage()),
//           );
//         }
//       } else {
//         _showErrorSnackBar(result['message'] ?? 'Something went wrong');
//       }
//     } catch (error) {
//       _showErrorSnackBar('An error occurred. Please try again.');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white, size: 20.w),
//             SizedBox(width: 8.w),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white, size: 20.w),
//             SizedBox(width: 8.w),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.all(24.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Back Button
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   size: 24.w,
//                   color: const Color(0xFF3F51B5),
//                 ),
//                 padding: EdgeInsets.zero,
//                 constraints: BoxConstraints(),
//               ),
//               SizedBox(height: 40.h),
//
//               // Header Section
//               Center(
//                 child: Column(
//                   children: [
//                     // Icon Container
//                     Container(
//                       width: 100.w,
//                       height: 100.w,
//                       decoration: BoxDecoration(
//                         // ignore: deprecated_member_use
//                         color: const Color(0xFF3F51B5).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.lock_reset_rounded,
//                         size: 50.w,
//                         color: const Color(0xFF3F51B5),
//                       ),
//                     ),
//                     SizedBox(height: 24.h),
//                     Text(
//                       "Forgot Password?",
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     Text(
//                       "No worries! Enter your email and we'll send you a reset link",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: Colors.grey[600],
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 40.h),
//
//               // Form Section
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Email Field
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16.r),
//                         boxShadow: [
//                           BoxShadow(
//                             // ignore: deprecated_member_use
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10.r,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         textInputAction: TextInputAction.done,
//                         style: TextStyle(fontSize: 16.sp),
//                         decoration: InputDecoration(
//                           labelText: "Email Address",
//                           hintText: "Enter your email",
//                           floatingLabelBehavior: FloatingLabelBehavior.always,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16.r),
//                             borderSide: BorderSide.none,
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                           prefixIcon: Container(
//                             margin: EdgeInsets.all(12.w),
//                             decoration: BoxDecoration(
//                               // ignore: deprecated_member_use
//                               color: const Color(0xFF3F51B5).withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.email_rounded,
//                               color: const Color(0xFF3F51B5),
//                               size: 20.w,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16.w,
//                             vertical: 16.h,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Email is required";
//                           } else if (!RegExp(
//                             r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
//                           ).hasMatch(value)) {
//                             return "Please enter a valid email address";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//
//                     SizedBox(height: 32.h),
//
//                     // Submit Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF3F51B5),
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 18.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           elevation: 4,
//                           // ignore: deprecated_member_use
//                           shadowColor: const Color(0xFF3F51B5).withOpacity(0.3),
//                         ),
//                         onPressed: _isLoading ? null : _handleForgotPassword,
//                         child: _isLoading
//                             ? SizedBox(
//                                 height: 20.h,
//                                 width: 20.h,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.w,
//                                 ),
//                               )
//                             : Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.send_rounded, size: 20.w),
//                                   SizedBox(width: 8.w),
//                                   Text(
//                                     "Send Reset Link",
//                                     style: TextStyle(
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//
//                     SizedBox(height: 24.h),
//
//                     // Back to Login
//                     TextButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => LoginPage()),
//                               );
//                             },
//                       style: TextButton.styleFrom(
//                         foregroundColor: const Color(0xFF3F51B5),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 24.w,
//                           vertical: 12.h,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.arrow_back_rounded, size: 18.w),
//                           SizedBox(width: 8.w),
//                           Text(
//                             "Back to Login",
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 60.h),
//
//               // Footer Text
//               Center(
//                 child: Text(
//                   "You'll receive an email with a password reset link",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
