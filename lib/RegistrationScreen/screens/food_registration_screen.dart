// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Authservice.dart';
// import '../models/vendor_form_data.dart';
// import '../steps/company_profile_step.dart';
// import '../steps/contact_details_step.dart';
// import '../steps/license_documents_step.dart';
// import '../steps/preview_step.dart';
// import '../services/vendor_api_service.dart';
//
// // Design tokens
// const Color _kOrange = Color(0xFFE66D33);
// const Color _kOrangeDark = Color(0xFFE66D33);
// const Color _kOrangeLight = Color(0xFFFEF3E8);
// const Color _kGreen = Color(0xFF10B981);
// const Color _kGreenDark = Color(0xFF059669);
// const Color _kGreenLight = Color(0xFFD1FAE5);
// const Color _kWhite = Color(0xFFFFFFFF);
// const Color _kBackground = Color(0xFFF7F8FC);
// const Color _kBorder = Color(0xFFEEEFF5);
// const Color _kTextPrimary = Color(0xFF111827);
// const Color _kTextSecondary = Color(0xFF6B7280);
// const Color _kTextTertiary = Color(0xFFB0B3C1);
// const Color _kError = Color(0xFFEF4444);
// const Color _kErrorLight = Color(0xFFFEE2E2);
//
// const LinearGradient _kGrad = LinearGradient(
//   colors: [_kOrange, _kOrangeDark],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class FoodRegistrationScreen extends StatefulWidget {
//   final bool isNewVendor;
//   final String? demoVendorId;
//   final bool showAppBar;
//
//   const FoodRegistrationScreen({
//     super.key,
//     this.isNewVendor = false,
//     this.demoVendorId,
//     this.showAppBar = false,
//   });
//
//   @override
//   State<FoodRegistrationScreen> createState() => _FoodRegistrationScreenState();
// }
//
// class _FoodRegistrationScreenState extends State<FoodRegistrationScreen>
//     with SingleTickerProviderStateMixin {
//   int _currentStep = 1;
//   VendorFormData _formData = VendorFormData();
//   bool _isLoading = true;
//   String _vendorId = '';
//   String? _errorMessage;
//   late TabController _tc;
//
//   // Step meta — label + icon shown in the scrollable tab strip
//   static const _steps = [
//     {'icon': Icons.business_rounded, 'label': 'Company'},
//     {'icon': Icons.contact_phone_rounded, 'label': 'Contact'},
//     {'icon': Icons.folder_rounded, 'label': 'Documents'},
//     {'icon': Icons.preview_rounded, 'label': 'Preview'},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _tc = TabController(length: 4, vsync: this);
//
//     _tc.addListener(() {
//       if (mounted) {
//         setState(() {
//           _currentStep = _tc.index + 1;
//         });
//       }
//     });
//
//     _loadVendorIdAndData();
//   }
//
//   @override
//   void dispose() {
//     _tc.dispose();
//     super.dispose();
//   }
//
//   // ── Data loading ─────────────────────────────────────────────────────────────
//   Future<void> _loadVendorIdAndData() async {
//     setState(() => _isLoading = true);
//
//     try {
//       if (widget.demoVendorId != null && widget.demoVendorId!.isNotEmpty) {
//         setState(() => _vendorId = widget.demoVendorId!);
//         debugPrint('✅ Using demo vendor ID: $_vendorId');
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // 2 — stored in SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       final storedVendorId = prefs.getInt('vendorId');
//
//       if (storedVendorId != null && storedVendorId > 0) {
//         setState(() => _vendorId = storedVendorId.toString());
//         debugPrint('✅ Using stored vendor ID: $_vendorId');
//
//         final existingData = await VendorApiService.getVendorFormData(
//           _vendorId,
//         );
//         if (existingData != null && mounted) {
//           setState(() => _formData = existingData);
//         }
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // 3 — from auth service
//       final vendorId = await Authservice.getVendorId();
//       if (vendorId == null) {
//         _errorMessage = 'Please login again';
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Please login again'),
//               backgroundColor: _kError,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       setState(() => _vendorId = vendorId.toString());
//       debugPrint('✅ Vendor ID from auth: $_vendorId');
//
//       if (!widget.isNewVendor) {
//         final existingData = await VendorApiService.getVendorFormData(
//           _vendorId,
//         );
//         if (existingData != null && mounted) {
//           setState(() => _formData = existingData);
//           debugPrint('✅ Loaded existing vendor data');
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ Error: $e');
//       _errorMessage = 'Error loading data: $e';
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading data: $e'),
//             backgroundColor: _kError,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // ── Navigation ───────────────────────────────────────────────────────────────
//   void _nextStep() {
//     if (_currentStep < 4) setState(() => _currentStep++);
//   }
//
//   void _backStep() {
//     if (_currentStep > 1) setState(() => _currentStep--);
//   }
//
//   void _goToStep(int step) => setState(() => _currentStep = step);
//
//   /// Back arrow always goes to the home page (or pops if possible).
//   void _handleBack() {
//     if (Navigator.of(context).canPop()) {
//       Navigator.of(context).pop();
//     } else {
//       Navigator.pushReplacementNamed(context, '/home');
//     }
//   }
//
//   // ── Step content ─────────────────────────────────────────────────────────────
//   Widget _buildCurrentStep() {
//     switch (_currentStep) {
//       case 1:
//         return CompanyProfileStep(
//           formData: _formData,
//           onChanged: (u) => setState(() => _formData = u),
//           onNext: _nextStep,
//         );
//       case 2:
//         return ContactDetailsStep(
//           formData: _formData,
//           onChanged: (u) => setState(() => _formData = u),
//           onNext: _nextStep,
//           onBack: _backStep,
//         );
//       case 3:
//         return LicenseDocumentsStep(
//           formData: _formData,
//           onChanged: (u) => setState(() => _formData = u),
//           onNext: _nextStep,
//           onBack: _backStep,
//         );
//       case 4:
//         return PreviewStep(
//           formData: _formData,
//           onBack: _backStep,
//           vendorId: _vendorId,
//           isNewVendor: widget.isNewVendor,
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   // ── Scrollable step tab strip ───────────────────────────────────────────────
//   Widget _buildStepTabBar() {
//     return Container(
//       // REMOVED: color: _kWhite - this was causing the error
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
//       decoration: const BoxDecoration(
//         color: _kWhite, // Color moved here
//         border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
//       ),
//       child: Row(
//         children: [
//           // Back button (fixed left) - matches SettingsScreen style
//           GestureDetector(
//             onTap: _handleBack,
//             child: Container(
//               width: 36,
//               height: 36,
//               margin: const EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: _kBackground,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: _kBorder),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: _kTextPrimary,
//                 size: 16,
//               ),
//             ),
//           ),
//
//           // Scrollable tab chips (fills the middle)
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: Row(
//                 children: List.generate(_steps.length, (i) {
//                   final stepNum = i + 1;
//                   final isActive = _tc.index == i;
//                   final isDone = _tc.index > i;
//                   final label = _steps[i]['label'] as String;
//                   final icon = _steps[i]['icon'] as IconData;
//
//                   return GestureDetector(
//                     onTap: () => _tc.animateTo(i),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       margin: const EdgeInsets.only(right: 8),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isActive
//                             ? _kGreen
//                             : isDone
//                             ? _kGreen
//                             : _kOrange,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Badge: number or green tick
//                           Container(
//                             width: 18,
//                             height: 18,
//                             decoration: BoxDecoration(
//                               color: isActive
//                                   ? _kWhite.withOpacity(0.2)
//                                   : isDone
//                                   ? _kWhite.withOpacity(0.3)
//                                   : _kBorder,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: isDone
//                                   ? const Icon(
//                                       Icons.check_rounded,
//                                       color: _kWhite,
//                                       size: 10,
//                                     )
//                                   : Text(
//                                       '$stepNum',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w700,
//                                         color: isActive
//                                             ? _kWhite
//                                             : _kTextSecondary,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Icon(icon, size: 14, color: _kWhite),
//                           const SizedBox(width: 4),
//                           Text(
//                             label,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: isActive
//                                   ? FontWeight.w700
//                                   : FontWeight.w500,
//                               color: _kWhite,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Build ─────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kBackground,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildStepTabBar(),
//
//             Expanded(
//               child: _isLoading
//                   ? const Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircularProgressIndicator(
//                             color: _kOrange,
//                             strokeWidth: 2,
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             'Loading vendor data...',
//                             style: TextStyle(
//                               color: _kTextSecondary,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : _vendorId.isEmpty
//                   ? Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 72,
//                               height: 72,
//                               decoration: const BoxDecoration(
//                                 color: _kErrorLight,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.error_outline_rounded,
//                                 color: _kError,
//                                 size: 32,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Authentication Error',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w800,
//                                 color: _kTextPrimary,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _errorMessage ?? 'Please login again',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: _kTextSecondary,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 20),
//                             GestureDetector(
//                               onTap: _loadVendorIdAndData,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 24,
//                                   vertical: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   gradient: _kGrad,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: _kOrange.withOpacity(0.3),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.refresh_rounded,
//                                       color: _kWhite,
//                                       size: 18,
//                                     ),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Retry',
//                                       style: TextStyle(
//                                         color: _kWhite,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 280),
//                       transitionBuilder: (child, animation) => FadeTransition(
//                         opacity: animation,
//                         child: SlideTransition(
//                           position: Tween<Offset>(
//                             begin: const Offset(0.05, 0),
//                             end: Offset.zero,
//                           ).animate(animation),
//                           child: child,
//                         ),
//                       ),
//                       child: KeyedSubtree(
//                         key: ValueKey(_currentStep),
//                         child: TabBarView(
//                           controller: _tc,
//                           children: [
//                             CompanyProfileStep(
//                               formData: _formData,
//                               onChanged: (u) => setState(() => _formData = u),
//                               onNext: () => _tc.animateTo(1),
//                             ),
//                             ContactDetailsStep(
//                               formData: _formData,
//                               onChanged: (u) => setState(() => _formData = u),
//                               onNext: () => _tc.animateTo(2),
//                               onBack: () => _tc.animateTo(0),
//                             ),
//                             LicenseDocumentsStep(
//                               formData: _formData,
//                               onChanged: (u) => setState(() => _formData = u),
//                               onNext: () => _tc.animateTo(3),
//                               onBack: () => _tc.animateTo(1),
//                             ),
//                             PreviewStep(
//                               formData: _formData,
//                               onBack: () => _tc.animateTo(2),
//                               vendorId: _vendorId,
//                               isNewVendor: widget.isNewVendor,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
//
// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});
//
//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }
//
// class _MyWidgetState extends State<MyWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

import 'package:flutter/cupertino.dart';

class MyClass extends StatefulWidget {
  const MyClass({super.key});

  @override
  State<MyClass> createState() => _State();
}

class _State extends State<MyClass> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
