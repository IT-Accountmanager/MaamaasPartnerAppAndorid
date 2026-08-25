// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../API/Apiclient.dart';
// import '../RegistrationScreen/screens/food_registration_screen.dart';
//
// class CTASection extends StatefulWidget {
//   final bool isOpen;
//   final VoidCallback onClose;
//   final VoidCallback? onLoginClick;
//   final BuildContext parentContext;
//
//   const CTASection({
//     super.key,
//     required this.isOpen,
//     required this.onClose,
//     this.onLoginClick,
//     required this.parentContext,
//   });
//
//   @override
//   State<CTASection> createState() => _CTASectionState();
// }
//
// class _CTASectionState extends State<CTASection>
//     with SingleTickerProviderStateMixin {
//   // Controllers for form fields
//   final _nameController = TextEditingController();
//   final _companyNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cityController = TextEditingController();
//
//   // Business verticals dropdown value
//   String _selectedBusinessVertical = "FOOD_AND_BEVERAGES";
//
//   // Loading state
//   bool _isLoading = false;
//
//   // Animation controllers
//   AnimationController? _animationController;
//   Animation<double>? _fadeAnimation;
//   Animation<Offset>? _slideAnimation;
//
//   final List<Map<String, String>> _businessVerticalsOptions = [
//     {"value": "FOOD_AND_BEVERAGES", "label": "Food & Beverages"},
//     {"value": "CATERINGS_SERVICES", "label": "Catering TableServices"},
//     {"value": "LOGISTICS_SUPPLY", "label": "Logistics & Supply"},
//     {"value": "FRESH_GROCERIES", "label": "Fresh Groceries"},
//     {"value": "ENGINEERING_SERVICE", "label": "Engineering Service"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.easeOut,
//     );
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController!,
//             curve: Curves.easeOutCubic,
//           ),
//         );
//
//     if (widget.isOpen) {
//       _animationController?.forward();
//     }
//   }
//
//   @override
//   void didUpdateWidget(CTASection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isOpen && !oldWidget.isOpen) {
//       _animationController?.forward();
//     } else if (!widget.isOpen && oldWidget.isOpen) {
//       _animationController?.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _companyNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   void _showCustomAlert(String message, {bool isError = true}) {
//     ScaffoldMessenger.of(widget.parentContext).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<void> _handleSubmit() async {
//     // Validations
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final city = _cityController.text.trim();
//
//     // Log the data being submitted
//     debugPrint("📝 Submitting enquiry with data:");
//     debugPrint("Name: $name");
//     debugPrint("Email: $email");
//     debugPrint("Phone: $phone");
//     debugPrint("City: $city");
//     debugPrint("Business Vertical: $_selectedBusinessVertical");
//
//     if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
//       _showCustomAlert("Please fill all required fields");
//       return;
//     }
//
//     if (name.length < 2) {
//       _showCustomAlert("Name must be at least 2 characters");
//       return;
//     }
//
//     // Name validation - letters and spaces only
//     final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//     if (!nameRegex.hasMatch(name)) {
//       _showCustomAlert("Name should contain only letters");
//       return;
//     }
//
//     // Email validation
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
//     );
//     if (!emailRegex.hasMatch(email)) {
//       _showCustomAlert("Enter valid email (example@gmail.com)");
//       return;
//     }
//
//     // Phone validation - exactly 10 digits
//     final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
//     if (phoneDigits.length != 10) {
//       _showCustomAlert("Enter valid 10-digit phone number");
//       return;
//     }
//
//     if (city.length < 2) {
//       _showCustomAlert("Enter valid city");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final currentDateTime = DateTime.now().toUtc().toIso8601String();
//
//       final payload = {
//         "vendorId": 0,
//         "parentId": null,
//         "name": name,
//         "email": email,
//         "city": city,
//         "mobileNumber": phoneDigits,
//         "companyName": _companyNameController.text.trim().isEmpty
//             ? null
//             : _companyNameController.text.trim(),
//         "role": "ROLE_VENDOR",
//         "registerTime": currentDateTime,
//         "businessVerticals": [_selectedBusinessVertical],
//       };
//
//       debugPrint("📤 Sending payload: ${jsonEncode(payload)}");
//
//       // Close modal first
//       widget.onClose();
//
//
//       final response = await ApiClient.post(
//         "api/vendor/enquiry",
//         payload,
//         service: "subscription",
//       );
//       debugPrint("📨 Response status: ${response.statusCode}");
//       debugPrint("📨 Response body: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Map<String, dynamic> responseData = {};
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         }
//
//         debugPrint("✅ Response data: $responseData");
//
//         // Store data in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//
//         if (responseData['vendorId'] != null) {
//           await prefs.setInt('vendorId', responseData['vendorId']);
//           debugPrint("✅ Stored vendorId: ${responseData['vendorId']}");
//         } else {
//           debugPrint("⚠️ vendorId not found in response");
//         }
//
//         if (responseData['referenceId'] != null) {
//           await prefs.setString(
//             'customerId',
//             responseData['referenceId'].toString(),
//           );
//           debugPrint("✅ Stored customerId: ${responseData['referenceId']}");
//         }
//
//         // Store business vertical
//         await prefs.setString('businessVertical', _selectedBusinessVertical);
//         debugPrint("✅ Stored businessVertical: $_selectedBusinessVertical");
//
//         await prefs.setStringList('vendorBusinessVerticals', [
//           _selectedBusinessVertical,
//         ]);
//
//         // Store full vendor data
//         final vendorData = {
//           ...responseData,
//           'businessVerticals': [_selectedBusinessVertical],
//           'name': name,
//           'email': email,
//           'mobileNumber': phoneDigits,
//           'city': city,
//         };
//         await prefs.setString('vendorData', jsonEncode(vendorData));
//
//         // Store user info
//         await prefs.setString('userName', name);
//         await prefs.setString('userEmail', email);
//         await prefs.setString('userPhone', phoneDigits);
//         await prefs.setString('userCity', city);
//
//         debugPrint("✅ All data stored successfully");
//
//         // Reset form
//         _nameController.clear();
//         _companyNameController.clear();
//         _emailController.clear();
//         _phoneController.clear();
//         _cityController.clear();
//         setState(() => _selectedBusinessVertical = "FOOD_AND_BEVERAGES");
//
//         _showCustomAlert("Enquiry submitted successfully!", isError: false);
//
//         // Navigate to demo dashboard
//         if (widget.parentContext.mounted) {
//           Navigator.pushReplacement(
//             widget.parentContext,
//             MaterialPageRoute(builder: (_) => const DemoDashboardScreen()),
//           );
//         }
//       } else {
//         // Handle error response
//         String errorMessage = "Something went wrong";
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['message'] != null) {
//             errorMessage = errorData['message'];
//           }
//         } catch (e) {
//           // If response body is not JSON
//           final bodyLower = response.body.toLowerCase();
//           if (bodyLower.contains('email') && bodyLower.contains('exist')) {
//             errorMessage = "Email already exists";
//           } else if (bodyLower.contains('mobile') ||
//               bodyLower.contains('phone')) {
//             errorMessage = "Phone number already exists";
//           }
//         }
//         _showCustomAlert(errorMessage);
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       if (e.toString().toLowerCase().contains('timeout')) {
//         _showCustomAlert(
//           "Connection timeout. Please check your internet connection",
//         );
//       } else if (e.toString().toLowerCase().contains('network')) {
//         _showCustomAlert("Network error. Please check your connection");
//       } else {
//         _showCustomAlert("Something went wrong: ${e.toString()}");
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isOpen) return const SizedBox.shrink();
//
//     return AnimatedBuilder(
//       animation: _animationController!,
//       builder: (context, child) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               // Backdrop
//               GestureDetector(
//                 onTap: widget.onClose,
//                 child: Container(
//                   color: Colors.black.withOpacity(
//                     0.6 * (_fadeAnimation?.value ?? 0),
//                   ),
//                 ),
//               ),
//               // Modal
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation!,
//                   child: SlideTransition(
//                     position: _slideAnimation!,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       constraints: const BoxConstraints(
//                         maxWidth: 400,
//                         maxHeight: 600,
//                       ),
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 30,
//                             offset: Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Header with close button
//                           Stack(
//                             children: [
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 20),
//                                 child: Center(
//                                   child: Text(
//                                     "Book a Demo",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF333333),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 right: 12,
//                                 top: 12,
//                                 child: IconButton(
//                                   icon: const Icon(
//                                     Icons.close,
//                                     size: 20,
//                                     color: Colors.black,
//                                   ),
//                                   onPressed: widget.onClose,
//                                   padding: EdgeInsets.zero,
//                                   constraints: const BoxConstraints(),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           // Form - Make it scrollable
//                           Flexible(
//                             child: SingleChildScrollView(
//                               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                               child: Column(
//                                 children: [
//                                   _buildTextField(
//                                     controller: _nameController,
//                                     hint: "Name *",
//                                     keyboardType: TextInputType.name,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _buildTextField(
//                                     controller: _companyNameController,
//                                     hint: "Company Name",
//                                     keyboardType: TextInputType.text,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _buildTextField(
//                                     controller: _emailController,
//                                     hint: "Email *",
//                                     keyboardType: TextInputType.emailAddress,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _buildTextField(
//                                     controller: _phoneController,
//                                     hint: "Phone *",
//                                     keyboardType: TextInputType.phone,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _buildTextField(
//                                     controller: _cityController,
//                                     hint: "City *",
//                                     keyboardType: TextInputType.text,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   // Business Verticals Dropdown
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: const Color(0xFFE0E0E0),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: DropdownButtonHideUnderline(
//                                       child: DropdownButton<String>(
//                                         value: _selectedBusinessVertical,
//                                         isExpanded: true,
//                                         icon: const Padding(
//                                           padding: EdgeInsets.only(right: 12),
//                                           child: Icon(
//                                             Icons.arrow_drop_down,
//                                             color: Color(0xFF666666),
//                                           ),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                         ),
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Color(0xFF000000),
//                                         ),
//                                         onChanged: (String? newValue) {
//                                           if (newValue != null) {
//                                             setState(
//                                               () => _selectedBusinessVertical =
//                                                   newValue,
//                                             );
//                                           }
//                                         },
//                                         items: _businessVerticalsOptions.map((
//                                           option,
//                                         ) {
//                                           return DropdownMenuItem<String>(
//                                             value: option["value"],
//                                             child: Text(option["label"]!),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//
//                                   // Login switch
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 12,
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Text(
//                                           "Already have an account?",
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Color(0xFF666666),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             widget.onClose();
//                                             if (widget.onLoginClick != null) {
//                                               widget.onLoginClick!();
//                                             }
//                                           },
//                                           style: TextButton.styleFrom(
//                                             padding: EdgeInsets.zero,
//                                           ),
//                                           child: const Text(
//                                             "Login here",
//                                             style: TextStyle(
//                                               color: Color(0xFFE66D33),
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   // Submit Button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: _isLoading
//                                           ? null
//                                           : _handleSubmit,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color(
//                                           0xFFE66D33,
//                                         ),
//                                         foregroundColor: Colors.white,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 12,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: _isLoading
//                                           ? const SizedBox(
//                                               width: 20,
//                                               height: 20,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 color: Colors.white,
//                                               ),
//                                             )
//                                           : const Text(
//                                               "Explore",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
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
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),
//         ),
//         style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
//       ),
//     );
//   }
// }
//
// // // Demo Dashboard Screen
// // class DemoDashboardScreen extends StatelessWidget {
// //   const DemoDashboardScreen({super.key});
// //
// //   Future<Map<String, dynamic>> _getStoredData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return {
// //       'userName': prefs.getString('userName') ?? '',
// //       'userEmail': prefs.getString('userEmail') ?? '',
// //       'userPhone': prefs.getString('userPhone') ?? '',
// //       'userCity': prefs.getString('userCity') ?? '',
// //       'businessVertical': prefs.getString('businessVertical') ?? '',
// //       'vendorId': prefs.getInt('vendorId') ?? 0,
// //       'customerId': prefs.getString('customerId') ?? '',
// //     };
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFFBF9FF),
// //       appBar: AppBar(
// //         title: const Text(
// //           "Demo Dashboard",
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         backgroundColor: const Color(0xFFE66D33),
// //         foregroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //       ),
// //       body: FutureBuilder<Map<String, dynamic>>(
// //         future: _getStoredData(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           if (snapshot.hasError) {
// //             return Center(child: Text("Error: ${snapshot.error}"));
// //           }
// //
// //           final data = snapshot.data ?? {};
// //
// //           return SingleChildScrollView(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               children: [
// //                 const Icon(Icons.check_circle, size: 80, color: Colors.green),
// //                 const SizedBox(height: 20),
// //                 const Text(
// //                   "Welcome to Demo Dashboard!",
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF2A0947),
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   "Your enquiry has been submitted successfully",
// //                   style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 30),
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: const Color(0xFFEEECF5)),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.05),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       _buildInfoRow("Name", data['userName']),
// //                       const Divider(),
// //                       _buildInfoRow("Email", data['userEmail']),
// //                       const Divider(),
// //                       _buildInfoRow("Phone", data['userPhone']),
// //                       const Divider(),
// //                       _buildInfoRow("City", data['userCity']),
// //                       const Divider(),
// //                       _buildInfoRow(
// //                         "Business Vertical",
// //                         data['businessVertical']
// //                             .replaceAll('_', ' ')
// //                             .toLowerCase(),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 30),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       Navigator.pushReplacement(
// //                         context,
// //                         MaterialPageRoute(
// //                           // isNewVendor: true → registration form starts empty,
// //                           // never pre-filled with another vendor's data.
// //                           builder: (_) =>
// //                               const FoodRegistrationScreen(isNewVendor: true),
// //                         ),
// //                       );
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFE66D33),
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 14),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       "Continue to Registration",
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w600,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 2,
// //             child: Text(
// //               label,
// //               style: const TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w600,
// //                 color: Color(0xFF1A0A2E),
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             flex: 3,
// //             child: Text(
// //               value.isNotEmpty ? value : "Not provided",
// //               style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // Demo Dashboard Screen - FIXED VERSION
// class DemoDashboardScreen extends StatelessWidget {
//   const DemoDashboardScreen({super.key});
//
//   Future<Map<String, dynamic>> _getStoredData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'userName': prefs.getString('userName') ?? '',
//       'userEmail': prefs.getString('userEmail') ?? '',
//       'userPhone': prefs.getString('userPhone') ?? '',
//       'userCity': prefs.getString('userCity') ?? '',
//       'businessVertical': prefs.getString('businessVertical') ?? '',
//       'vendorId': prefs.getInt('vendorId') ?? 0,  // This is the correct ID (3)
//       'customerId': prefs.getString('customerId') ?? '',
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF9FF),
//       appBar: AppBar(
//         title: const Text(
//           "Demo Dashboard",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFE66D33),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _getStoredData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final data = snapshot.data ?? {};
//           final vendorId = data['vendorId'];  // Get the vendor ID from enquiry
//
//           debugPrint('🔍 DemoDashboard - Vendor ID from storage: $vendorId');
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 const Icon(Icons.check_circle, size: 80, color: Colors.green),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome to Demo Dashboard!",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2A0947),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Your enquiry has been submitted successfully",
//                   style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFEEECF5)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildInfoRow("Name", data['userName']),
//                       const Divider(),
//                       _buildInfoRow("Email", data['userEmail']),
//                       const Divider(),
//                       _buildInfoRow("Phone", data['userPhone']),
//                       const Divider(),
//                       _buildInfoRow("City", data['userCity']),
//                       const Divider(),
//                       _buildInfoRow(
//                         "Business Vertical",
//                         data['businessVertical']
//                             .replaceAll('_', ' ')
//                             .toLowerCase(),
//                       ),
//                       const Divider(),
//                       _buildInfoRow("Vendor ID", vendorId.toString()), // Show vendor ID
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FoodRegistrationScreen(
//                             isNewVendor: true,
//                             demoVendorId: vendorId.toString(), // Pass the correct ID (3)
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE66D33),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       "Continue to Registration",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A0A2E),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value.isNotEmpty ? value : "Not provided",
//               style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../API/Apiclient.dart';
// import '../RegistrationScreen/screens/food_registration_screen.dart';
//
// class CTASection extends StatefulWidget {
//   final bool isOpen;
//   final VoidCallback onClose;
//   final VoidCallback? onLoginClick;
//   final BuildContext parentContext;
//
//   const CTASection({
//     super.key,
//     required this.isOpen,
//     required this.onClose,
//     this.onLoginClick,
//     required this.parentContext,
//   });
//
//   @override
//   State<CTASection> createState() => _CTASectionState();
// }
//
// class _CTASectionState extends State<CTASection>
//     with SingleTickerProviderStateMixin {
//   // Controllers for form fields
//   final _nameController = TextEditingController();
//   final _companyNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cityController = TextEditingController();
//
//   // Business verticals dropdown value
//   String _selectedBusinessVertical = "FOOD_AND_BEVERAGES";
//
//   // Loading state
//   bool _isLoading = false;
//
//   // Animation controllers
//   AnimationController? _animationController;
//   Animation<double>? _fadeAnimation;
//   Animation<Offset>? _slideAnimation;
//
//   final List<Map<String, String>> _businessVerticalsOptions = [
//     {"value": "FOOD_AND_BEVERAGES", "label": "Food & Beverages"},
//     {"value": "CATERINGS_SERVICES", "label": "Catering TableServices"},
//     {"value": "LOGISTICS_SUPPLY", "label": "Logistics & Supply"},
//     {"value": "FRESH_GROCERIES", "label": "Fresh Groceries"},
//     {"value": "ENGINEERING_SERVICE", "label": "Engineering Service"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.easeOut,
//     );
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController!,
//             curve: Curves.easeOutCubic,
//           ),
//         );
//
//     if (widget.isOpen) {
//       _animationController?.forward();
//     }
//   }
//
//   @override
//   void didUpdateWidget(CTASection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isOpen && !oldWidget.isOpen) {
//       _animationController?.forward();
//     } else if (!widget.isOpen && oldWidget.isOpen) {
//       _animationController?.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _companyNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   void _showCustomAlert(String message, {bool isError = true}) {
//     ScaffoldMessenger.of(widget.parentContext).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<void> _handleSubmit() async {
//     // Validations
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final city = _cityController.text.trim();
//
//     // Log the data being submitted
//     debugPrint("📝 Submitting enquiry with data:");
//     debugPrint("Name: $name");
//     debugPrint("Email: $email");
//     debugPrint("Phone: $phone");
//     debugPrint("City: $city");
//     debugPrint("Business Vertical: $_selectedBusinessVertical");
//
//     if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
//       _showCustomAlert("Please fill all required fields");
//       return;
//     }
//
//     if (name.length < 2) {
//       _showCustomAlert("Name must be at least 2 characters");
//       return;
//     }
//
//     // Name validation - letters and spaces only
//     final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//     if (!nameRegex.hasMatch(name)) {
//       _showCustomAlert("Name should contain only letters");
//       return;
//     }
//
//     // Email validation
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
//     );
//     if (!emailRegex.hasMatch(email)) {
//       _showCustomAlert("Enter valid email (example@gmail.com)");
//       return;
//     }
//
//     // Phone validation - exactly 10 digits
//     final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
//     if (phoneDigits.length != 10) {
//       _showCustomAlert("Enter valid 10-digit phone number");
//       return;
//     }
//
//     if (city.length < 2) {
//       _showCustomAlert("Enter valid city");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final currentDateTime = DateTime.now().toUtc().toIso8601String();
//
//       final payload = {
//         "vendorId": 0,
//         "parentId": null,
//         "name": name,
//         "email": email,
//         "city": city,
//         "mobileNumber": phoneDigits,
//         "companyName": _companyNameController.text.trim().isEmpty
//             ? null
//             : _companyNameController.text.trim(),
//         "role": "ROLE_VENDOR",
//         "registerTime": currentDateTime,
//         "businessVerticals": [_selectedBusinessVertical],
//       };
//
//       debugPrint("📤 Sending payload: ${jsonEncode(payload)}");
//
//       // Close modal first
//       widget.onClose();
//
//       final response = await ApiClient.post(
//         "api/vendor/enquiry",
//         payload,
//         service: "subscription",
//       );
//       debugPrint("📨 Response status: ${response.statusCode}");
//       debugPrint("📨 Response body: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Map<String, dynamic> responseData = {};
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         }
//
//         debugPrint("✅ Response data: $responseData");
//
//         // Store data in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//
//         if (responseData['vendorId'] != null) {
//           await prefs.setInt('vendorId', responseData['vendorId']);
//           debugPrint("✅ Stored vendorId: ${responseData['vendorId']}");
//         } else {
//           debugPrint("⚠️ vendorId not found in response");
//         }
//
//         if (responseData['referenceId'] != null) {
//           await prefs.setString(
//             'customerId',
//             responseData['referenceId'].toString(),
//           );
//           debugPrint("✅ Stored customerId: ${responseData['referenceId']}");
//         }
//
//         // Store business vertical
//         await prefs.setString('businessVertical', _selectedBusinessVertical);
//         debugPrint("✅ Stored businessVertical: $_selectedBusinessVertical");
//
//         await prefs.setStringList('vendorBusinessVerticals', [
//           _selectedBusinessVertical,
//         ]);
//
//         // Store full vendor data
//         final vendorData = {
//           ...responseData,
//           'businessVerticals': [_selectedBusinessVertical],
//           'name': name,
//           'email': email,
//           'mobileNumber': phoneDigits,
//           'city': city,
//         };
//         await prefs.setString('vendorData', jsonEncode(vendorData));
//
//         // Store user info
//         await prefs.setString('userName', name);
//         await prefs.setString('userEmail', email);
//         await prefs.setString('userPhone', phoneDigits);
//         await prefs.setString('userCity', city);
//
//         debugPrint("✅ All data stored successfully");
//
//         // Reset form
//         _nameController.clear();
//         _companyNameController.clear();
//         _emailController.clear();
//         _phoneController.clear();
//         _cityController.clear();
//         setState(() => _selectedBusinessVertical = "FOOD_AND_BEVERAGES");
//
//         _showCustomAlert("Enquiry submitted successfully!", isError: false);
//
//         // Navigate to demo dashboard
//         if (widget.parentContext.mounted) {
//           Navigator.pushReplacement(
//             widget.parentContext,
//             MaterialPageRoute(builder: (_) => const DemoDashboardScreen()),
//           );
//         }
//       } else {
//         // Handle error response
//         String errorMessage = "Something went wrong";
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['message'] != null) {
//             errorMessage = errorData['message'];
//           }
//         } catch (e) {
//           // If response body is not JSON
//           final bodyLower = response.body.toLowerCase();
//           if (bodyLower.contains('email') && bodyLower.contains('exist')) {
//             errorMessage = "Email already exists";
//           } else if (bodyLower.contains('mobile') ||
//               bodyLower.contains('phone')) {
//             errorMessage = "Phone number already exists";
//           }
//         }
//         _showCustomAlert(errorMessage);
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       if (e.toString().toLowerCase().contains('timeout')) {
//         _showCustomAlert(
//           "Connection timeout. Please check your internet connection",
//         );
//       } else if (e.toString().toLowerCase().contains('network')) {
//         _showCustomAlert("Network error. Please check your connection");
//       } else {
//         _showCustomAlert("Something went wrong: ${e.toString()}");
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isOpen) return const SizedBox.shrink();
//
//     return AnimatedBuilder(
//       animation: _animationController!,
//       builder: (context, child) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               // Backdrop
//               GestureDetector(
//                 onTap: widget.onClose,
//                 child: Container(
//                   color: Colors.black.withOpacity(
//                     0.6 * (_fadeAnimation?.value ?? 0),
//                   ),
//                 ),
//               ),
//
//               // Modal
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation!,
//                   child: SlideTransition(
//                     position: _slideAnimation!,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       constraints: BoxConstraints(
//                         maxWidth: 400,
//                         maxHeight: MediaQuery.of(context).size.height * 0.8,
//                       ),
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 30,
//                             offset: Offset(0, 10),
//                           ),
//                         ],
//                       ),
//
//                       // 👇 KEY FIX: remove Expanded, use Flexible + min column
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Header
//                           SizedBox(
//                             height: 44,
//                             child: Stack(
//                               children: [
//                                 const Center(
//                                   child: Text(
//                                     "Book a Demo",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF333333),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 12,
//                                   top: 12,
//                                   child: GestureDetector(
//                                     onTap: widget.onClose,
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 20,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Form
//                           Flexible(
//                             child: SingleChildScrollView(
//                               physics: const BouncingScrollPhysics(),
//                               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   _buildTextField(
//                                     controller: _nameController,
//                                     hint: "Name *",
//                                     keyboardType: TextInputType.name,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _companyNameController,
//                                     hint: "Company Name",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _emailController,
//                                     hint: "Email *",
//                                     keyboardType: TextInputType.emailAddress,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _phoneController,
//                                     hint: "Phone *",
//                                     keyboardType: TextInputType.phone,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _cityController,
//                                     hint: "City *",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   // Dropdown
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: const Color(0xFFE0E0E0),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: DropdownButtonHideUnderline(
//                                       child: DropdownButton<String>(
//                                         value: _selectedBusinessVertical,
//                                         isExpanded: true,
//                                         icon: const Padding(
//                                           padding: EdgeInsets.only(right: 12),
//                                           child: Icon(
//                                             Icons.arrow_drop_down,
//                                             color: Color(0xFF666666),
//                                           ),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                         ),
//                                         onChanged: (String? newValue) {
//                                           if (newValue != null) {
//                                             setState(() {
//                                               _selectedBusinessVertical = newValue;
//                                             });
//                                           }
//                                         },
//                                         items:
//                                         _businessVerticalsOptions.map((option) {
//                                           return DropdownMenuItem<String>(
//                                             value: option["value"],
//                                             child: Text(option["label"]!),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 12),
//
//                                   // Login switch
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         "Already have an account?",
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Color(0xFF666666),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           widget.onClose();
//                                           widget.onLoginClick?.call();
//                                         },
//                                         style: TextButton.styleFrom(
//                                           padding: EdgeInsets.zero,
//                                         ),
//                                         child: const Text(
//                                           " Login here",
//                                           style: TextStyle(
//                                             color: Color(0xFFE66D33),
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 10),
//
//                                   // Button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed:
//                                       _isLoading ? null : _handleSubmit,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color(0xFFE66D33),
//                                         foregroundColor: Colors.white,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 12,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: _isLoading
//                                           ? const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                           : const Text(
//                                         "Explore",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
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
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),
//         ),
//         style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
//       ),
//     );
//   }
// }
//
// // Demo Dashboard Screen - UPDATED with showAppBar: true
// class DemoDashboardScreen extends StatelessWidget {
//   const DemoDashboardScreen({super.key});
//
//   Future<Map<String, dynamic>> _getStoredData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'userName': prefs.getString('userName') ?? '',
//       'userEmail': prefs.getString('userEmail') ?? '',
//       'userPhone': prefs.getString('userPhone') ?? '',
//       'userCity': prefs.getString('userCity') ?? '',
//       'businessVertical': prefs.getString('businessVertical') ?? '',
//       'vendorId': prefs.getInt('vendorId') ?? 0,
//       'customerId': prefs.getString('customerId') ?? '',
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF9FF),
//       appBar: AppBar(
//         title: const Text(
//           "Demo Dashboard",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFE66D33),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _getStoredData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final data = snapshot.data ?? {};
//           final vendorId = data['vendorId'];
//
//           debugPrint('🔍 DemoDashboard - Vendor ID from storage: $vendorId');
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 const Icon(Icons.check_circle, size: 80, color: Colors.green),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome to Demo Dashboard!",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2A0947),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Your enquiry has been submitted successfully",
//                   style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFEEECF5)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildInfoRow("Name", data['userName']),
//                       const Divider(),
//                       _buildInfoRow("Email", data['userEmail']),
//                       const Divider(),
//                       _buildInfoRow("Phone", data['userPhone']),
//                       const Divider(),
//                       _buildInfoRow("City", data['userCity']),
//                       const Divider(),
//                       _buildInfoRow(
//                         "Business Vertical",
//                         data['businessVertical']
//                             .replaceAll('_', ' ')
//                             .toLowerCase(),
//                       ),
//                       const Divider(),
//                       _buildInfoRow("Vendor ID", vendorId.toString()),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FoodRegistrationScreen(
//                             isNewVendor: true,
//                             demoVendorId: vendorId.toString(),
//                             showAppBar: true, // Show AppBar in demo flow
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE66D33),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       "Continue to Registration",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A0A2E),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value.isNotEmpty ? value : "Not provided",
//               style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../API/Apiclient.dart';
// import '../Registration01/screens/food_registration_screen.dart';
// import '../RegistrationScreen/screens/food_registration_screen.dart';
//
// class CTASection extends StatefulWidget {
//   final bool isOpen;
//   final VoidCallback onClose;
//   final VoidCallback? onLoginClick;
//   final BuildContext parentContext;
//
//   const CTASection({
//     super.key,
//     required this.isOpen,
//     required this.onClose,
//     this.onLoginClick,
//     required this.parentContext,
//   });
//
//   @override
//   State<CTASection> createState() => _CTASectionState();
// }
//
// class _CTASectionState extends State<CTASection>
//     with SingleTickerProviderStateMixin {
//   // Controllers for form fields
//   late TextEditingController _nameController;
//   late TextEditingController _companyNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _cityController;
//
//   // Business verticals dropdown value
//   String _selectedBusinessVertical = "FOOD_AND_BEVERAGES";
//
//   // Loading state
//   bool _isLoading = false;
//
//   // Animation controllers
//   AnimationController? _animationController;
//   Animation<double>? _fadeAnimation;
//   Animation<Offset>? _slideAnimation;
//
//   final List<Map<String, String>> _businessVerticalsOptions = [
//     {"value": "FOOD_AND_BEVERAGES", "label": "Food & Beverages"},
//     {"value": "CATERINGS_SERVICES", "label": "Catering TableServices"},
//     {"value": "LOGISTICS_SUPPLY", "label": "Logistics & Supply"},
//     {"value": "FRESH_GROCERIES", "label": "Fresh Groceries"},
//     {"value": "ENGINEERING_SERVICE", "label": "Engineering Service"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers here
//     _nameController = TextEditingController();
//     _companyNameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _cityController = TextEditingController();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.easeOut,
//     );
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController!,
//             curve: Curves.easeOutCubic,
//           ),
//         );
//
//     if (widget.isOpen) {
//       _animationController?.forward();
//     }
//   }
//
//   @override
//   void didUpdateWidget(CTASection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isOpen && !oldWidget.isOpen) {
//       _animationController?.forward();
//     } else if (!widget.isOpen && oldWidget.isOpen) {
//       _animationController?.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     // Dispose controllers safely
//     _nameController.dispose();
//     _companyNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   void _showCustomAlert(String message, {bool isError = true}) {
//     if (widget.parentContext.mounted) {
//       ScaffoldMessenger.of(widget.parentContext).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleSubmit() async {
//     // Check if mounted before using controllers
//     if (!mounted) return;
//
//     // Validations
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final city = _cityController.text.trim();
//
//     // Log the data being submitted
//     debugPrint("📝 Submitting enquiry with data:");
//     debugPrint("Name: $name");
//     debugPrint("Email: $email");
//     debugPrint("Phone: $phone");
//     debugPrint("City: $city");
//     debugPrint("Business Vertical: $_selectedBusinessVertical");
//
//     if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
//       _showCustomAlert("Please fill all required fields");
//       return;
//     }
//
//     if (name.length < 2) {
//       _showCustomAlert("Name must be at least 2 characters");
//       return;
//     }
//
//     // Name validation - letters and spaces only
//     final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//     if (!nameRegex.hasMatch(name)) {
//       _showCustomAlert("Name should contain only letters");
//       return;
//     }
//
//     // Email validation
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
//     );
//     if (!emailRegex.hasMatch(email)) {
//       _showCustomAlert("Enter valid email (example@gmail.com)");
//       return;
//     }
//
//     // Phone validation - exactly 10 digits
//     final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
//     if (phoneDigits.length != 10) {
//       _showCustomAlert("Enter valid 10-digit phone number");
//       return;
//     }
//
//     if (city.length < 2) {
//       _showCustomAlert("Enter valid city");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final currentDateTime = DateTime.now().toUtc().toIso8601String();
//
//       final payload = {
//         "vendorId": 0,
//         "parentId": null,
//         "name": name,
//         "email": email,
//         "city": city,
//         "mobileNumber": phoneDigits,
//         "companyName": _companyNameController.text.trim().isEmpty
//             ? null
//             : _companyNameController.text.trim(),
//         "role": "ROLE_VENDOR",
//         "registerTime": currentDateTime,
//         "businessVerticals": [_selectedBusinessVertical],
//       };
//
//       debugPrint("📤 Sending payload: ${jsonEncode(payload)}");
//
//       // Close modal first
//       widget.onClose();
//
//       final response = await ApiClient.post(
//         "api/vendor/enquiry",
//         payload,
//         service: "subscription",
//       );
//       debugPrint("📨 Response status: ${response.statusCode}");
//       debugPrint("📨 Response body: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Map<String, dynamic> responseData = {};
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         }
//
//         debugPrint("✅ Response data: $responseData");
//
//         // Store data in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//
//         if (responseData['vendorId'] != null) {
//           await prefs.setInt('vendorId', responseData['vendorId']);
//           debugPrint("✅ Stored vendorId: ${responseData['vendorId']}");
//         } else {
//           debugPrint("⚠️ vendorId not found in response");
//         }
//
//         if (responseData['referenceId'] != null) {
//           await prefs.setString(
//             'customerId',
//             responseData['referenceId'].toString(),
//           );
//           debugPrint("✅ Stored customerId: ${responseData['referenceId']}");
//         }
//
//         // Store business vertical
//         await prefs.setString('businessVertical', _selectedBusinessVertical);
//         debugPrint("✅ Stored businessVertical: $_selectedBusinessVertical");
//
//         await prefs.setStringList('vendorBusinessVerticals', [
//           _selectedBusinessVertical,
//         ]);
//
//         // Store full vendor data
//         final vendorData = {
//           ...responseData,
//           'businessVerticals': [_selectedBusinessVertical],
//           'name': name,
//           'email': email,
//           'mobileNumber': phoneDigits,
//           'city': city,
//         };
//         await prefs.setString('vendorData', jsonEncode(vendorData));
//
//         // Store user info
//         await prefs.setString('userName', name);
//         await prefs.setString('userEmail', email);
//         await prefs.setString('userPhone', phoneDigits);
//         await prefs.setString('userCity', city);
//
//         debugPrint("✅ All data stored successfully");
//
//         // Reset form if mounted
//         if (mounted) {
//           _nameController.clear();
//           _companyNameController.clear();
//           _emailController.clear();
//           _phoneController.clear();
//           _cityController.clear();
//           setState(() => _selectedBusinessVertical = "FOOD_AND_BEVERAGES");
//         }
//
//         _showCustomAlert("Enquiry submitted successfully!", isError: false);
//
//         // Navigate to demo dashboard
//         if (widget.parentContext.mounted) {
//           Navigator.pushReplacement(
//             widget.parentContext,
//             MaterialPageRoute(builder: (_) => const DemoDashboardScreen()),
//           );
//         }
//       } else {
//         // Handle error response
//         String errorMessage = "Something went wrong";
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['message'] != null) {
//             errorMessage = errorData['message'];
//           }
//         } catch (e) {
//           // If response body is not JSON
//           final bodyLower = response.body.toLowerCase();
//           if (bodyLower.contains('email') && bodyLower.contains('exist')) {
//             errorMessage = "Email already exists";
//           } else if (bodyLower.contains('mobile') ||
//               bodyLower.contains('phone')) {
//             errorMessage = "Phone number already exists";
//           }
//         }
//         _showCustomAlert(errorMessage);
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       if (e.toString().toLowerCase().contains('timeout')) {
//         _showCustomAlert(
//           "Connection timeout. Please check your internet connection",
//         );
//       } else if (e.toString().toLowerCase().contains('network')) {
//         _showCustomAlert("Network error. Please check your connection");
//       } else {
//         _showCustomAlert("Something went wrong: ${e.toString()}");
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isOpen) return const SizedBox.shrink();
//
//     return AnimatedBuilder(
//       animation: _animationController!,
//       builder: (context, child) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               // Backdrop
//               GestureDetector(
//                 onTap: widget.onClose,
//                 child: Container(
//                   color: Colors.black.withOpacity(
//                     0.6 * (_fadeAnimation?.value ?? 0),
//                   ),
//                 ),
//               ),
//
//               // Modal
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation!,
//                   child: SlideTransition(
//                     position: _slideAnimation!,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       constraints: BoxConstraints(
//                         maxWidth: 400,
//                         maxHeight: MediaQuery.of(context).size.height * 0.8,
//                       ),
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 30,
//                             offset: Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Header
//                           SizedBox(
//                             height: 44,
//                             child: Stack(
//                               children: [
//                                 const Center(
//                                   child: Text(
//                                     "Book a Demo",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF333333),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 12,
//                                   top: 12,
//                                   child: GestureDetector(
//                                     onTap: widget.onClose,
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 20,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Form
//                           Flexible(
//                             child: SingleChildScrollView(
//                               physics: const BouncingScrollPhysics(),
//                               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   _buildTextField(
//                                     controller: _nameController,
//                                     hint: "Name *",
//                                     keyboardType: TextInputType.name,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _companyNameController,
//                                     hint: "Company Name",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _emailController,
//                                     hint: "Email *",
//                                     keyboardType: TextInputType.emailAddress,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _phoneController,
//                                     hint: "Phone *",
//                                     keyboardType: TextInputType.phone,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _cityController,
//                                     hint: "City *",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   // Dropdown
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: const Color(0xFFE0E0E0),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: DropdownButtonHideUnderline(
//                                       child: DropdownButton<String>(
//                                         value: _selectedBusinessVertical,
//                                         isExpanded: true,
//                                         icon: const Padding(
//                                           padding: EdgeInsets.only(right: 12),
//                                           child: Icon(
//                                             Icons.arrow_drop_down,
//                                             color: Color(0xFF666666),
//                                           ),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                         ),
//                                         onChanged: (String? newValue) {
//                                           if (newValue != null && mounted) {
//                                             setState(() {
//                                               _selectedBusinessVertical =
//                                                   newValue;
//                                             });
//                                           }
//                                         },
//                                         items: _businessVerticalsOptions.map((
//                                           option,
//                                         ) {
//                                           return DropdownMenuItem<String>(
//                                             value: option["value"],
//                                             child: Text(option["label"]!),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 12),
//
//                                   // Login switch
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         "Already have an account?",
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Color(0xFF666666),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           widget.onClose();
//                                           widget.onLoginClick?.call();
//                                         },
//                                         style: TextButton.styleFrom(
//                                           padding: EdgeInsets.zero,
//                                         ),
//                                         child: const Text(
//                                           " Login here",
//                                           style: TextStyle(
//                                             color: Color(0xFFE66D33),
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 10),
//
//                                   // Button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: _isLoading
//                                           ? null
//                                           : _handleSubmit,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color(
//                                           0xFFE66D33,
//                                         ),
//                                         foregroundColor: Colors.white,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 12,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: _isLoading
//                                           ? const SizedBox(
//                                               width: 20,
//                                               height: 20,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 color: Colors.white,
//                                               ),
//                                             )
//                                           : const Text(
//                                               "Explore",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
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
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),
//         ),
//         style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
//       ),
//     );
//   }
// }
//
// // Demo Dashboard Screen - UPDATED with showAppBar: true
// class DemoDashboardScreen extends StatelessWidget {
//   const DemoDashboardScreen({super.key});
//
//   Future<Map<String, dynamic>> _getStoredData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'userName': prefs.getString('userName') ?? '',
//       'userEmail': prefs.getString('userEmail') ?? '',
//       'userPhone': prefs.getString('userPhone') ?? '',
//       'userCity': prefs.getString('userCity') ?? '',
//       'businessVertical': prefs.getString('businessVertical') ?? '',
//       'vendorId': prefs.getInt('vendorId') ?? 0,
//       'customerId': prefs.getString('customerId') ?? '',
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF9FF),
//       appBar: AppBar(
//         title: const Text(
//           "Demo Dashboard",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFE66D33),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _getStoredData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final data = snapshot.data ?? {};
//           final vendorId = data['vendorId'];
//
//           debugPrint('🔍 DemoDashboard - Vendor ID from storage: $vendorId');
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 const Icon(Icons.check_circle, size: 80, color: Colors.green),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome to Demo Dashboard!",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2A0947),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Your enquiry has been submitted successfully",
//                   style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFEEECF5)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildInfoRow("Name", data['userName']),
//                       const Divider(),
//                       _buildInfoRow("Email", data['userEmail']),
//                       const Divider(),
//                       _buildInfoRow("Phone", data['userPhone']),
//                       const Divider(),
//                       _buildInfoRow("City", data['userCity']),
//                       const Divider(),
//                       _buildInfoRow(
//                         "Business Vertical",
//                         data['businessVertical']
//                             .replaceAll('_', ' ')
//                             .toLowerCase(),
//                       ),
//                       const Divider(),
//                       _buildInfoRow("Vendor ID", vendorId.toString()),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FoodRegistrationScreen01(
//                             isNewVendor: true,
//                             demoVendorId: vendorId.toString(),
//                             showAppBar: true,
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE66D33),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       "Continue to Registration",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A0A2E),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value.isNotEmpty ? value : "Not provided",
//               style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../API/Apiclient.dart';
// import '../Registration01/screens/food_registration_screen.dart';
// import '../RegistrationScreen/screens/food_registration_screen.dart';
//
// class CTASection extends StatefulWidget {
//   final bool isOpen;
//   final VoidCallback onClose;
//   final VoidCallback? onLoginClick;
//   final BuildContext parentContext;
//
//   const CTASection({
//     super.key,
//     required this.isOpen,
//     required this.onClose,
//     this.onLoginClick,
//     required this.parentContext,
//   });
//
//   @override
//   State<CTASection> createState() => _CTASectionState();
// }
//
// class _CTASectionState extends State<CTASection>
//     with SingleTickerProviderStateMixin {
//   // Controllers for form fields
//   late TextEditingController _nameController;
//   late TextEditingController _companyNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _cityController;
//   late TextEditingController _referralCodeController; // ← NEW
//
//   // Business verticals dropdown value
//   String _selectedBusinessVertical = "FOOD_AND_BEVERAGES";
//
//   // Loading state
//   bool _isLoading = false;
//
//   // Animation controllers
//   AnimationController? _animationController;
//   Animation<double>? _fadeAnimation;
//   Animation<Offset>? _slideAnimation;
//
//   final List<Map<String, String>> _businessVerticalsOptions = [
//     {"value": "FOOD_AND_BEVERAGES", "label": "Food & Beverages"},
//     {"value": "CATERINGS_SERVICES", "label": "Catering TableServices"},
//     {"value": "LOGISTICS_SUPPLY", "label": "Logistics & Supply"},
//     {"value": "FRESH_GROCERIES", "label": "Fresh Groceries"},
//     {"value": "ENGINEERING_SERVICE", "label": "Engineering Service"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _companyNameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _cityController = TextEditingController();
//     _referralCodeController = TextEditingController(); // ← NEW
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.easeOut,
//     );
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController!,
//             curve: Curves.easeOutCubic,
//           ),
//         );
//
//     if (widget.isOpen) {
//       _animationController?.forward();
//     }
//   }
//
//   @override
//   void didUpdateWidget(CTASection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isOpen && !oldWidget.isOpen) {
//       _animationController?.forward();
//     } else if (!widget.isOpen && oldWidget.isOpen) {
//       _animationController?.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _companyNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cityController.dispose();
//     _referralCodeController.dispose(); // ← NEW
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   void _showCustomAlert(String message, {bool isError = true}) {
//     if (widget.parentContext.mounted) {
//       ScaffoldMessenger.of(widget.parentContext).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleSubmit() async {
//     if (!mounted) return;
//
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final city = _cityController.text.trim();
//     final referralCode = _referralCodeController.text.trim(); // ← NEW
//
//     debugPrint("📝 Submitting enquiry with data:");
//     debugPrint("Name: $name");
//     debugPrint("Email: $email");
//     debugPrint("Phone: $phone");
//     debugPrint("City: $city");
//     debugPrint("Business Vertical: $_selectedBusinessVertical");
//     debugPrint("Referral Code: $referralCode"); // ← NEW
//
//     if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
//       _showCustomAlert("Please fill all required fields");
//       return;
//     }
//
//     if (name.length < 2) {
//       _showCustomAlert("Name must be at least 2 characters");
//       return;
//     }
//
//     final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
//     if (!nameRegex.hasMatch(name)) {
//       _showCustomAlert("Name should contain only letters");
//       return;
//     }
//
//     final emailRegex = RegExp(
//       r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
//     );
//     if (!emailRegex.hasMatch(email)) {
//       _showCustomAlert("Enter valid email (example@gmail.com)");
//       return;
//     }
//
//     final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
//     if (phoneDigits.length != 10) {
//       _showCustomAlert("Enter valid 10-digit phone number");
//       return;
//     }
//
//     if (city.length < 2) {
//       _showCustomAlert("Enter valid city");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final currentDateTime = DateTime.now().toUtc().toIso8601String();
//
//       final payload = {
//         "vendorId": 0,
//         "parentId": null,
//         "name": name,
//         "email": email,
//         "city": city,
//         "mobileNumber": phoneDigits,
//         "companyName": _companyNameController.text.trim().isEmpty
//             ? null
//             : _companyNameController.text.trim(),
//         "role": "ROLE_VENDOR",
//         "registerTime": currentDateTime,
//         "businessVerticals": [_selectedBusinessVertical],
//         // ── NEW ──
//         "referralCodeUsed": referralCode.isEmpty
//             ? null
//             : referralCode.toUpperCase(),
//       };
//
//       debugPrint("📤 Sending payload: ${jsonEncode(payload)}");
//
//       // Close modal first
//       widget.onClose();
//
//       final response = await ApiClient.post(
//         "api/vendor/enquiry",
//         payload,
//         service: "subscription",
//       );
//       debugPrint("📨 Response status: ${response.statusCode}");
//       debugPrint("📨 Response body: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Map<String, dynamic> responseData = {};
//         if (response.body.isNotEmpty) {
//           responseData = jsonDecode(response.body);
//         }
//
//         debugPrint("✅ Response data: $responseData");
//
//         final prefs = await SharedPreferences.getInstance();
//
//         if (responseData['vendorId'] != null) {
//           await prefs.setInt('vendorId', responseData['vendorId']);
//           debugPrint("✅ Stored vendorId: ${responseData['vendorId']}");
//         } else {
//           debugPrint("⚠️ vendorId not found in response");
//         }
//
//         if (responseData['referenceId'] != null) {
//           await prefs.setString(
//             'customerId',
//             responseData['referenceId'].toString(),
//           );
//           debugPrint("✅ Stored customerId: ${responseData['referenceId']}");
//         }
//
//         await prefs.setString('businessVertical', _selectedBusinessVertical);
//         debugPrint("✅ Stored businessVertical: $_selectedBusinessVertical");
//
//         await prefs.setStringList('vendorBusinessVerticals', [
//           _selectedBusinessVertical,
//         ]);
//
//         final vendorData = {
//           ...responseData,
//           'businessVerticals': [_selectedBusinessVertical],
//           'name': name,
//           'email': email,
//           'mobileNumber': phoneDigits,
//           'city': city,
//         };
//         await prefs.setString('vendorData', jsonEncode(vendorData));
//
//         await prefs.setString('userName', name);
//         await prefs.setString('userEmail', email);
//         await prefs.setString('userPhone', phoneDigits);
//         await prefs.setString('userCity', city);
//
//         debugPrint("✅ All data stored successfully");
//
//         // Reset form if mounted
//         if (mounted) {
//           _nameController.clear();
//           _companyNameController.clear();
//           _emailController.clear();
//           _phoneController.clear();
//           _cityController.clear();
//           _referralCodeController.clear(); // ← NEW
//           setState(() => _selectedBusinessVertical = "FOOD_AND_BEVERAGES");
//         }
//
//         _showCustomAlert("Enquiry submitted successfully!", isError: false);
//
//         if (widget.parentContext.mounted) {
//           Navigator.pushReplacement(
//             widget.parentContext,
//             MaterialPageRoute(builder: (_) => const DemoDashboardScreen()),
//           );
//         }
//       } else {
//         String errorMessage = "Something went wrong";
//         try {
//           final errorData = jsonDecode(response.body);
//           if (errorData['message'] != null) {
//             errorMessage = errorData['message'];
//           }
//         } catch (e) {
//           final bodyLower = response.body.toLowerCase();
//           if (bodyLower.contains('email') && bodyLower.contains('exist')) {
//             errorMessage = "Email already exists";
//           } else if (bodyLower.contains('mobile') ||
//               bodyLower.contains('phone')) {
//             errorMessage = "Phone number already exists";
//           }
//         }
//         _showCustomAlert(errorMessage);
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       if (e.toString().toLowerCase().contains('timeout')) {
//         _showCustomAlert(
//           "Connection timeout. Please check your internet connection",
//         );
//       } else if (e.toString().toLowerCase().contains('network')) {
//         _showCustomAlert("Network error. Please check your connection");
//       } else {
//         _showCustomAlert("Something went wrong: ${e.toString()}");
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isOpen) return const SizedBox.shrink();
//
//     return AnimatedBuilder(
//       animation: _animationController!,
//       builder: (context, child) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               // Backdrop
//               GestureDetector(
//                 onTap: widget.onClose,
//                 child: Container(
//                   color: Colors.black.withOpacity(
//                     0.6 * (_fadeAnimation?.value ?? 0),
//                   ),
//                 ),
//               ),
//
//               // Modal
//               Center(
//                 child: FadeTransition(
//                   opacity: _fadeAnimation!,
//                   child: SlideTransition(
//                     position: _slideAnimation!,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       constraints: BoxConstraints(
//                         maxWidth: 400,
//                         maxHeight: MediaQuery.of(context).size.height * 0.85,
//                       ),
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 30,
//                             offset: Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Header
//                           SizedBox(
//                             height: 44,
//                             child: Stack(
//                               children: [
//                                 const Center(
//                                   child: Text(
//                                     "Book a Demo",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF333333),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 12,
//                                   top: 12,
//                                   child: GestureDetector(
//                                     onTap: widget.onClose,
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 20,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Form
//                           Flexible(
//                             child: SingleChildScrollView(
//                               physics: const BouncingScrollPhysics(),
//                               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   _buildTextField(
//                                     controller: _nameController,
//                                     hint: "Name *",
//                                     keyboardType: TextInputType.name,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _companyNameController,
//                                     hint: "Company Name",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _emailController,
//                                     hint: "Email *",
//                                     keyboardType: TextInputType.emailAddress,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _phoneController,
//                                     hint: "Phone *",
//                                     keyboardType: TextInputType.phone,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   _buildTextField(
//                                     controller: _cityController,
//                                     hint: "City *",
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   // ── NEW: Referral Code field ──
//                                   _buildTextField(
//                                     controller: _referralCodeController,
//                                     hint: "Referral Code (Optional)",
//                                     textCapitalization:
//                                         TextCapitalization.characters,
//                                   ),
//                                   const SizedBox(height: 10),
//
//                                   // Dropdown
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: const Color(0xFFE0E0E0),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: DropdownButtonHideUnderline(
//                                       child: DropdownButton<String>(
//                                         value: _selectedBusinessVertical,
//                                         isExpanded: true,
//                                         icon: const Padding(
//                                           padding: EdgeInsets.only(right: 12),
//                                           child: Icon(
//                                             Icons.arrow_drop_down,
//                                             color: Color(0xFF666666),
//                                           ),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                         ),
//                                         onChanged: (String? newValue) {
//                                           if (newValue != null && mounted) {
//                                             setState(() {
//                                               _selectedBusinessVertical =
//                                                   newValue;
//                                             });
//                                           }
//                                         },
//                                         items: _businessVerticalsOptions.map((
//                                           option,
//                                         ) {
//                                           return DropdownMenuItem<String>(
//                                             value: option["value"],
//                                             child: Text(option["label"]!),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 12),
//
//                                   // Login switch
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         "Already have an account?",
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Color(0xFF666666),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           widget.onClose();
//                                           widget.onLoginClick?.call();
//                                         },
//                                         style: TextButton.styleFrom(
//                                           padding: EdgeInsets.zero,
//                                         ),
//                                         child: const Text(
//                                           " Login here",
//                                           style: TextStyle(
//                                             color: Color(0xFFE66D33),
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 10),
//
//                                   // Submit button
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: _isLoading
//                                           ? null
//                                           : _handleSubmit,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: const Color(
//                                           0xFFE66D33,
//                                         ),
//                                         foregroundColor: Colors.white,
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 12,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                         ),
//                                         elevation: 0,
//                                       ),
//                                       child: _isLoading
//                                           ? const SizedBox(
//                                               width: 20,
//                                               height: 20,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 color: Colors.white,
//                                               ),
//                                             )
//                                           : const Text(
//                                               "Explore",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
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
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     TextCapitalization textCapitalization = TextCapitalization.none, // ← NEW
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         textCapitalization: textCapitalization, // ← NEW
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),
//         ),
//         style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
//       ),
//     );
//   }
// }
//
// // ─── Demo Dashboard Screen ────────────────────────────────────────────────────
// class DemoDashboardScreen extends StatelessWidget {
//   const DemoDashboardScreen({super.key});
//
//   Future<Map<String, dynamic>> _getStoredData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'userName': prefs.getString('userName') ?? '',
//       'userEmail': prefs.getString('userEmail') ?? '',
//       'userPhone': prefs.getString('userPhone') ?? '',
//       'userCity': prefs.getString('userCity') ?? '',
//       'businessVertical': prefs.getString('businessVertical') ?? '',
//       'vendorId': prefs.getInt('vendorId') ?? 0,
//       'customerId': prefs.getString('customerId') ?? '',
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF9FF),
//       appBar: AppBar(
//         title: const Text(
//           "Demo Dashboard",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFE66D33),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _getStoredData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final data = snapshot.data ?? {};
//           final vendorId = data['vendorId'];
//
//           debugPrint('🔍 DemoDashboard - Vendor ID from storage: $vendorId');
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 const Icon(Icons.check_circle, size: 80, color: Colors.green),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome to Demo Dashboard!",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2A0947),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Your enquiry has been submitted successfully",
//                   style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFEEECF5)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildInfoRow("Name", data['userName']),
//                       const Divider(),
//                       _buildInfoRow("Email", data['userEmail']),
//                       const Divider(),
//                       _buildInfoRow("Phone", data['userPhone']),
//                       const Divider(),
//                       _buildInfoRow("City", data['userCity']),
//                       const Divider(),
//                       _buildInfoRow(
//                         "Business Vertical",
//                         data['businessVertical']
//                             .replaceAll('_', ' ')
//                             .toLowerCase(),
//                       ),
//                       const Divider(),
//                       _buildInfoRow("Vendor ID", vendorId.toString()),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FoodRegistrationScreen01(
//                             isNewVendor: true,
//                             demoVendorId: vendorId.toString(),
//                             showAppBar: true,
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE66D33),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       "Continue to Registration",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1A0A2E),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value.isNotEmpty ? value : "Not provided",
//               style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../API/Apiclient.dart';
import '../Login Dialog/dialog screen.dart';
import '../Registration01/screens/food_registration_screen.dart';

class CTASection extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback? onLoginClick;
  final BuildContext parentContext;

  const CTASection({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.onLoginClick,
    required this.parentContext,
  });

  @override
  State<CTASection> createState() => _CTASectionState();
}

class _CTASectionState extends State<CTASection>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _companyNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _referralCodeController;
  bool _showLoginDialog = false;

  String _selectedBusinessVertical = "FOOD_AND_BEVERAGES";
  bool _isLoading = false;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final List<Map<String, String>> _businessVerticalsOptions = [
    {"value": "FOOD_AND_BEVERAGES", "label": "Food & Beverages"},
    {"value": "CATERINGS_SERVICES", "label": "Catering TableServices"},
    {"value": "LOGISTICS_SUPPLY", "label": "Logistics & Supply"},
    {"value": "FRESH_GROCERIES", "label": "Fresh Groceries"},
    {"value": "ENGINEERING_SERVICE", "label": "Engineering Service"},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _companyNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _referralCodeController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.isOpen) {
      _animationController?.forward();
    }
  }

  @override
  void didUpdateWidget(CTASection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _animationController?.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _animationController?.reverse();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _referralCodeController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _showCustomAlert(String message, {bool isError = true}) {
    if (widget.parentContext.mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: widget.parentContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const _LoadingOverlay(),
    );
  }

  void _hideLoadingOverlay() {
    if (widget.parentContext.mounted) {
      Navigator.of(widget.parentContext, rootNavigator: true).pop();
    }
  }

  Future<void> _handleSubmit() async {
    if (!mounted) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final referralCode = _referralCodeController.text.trim();

    // ── Validation ────────────────────────────────────────────────────────────
    if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
      _showCustomAlert("Please fill all required fields");
      return;
    }
    if (name.length < 2) {
      _showCustomAlert("Name must be at least 2 characters");
      return;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _showCustomAlert("Name should contain only letters");
      return;
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$',
    ).hasMatch(email)) {
      _showCustomAlert("Enter valid email (example@gmail.com)");
      return;
    }
    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length != 10) {
      _showCustomAlert("Enter valid 10-digit phone number");
      return;
    }
    if (city.length < 2) {
      _showCustomAlert("Enter valid city");
      return;
    }

    // ── Close the CTA modal, then show the loading overlay ───────────────────
    widget.onClose();

    await Future.delayed(const Duration(milliseconds: 200));

    _showLoadingOverlay();

    try {
      final payload = {
        "vendorId": 0,
        "parentId": null,
        "name": name,
        "email": email,
        "city": city,
        "mobileNumber": phoneDigits,
        "companyName": _companyNameController.text.trim().isEmpty
            ? null
            : _companyNameController.text.trim(),
        "role": "ROLE_VENDOR",
        "registerTime": DateTime.now().toUtc().toIso8601String(),
        "businessVerticals": [_selectedBusinessVertical],
        "referralCodeUsed": referralCode.isEmpty
            ? null
            : referralCode.toUpperCase(),
      };

      final response = await ApiClient.post(
        "api/vendor/enquiry",
        payload,
        service: "subscription",
      );

      _hideLoadingOverlay();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = {};
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }

        final prefs = await SharedPreferences.getInstance();

        if (responseData['vendorId'] != null) {
          await prefs.setInt('vendorId', responseData['vendorId']);
        }
        if (responseData['referenceId'] != null) {
          await prefs.setString(
            'customerId',
            responseData['referenceId'].toString(),
          );
        }
        await prefs.setString('businessVertical', _selectedBusinessVertical);
        await prefs.setStringList('vendorBusinessVerticals', [
          _selectedBusinessVertical,
        ]);

        final vendorData = {
          ...responseData,
          'businessVerticals': [_selectedBusinessVertical],
          'name': name,
          'email': email,
          'mobileNumber': phoneDigits,
          'city': city,
        };
        await prefs.setString('vendorData', jsonEncode(vendorData));
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);
        await prefs.setString('userPhone', phoneDigits);
        await prefs.setString('userCity', city);

        if (mounted) {
          _nameController.clear();
          _companyNameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _cityController.clear();
          _referralCodeController.clear();
          setState(() => _selectedBusinessVertical = "FOOD_AND_BEVERAGES");
        }

        _showCustomAlert("Enquiry submitted successfully!", isError: false);

        if (widget.parentContext.mounted) {
          Navigator.pushReplacement(
            widget.parentContext,
            MaterialPageRoute(builder: (_) => const DemoDashboardScreen()),
          );
        }
      } else {
        String errorMessage = "Something went wrong";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {
          final bodyLower = response.body.toLowerCase();
          if (bodyLower.contains('email') && bodyLower.contains('exist')) {
            errorMessage = "Email already exists";
          } else if (bodyLower.contains('mobile') ||
              bodyLower.contains('phone')) {
            errorMessage = "Phone number already exists";
          }
        }
        _showCustomAlert(errorMessage);
      }
    } catch (e) {
      _hideLoadingOverlay();
      if (e.toString().toLowerCase().contains('timeout')) {
        _showCustomAlert(
          "Connection timeout. Please check your internet connection",
        );
      } else if (e.toString().toLowerCase().contains('network')) {
        _showCustomAlert("Network error. Please check your connection");
      } else {
        _showCustomAlert("Something went wrong: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  color: Colors.black.withOpacity(
                    0.6 * (_fadeAnimation?.value ?? 0),
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: BoxConstraints(
                        maxWidth: 400,
                        maxHeight: MediaQuery.of(context).size.height * 0.85,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                          // Header
                          SizedBox(
                            height: 44,
                            child: Stack(
                              children: [
                                const Center(
                                  child: Text(
                                    "Book a Demo",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: GestureDetector(
                                    onTap: widget.onClose,
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Form
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    hint: "Name *",
                                    keyboardType: TextInputType.name,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: _companyNameController,
                                    hint: "Company Name",
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: _emailController,
                                    hint: "Email *",
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: _phoneController,
                                    hint: "Phone *",
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: _cityController,
                                    hint: "City *",
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField(
                                    controller: _referralCodeController,
                                    hint: "Referral Code (Optional)",
                                    textCapitalization:
                                        TextCapitalization.characters,
                                  ),
                                  const SizedBox(height: 10),

                                  // Dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedBusinessVertical,
                                        isExpanded: true,
                                        icon: const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        onChanged: (String? newValue) {
                                          if (newValue != null && mounted) {
                                            setState(
                                              () => _selectedBusinessVertical =
                                                  newValue,
                                            );
                                          }
                                        },
                                        items: _businessVerticalsOptions
                                            .map(
                                              (option) =>
                                                  DropdownMenuItem<String>(
                                                    value: option["value"],
                                                    child: Text(
                                                      option["label"]!,
                                                    ),
                                                  ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Already have an account?",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          widget.onClose();

                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            if (widget.parentContext.mounted) {
                                              showDialog(
                                                context: widget.parentContext,
                                                barrierDismissible: true,
                                                builder: (context) => LoginDialog(
                                                  onClose: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  onSignUpClick: () {
                                                  },
                                                ),
                                              );
                                            }
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Text(
                                          " Login here",
                                          style: TextStyle(
                                            color: Color(0xFFE66D33),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE66D33,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Explore",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
      ),
    );
  }
}

// ─── Full-screen loading overlay widget ──────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back-button from dismissing it
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE66D33)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Submitting enquiry…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please wait a moment',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Demo Dashboard Screen ────────────────────────────────────────────────────
class DemoDashboardScreen extends StatelessWidget {
  const DemoDashboardScreen({super.key});

  Future<Map<String, dynamic>> _getStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? '',
      'userEmail': prefs.getString('userEmail') ?? '',
      'userPhone': prefs.getString('userPhone') ?? '',
      'userCity': prefs.getString('userCity') ?? '',
      'businessVertical': prefs.getString('businessVertical') ?? '',
      'vendorId': prefs.getInt('vendorId') ?? 0,
      'customerId': prefs.getString('customerId') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FF),
      appBar: AppBar(
        title: const Text(
          "Demo Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE66D33),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getStoredData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? {};
          final vendorId = data['vendorId'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  "Welcome to Demo Dashboard!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A0947),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your enquiry has been submitted successfully",
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEECF5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Name", data['userName']),
                      const Divider(),
                      _buildInfoRow("Email", data['userEmail']),
                      const Divider(),
                      _buildInfoRow("Phone", data['userPhone']),
                      const Divider(),
                      _buildInfoRow("City", data['userCity']),
                      const Divider(),
                      _buildInfoRow(
                        "Business Vertical",
                        data['businessVertical']
                            .replaceAll('_', ' ')
                            .toLowerCase(),
                      ),
                      const Divider(),
                      _buildInfoRow("Vendor ID", vendorId.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodRegistrationScreen01(
                            isNewVendor: true,
                            demoVendorId: vendorId.toString(),
                            showAppBar: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE66D33),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Continue to Registration",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A0A2E),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : "Not provided",
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B5E7A)),
            ),
          ),
        ],
      ),
    );
  }
}
