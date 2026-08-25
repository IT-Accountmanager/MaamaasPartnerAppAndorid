// import 'package:flutter/material.dart';
//
// import 'AdPreviewPanel.dart';
// import 'BudgetStep.dart';
// import 'CampaignConstants.dart';
// import 'GoalDetailsStep.dart';
// import 'MediumMediaStep.dart';
// import 'PromotionalModel.dart';
// import 'StepProgressBar.dart';
// import 'TargetingStep.dart';
//
//
// class CreateCampaignScreen extends StatefulWidget {
//   const CreateCampaignScreen({super.key});
//
//   @override
//   State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
// }
//
// class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
//   int _currentStep = 1;
//   CampaignFormData _formData = CampaignFormData();
//   bool _couponApplied = false;
//   double _couponDiscount = 0;
//   final _scrollController = ScrollController();
//
//   // ─── NAVIGATION ─────────────────────────────────────────────────
//   void _handleNext() {
//     int next = _currentStep + 1;
//     // Skip step 2 logic mirrors the React: digital → step 4
//     if (_currentStep == 2 && _formData.mediums.contains('digital')) {
//       next = 4;
//     }
//     setState(() => _currentStep = next.clamp(1, 4));
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }
//
//   void _handleBack() {
//     int prev = _currentStep - 1;
//     if (_currentStep == 4 && _formData.mediums.contains('digital')) {
//       prev = 2;
//     }
//     setState(() => _currentStep = prev.clamp(1, 4));
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }
//
//   // ─── FORM UPDATERS ───────────────────────────────────────────────
//   void _toggleList(String field, String value) {
//     setState(() {
//       List<String> current;
//       switch (field) {
//         case 'mediums':
//           current = List.from(_formData.mediums);
//           break;
//         case 'audience':
//           current = List.from(_formData.audience);
//           break;
//         case 'mediaTypes':
//           current = List.from(_formData.mediaTypes);
//           break;
//         case 'appTypes':
//           current = List.from(_formData.appTypes);
//           break;
//         case 'placements':
//           current = List.from(_formData.placements);
//           break;
//         default:
//           return;
//       }
//       if (current.contains(value)) {
//         current.remove(value);
//       } else {
//         current.add(value);
//       }
//       switch (field) {
//         case 'mediums':
//           _formData = _formData.copyWith(mediums: current);
//           break;
//         case 'audience':
//           _formData = _formData.copyWith(audience: current);
//           break;
//         case 'mediaTypes':
//           _formData = _formData.copyWith(mediaTypes: current);
//           break;
//         case 'appTypes':
//           _formData = _formData.copyWith(appTypes: current);
//           break;
//         case 'placements':
//           _formData = _formData.copyWith(placements: current);
//           break;
//       }
//     });
//   }
//
//   void _showAdPreview() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.75,
//         maxChildSize: 0.95,
//         minChildSize: 0.4,
//         builder: (_, ctrl) => SingleChildScrollView(
//           controller: ctrl,
//           child: AdPreviewPanel(formData: _formData),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentStep() {
//     switch (_currentStep) {
//       case 1:
//         return GoalDetailsStep(
//           formData: _formData,
//           onGoalChange: (v) => setState(
//             () => _formData = _formData.copyWith(goal: v, subGoal: ''),
//           ),
//           onSubGoalChange: (v) =>
//               setState(() => _formData = _formData.copyWith(subGoal: v)),
//           onNameChange: (v) =>
//               setState(() => _formData = _formData.copyWith(name: v)),
//           onNext: _handleNext,
//         );
//       case 2:
//         return MediumMediaStep(
//           formData: _formData,
//           onToggleMedium: (v) => _toggleList('mediums', v),
//           onTogglePlacement: (v) => _toggleList('placements', v),
//           onToggleAudience: (v) => _toggleList('audience', v),
//           onToggleMediaType: (v) => _toggleList('mediaTypes', v),
//           onToggleAppType: (v) => _toggleList('appTypes', v),
//           onDurationSelect: (v) => setState(
//             () => _formData = _formData.copyWith(durationSeconds: v),
//           ),
//           onCallToActionChange: (v) =>
//               setState(() => _formData = _formData.copyWith(callToAction: v)),
//           onImageUpload: (_) {
//             // In a real app: use image_picker package
//             // Mocked: add a placeholder URL
//             setState(() {
//               final imgs = List<String>.from(_formData.images);
//               imgs.add(
//                 'https://picsum.photos/seed/${DateTime.now().millisecond}/400/300',
//               );
//               _formData = _formData.copyWith(images: imgs);
//             });
//           },
//           onVideoUpload: (_) {
//             // In a real app: use file_picker
//             setState(
//               () => _formData = _formData.copyWith(
//                 videoFile: 'placeholder_video',
//               ),
//             );
//           },
//           onDescriptionChange: (v) {
//             final newDesc = Map<String, String>.from(
//               _formData.mediaDescriptions,
//             );
//             newDesc['image'] = v;
//             setState(
//               () => _formData = _formData.copyWith(mediaDescriptions: newDesc),
//             );
//           },
//           onWebsiteUrlChange: (v) =>
//               setState(() => _formData = _formData.copyWith(websiteUrl: v)),
//           onNext: _handleNext,
//           onBack: _handleBack,
//         );
//       case 3:
//         return TargetingStep(
//           formData: _formData,
//           onLeadsConfigChange: (lc) => setState(
//             () => _formData = _formData.copyWith(
//               goalConfig: _formData.goalConfig.copyWith(leads: lc),
//             ),
//           ),
//           onDiscountConfigChange: (dc) => setState(
//             () => _formData = _formData.copyWith(
//               goalConfig: _formData.goalConfig.copyWith(discount: dc),
//             ),
//           ),
//           onNext: _handleNext,
//           onBack: _handleBack,
//         );
//       case 4:
//         return BudgetStep(
//           formData: _formData,
//           onInvestmentChange: (v) =>
//               setState(() => _formData = _formData.copyWith(investment: v)),
//           onDaysChange: (v) =>
//               setState(() => _formData = _formData.copyWith(days: v)),
//           onCouponChange: (v) =>
//               setState(() => _formData = _formData.copyWith(couponCode: v)),
//           onApplyCoupon: _handleApplyCoupon,
//           onPayNow: _handlePayment,
//           onBack: _handleBack,
//           couponApplied: _couponApplied,
//           couponDiscount: _couponDiscount,
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Future<void> _handleApplyCoupon() async {
//     if (_formData.couponCode.isEmpty) {
//       _showSnack('Please enter a coupon code', isError: true);
//       return;
//     }
//     // Simulate API call
//     await Future.delayed(const Duration(milliseconds: 800));
//     setState(() {
//       _couponApplied = true;
//       final investment = double.tryParse(_formData.investment) ?? 0;
//       _couponDiscount = investment * 0.10; // mock 10% discount
//     });
//     _showSnack('Coupon applied successfully!');
//   }
//
//   void _handlePayment() async {
//     // Show loading
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(
//         child: CircularProgressIndicator(color: AppColors.primary),
//       ),
//     );
//     // Simulate payment flow
//     await Future.delayed(const Duration(seconds: 2));
//     if (mounted) {
//       Navigator.pop(context); // dismiss loader
//       _showCampaignCreatedDialog();
//     }
//   }
//
//   void _showCampaignCreatedDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: const BoxDecoration(
//                 color: AppColors.greenBg,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_circle,
//                 size: 36,
//                 color: AppColors.success,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Campaign Created!',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your campaign "${_formData.name.isNotEmpty ? _formData.name : _formData.campaignId}" has been created successfully.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _formData = CampaignFormData();
//                   _currentStep = 1;
//                   _couponApplied = false;
//                   _couponDiscount = 0;
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'New Campaign',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSnack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : AppColors.success,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F4F6),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         titleSpacing: 16,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Create Campaign',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//
//           ],
//         ),
//         // actions: [
//         //   // Preview button
//         //   TextButton.icon(
//         //     onPressed: _showAdPreview,
//         //     icon: const Icon(
//         //       Icons.visibility_outlined,
//         //       size: 16,
//         //       color: AppColors.primary,
//         //     ),
//         //     label: const Text(
//         //       'Preview',
//         //       style: TextStyle(
//         //         color: AppColors.primary,
//         //         fontWeight: FontWeight.w600,
//         //         fontSize: 13,
//         //       ),
//         //     ),
//         //   ),
//         // ],
//       ),
//
//       body: Column(
//         children: [
//           // Progress bar
//           StepProgressBar(
//             currentStep: _currentStep,
//             steps: CampaignConstants.steps,
//             onStepTap: (step) {
//               if (_formData.goal == 'discount' && step == 2) return;
//               setState(() => _currentStep = step);
//             },
//           ),
//
//           // Content
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               child: _buildCurrentStep(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
