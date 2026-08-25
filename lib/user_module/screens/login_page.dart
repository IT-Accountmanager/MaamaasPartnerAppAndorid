// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maamaaspartner/user_module/screens/signupdummy.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../API/Auth_service.dart';
// import 'forgetpassword_screen.dart';
// import 'newscreens/foodmainscreen.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool _obscureText = true;
//   bool _isLoading = false;
//
//   // Colors
//   final Color _primaryColor = const Color(0xFF6C63FF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//   final Color _cardColor = Colors.white;
//   final Color _textColor = const Color(0xFF2D3748);
//   final fcm = FirebaseMessaging.instance;
//
//   Future<String> getUserType() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userType') ?? "PERSONAL";
//   }
//
//   void _handleLogin() async {
//     setState(() => _isLoading = true);
//
//     final result = await AuthService.login(
//       identifier: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );
//
//     setState(() => _isLoading = false);
//
//     if (result != "success" || !mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result), backgroundColor: Colors.red),
//       );
//       return;
//     }
//
//     {
//       // Navigator.of(context).pushAndRemoveUntil(
//       //   MaterialPageRoute(builder: (_) => MainScreennew()),
//       //   (route) => false, // removes ALL previous screens
//       // );
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const MainScreenfood()),
//         (route) => false, // removes ALL previous screens
//       );
//     }
//
//     /// 🔥 FCM
//     final fcmToken = await fcm.getToken();
//     if (fcmToken != null) {
//       AuthService.registerFcmToken(fcmToken);
//     }
//
//     /// 🔐 Permissions
//     Future.delayed(const Duration(seconds: 1), requestAllPermissions);
//   }
//
//   Future<bool> requestAllPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.notification,
//     ].request();
//
//     bool granted = statuses.values.every((status) => status.isGranted);
//     return granted;
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
//                 // Header Section
//                 _buildHeader(),
//                 SizedBox(height: 20.h),
//
//                 // Login Card
//                 Container(
//                   decoration: BoxDecoration(
//                     color: _cardColor,
//                     borderRadius: BorderRadius.circular(20.r),
//                     boxShadow: [
//                       BoxShadow(
//                         // ignore: deprecated_member_use
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(24.w),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           // Form Fields
//                           _buildEmailField(),
//                           SizedBox(height: 16.h),
//
//                           _buildPasswordField(),
//                           SizedBox(height: 8.h),
//
//                           // Forgot Password
//                           _buildForgotPassword(),
//                           SizedBox(height: 24.h),
//
//                           // Login Button
//                           _buildLoginButton(),
//                           SizedBox(height: 20.h),
//
//                           // Sign Up Redirect
//                           _buildSignUpRedirect(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
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
//         SizedBox(height: 40.h),
//         // Logo Container
//         Container(
//           width: 100.w,
//           height: 100.h,
//           decoration: BoxDecoration(
//             color: _primaryColor,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 // ignore: deprecated_member_use
//                 color: _primaryColor.withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Icon(Icons.person, color: Colors.white, size: 40.sp),
//         ),
//         SizedBox(height: 20.h),
//         Text(
//           "Welcome Back!",
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           "Sign in to access your account",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmailField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Phone Number",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: TextFormField(
//             controller: emailController,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "phone number",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.email_outlined,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Email or Phone number is required";
//               }
//               final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//               final phoneRegex = RegExp(r'^[6-9]\d{9}$');
//               if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
//                 return "Enter a valid email or phone number";
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Password",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 6.h),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: TextFormField(
//             controller: passwordController,
//             obscureText: _obscureText,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "Enter your password",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.lock_outline,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscureText ? Icons.visibility_off : Icons.visibility,
//                   color: Colors.grey[500],
//                   size: 20.sp,
//                 ),
//                 onPressed: () {
//                   setState(() => _obscureText = !_obscureText);
//                 },
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Password is required";
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildForgotPassword() {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
//           );
//         },
//         child: Text(
//           "Forgot Password?",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//             color: _primaryColor,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isLoading
//             ? null
//             : () {
//                 if (_formKey.currentState!.validate()) {
//                   _handleLogin();
//                 }
//               },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 4,
//           // ignore: deprecated_member_use
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
//                 "Sign In",
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//               ),
//       ),
//     );
//   }
//
//   Widget _buildSignUpRedirect() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Don't have an account? ",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => Signup()),
//             );
//           },
//           child: Text(
//             "Sign Up",
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: _primaryColor,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
