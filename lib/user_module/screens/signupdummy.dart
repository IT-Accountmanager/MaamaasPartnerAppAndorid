// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../API/Auth_service.dart';
// import 'login_page.dart';
//
// class Signup extends StatefulWidget {
//   const Signup({super.key});
//
//   @override
//   State<Signup> createState() => _SignupState();
// }
//
// class _SignupState extends State<Signup> {
//   final _formKey = GlobalKey<FormState>();
//   final AuthService _authService = AuthService();
//   final TextEditingController _userNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//   TextEditingController();
//   final TextEditingController _refferalcodecontroller = TextEditingController();
//   userType _userType = userType.PERSONAL;
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isTermsAccepted = false;
//
//   // Colors
//   final Color _primaryColor = const Color(0xFF6C63FF);
//   final Color _backgroundColor = const Color(0xFFF8F9FA);
//   final Color _cardColor = Colors.white;
//   final Color _textColor = const Color(0xFF2D3748);
//
//   Future<void> _handleSignup() async {
//     final isProfessional = _userType == userType.PROFESSIONAL;
//
//     final success = await _authService.registerUser(
//       userName: _userNameController.text.trim(),
//       password: _passwordController.text.trim(),
//       referralCodeUsed: _refferalcodecontroller.text.trim(),
//       emailId: _emailController.text.trim(),
//       mobileNumber: _mobileController.text.trim(),
//       userType: isProfessional ? "PROFESSIONAL" : "PERSONAL",
//       companyName: isProfessional ? _companyNameController.text.trim() : null,
//     );
//
//     if (success) {
//       final prefs = await SharedPreferences.getInstance();
//       final userType = isProfessional ? "PROFESSIONAL" : "PERSONAL";
//
//       await prefs.setString("userType", userType);
//
//       // print('stored user type $userType');
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("signup successful!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Signup failed. Please try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
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
//                 // Form Card
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
//                           // User Type Toggle
//                           _buildUserTypeToggle(),
//                           SizedBox(height: 20.h),
//
//                           // Form Fields
//                           _buildFormFields(),
//                           SizedBox(height: 20.h),
//
//                           // Terms & Conditions
//                           _buildTermsAndConditions(),
//                           SizedBox(height: 24.h),
//
//                           // Sign Up Button
//                           _buildSignUpButton(),
//                           SizedBox(height: 16.h),
//
//                           // Login Redirect
//                           _buildLoginRedirect(),
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
//         SizedBox(height: 20.h),
//         // Logo and Title
//         Container(
//           width: 80.w,
//           height: 80.h,
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
//           child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 40.sp),
//         ),
//         SizedBox(height: 16.h),
//         Text(
//           "Create Account",
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: _textColor,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           "Join us today and get started",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildUserTypeToggle() {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: _backgroundColor,
//             borderRadius: BorderRadius.circular(15.r),
//           ),
//           padding: EdgeInsets.all(4.w),
//           child: Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() => _userType = userType.PERSONAL);
//                   },
//                   child: Container(
//                     height: 45.h,
//                     decoration: BoxDecoration(
//                       color: _userType == userType.PERSONAL
//                           ? _primaryColor
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Personal",
//                         style: TextStyle(
//                           color: _userType == userType.PERSONAL
//                               ? Colors.white
//                               : _textColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() => _userType = userType.PROFESSIONAL);
//                   },
//                   child: Container(
//                     height: 45.h,
//                     decoration: BoxDecoration(
//                       color: _userType == userType.PROFESSIONAL
//                           ? _primaryColor
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Professional",
//                         style: TextStyle(
//                           color: _userType == userType.PROFESSIONAL
//                               ? Colors.white
//                               : _textColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           _userType == userType.PERSONAL
//               ? "For personal use and individual accounts"
//               : "For business and professional services",
//           style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFormFields() {
//     return Column(
//       children: [
//         // Company Name for Professional Users
//         if (_userType == userType.PROFESSIONAL) ...[
//           _buildCompanyNameField(),
//           SizedBox(height: 16.h),
//         ],
//
//         // Email Field
//         _buildTextField(
//           controller: _emailController,
//           label: "Email Address",
//           hintText: "Enter your email",
//           prefixIcon: Icons.email_outlined,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return "Email is required";
//             } else if (!RegExp(
//               r'^[a-z0-9.]+@[a-z]+\.[a-z]+$',
//             ).hasMatch(value)) {
//               return "Enter a valid email address";
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 16.h),
//
//         // Full Name Field
//         _buildTextField(
//           controller: _userNameController,
//           label: "Full Name",
//           hintText: "Enter your full name",
//           prefixIcon: Icons.person_outline,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return "Full name is required";
//             } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
//               return "Enter a valid name (letters only)";
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 16.h),
//
//         // Phone Field
//         _buildTextField(
//           controller: _mobileController,
//           label: "Phone Number",
//           hintText: "Enter your phone number",
//           prefixIcon: Icons.phone_android_outlined,
//           keyboardType: TextInputType.phone,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return "Phone number is required";
//             } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//               return "Enter a valid 10-digit number";
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 16.h),
//
//         // Password Field
//         _buildPasswordField(),
//         SizedBox(height: 16.h),
//
//         // Confirm Password Field
//         _buildConfirmPasswordField(),
//         SizedBox(height: 16.h),
//         _buildTextField(
//           controller: _refferalcodecontroller,
//           label: "refferal code(optional)",
//           hintText: "Enter your refferal code",
//           prefixIcon: Icons.person_outline,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     required IconData prefixIcon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
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
//             controller: controller,
//             keyboardType: keyboardType,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(prefixIcon, color: _primaryColor, size: 20.sp),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             validator: validator,
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
//             controller: _passwordController,
//             obscureText: _obscurePassword,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "Create a strong password",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.lock_outline,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                   color: Colors.grey[500],
//                   size: 20.sp,
//                 ),
//                 onPressed: () {
//                   setState(() => _obscurePassword = !_obscurePassword);
//                 },
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//
//             // ✅ VALIDATOR
//             // validator: (value) {
//             //   if (value == null || value.isEmpty) {
//             //     return "Password is required";
//             //   } else if (value.length < 6) {
//             //     return "Password must be at least 6 characters";
//             //   }
//             //   return null;
//             // },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildConfirmPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Confirm Password",
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
//             controller: _confirmPasswordController,
//             obscureText: _obscureConfirmPassword,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "Confirm your password",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.lock_outline,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscureConfirmPassword
//                       ? Icons.visibility_off
//                       : Icons.visibility,
//                   color: Colors.grey[500],
//                   size: 20.sp,
//                 ),
//                 onPressed: () {
//                   setState(
//                         () => _obscureConfirmPassword = !_obscureConfirmPassword,
//                   );
//                 },
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//
//             // ✅ VALIDATOR
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please confirm your password";
//               } else if (value != _passwordController.text) {
//                 return "Passwords do not match";
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCompanyNameField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Company Name",
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
//             controller: _companyNameController,
//             style: TextStyle(fontSize: 14.sp, color: _textColor),
//             decoration: InputDecoration(
//               hintText: "Enter your company name",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
//               border: InputBorder.none,
//               prefixIcon: Icon(
//                 Icons.business_outlined,
//                 color: _primaryColor,
//                 size: 20.sp,
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//             validator: (value) {
//               if (_userType == userType.PROFESSIONAL &&
//                   (value == null || value.isEmpty)) {
//                 return "Company name is required for professional accounts";
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTermsAndConditions() {
//     return Row(
//       children: [
//         Container(
//           width: 20.w,
//           height: 20.h,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4.r),
//             border: Border.all(color: Colors.grey[400]!),
//           ),
//           child: Theme(
//             data: ThemeData(unselectedWidgetColor: Colors.transparent),
//             child: Checkbox(
//               value: _isTermsAccepted,
//               onChanged: (value) {
//                 setState(() => _isTermsAccepted = value ?? false);
//               },
//               activeColor: _primaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//           ),
//         ),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: RichText(
//             text: TextSpan(
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
//               children: [
//                 const TextSpan(text: "I agree to the "),
//
//                 // 🔹 Terms & Conditions link
//                 TextSpan(
//                   text: "Terms & Conditions",
//                   style: TextStyle(
//                     color: _primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       launchUrl(
//                         Uri.parse("https://maamaas.com/privacy-policy"),
//                       );
//                     },
//                 ),
//
//                 const TextSpan(text: " and "),
//
//                 // 🔹 Privacy Policy link
//                 TextSpan(
//                   text: "Privacy Policy",
//                   style: TextStyle(
//                     color: _primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       launchUrl(
//                         Uri.parse("https://maamaas.com/privacy-policy"),
//                       );
//                     },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSignUpButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isTermsAccepted && !_isLoading
//             ? () async {
//           if (_formKey.currentState!.validate()) {
//             setState(() => _isLoading = true);
//             await _handleSignup();
//             setState(() => _isLoading = false);
//           }
//         }
//             : null,
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
//           height: 20.h,
//           width: 20.h,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 2,
//           ),
//         )
//             : Text(
//           "Create Account",
//           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoginRedirect() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Already have an account? ",
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const LoginPage()),
//             );
//           },
//           child: Text(
//             "Sign In",
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
//
// enum userType { PERSONAL, PROFESSIONAL }
