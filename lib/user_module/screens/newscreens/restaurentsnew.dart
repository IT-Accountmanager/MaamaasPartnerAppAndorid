// // ignore_for_file: deprecated_member_use
//
// // ignore_for_file: deprecated_member_use
//
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:in_app_update/in_app_update.dart';
// import '../../../widgets_helper/Home_screen_1.dart';
// import '../../API/Auth_service.dart';
// import '../../API/food_authservice.dart';
// import '../../Models/coupon_model.dart';
// import '../../Models/food/food_categries_model.dart';
// import '../../Models/food/restaurent_banner_model.dart';
// import '../../Models/food/toprestaurentbanner_model.dart';
// import '../../widgets/couponcards.dart';
// import '../Advideo.dart';
// import '../Catering&TableServices/Caterings.dart';
// import '../Food&beverages/menu_screen.dart';
// import '../saved_address.dart';
//
// class Restaurentsnew extends StatefulWidget {
//   final ScrollController scrollController;
//
//   const Restaurentsnew({super.key, required this.scrollController});
//   @override
//   _RestaurentsState createState() => _RestaurentsState();
// }
//
// class _RestaurentsState extends State<Restaurentsnew> {
//   String _currentLocation = "Fetching location...";
//
//   List<BannerItemtoprestaurents> banners = [];
//   bool _updateAvailable = false;
//   AppUpdateInfo? _updateInfo;
//   String? selectedOrderType;
//   int selectedCategoryIndex = 0;
//
//   final List<CouponModel> offers = [];
//
//   bool showPinnedSearch = false;
//   List<FoodCategory> categories = [];
//   List<int>? selectedCategoryVendorIds;
//   bool isLoadingDishes = false;
//
//   // Add this for toggle state
//   bool isVendorMode = false; // User mode is active in this screen
//
//   void _changeLocation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SavedAddress(
//           onAddressSelected: (city, pincode, state, lat, lng, id) {
//             setState(() {
//               _currentLocation = "$city, $state - $pincode";
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   void onCategorySelected(FoodCategory category) {
//     setState(() {
//       selectedCategoryVendorIds = category.vendorIds;
//     });
//   }
//
//   final List<Map<String, dynamic>> _orderTabs = [
//     {
//       'label': 'Dine-In',
//       'icon': Icons.restaurant,
//       'type': 'dinein',
//       'color': Color(0xFFFF6B35),
//       'gradient': [Color(0xFFFF6B35), Color(0xFFF7931E)],
//       'action': 'filter',
//     },
//     {
//       'label': 'Takeaway',
//       'icon': Icons.takeout_dining,
//       'type': 'takeaway',
//       'color': Color(0xFF4CAF50),
//       'gradient': [Color(0xFF4CAF50), Color(0xFF66BB6A)],
//       'action': 'filter',
//     },
//     {
//       'label': 'Table',
//       'icon': Icons.table_restaurant,
//       'type': 'table',
//       'color': Color(0xFF6C63FF),
//       'gradient': [Color(0xFF6C63FF), Color(0xFF8B85FF)],
//       'action': 'filter',
//     },
//     {
//       'label': 'Delivery',
//       'icon': Icons.delivery_dining,
//       'type': 'delivery',
//       'color': Color(0xFF2196F3),
//       'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
//       'action': 'filter',
//     },
//     {
//       'label': 'Catering',
//       'icon': Icons.category_rounded,
//       'type': 'catering',
//       'color': Color(0xFF2196F3),
//       'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
//       'action': 'navigate',
//     },
//   ];
//
//   final Map<String, String> _typeMapping = {
//     'dinein': 'DINE_IN',
//     'table': 'TABLE_DINE_IN',
//     'delivery': 'DELIVERY',
//     'takeaway': 'TAKEAWAY',
//   };
//
//   @override
//   void initState() {
//     super.initState();
//
//     widget.scrollController.addListener(_onScroll);
//     _initializeData();
//     _loadLocationFromAPI();
//     _checkForUpdate();
//     _fetchCategories();
//     selectedCategoryVendorIds = null;
//   }
//
//   void _onScroll() {
//     final shouldShow = widget.scrollController.offset > 180;
//     if (shouldShow != showPinnedSearch) {
//       if (mounted) {
//         setState(() => showPinnedSearch = shouldShow);
//       }
//     }
//   }
//
//   void _loadLocationFromAPI() async {
//     final location = await AuthService.fetchCurrentLocation();
//
//     if (!mounted) return;
//
//     if (location != null) {
//       setState(() {
//         _currentLocation = location.address;
//       });
//     } else {
//       setState(() {
//         _currentLocation = "Fetching location...";
//       });
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showUpdateLocationDialog();
//       });
//     }
//   }
//
//   void _showUpdateLocationDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.location_off, color: Colors.red),
//               SizedBox(width: 8.w),
//               Text("Location Required"),
//             ],
//           ),
//           content: const Text(
//             "We couldn't detect your location. Please update your location to continue.",
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _changeLocation();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFB15DC6),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Update Location"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _initializeData() {
//     _fetchBanners();
//   }
//
//   void _fetchBanners() async {
//     try {
//       final result = await food_Authservice().fetchBanners();
//       setState(() {
//         banners = result;
//       });
//     } catch (e) {
//       // print("Error fetching banners: $e");
//     }
//   }
//
//   String? _getApiOrderType() {
//     if (selectedOrderType == null) return null;
//     return _typeMapping[selectedOrderType!];
//   }
//
//   Future<void> _handleOrderTypeSelection(String type) async {
//     setState(() => selectedOrderType = type);
//     if (type == 'catering') {
//       return;
//     }
//     final apiOrderType = _getApiOrderType();
//     if (apiOrderType != null) {
//       await food_Authservice.createCart(apiOrderType);
//     }
//   }
//
//   Future<void> _checkForUpdate() async {
//     try {
//       final info = await InAppUpdate.checkForUpdate();
//
//       if (!mounted) return;
//
//       setState(() {
//         _updateInfo = info;
//         _updateAvailable =
//             info.updateAvailability == UpdateAvailability.updateAvailable;
//       });
//     } catch (e) {
//       debugPrint("Update check failed: $e");
//     }
//   }
//
//   void _startFlexibleUpdate() async {
//     if (_updateInfo != null) {
//       try {
//         await InAppUpdate.performImmediateUpdate();
//       } catch (e) {
//         debugPrint("Error starting update: $e");
//       }
//     }
//   }
//
//   Future<void> _fetchCategories() async {
//     try {
//       final result = await food_Authservice().fetchFoodCategories();
//
//       if (!mounted) return;
//
//       debugPrint("✅ Categories fetched: ${result.length}");
//
//       setState(() {
//         categories = result;
//
//         if (categories.isNotEmpty) {
//           selectedCategoryIndex = 0;
//           selectedCategoryVendorIds = categories[0].vendorIds;
//         }
//       });
//
//     } catch (e) {
//       debugPrint("❌ Category fetch error: $e");
//     }
//   }
//
//   void _navigateToVendorMode() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const HomeWrapper()),
//     ).then((_) {
//       // When returning from vendor mode, refresh if needed
//       if (mounted) {
//         setState(() {
//           // Any cleanup if needed
//         });
//       }
//     });
//   }
//
//   void _navigateToUserMode() {
//     // Already in user mode, just show a message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Already in User Mode'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           CustomScrollView(
//             controller: widget.scrollController,
//             physics: const AlwaysScrollableScrollPhysics(),
//             slivers: [
//               SliverAppBar(
//                 backgroundColor: Colors.white,
//                 elevation: 2,
//                 shadowColor: Colors.black12,
//                 floating: true,
//                 snap: true,
//                 pinned: false,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(
//                     bottom: Radius.circular(20.r),
//                   ),
//                 ),
//                 automaticallyImplyLeading: false,
//                 title: _buildAppBarContent(),
//                 actions: [
//                   // Vendor/User Toggle Switch
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFB15DC6).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Color(0xFFB15DC6).withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Vendor Option
//                         GestureDetector(
//                           onTap: () {
//                             if (!isVendorMode) {
//                               setState(() {
//                                 isVendorMode = true;
//                               });
//                               _navigateToVendorMode();
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: !isVendorMode ? Colors.transparent : Color(0xFFB15DC6),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.storefront,
//                                   size: 16,
//                                   color: !isVendorMode ? Color(0xFFB15DC6) : Colors.white,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   "Vendor",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: !isVendorMode ? Color(0xFFB15DC6) : Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         // User Option
//                         GestureDetector(
//                           onTap: () {
//                             if (isVendorMode) {
//                               setState(() {
//                                 isVendorMode = false;
//                               });
//                               _navigateToUserMode();
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: isVendorMode ? Colors.transparent : Color(0xFFB15DC6),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.person,
//                                   size: 16,
//                                   color: isVendorMode ? Color(0xFFB15DC6) : Colors.white,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   "User",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: isVendorMode ? Color(0xFFB15DC6) : Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               SliverToBoxAdapter(child: _buildVideoSection()),
//               SliverToBoxAdapter(child: CouponsOffersSection()),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: StickyHeaderDelegate(
//                   height: 120.h,
//                   child: Container(
//                     color: Colors.white,
//                     child: SafeArea(
//                       bottom: false,
//                       child: _buildFoodCategories(),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverPersistentHeader(
//                 pinned: false,
//                 delegate: SearchBarHeaderDelegate(),
//               ),
//               SliverPersistentHeader(
//                 pinned: false,
//                 delegate: StickyHeaderDelegate(
//                   height: 56.h,
//                   child: Container(
//                     color: Colors.white,
//                     padding: EdgeInsets.symmetric(horizontal: 10.w),
//                     child: _buildFilterRow(),
//                   ),
//                 ),
//               ),
//
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: buildOfferFilters(),
//                 ),
//               ),
//
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: StickyHeaderDelegate(
//                   height: 90.h,
//                   child: Container(
//                     color: Colors.white,
//                     child: _buildOrderTypeTabs(),
//                   ),
//                 ),
//               ),
//
//               SliverToBoxAdapter(child: _buildNearbyRestaurantsSection()),
//
//               SliverToBoxAdapter(child: SizedBox(height: 20.h)),
//             ],
//           ),
//
//           /// 🔔 UPDATE BANNER
//           if (_updateAvailable)
//             Positioned(
//               left: 16.w,
//               right: 16.w,
//               bottom: 16.h,
//               child: SafeArea(child: _buildUpdateBanner()),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAppBarContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Current Location",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.black,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         SizedBox(height: 2.h),
//         GestureDetector(
//           onTap: _changeLocation,
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   _currentLocation,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//               Icon(Icons.arrow_drop_down, color: Color(0xFFB15DC6)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildUpdateBanner() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20.r),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20.r,
//             spreadRadius: 1.r,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200, width: 1.w),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Row(
//               children: [
//                 Container(
//                   width: 50.r,
//                   height: 50.r,
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Icon(
//                     Icons.system_update_rounded,
//                     color: Colors.red,
//                     size: 28.r,
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "New Update Available",
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: Colors.grey.shade200),
//           TextButton(
//             onPressed: _startFlexibleUpdate,
//             style: TextButton.styleFrom(
//               minimumSize: Size.fromHeight(50.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20.r),
//                   bottomRight: Radius.circular(20.r),
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "UPDATE NOW",
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.red,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Icon(Icons.download_rounded, color: Colors.red, size: 20.r),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ... rest of your existing methods (_buildVideoSection, buildOfferFilters,
//   // _buildFoodCategories, _buildOrderTypeTabs, _buildOrderTab,
//   // _calculateCompactTabWidth, _buildNearbyRestaurantsSection,
//   // _buildSectionHeader, _buildFilterRow, _openFilterBottomSheet, etc.)
//
//   // Make sure to copy all your existing methods here exactly as they were
//
//   Widget _buildVideoSection() {
//     return ClipRRect(child: VideoPreviewContainer());
//   }
//
//   Widget buildOfferFilters() {
//     final List<OfferFilter> offerFilters = [
//       OfferFilter(
//         title: "10% OFF",
//         subtitle: "UP TO ₹100",
//         gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
//       ),
//       OfferFilter(
//         title: "20% OFF",
//         subtitle: "UP TO ₹150",
//         gradient: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
//       ),
//       OfferFilter(
//         title: "FLAT ₹100",
//         subtitle: "NO MIN ORDER",
//         gradient: [Color(0xFF00B894), Color(0xFF55EFC4)],
//       ),
//       OfferFilter(
//         title: "FREE DELIVERY",
//         subtitle: "TODAY ONLY",
//         gradient: [Color(0xFF0984E3), Color(0xFF74B9FF)],
//       ),
//     ];
//
//     return SizedBox(
//       height: 70,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         scrollDirection: Axis.horizontal,
//         itemCount: offerFilters.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, index) {
//           final offer = offerFilters[index];
//
//           return GestureDetector(
//             onTap: () {
//               debugPrint("Applied: ${offer.title}");
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: offer.gradient,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 6,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     offer.title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     offer.subtitle,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFoodCategories() {
//     if (categories.isEmpty) {
//       return SizedBox(
//         height: 80.h,
//         child: Center(
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             color: Color(0xFF6C63FF),
//           ),
//         ),
//       );
//     }
//
//     return SizedBox(
//       height: 80.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         itemCount: categories.length + 1,
//         separatorBuilder: (_, __) => SizedBox(width: 14.w),
//         itemBuilder: (context, index) {
//           final bool isAll = index == 0;
//           final bool isSelected = selectedCategoryIndex == index;
//
//           final item = isAll ? null : categories[index - 1];
//
//           return InkWell(
//             onTap: () {
//               setState(() {
//                 selectedCategoryIndex = index;
//
//                 if (isAll) {
//                   selectedCategoryVendorIds = null;
//                 } else {
//                   selectedCategoryVendorIds = item!.vendorIds;
//                 }
//               });
//             },
//             borderRadius: BorderRadius.circular(12.r),
//             child: Column(
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   height: 60.h,
//                   width: 60.h,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected
//                         ? const Color(0xFF6C63FF).withOpacity(0.15)
//                         : Colors.grey[100],
//                     border: isSelected
//                         ? Border.all(color: const Color(0xFF6C63FF), width: 2)
//                         : null,
//                   ),
//                   child: ClipOval(
//                     child: isAll
//                         ? Icon(
//                       Icons.grid_view_rounded,
//                       color: const Color(0xFF6C63FF),
//                     )
//                         : item!.image != null
//                         ? Image.network(
//                       item.image!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                       const Icon(Icons.fastfood),
//                     )
//                         : const Icon(Icons.fastfood),
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   isAll ? 'All' : item!.name,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected
//                         ? const Color(0xFF6C63FF)
//                         : Colors.black87,
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
//   Widget _buildOrderTypeTabs() {
//     final double tabWidth = _calculateCompactTabWidth(context);
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 60.h,
//             child: ListView.builder(
//               physics: const BouncingScrollPhysics(),
//               scrollDirection: Axis.horizontal,
//               itemCount: _orderTabs.length,
//               padding: EdgeInsets.symmetric(horizontal: 5.w),
//               itemBuilder: (context, index) {
//                 final tab = _orderTabs[index];
//                 return _buildOrderTab(
//                   tab['label'] as String,
//                   tab['icon'] as IconData,
//                   tab['type'] as String,
//                   tab['color'] as Color,
//                   tab['gradient'] as List<Color>,
//                   tabWidth,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderTab(
//       String label,
//       IconData icon,
//       String type,
//       Color color,
//       List<Color> gradient,
//       double width,
//       ) {
//     final bool isSelected = selectedOrderType == type;
//
//     return GestureDetector(
//       onTap: () {
//         _handleOrderTypeSelection(type);
//       },
//       child: AnimatedContainer(
//         width: width,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         margin: EdgeInsets.symmetric(horizontal: 3.w),
//         padding: EdgeInsets.zero,
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           )
//               : const LinearGradient(colors: [Colors.white, Colors.white]),
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: isSelected ? color.withOpacity(0.3) : Colors.grey.shade200,
//             width: isSelected ? 1.8 : 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isSelected ? 0.12 : 0.04),
//               blurRadius: isSelected ? 14 : 6,
//               offset: Offset(0, isSelected ? 6 : 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(2.w),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? Colors.white.withOpacity(0.25)
//                       : color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   color: isSelected ? Colors.white : color,
//                   size: 14.sp,
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     label,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? Colors.white : Colors.grey[800],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   double _calculateCompactTabWidth(BuildContext context) {
//     double maxWidth = 0;
//
//     final TextStyle style = TextStyle(
//       fontSize: 12.sp,
//       fontWeight: FontWeight.w600,
//     );
//
//     for (var tab in _orderTabs) {
//       final tp = TextPainter(
//         text: TextSpan(text: tab['label'], style: style),
//         maxLines: 1,
//         textDirection: TextDirection.ltr,
//       )..layout();
//
//       maxWidth = max(maxWidth, tp.width);
//     }
//
//     return maxWidth + 24.w;
//   }
//
//   Widget _buildNearbyRestaurantsSection() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 250),
//       child: selectedOrderType == 'catering'
//           ? CateringsPage()
//           : NearbyRestaurentBannersWidget(
//         key: ValueKey(_getApiOrderType()),
//         orderType: _getApiOrderType(),
//         categoryVendorIds: selectedCategoryVendorIds,
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 5.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(5.w),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 20.sp),
//           ),
//           SizedBox(width: 12.w),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.grey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   int _activeFilterIndex = -1;
//
//   final List<Map<String, dynamic>> _filters = [
//     {'icon': Icons.tune, 'label': 'Filters', 'tab': 0},
//     {'icon': Icons.flash_on, 'label': 'Near & Fast', 'tab': null},
//     {'icon': Icons.star, 'label': 'Rating', 'tab': null},
//     {'icon': Icons.local_offer, 'label': 'Offers', 'tab': null},
//     {'icon': Icons.restaurant, 'label': 'Pure Veg', 'tab': null},
//     {'icon': Icons.whatshot, 'label': 'Trending', 'tab': null},
//   ];
//
//   Widget _buildFilterRow() {
//     return SizedBox(
//       height: 40.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         itemCount: _filters.length,
//         separatorBuilder: (_, __) => SizedBox(width: 8.w),
//         itemBuilder: (context, index) {
//           final filter = _filters[index];
//           final bool isSelected = _activeFilterIndex == index;
//
//           return ChoiceChip(
//             selected: isSelected,
//             onSelected: (_) {
//               setState(() {
//                 _activeFilterIndex = index;
//               });
//
//               if (filter['label'] == 'Filters') {
//                 _openFilterBottomSheet(initialTab: filter['tab']);
//               }
//             },
//             label: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   filter['icon'],
//                   size: 16.sp,
//                   color: isSelected ? Colors.white : Colors.black87,
//                 ),
//                 SizedBox(width: 6.w),
//                 Text(
//                   filter['label'],
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w500,
//                     color: isSelected ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.white,
//             selectedColor: const Color(0xFF6C63FF),
//             side: BorderSide(
//               color: isSelected
//                   ? const Color(0xFF6C63FF)
//                   : Colors.grey.shade300,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           );
//         },
//       ),
//     );
//   }
//
//   void _openFilterBottomSheet({int initialTab = 0}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return FractionallySizedBox(
//           heightFactor: 0.92,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//             ),
//             child: FilterBottomSheet(initialTab: initialTab),
//           ),
//         );
//       },
//     );
//   }
// }
//
//
// class FilterBottomSheet extends StatefulWidget {
//   final int initialTab;
//   const FilterBottomSheet({super.key, this.initialTab = 0});
//
//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }
//
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   int selectedIndex = 0;
//
//   final List<String> menu = ['Time', 'Rating', 'Offers', 'Dish Price', 'Trust'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildHeader(),
//         Expanded(
//           child: Row(
//             children: [
//               _buildLeftMenu(),
//               Expanded(child: _buildRightContent()),
//             ],
//           ),
//         ),
//         _buildBottomActions(),
//       ],
//     );
//   }
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Filters and sorting',
//             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//           ),
//           Text('Clear all', style: TextStyle(color: Colors.green)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLeftMenu() {
//     return Container(
//       width: 90.w,
//       color: Colors.grey.shade100,
//       child: ListView.builder(
//         itemCount: menu.length,
//         itemBuilder: (context, index) {
//           final isSelected = selectedIndex == index;
//           return InkWell(
//             onTap: () => setState(() => selectedIndex = index),
//             child: Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.white : Colors.transparent,
//                 border: Border(
//                   left: BorderSide(
//                     color: isSelected ? Colors.green : Colors.transparent,
//                     width: 3,
//                   ),
//                 ),
//               ),
//               child: Text(
//                 menu[index],
//                 style: TextStyle(
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildBottomActions() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 // Apply filters
//                 Navigator.pop(context);
//               },
//               child: const Text('Show results'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRightContent() {
//     switch (selectedIndex) {
//       case 0:
//         return _timeFilters();
//       case 1:
//         return _ratingFilters();
//       case 2:
//         return _offerFilters();
//       case 3:
//         return _priceFilters();
//       case 4:
//         return _trustFilters();
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _timeFilters() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('Time'),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 12.w,
//             runSpacing: 12.h,
//             children: [
//               _optionChip(Icons.schedule, 'Schedule'),
//               _optionChip(Icons.flash_on, 'Near & Fast'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _ratingFilters() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('Restaurant Rating'),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 12.w,
//             runSpacing: 12.h,
//             children: [
//               _optionChip(Icons.star, 'Rated 3.5+'),
//               _optionChip(Icons.star, 'Rated 4.0+'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _offerFilters() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('Offers'),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 12.w,
//             runSpacing: 12.h,
//             children: [
//               _optionChip(Icons.local_offer, 'Buy 1 Get 1'),
//               _optionChip(Icons.percent, 'Deals of the Day'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _priceFilters() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('Dish Price'),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 12.w,
//             runSpacing: 12.h,
//             children: [
//               _optionChip(Icons.currency_rupee, 'Under ₹150'),
//               _optionChip(Icons.currency_rupee, 'Under ₹250'),
//               _optionChip(Icons.currency_rupee, 'Under ₹500'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _trustFilters() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('Trust Markers'),
//           SizedBox(height: 12.h),
//           Wrap(
//             spacing: 12.w,
//             runSpacing: 12.h,
//             children: [
//               _optionChip(Icons.verified, 'Hygiene Rated'),
//               _optionChip(Icons.verified_user, 'Trusted Seller'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//     );
//   }
//
//   Widget _optionChip(IconData icon, String label) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(14.r),
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16.sp, color: Colors.green),
//           SizedBox(width: 6.w),
//           Text(label, style: TextStyle(fontSize: 12.sp)),
//         ],
//       ),
//     );
//   }
// }
//
// class TopRestaurentBannersWidget extends StatefulWidget {
//   final String? orderType;
//
//   const TopRestaurentBannersWidget({super.key, this.orderType});
//
//   @override
//   State<TopRestaurentBannersWidget> createState() =>
//       _TopRestaurentBannersWidgetState();
// }
//
// class _TopRestaurentBannersWidgetState
//     extends State<TopRestaurentBannersWidget> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     // FIT TWO CARDS ON SCREEN
//     double cardWidth = (screenWidth * 0.45);
//     double imageHeight = 110; // reduced height
//     double cardHeight = imageHeight + 90;
//
//     return FutureBuilder<List<BannerItemtoprestaurents>>(
//       future: food_Authservice().fetchBanners(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _loading(cardHeight);
//         } else if (snapshot.hasError) {
//           return _error("Error loading restaurants", cardHeight);
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _empty("No restaurants found", cardHeight);
//         }
//
//         final filtered = widget.orderType == null
//             ? snapshot.data!
//             : snapshot.data!
//                   .where((b) => b.orderTypes.contains(widget.orderType))
//                   .toList();
//
//         if (filtered.isEmpty) {
//           return _empty("No matches for this type", cardHeight);
//         }
//
//         return SizedBox(
//           height: cardHeight,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               return SizedBox(
//                 width: cardWidth,
//                 child: _buildCard(filtered[index], imageHeight),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   // -------------------------
//   // Card Builder
//   // -------------------------
//   Widget _buildCard(BannerItemtoprestaurents banner, double imageHeight) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MenuScreen(vendorId: banner.vendorId),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Image
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(14),
//               ),
//               child: Container(
//                 height: imageHeight,
//                 width: double.infinity,
//                 color: Colors.grey.shade200,
//                 child:
//                     banner.companyBanner != null &&
//                         banner.companyBanner!.isNotEmpty
//                     ? Image.network(banner.companyBanner!, fit: BoxFit.cover)
//                     : _placeholder(),
//               ),
//             ),
//
//             // Text Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     banner.companyName,
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     banner.Type,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Color(0xFF6C63FF),
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                   ),
//                   SizedBox(height: 3),
//                   Row(
//                     children: [
//                       Icon(Icons.location_on, color: Colors.red, size: 10),
//                       SizedBox(width: 2),
//                       Expanded(
//                         child: Text(
//                           "${banner.addressLine}, ${banner.city}",
//                           style: TextStyle(fontSize: 9),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _placeholder() => Icon(Icons.restaurant, size: 30, color: Colors.grey);
//
//   Widget _loading(double h) => SizedBox(
//     height: h,
//     child: Center(child: CircularProgressIndicator()),
//   );
//
//   Widget _error(String msg, double h) => SizedBox(
//     height: h,
//     child: Center(child: Text(msg)),
//   );
//
//   Widget _empty(String msg, double h) => SizedBox(
//     height: h,
//     child: Center(child: Text(msg)),
//   );
// }
//
// class NearbyRestaurentBannersWidget extends StatefulWidget {
//   final String? orderType;
//   final List<int>? categoryVendorIds; // 👈 ADD THIS
//
//   const NearbyRestaurentBannersWidget({
//     super.key,
//     this.orderType,
//     this.categoryVendorIds,
//   });
//
//   @override
//   State<NearbyRestaurentBannersWidget> createState() =>
//       _NearbyRestaurentBannersWidgetState();
// }
//
// class _NearbyRestaurentBannersWidgetState
//     extends State<NearbyRestaurentBannersWidget> {
//   double _maxCardHeight = 0;
//   static const double _minCardHeight = 180;
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Restaurent_Banner>>(
//       future: food_Authservice().fetchnearbyresturents(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingSection();
//         }
//
//         if (snapshot.hasError) {
//           return _buildErrorSection("Error loading nearby restaurants");
//         }
//
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptySection("No nearby restaurants found");
//         }
//
//         // final List<Restaurent_Banner> filtered = snapshot.data!.where((banner) {
//         //   // 1️⃣ orderType filter
//         //   final matchesOrderType = widget.orderType == null
//         //       ? true
//         //       : banner.orderTypes.contains(widget.orderType);
//         //
//         //   // 2️⃣ category vendorId filter
//         //   final matchesCategory = widget.categoryVendorIds == null
//         //       ? true
//         //       : widget.categoryVendorIds!.contains(banner.vendorId);
//         //
//         //   return matchesOrderType && matchesCategory;
//         // }).toList();
//         final List<Restaurent_Banner> filtered = snapshot.data!.where((banner) {
//           // 1️⃣ orderType filter
//           final matchesOrderType = widget.orderType == null
//               ? true
//               : banner.orderTypes.contains(widget.orderType);
//
//           // 2️⃣ category vendorId filter
//           final matchesCategory = widget.categoryVendorIds == null
//               ? true
//               : widget.categoryVendorIds!.contains(banner.vendorId);
//
//           return matchesOrderType && matchesCategory;
//         }).toList();
//
//         if (filtered.isEmpty) {
//           return _buildEmptySection("No restaurants for this category");
//         }
//
//         return _buildHorizontalList(filtered);
//       },
//     );
//   }
//
//   Widget _buildLoadingSection() {
//     return SizedBox(
//       height: 200.h,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Color(0xFF6C63FF)),
//             SizedBox(height: 12.h),
//             Text(
//               "Loading nearby restaurants...",
//               style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorSection(String message) {
//     return SizedBox(
//       height: 200.h,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 40.sp, color: Colors.grey[400]),
//             SizedBox(height: 10.h),
//             Text(
//               message,
//               style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptySection(String message) {
//     return SizedBox(
//       height: 200.h,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off, size: 40.sp, color: Colors.grey[400]),
//             SizedBox(height: 10.h),
//             Text(
//               message,
//               style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHorizontalList(List<Restaurent_Banner> banners) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: banners.length,
//       separatorBuilder: (_, __) => SizedBox(height: 12.h),
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           child: _buildNearbyRestaurantCard(banners[index]),
//         );
//       },
//     );
//   }
//
//   // ---------------- CARD UI ----------------
//
//   Widget _buildNearbyRestaurantCard(Restaurent_Banner banner) {
//     return SizedBox(
//       height: 200.h, // 👈 fixed card height
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => MenuScreen(vendorId: banner.vendorId),
//             ),
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 6,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔹 Image
//               SizedBox(
//                 height: 130.h, // 👈 safer height
//                 width: double.infinity,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(16.r),
//                   ),
//                   child:
//                       (banner.companyBanner != null &&
//                           banner.companyBanner!.isNotEmpty)
//                       ? Image.network(
//                           banner.companyBanner!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
//                         )
//                       : _buildPlaceholderIcon(),
//                 ),
//               ),
//
//               // 🔹 Content
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Company name
//                       Text(
//                         banner.companyName.toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//                       SizedBox(height: 2.h),
//
//                       // Type
//                       Text(
//                         banner.Type.isNotEmpty
//                             ? banner.Type[0].toUpperCase() +
//                                   banner.Type.substring(1).toLowerCase()
//                             : "",
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: const Color(0xFF6C63FF),
//                           fontWeight: FontWeight.w600,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//                       SizedBox(height: 4.h),
//
//                       // Address + distance
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "${banner.addressLine}, ${banner.city}",
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: Colors.black87,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             "(${formatDistance(banner.distance)})",
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String formatDistance(num distanceInKm) {
//     if (distanceInKm < 1) {
//       final meters = (distanceInKm * 1000).round();
//       return '$meters m';
//     } else {
//       return '${distanceInKm.toStringAsFixed(1)} km';
//     }
//   }
//
//   Widget _buildPlaceholderIcon() {
//     return Container(
//       color: Colors.grey[200],
//       child: Center(
//         child: Icon(Icons.restaurant, size: 28.sp, color: Colors.grey[400]),
//       ),
//     );
//   }
// }
//
// class _MeasuredCard extends StatefulWidget {
//   final Widget child;
//   final double width;
//   final ValueChanged<double> onHeight;
//
//   const _MeasuredCard({
//     required this.child,
//     required this.width,
//     required this.onHeight,
//   });
//
//   @override
//   State<_MeasuredCard> createState() => _MeasuredCardState();
// }
//
// class _MeasuredCardState extends State<_MeasuredCard> {
//   final GlobalKey _key = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final context = _key.currentContext;
//       if (context != null) {
//         final box = context.findRenderObject() as RenderBox;
//         widget.onHeight(box.size.height);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.width,
//       child: Container(key: _key, child: widget.child),
//     );
//   }
// }
//
// class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final double height;
//   final Widget child;
//
//   StickyHeaderDelegate({required this.height, required this.child});
//
//   @override
//   double get minExtent => height;
//
//   @override
//   double get maxExtent => height;
//
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return SizedBox.expand(child: child); // 🔑 critical
//   }
//
//   @override
//   bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
//     return height != oldDelegate.height || child != oldDelegate.child;
//   }
// }
//
// class _SearchBar extends StatelessWidget {
//   const _SearchBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // Add a subtle shadow at the top
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             offset: const Offset(0, 2),
//             blurRadius: 6,
//             spreadRadius: 1,
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, -2),
//             blurRadius: 4,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Material(
//         elevation: 4,
//         borderRadius: BorderRadius.circular(14),
//         child: TextField(
//           readOnly: false,
//           onTap: () {
//             // 👉 Navigate to search screen
//           },
//           decoration: InputDecoration(
//             hintText: "Search restaurants, dishes...",
//             prefixIcon: const Icon(Icons.search),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(vertical: 14),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
//   @override
//   double get minExtent => 70;
//
//   @override
//   double get maxExtent => 70;
//
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
//       child: _SearchBar(),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return false;
//   }
// }
//
// class OfferFilter {
//   final String title;
//   final String subtitle;
//   final List<Color> gradient;
//
//   OfferFilter({
//     required this.title,
//     required this.subtitle,
//     required this.gradient,
//   });
// }
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../../widgets_helper/Home_screen_1.dart';
import '../../API/Auth_service.dart';
import '../../API/food_authservice.dart';
import '../../Models/coupon_model.dart';
import '../../Models/food/food_categries_model.dart';
import '../../Models/food/restaurent_banner_model.dart';
import '../../Models/food/toprestaurentbanner_model.dart';
import '../../widgets/couponcards.dart';
import '../Advideo.dart';
import '../Catering&Services/Caterings.dart';
import '../Food&beverages/menu_screen.dart';
import '../saved_address.dart';

class Restaurentsnew extends StatefulWidget {
  final ScrollController scrollController;

  const Restaurentsnew({super.key, required this.scrollController});
  @override
  _RestaurentsState createState() => _RestaurentsState();
}

class _RestaurentsState extends State<Restaurentsnew> {
  String _currentLocation = "Fetching location...";

  List<BannerItemtoprestaurents> banners = [];
  bool _updateAvailable = false;
  AppUpdateInfo? _updateInfo;
  String? selectedOrderType;
  int selectedCategoryIndex = 0;

  final List<CouponModel> offers = [];

  bool showPinnedSearch = false;
  List<FoodCategory> categories = [];
  List<int>? selectedCategoryVendorIds;
  bool isLoadingDishes = false;

  // Add this for toggle state
  bool isVendorMode = false; // User mode is active in this screen

  void _changeLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAddress(
          onAddressSelected: (city, pincode, state, lat, lng, id) {
            setState(() {
              _currentLocation = "$city, $state - $pincode";
            });
          },
        ),
      ),
    );
  }

  void onCategorySelected(FoodCategory category) {
    setState(() {
      selectedCategoryVendorIds = category.vendorIds;
    });
  }

  final List<Map<String, dynamic>> _orderTabs = [
    {
      'label': 'Dine-In',
      'icon': Icons.restaurant,
      'type': 'dinein',
      'color': Color(0xFFFF6B35),
      'gradient': [Color(0xFFFF6B35), Color(0xFFF7931E)],
      'action': 'filter',
    },
    {
      'label': 'Takeaway',
      'icon': Icons.takeout_dining,
      'type': 'takeaway',
      'color': Color(0xFF4CAF50),
      'gradient': [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      'action': 'filter',
    },
    {
      'label': 'Table',
      'icon': Icons.table_restaurant,
      'type': 'table',
      'color': Color(0xFF6C63FF),
      'gradient': [Color(0xFF6C63FF), Color(0xFF8B85FF)],
      'action': 'filter',
    },
    {
      'label': 'Delivery',
      'icon': Icons.delivery_dining,
      'type': 'delivery',
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
      'action': 'filter',
    },
    {
      'label': 'Catering',
      'icon': Icons.category_rounded,
      'type': 'catering',
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
      'action': 'navigate',
    },
  ];

  final Map<String, String> _typeMapping = {
    'dinein': 'DINE_IN',
    'table': 'TABLE_DINE_IN',
    'delivery': 'DELIVERY',
    'takeaway': 'TAKEAWAY',
  };

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(_onScroll);
    _initializeData();
    _loadLocationFromAPI();
    _checkForUpdate();
    _fetchCategories();
    selectedCategoryVendorIds = null;
  }

  void _onScroll() {
    final shouldShow = widget.scrollController.offset > 180;
    if (shouldShow != showPinnedSearch) {
      if (mounted) {
        setState(() => showPinnedSearch = shouldShow);
      }
    }
  }

  void _loadLocationFromAPI() async {
    final location = await AuthService.fetchCurrentLocation();

    if (!mounted) return;

    if (location != null) {
      setState(() {
        _currentLocation = location.address;
      });
    } else {
      setState(() {
        _currentLocation = "Fetching location...";
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateLocationDialog();
      });
    }
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8.w),
              Text("Location Required"),
            ],
          ),
          content: const Text(
            "We couldn't detect your location. Please update your location to continue.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
                foregroundColor: Colors.white,
              ),
              child: const Text("Update Location"),
            ),
          ],
        );
      },
    );
  }

  void _initializeData() {
    _fetchBanners();
  }

  void _fetchBanners() async {
    try {
      final result = await food_Authservice().fetchBanners();
      setState(() {
        banners = result;
      });
    } catch (e) {
      // print("Error fetching banners: $e");
    }
  }

  String? _getApiOrderType() {
    if (selectedOrderType == null) return null;
    return _typeMapping[selectedOrderType!];
  }

  Future<void> _handleOrderTypeSelection(String type) async {
    setState(() => selectedOrderType = type);
    if (type == 'catering') {
      return;
    }
    final apiOrderType = _getApiOrderType();
    if (apiOrderType != null) {
      await food_Authservice.createCart(apiOrderType);
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (!mounted) return;

      setState(() {
        _updateInfo = info;
        _updateAvailable =
            info.updateAvailability == UpdateAvailability.updateAvailable;
      });
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  void _startFlexibleUpdate() async {
    if (_updateInfo != null) {
      try {
        await InAppUpdate.performImmediateUpdate();
      } catch (e) {
        debugPrint("Error starting update: $e");
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final result = await food_Authservice().fetchFoodCategories();

      if (!mounted) return;

      debugPrint("✅ Categories fetched: ${result.length}");

      setState(() {
        categories = result;

        if (categories.isNotEmpty) {
          selectedCategoryIndex = 0;
          selectedCategoryVendorIds = categories[0].vendorIds;
        }
      });

    } catch (e) {
      debugPrint("❌ Category fetch error: $e");
    }
  }

  void _navigateToVendorMode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeWrapper()),
    ).then((_) {
      // When returning from vendor mode, refresh if needed
      if (mounted) {
        setState(() {
          // Any cleanup if needed
        });
      }
    });
  }

  void _navigateToUserMode() {
    // Already in user mode, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Already in User Mode'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black12,
                floating: true,
                snap: true,
                pinned: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20.r),
                  ),
                ),
                automaticallyImplyLeading: false,
                title: _buildAppBarContent(),
                actions: [
                  // Single Switch to Vendor Button (not toggle)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFB15DC6),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFB15DC6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _navigateToVendorMode,
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.storefront,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Vendor",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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

              SliverToBoxAdapter(child: _buildVideoSection()),
              SliverToBoxAdapter(child: CouponsOffersSection()),
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  height: 120.h,
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: _buildFoodCategories(),
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: false,
                delegate: SearchBarHeaderDelegate(),
              ),
              SliverPersistentHeader(
                pinned: false,
                delegate: StickyHeaderDelegate(
                  height: 56.h,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: _buildFilterRow(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: buildOfferFilters(),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  height: 90.h,
                  child: Container(
                    color: Colors.white,
                    child: _buildOrderTypeTabs(),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: _buildNearbyRestaurantsSection()),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
          ),

          /// 🔔 UPDATE BANNER
          if (_updateAvailable)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: SafeArea(child: _buildUpdateBanner()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Location",
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: _changeLocation,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _currentLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Color(0xFFB15DC6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            spreadRadius: 1.r,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: Colors.red,
                    size: 28.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New Update Available",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          TextButton(
            onPressed: _startFlexibleUpdate,
            style: TextButton.styleFrom(
              minimumSize: Size.fromHeight(50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "UPDATE NOW",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.download_rounded, color: Colors.red, size: 20.r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return ClipRRect(child: VideoPreviewContainer());
  }

  Widget buildOfferFilters() {
    final List<OfferFilter> offerFilters = [
      OfferFilter(
        title: "10% OFF",
        subtitle: "UP TO ₹100",
        gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
      ),
      OfferFilter(
        title: "20% OFF",
        subtitle: "UP TO ₹150",
        gradient: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
      ),
      OfferFilter(
        title: "FLAT ₹100",
        subtitle: "NO MIN ORDER",
        gradient: [Color(0xFF00B894), Color(0xFF55EFC4)],
      ),
      OfferFilter(
        title: "FREE DELIVERY",
        subtitle: "TODAY ONLY",
        gradient: [Color(0xFF0984E3), Color(0xFF74B9FF)],
      ),
    ];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: offerFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final offer = offerFilters[index];

          return GestureDetector(
            onTap: () {
              debugPrint("Applied: ${offer.title}");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: offer.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodCategories() {
    if (categories.isEmpty) {
      return SizedBox(
        height: 80.h,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF6C63FF),
          ),
        ),
      );
    }

    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final bool isSelected = selectedCategoryIndex == index;

          final item = isAll ? null : categories[index - 1];

          return InkWell(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;

                if (isAll) {
                  selectedCategoryVendorIds = null;
                } else {
                  selectedCategoryVendorIds = item!.vendorIds;
                }
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 60.h,
                  width: 60.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF6C63FF).withOpacity(0.15)
                        : Colors.grey[100],
                    border: isSelected
                        ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                        : null,
                  ),
                  child: ClipOval(
                    child: isAll
                        ? Icon(
                      Icons.grid_view_rounded,
                      color: const Color(0xFF6C63FF),
                    )
                        : item!.image != null
                        ? Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.fastfood),
                    )
                        : const Icon(Icons.fastfood),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isAll ? 'All' : item!.name,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTypeTabs() {
    final double tabWidth = _calculateCompactTabWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60.h,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: _orderTabs.length,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemBuilder: (context, index) {
                final tab = _orderTabs[index];
                return _buildOrderTab(
                  tab['label'] as String,
                  tab['icon'] as IconData,
                  tab['type'] as String,
                  tab['color'] as Color,
                  tab['gradient'] as List<Color>,
                  tabWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTab(
      String label,
      IconData icon,
      String type,
      Color color,
      List<Color> gradient,
      double width,
      ) {
    final bool isSelected = selectedOrderType == type;

    return GestureDetector(
      onTap: () {
        _handleOrderTypeSelection(type);
      },
      child: AnimatedContainer(
        width: width,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.12 : 0.04),
              blurRadius: isSelected ? 14 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 14.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCompactTabWidth(BuildContext context) {
    double maxWidth = 0;

    final TextStyle style = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
    );

    for (var tab in _orderTabs) {
      final tp = TextPainter(
        text: TextSpan(text: tab['label'], style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      maxWidth = max(maxWidth, tp.width);
    }

    return maxWidth + 24.w;
  }

  Widget _buildNearbyRestaurantsSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: selectedOrderType == 'catering'
          ? CateringsPage()
          : NearbyRestaurentBannersWidget(
        key: ValueKey(_getApiOrderType()),
        orderType: _getApiOrderType(),
        categoryVendorIds: selectedCategoryVendorIds,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 5.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  int _activeFilterIndex = -1;

  final List<Map<String, dynamic>> _filters = [
    {'icon': Icons.tune, 'label': 'Filters', 'tab': 0},
    {'icon': Icons.flash_on, 'label': 'Near & Fast', 'tab': null},
    {'icon': Icons.star, 'label': 'Rating', 'tab': null},
    {'icon': Icons.local_offer, 'label': 'Offers', 'tab': null},
    {'icon': Icons.restaurant, 'label': 'Pure Veg', 'tab': null},
    {'icon': Icons.whatshot, 'label': 'Trending', 'tab': null},
  ];

  Widget _buildFilterRow() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool isSelected = _activeFilterIndex == index;

          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _activeFilterIndex = index;
              });

              if (filter['label'] == 'Filters') {
                _openFilterBottomSheet(initialTab: filter['tab']);
              }
            },
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter['icon'],
                  size: 16.sp,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                SizedBox(width: 6.w),
                Text(
                  filter['label'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF6C63FF),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : Colors.grey.shade300,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  void _openFilterBottomSheet({int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: FilterBottomSheet(initialTab: initialTab),
          ),
        );
      },
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final int initialTab;
  const FilterBottomSheet({super.key, this.initialTab = 0});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedIndex = 0;

  final List<String> menu = ['Time', 'Rating', 'Offers', 'Dish Price', 'Trust'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              _buildLeftMenu(),
              Expanded(child: _buildRightContent()),
            ],
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters and sorting',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          Text('Clear all', style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildLeftMenu() {
    return Container(
      width: 90.w,
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                menu[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                Navigator.pop(context);
              },
              child: const Text('Show results'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent() {
    switch (selectedIndex) {
      case 0:
        return _timeFilters();
      case 1:
        return _ratingFilters();
      case 2:
        return _offerFilters();
      case 3:
        return _priceFilters();
      case 4:
        return _trustFilters();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _timeFilters() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Time'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _optionChip(Icons.schedule, 'Schedule'),
              _optionChip(Icons.flash_on, 'Near & Fast'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingFilters() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Restaurant Rating'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _optionChip(Icons.star, 'Rated 3.5+'),
              _optionChip(Icons.star, 'Rated 4.0+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _offerFilters() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Offers'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _optionChip(Icons.local_offer, 'Buy 1 Get 1'),
              _optionChip(Icons.percent, 'Deals of the Day'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceFilters() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dish Price'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _optionChip(Icons.currency_rupee, 'Under ₹150'),
              _optionChip(Icons.currency_rupee, 'Under ₹250'),
              _optionChip(Icons.currency_rupee, 'Under ₹500'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trustFilters() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Trust Markers'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _optionChip(Icons.verified, 'Hygiene Rated'),
              _optionChip(Icons.verified_user, 'Trusted Seller'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
    );
  }

  Widget _optionChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.green),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class TopRestaurentBannersWidget extends StatefulWidget {
  final String? orderType;

  const TopRestaurentBannersWidget({super.key, this.orderType});

  @override
  State<TopRestaurentBannersWidget> createState() =>
      _TopRestaurentBannersWidgetState();
}

class _TopRestaurentBannersWidgetState
    extends State<TopRestaurentBannersWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = (screenWidth * 0.45);
    double imageHeight = 110;
    double cardHeight = imageHeight + 90;

    return FutureBuilder<List<BannerItemtoprestaurents>>(
      future: food_Authservice().fetchBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading(cardHeight);
        } else if (snapshot.hasError) {
          return _error("Error loading restaurants", cardHeight);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _empty("No restaurants found", cardHeight);
        }

        final filtered = widget.orderType == null
            ? snapshot.data!
            : snapshot.data!
            .where((b) => b.orderTypes.contains(widget.orderType))
            .toList();

        if (filtered.isEmpty) {
          return _empty("No matches for this type", cardHeight);
        }

        return SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: _buildCard(filtered[index], imageHeight),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCard(BannerItemtoprestaurents banner, double imageHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuScreen(vendorId: banner.vendorId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                color: Colors.grey.shade200,
                child:
                banner.companyBanner != null &&
                    banner.companyBanner!.isNotEmpty
                    ? Image.network(banner.companyBanner!, fit: BoxFit.cover)
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.companyName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Text(
                    banner.Type,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 10),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          "${banner.addressLine}, ${banner.city}",
                          style: TextStyle(fontSize: 9),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Icon(Icons.restaurant, size: 30, color: Colors.grey);

  Widget _loading(double h) => SizedBox(
    height: h,
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _error(String msg, double h) => SizedBox(
    height: h,
    child: Center(child: Text(msg)),
  );

  Widget _empty(String msg, double h) => SizedBox(
    height: h,
    child: Center(child: Text(msg)),
  );
}

class NearbyRestaurentBannersWidget extends StatefulWidget {
  final String? orderType;
  final List<int>? categoryVendorIds;

  const NearbyRestaurentBannersWidget({
    super.key,
    this.orderType,
    this.categoryVendorIds,
  });

  @override
  State<NearbyRestaurentBannersWidget> createState() =>
      _NearbyRestaurentBannersWidgetState();
}

class _NearbyRestaurentBannersWidgetState
    extends State<NearbyRestaurentBannersWidget> {
  double _maxCardHeight = 0;
  static const double _minCardHeight = 180;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Restaurent_Banner>>(
      future: food_Authservice().fetchnearbyresturents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }

        if (snapshot.hasError) {
          return _buildErrorSection("Error loading nearby restaurants");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection("No nearby restaurants found");
        }

        final List<Restaurent_Banner> filtered = snapshot.data!.where((banner) {
          final matchesOrderType = widget.orderType == null
              ? true
              : banner.orderTypes.contains(widget.orderType);

          final matchesCategory = widget.categoryVendorIds == null
              ? true
              : widget.categoryVendorIds!.contains(banner.vendorId);

          return matchesOrderType && matchesCategory;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptySection("No restaurants for this category");
        }

        return _buildHorizontalList(filtered);
      },
    );
  }

  Widget _buildLoadingSection() {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 12.h),
            Text(
              "Loading nearby restaurants...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: Colors.grey[400]),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 40.sp, color: Colors.grey[400]),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Restaurent_Banner> banners) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banners.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: _buildNearbyRestaurantCard(banners[index]),
        );
      },
    );
  }

  Widget _buildNearbyRestaurantCard(Restaurent_Banner banner) {
    return SizedBox(
      height: 200.h,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(vendorId: banner.vendorId),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130.h,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child:
                  (banner.companyBanner != null &&
                      banner.companyBanner!.isNotEmpty)
                      ? Image.network(
                    banner.companyBanner!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                  )
                      : _buildPlaceholderIcon(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.companyName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        banner.Type.isNotEmpty
                            ? banner.Type[0].toUpperCase() +
                            banner.Type.substring(1).toLowerCase()
                            : "",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${banner.addressLine}, ${banner.city}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "(${formatDistance(banner.distance)})",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDistance(num distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.restaurant, size: 28.sp, color: Colors.grey[400]),
      ),
    );
  }
}

class _MeasuredCard extends StatefulWidget {
  final Widget child;
  final double width;
  final ValueChanged<double> onHeight;

  const _MeasuredCard({
    required this.child,
    required this.width,
    required this.onHeight,
  });

  @override
  State<_MeasuredCard> createState() => _MeasuredCardState();
}

class _MeasuredCardState extends State<_MeasuredCard> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        widget.onHeight(box.size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Container(key: _key, child: widget.child),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  StickyHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        child: TextField(
          readOnly: false,
          onTap: () {},
          decoration: InputDecoration(
            hintText: "Search restaurants, dishes...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
      child: _SearchBar(),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class OfferFilter {
  final String title;
  final String subtitle;
  final List<Color> gradient;

  OfferFilter({
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}