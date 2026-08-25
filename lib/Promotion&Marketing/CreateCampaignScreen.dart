// // lib/Promotion&Marketing/CreateCampaignScreen.dart
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'Models.dart';
// import 'CampaignProgress.dart';
// import 'GoalDetailsWidget.dart';
// import 'MediumMediaWidget.dart';
// import 'Services.dart';
// import 'TargetingConfigWidget.dart';
// import 'BudgetReviewWidget.dart';
//
// class CreateCampaignScreen extends StatefulWidget {
//   const CreateCampaignScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
// }
//
// class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
//   late ApiService _apiService;
//
//   int _currentStep = 1;
//   bool _isLoading = false;
//   List<MenuItem> _menuItems = [];
//   List<Screen> _screens = [];
//
//   CampaignData _formData = CampaignData(
//     campaignId:
//         'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}',
//     goalConfig: GoalConfig(
//       leads: LeadsConfig(ageRange: [18, 60]),
//       discount: DiscountConfig(),
//     ),
//   );
//
//   final List<Map<String, dynamic>> _steps = [
//     {'number': 1, 'label': 'Goal Details'},
//     {'number': 2, 'label': 'Medium & Media'},
//     {'number': 3, 'label': 'Targeting'},
//     {'number': 4, 'label': 'Budget'},
//   ];
//
//   final List<Map<String, String>> _goals = [
//     {'value': 'leads', 'label': 'Leads'},
//     {'value': 'branding', 'label': 'Branding'},
//     {'value': 'discount', 'label': 'Discount'},
//   ];
//
//   final Map<String, List<Map<String, dynamic>>> _subGoals = {
//     'leads': [
//       {
//         'value': 'whatsapp_messages',
//         'label': 'Get more WhatsApp messages',
//         'description':
//             'Create an ad that includes the call-to-action button from your Page.',
//         'icon': Icons.chat,
//       },
//       {
//         'value': 'more_calls',
//         'label': 'Get more calls',
//         'description': '',
//         'icon': Icons.phone,
//       },
//       {
//         'value': 'website_visitors',
//         'label': 'Get more website visitors',
//         'description': 'Create an ad to send people to your website.',
//         'icon': Icons.public,
//       },
//       {
//         'value': 'more_leads',
//         'label': 'Get more leads',
//         'description':
//             'Create an ad to request contact details from potential customers.',
//         'icon': Icons.contact_mail,
//       },
//     ],
//     'branding': [
//       {
//         'value': 'awareness',
//         'label': 'Brand Awareness',
//         'description': 'Introduce your brand to new audiences',
//         'icon': Icons.visibility,
//       },
//       {
//         'value': 'recall',
//         'label': 'Brand Recall',
//         'description': 'Stay top of mind with your audience',
//         'icon': Icons.campaign,
//       },
//       {
//         'value': 'premium',
//         'label': 'Premium Positioning',
//         'description': 'Build a high-value brand perception',
//         'icon': Icons.star,
//       },
//     ],
//     'discount': [
//       {
//         'value': 'new_customers',
//         'label': 'New Customers',
//         'description': 'Attract first-time buyers with deals',
//         'icon': Icons.people,
//       },
//       {
//         'value': 'existing_customers',
//         'label': 'Existing Customers',
//         'description': 'Reward loyalty with exclusive offers',
//         'icon': Icons.check_circle,
//       },
//       {
//         'value': 'all_customers',
//         'label': 'All Customers',
//         'description': 'Run a wide discount for everyone',
//         'icon': Icons.groups,
//       },
//       {
//         'value': 'specific_items',
//         'label': 'Specific Items',
//         'description': 'Discount selected products only',
//         'icon': Icons.shopping_cart,
//       },
//     ],
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _apiService = ApiService();
//     _loadInitialData();
//   }
//
//   Future<void> _loadInitialData() async {
//     setState(() => _isLoading = true);
//     try {
//       final menuItems = await _apiService.fetchMenuItems();
//       final screens = await _apiService.fetchScreens();
//       setState(() {
//         _menuItems = menuItems;
//         _screens = screens;
//       });
//     } catch (e) {
//       _showErrorSnackBar('Failed to load data: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _updateFormData(CampaignData newData) {
//     setState(() {
//       _formData = newData;
//     });
//   }
//
//   void _updateGoalConfig(String goalType, String field, dynamic value) {
//     final newGoalConfig = GoalConfig(
//       leads: _formData.goalConfig.leads,
//       branding: _formData.goalConfig.branding,
//       discount: _formData.goalConfig.discount,
//     );
//
//     if (goalType == 'leads') {
//       final newLeads = LeadsConfig(
//         leadSource: _formData.goalConfig.leads?.leadSource,
//         ctaType: _formData.goalConfig.leads?.ctaType,
//         contactName: _formData.goalConfig.leads?.contactName,
//         contactMobile: _formData.goalConfig.leads?.contactMobile,
//         serviceInterest: _formData.goalConfig.leads?.serviceInterest,
//         gender: _formData.goalConfig.leads?.gender,
//         ageRange: _formData.goalConfig.leads?.ageRange,
//         locations: _formData.goalConfig.leads?.locations,
//         interests: _formData.goalConfig.leads?.interests,
//         followUpDate: _formData.goalConfig.leads?.followUpDate,
//       );
//
//       switch (field) {
//         case 'gender':
//           newLeads.gender = value;
//           break;
//         case 'ageRange':
//           newLeads.ageRange = value;
//           break;
//         case 'contactMobile':
//           newLeads.contactMobile = value;
//           break;
//         case 'interests':
//           newLeads.interests = value;
//           break;
//         case 'locations':
//           newLeads.locations = value;
//           break;
//       }
//       newGoalConfig.leads = newLeads;
//     } else if (goalType == 'discount') {
//       final newDiscount = DiscountConfig(
//         applicableOn: _formData.goalConfig.discount?.applicableOn,
//         selectedItems: _formData.goalConfig.discount?.selectedItems,
//         discountType: _formData.goalConfig.discount?.discountType,
//         discountValue: _formData.goalConfig.discount?.discountValue,
//         validDays: _formData.goalConfig.discount?.validDays,
//         timeSlot: _formData.goalConfig.discount?.timeSlot,
//         startTime: _formData.goalConfig.discount?.startTime,
//         endTime: _formData.goalConfig.discount?.endTime,
//         timeCategory: _formData.goalConfig.discount?.timeCategory,
//         couponCode: _formData.goalConfig.discount?.couponCode,
//         minimumOrderValue: _formData.goalConfig.discount?.minimumOrderValue,
//         couponType: _formData.goalConfig.discount?.couponType,
//         startDate: _formData.goalConfig.discount?.startDate,
//         endDate: _formData.goalConfig.discount?.endDate,
//       );
//
//       switch (field) {
//         case 'discountType':
//           newDiscount.discountType = value;
//           break;
//         case 'discountValue':
//           newDiscount.discountValue = value;
//           break;
//         case 'selectedItems':
//           newDiscount.selectedItems = value;
//           break;
//         case 'startDate':
//           newDiscount.startDate = value;
//           break;
//         case 'endDate':
//           newDiscount.endDate = value;
//           break;
//         case 'startTime':
//           newDiscount.startTime = value;
//           break;
//         case 'endTime':
//           newDiscount.endTime = value;
//           break;
//         case 'timeCategory':
//           newDiscount.timeCategory = value;
//           break;
//         case 'couponCode':
//           newDiscount.couponCode = value;
//           break;
//         case 'minimumOrderValue':
//           newDiscount.minimumOrderValue = value;
//           break;
//         case 'couponType':
//           newDiscount.couponType = value;
//           break;
//       }
//       newGoalConfig.discount = newDiscount;
//     }
//
//     _updateFormData(_formData.copyWith(goalConfig: newGoalConfig));
//   }
//
//   void _handleMultiSelect(String field, String value) {
//     final currentList = _getListField(field);
//     final updatedList = currentList.contains(value)
//         ? currentList.where((v) => v != value).toList()
//         : [...currentList, value];
//
//     _updateFormData(
//       _formData.copyWith(
//         mediums: field == 'mediums' ? updatedList : _formData.mediums,
//         audience: field == 'audience' ? updatedList : _formData.audience,
//         mediaTypes: field == 'mediaTypes' ? updatedList : _formData.mediaTypes,
//         placements: field == 'placements' ? updatedList : _formData.placements,
//         appTypes: field == 'appTypes' ? updatedList : _formData.appTypes,
//       ),
//     );
//   }
//
//   List<String> _getListField(String field) {
//     switch (field) {
//       case 'mediums':
//         return _formData.mediums;
//       case 'audience':
//         return _formData.audience;
//       case 'mediaTypes':
//         return _formData.mediaTypes;
//       case 'placements':
//         return _formData.placements;
//       case 'appTypes':
//         return _formData.appTypes;
//       default:
//         return [];
//     }
//   }
//
//   Future<void> _handleImageUpload() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       _updateFormData(_formData.copyWith(images: [pickedFile.path]));
//     }
//   }
//
//   Future<void> _handleVideoUpload() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       _updateFormData(_formData.copyWith(videoFile: pickedFile.path));
//     }
//   }
//
//   bool _isStepValid() {
//     switch (_currentStep) {
//       case 1:
//         if (_formData.goal == 'discount') return _formData.goal != null;
//         return _formData.goal != null && _formData.subGoal != null;
//       case 2:
//         final mediaValid = _formData.mediaTypes.isNotEmpty;
//         final mediumValid = _formData.mediums.isNotEmpty;
//         final appAudienceValid = _formData.mediums.contains('app')
//             ? _formData.audience.isNotEmpty
//             : true;
//         return mediaValid && mediumValid && appAudienceValid;
//       case 3:
//         return true;
//       case 4:
//         return _formData.days != null ||
//             _formData.reach != null ||
//             _formData.investment != null;
//       default:
//         return true;
//     }
//   }
//
//   void _handleNext() {
//     if (!_isStepValid()) {
//       _showErrorSnackBar('Please complete all required fields');
//       return;
//     }
//
//     // Custom navigation for digital medium
//     if (_currentStep == 2 && _formData.mediums.contains('digital')) {
//       setState(() => _currentStep = 4);
//       return;
//     }
//
//     if (_currentStep < _steps.length) {
//       setState(() => _currentStep++);
//     }
//   }
//
//   void _handleBack() {
//     if (_currentStep == 4 && _formData.mediums.contains('digital')) {
//       setState(() => _currentStep = 2);
//       return;
//     }
//
//     if (_currentStep > 1) {
//       setState(() => _currentStep--);
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Create Campaign'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 CampaignProgress(
//                   currentStep: _currentStep,
//                   steps: _steps,
//                   onStepTap: (step) {
//                     if (_formData.goal == 'discount' && step == 2) return;
//                     setState(() => _currentStep = step);
//                   },
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: _buildCurrentStep(),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
//
//   Widget _buildCurrentStep() {
//     switch (_currentStep) {
//       case 1:
//         return GoalDetailsWidget(
//           formData: _formData,
//           goals: _goals,
//           subGoals: _subGoals,
//           onInputChange: (field, value) {
//             _updateFormData(
//               _formData.copyWith(
//                 goal: field == 'goal' ? value : _formData.goal,
//                 subGoal: field == 'subGoal' ? value : _formData.subGoal,
//                 name: field == 'name' ? value : _formData.name,
//               ),
//             );
//           },
//           onGoalConfigChange: _updateGoalConfig,
//           onNext: _handleNext,
//           menuItems: _menuItems,
//         );
//       case 2:
//         return MediumMediaWidget(
//           formData: _formData,
//           goals: _goals,
//           subGoals: _subGoals,
//           onInputChange: (field, value) {
//             _updateFormData(
//               _formData.copyWith(
//                 callToAction: field == 'callToAction'
//                     ? value
//                     : _formData.callToAction,
//                 durationSeconds: field == 'durationSeconds'
//                     ? int.tryParse(value.toString())
//                     : _formData.durationSeconds,
//                 websiteUrl: field == 'websiteUrl'
//                     ? value
//                     : _formData.websiteUrl,
//               ),
//             );
//           },
//           onMultiSelect: _handleMultiSelect,
//           onImageUpload: _handleImageUpload,
//           onVideoUpload: _handleVideoUpload,
//           onNext: _handleNext,
//           onBack: _handleBack,
//           screensData: _screens,
//           placementsByMedium: _getPlacementsByMedium(),
//         );
//       case 3:
//         return TargetingConfigWidget(
//           formData: _formData,
//           goalConfig: _formData.goalConfig,
//           onGoalConfigChange: _updateGoalConfig,
//           onNext: _handleNext,
//           onBack: _handleBack,
//           menuItems: _menuItems,
//         );
//       case 4:
//         return BudgetReviewWidget(
//           formData: _formData,
//           onInputChange: (field, value) {
//             _updateFormData(
//               _formData.copyWith(
//                 days: field == 'days' ? value : _formData.days,
//                 reach: field == 'reach' ? value : _formData.reach,
//                 investment: field == 'investment'
//                     ? value
//                     : _formData.investment,
//                 startDate: field == 'startDate' ? value : _formData.startDate,
//                 endDate: field == 'endDate' ? value : _formData.endDate,
//                 couponCode: field == 'couponCode'
//                     ? value
//                     : _formData.couponCode,
//               ),
//             );
//           },
//           onNext: _handleNext,
//           onBack: _handleBack,
//           isStepValid: _isStepValid,
//           menuItems: _menuItems,
//           apiService: _apiService,
//         );
//       default:
//         return const SizedBox();
//     }
//   }
//
//   Map<String, List<Map<String, dynamic>>> _getPlacementsByMedium() {
//     return {
//       'app': [
//         {
//           'value': 'place_banner',
//           'label': 'Place Banner',
//           'icon': Icons.crop_landscape,
//         },
//         {'value': 'adds', 'label': 'Deals', 'icon': Icons.campaign},
//         {'value': 'cart', 'label': 'Cart', 'icon': Icons.shopping_cart},
//         {
//           'value': 'in_app_popup',
//           'label': 'In App Pop Up',
//           'icon': Icons.smartphone,
//         },
//       ],
//     };
//   }
// }
