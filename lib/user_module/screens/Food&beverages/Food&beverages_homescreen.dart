// // ignore_for_file: deprecated_member_use
//
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Auth_service.dart';
// import '../../API/food_authservice.dart';
// import '../../Models/coupon_model.dart';
// import '../../Models/food/restaurent_banner_model.dart';
// import '../../Models/food/toprestaurentbanner_model.dart';
// import '../Advideo.dart';
// import '../Catering&TableServices/Caterings.dart';
// import '../Logistics&supply/logistics_homepage.dart';
// import '../notifications.dart';
// import '../saved_address.dart';
// import 'Discount_dishes_screens.dart';
// import 'menu_screen.dart';
//
// class Restaurents extends StatefulWidget {
//   @override
//   _RestaurentsState createState() => _RestaurentsState();
// }
//
// class _RestaurentsState extends State<Restaurents> {
//   String _currentLocation = "Fetching location...";
//
//   List<BannerItemtoprestaurents> banners = [];
//   bool _updateAvailable = false;
//   AppUpdateInfo? _updateInfo;
//   String? selectedOrderType;
//   int _unreadCount = 0;
//
//   final List<CouponModel> offers = [];
//
//   void _changeLocation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SavedAddress(
//           onAddressSelected: (city, pincode, state, lat, lng, id) {
//             setState(() {
//               _currentLocation =
//                   "$city, $state "
//                   "- $pincode";
//             });
//           },
//         ),
//       ),
//     );
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
//
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
//     // {
//     //   'label': 'Catering',
//     //   'icon': Icons.category_rounded,
//     //   'type': 'catering', // ✅ lowercase
//     //   'color': Color(0xFF2196F3),
//     //   'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
//     //   'action': 'navigate',
//     // },
//     // {
//     //   'label': 'Logistics',
//     //   'icon': Icons.bike_scooter,
//     //   'type': 'logistics', // ✅ lowercase
//     //   'color': Color(0xFF2196F3),
//     //   'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
//     //   'action': 'navigate',
//     // },
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
//     _initializeData();
//     _loadLocationFromAPI();
//     _checkForUpdate();
//     _loadUnreadCount();
//   }
//
//   Future<void> _loadUnreadCount() async {
//     final count = await AuthService.fetchUnreadNotificationCount();
//     if (!mounted) return;
//     setState(() {
//       _unreadCount = count;
//     });
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
//       // show dialog after build completes
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
//             // TextButton(
//             //   onPressed: () {
//             //     Navigator.pop(context);
//             //   },
//             //   child: const Text("Later"),
//             // ),
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
//
//     // // 👇 STOP normal order flow for catering
//     // if (type == 'catering' || type == 'logistics') {
//     //   return;
//     // }
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("orderType", type);
//
//     // final apiOrderType = _getApiOrderType();
//     // await food_Authservice.createCart(apiOrderType!);
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: Stack(
//         children: [
//           _buildBody(), // scrollable content
//
//           if (_updateAvailable)
//             Positioned(
//               left: 16.w,
//               right: 16.w,
//               bottom: 16.h,
//               child: SafeArea(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20.r),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20.r,
//                         spreadRadius: 1.r,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(color: Colors.grey.shade200, width: 1.w),
//                   ),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(16.w),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 50.r,
//                               height: 50.r,
//                               decoration: BoxDecoration(
//                                 color: Colors.red.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               child: Icon(
//                                 Icons.system_update_rounded,
//                                 color: Colors.red,
//                                 size: 28.r,
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "New Update Available",
//                                     style: TextStyle(
//                                       fontSize: 16.sp,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Divider(height: 1, color: Colors.grey.shade200),
//                       TextButton(
//                         onPressed: _startFlexibleUpdate,
//                         style: TextButton.styleFrom(
//                           minimumSize: Size.fromHeight(50.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(20.r),
//                               bottomRight: Radius.circular(20.r),
//                             ),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "UPDATE NOW",
//                               style: TextStyle(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.red,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             Icon(
//                               Icons.download_rounded,
//                               color: Colors.red,
//                               size: 20.r,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       // bottomNavigationBar: food_foooter(),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 2,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
//       ),
//       automaticallyImplyLeading: false,
//
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Current Location",
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: Colors.black,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           GestureDetector(
//             onTap: _changeLocation,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _currentLocation,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     softWrap: true,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_drop_down,
//                   color: Color(0xFFB15DC6),
//                   size: 20.sp,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//
//       /// 🔔 ACTIONS
//       actions: [
//         Padding(
//           padding: EdgeInsets.only(right: 12.w),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   Icons.notifications_none,
//                   color: Colors.black87,
//                   size: 26.sp,
//                 ),
//                 onPressed: _openNotifications, // 👈 navigate
//               ),
//
//               /// 🔴 BADGE
//               if (_unreadCount > 0)
//                 Positioned(
//                   right: -2,
//                   top: -2,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 14,
//                       minHeight: 14,
//                     ),
//                     child: Text(
//                       _unreadCount > 99 ? '99+' : _unreadCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                         height: 1,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _openNotifications() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const NotificationScreen()),
//     );
//   }
//
//   Widget _buildBody() {
//     return RefreshIndicator(
//       color: Colors.white,
//       backgroundColor: Color(0xFF6C63FF),
//       displacement: 40,
//       strokeWidth: 3,
//       onRefresh: _onRefresh,
//       child: CustomScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(child: _buildVideoSection()),
//           SliverToBoxAdapter(child: CouponsOffersSection()),
//           SliverToBoxAdapter(child: _buildOrderTypeTabs()),
//           // SliverToBoxAdapter(child: _buildTopBrandsSection()),
//           SliverToBoxAdapter(child: _buildNearbyRestaurantsSection()),
//           SliverToBoxAdapter(child: SizedBox(height: 20.h)),
//           if (_updateAvailable)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(12.w),
//                 child: ElevatedButton(
//                   onPressed: _startFlexibleUpdate,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   child: const Text(
//                     "Update App",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVideoSection() {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(child: VideoPreviewContainer()),
//     );
//   }
//
//   Widget _buildOrderTypeTabs() {
//     final double tabWidth = _calculateCompactTabWidth(context);
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 12.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Padding(
//           //   padding: EdgeInsets.only(left: 8.w, bottom: 10.h),
//           //   child: Text(
//           //     // "How would you like to order?",
//           //     "Choose how you’d like to be served",
//           //     style: TextStyle(
//           //       fontSize: 16.sp,
//           //       fontWeight: FontWeight.w700,
//           //       color: Colors.grey[800],
//           //     ),
//           //   ),
//           // ),
//           SizedBox(
//             height: 72.h, // 👈 reduced height
//             child: ListView.builder(
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
//     String label,
//     IconData icon,
//     String type,
//     Color color,
//     List<Color> gradient,
//     double width,
//   ) {
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
//         padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? LinearGradient(
//                   colors: gradient,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
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
//
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(4.w),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? Colors.white.withOpacity(0.25)
//                     : color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? Colors.white : color,
//                 size: 14.sp, // 👈 smaller icon
//               ),
//             ),
//
//             SizedBox(height: 4.h),
//
//             FittedBox(
//               child: Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 12.sp, // 👈 smaller text
//                   fontWeight: FontWeight.w600,
//                   color: isSelected ? Colors.white : Colors.grey[800],
//                 ),
//               ),
//             ),
//           ],
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
//     return maxWidth + 36.w; // 👈 reduced padding
//   }
//
//   Widget _buildTopBrandsSection() {
//     return Column(
//       children: [
//         _buildSectionHeader(
//           "Top Brands for you",
//           Icons.star,
//           Color(0xFFFF6B35),
//         ),
//         TopRestaurentBannersWidget(orderType: _getApiOrderType()),
//       ],
//     );
//   }
//
//   // Widget _buildNearbyRestaurantsSection() {
//   //   // 👇 If Catering selected
//   //   if (selectedOrderType == 'catering') {
//   //     return CateringsPage(); // 👈 inline widget
//   //   }
//   //   if (selectedOrderType == 'logistics') {
//   //     return LogisticsScreen();
//   //   }
//   //
//   //   // 👇 Normal order flow
//   //   return Column(
//   //     children: [
//   //       _buildSectionHeader(
//   //         "Top Brands for you",
//   //         Icons.location_on,
//   //         const Color(0xFF6C63FF),
//   //       ),
//   //       NearbyRestaurentBannersWidget(orderType: _getApiOrderType()),
//   //     ],
//   //   );
//   // }
//   Widget _buildNearbyRestaurantsSection() {
//     switch (selectedOrderType) {
//       case 'catering':
//         return CateringsPage();
//
//       case 'logistics':
//         return LogisticsScreen();
//
//       default:
//         return Column(
//           children: [
//             _buildSectionHeader(
//               "Top Brands for you",
//               Icons.location_on,
//               const Color(0xFF6C63FF),
//             ),
//             NearbyRestaurentBannersWidget(orderType: _getApiOrderType()),
//           ],
//         );
//     }
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               // ignore: duplicate_ignore
//               // ignore: deprecated_member_use
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
//   Future<void> _onRefresh() async {
//     debugPrint("🔄 Refresh triggered!");
//     await Future.delayed(const Duration(seconds: 1));
//     setState(() => _initializeData());
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
//
//   const NearbyRestaurentBannersWidget({super.key, this.orderType});
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
//         final List<Restaurent_Banner> filtered = widget.orderType == null
//             ? snapshot.data! // 👈 SHOW ALL
//             : snapshot.data!
//                   .where((b) => b.orderTypes.contains(widget.orderType))
//                   .toList();
//
//         if (filtered.isEmpty) {
//           return _buildEmptySection("No matches for this order type");
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
//   // ---------------- RESPONSIVE SCROLL + GRID ----------------
//
//   Widget _buildHorizontalList(List<Restaurent_Banner> banners) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double spacing = 12.w;
//         final double horizontalPadding = 24.w;
//         final double cardWidth =
//             (constraints.maxWidth - horizontalPadding - spacing) / 2;
//
//         return SizedBox(
//           // 🔥 ALWAYS give height
//           height: _maxCardHeight > 0 ? _maxCardHeight : _minCardHeight,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             itemCount: banners.length,
//             separatorBuilder: (_, __) => SizedBox(width: spacing),
//             itemBuilder: (context, index) {
//               return _MeasuredCard(
//                 width: cardWidth,
//                 onHeight: (h) {
//                   if (h > _maxCardHeight) {
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted) {
//                         setState(() => _maxCardHeight = h);
//                       }
//                     });
//                   }
//                 },
//                 child: _buildNearbyRestaurantCard(banners[index]),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   // ---------------- CARD UI ----------------
//
//   Widget _buildNearbyRestaurantCard(Restaurent_Banner banner) {
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
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Responsive image
//             AspectRatio(
//               aspectRatio: 16 / 9,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
//                 child: banner.companyBanner.isNotEmpty
//                     ? Image.network(
//                         banner.companyBanner,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
//                       )
//                     : _buildPlaceholderIcon(),
//               ),
//             ),
//
//             // 🔹 Content
//             Padding(
//               padding: EdgeInsets.all(1.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Company name
//                   Text(
//                     banner.companyName.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   // Type
//                   Text(
//                     banner.Type.isNotEmpty
//                         ? banner.Type[0].toUpperCase() +
//                               banner.Type.substring(1).toLowerCase()
//                         : "",
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: const Color(0xFF6C63FF),
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   // Location
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.location_on, color: Colors.red, size: 12.sp),
//                       SizedBox(width: 4.w),
//                       Expanded(
//                         child: Text(
//                           "${banner.addressLine}, ${banner.city}",
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                             color: Colors.black87,
//                           ),
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
// class DiscountBanner extends StatefulWidget {
//   @override
//   _DiscountBannerState createState() => _DiscountBannerState();
// }
//
// class _DiscountBannerState extends State<DiscountBanner> {
//   String discount = 'Loading...';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDiscountAndDishes();
//   }
//
//   Future<void> fetchDiscountAndDishes() async {
//     try {
//       // Fetch all dishes
//       final fetchedDishes = await food_Authservice.fetchAllDiscountDishes();
//
//       // Filter by balanceQuantity > 0
//       final availableDishes = fetchedDishes
//           .where((d) => d.stockQuantity > 0)
//           .toList();
//
//       // Calculate highest discount
//       double highest = availableDishes
//           .map((e) => e.discount)
//           .fold(0.0, (a, b) => a > b ? a : b);
//
//       setState(() {
//         discount = highest > 0
//             ? 'upto ${highest.toInt()}% OFF'
//             : 'No discounts available';
//       });
//     } catch (e) {
//       // print('❌ Error fetching discount: $e');
//       setState(() {
//         discount = 'No discounts available';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         // borderRadius: BorderRadius.circular(5),
//         color: Colors.redAccent,
//       ),
//
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AllDishesScreen()),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.all(28),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Icon for better visual appeal
//                 Icon(Icons.local_offer_rounded, color: Colors.white, size: 32),
//
//                 SizedBox(height: 10),
//
//                 // Main discount text
//                 Text(
//                   discount,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 SizedBox(height: 8),
//
//                 // Subtitle text
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Center(
//                       child: Text(
//                         "Tap to view all dishes",
//                         style: TextStyle(
//                           // ignore: duplicate_ignore
//                           // ignore: deprecated_member_use
//                           color: Colors.white.withOpacity(0.9),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_rounded,
//                       // ignore: duplicate_ignore
//                       // ignore: deprecated_member_use
//                       color: Colors.white.withOpacity(0.8),
//                       size: 18,
//                     ),
//                   ],
//                 ),
//
//                 // Arrow indicator
//               ],
//             ),
//           ),
//         ),
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
// class CouponsOffersSection extends StatelessWidget {
//   CouponsOffersSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<CouponModel>>(
//       future: AuthService.fetchCoupons(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(
//             height: 140,
//             child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//           );
//         }
//
//         if (snapshot.hasError) {
//           return Container(
//             height: 140,
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Failed to load offers",
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final coupons = snapshot.data!
//             .where((c) => c.active && !c.isExpired)
//             .toList();
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const Padding(
//             //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             //   child: Row(
//             //     children: [
//             //       Icon(
//             //         Icons.local_offer_outlined,
//             //         size: 20,
//             //         color: Color(0xFF6B7280),
//             //       ),
//             //       SizedBox(width: 8),
//             //       Text(
//             //         "Offers & Coupons",
//             //         style: TextStyle(
//             //           fontSize: 18,
//             //           fontWeight: FontWeight.w600,
//             //           color: Color(0xFF111827),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//
//             // SizedBox(
//             //   height: 140,
//             //   child: ListView.separated(
//             //     padding: const EdgeInsets.symmetric(horizontal: 20),
//             //     scrollDirection: Axis.horizontal,
//             //     physics: const BouncingScrollPhysics(),
//             //     itemCount: coupons.length + 2,
//             //     separatorBuilder: (_, __) => const SizedBox(width: 16),
//             //     itemBuilder: (context, index) {
//             //       const double cardWidth = 280;
//             //
//             //       if (index < coupons.length) {
//             //         return SizedBox(
//             //           width: cardWidth,
//             //           child: CouponCard(coupon: coupons[index], index: index)
//             //         );
//             //       }
//             //
//             //       return SizedBox(
//             //         width: cardWidth,
//             //         child: _staticCouponCard(index - coupons.length),
//             //       );
//             //     },
//             //   ),
//             // ),
//             SizedBox(
//               height: 120,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: 3, // 👈 number of static cards
//                 separatorBuilder: (_, __) => const SizedBox(width: 16),
//                 itemBuilder: (context, index) {
//                   const double cardWidth = 280;
//
//                   return SizedBox(
//                     width: cardWidth,
//                     child: _staticCouponCard(index),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   final List<Map<String, dynamic>> staticCoupons = [
//     {
//       "headline": "Authentic Taste. Fantastic Savings.",
//       "title": "First Order",
//       "offer": "Get Flat ₹25 OFF on Your First Order!",
//       // "description": "",
//       "type": "REFER",
//       // "icon": Icons.group_add_outlined,
//       "gradient": const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
//       ),
//       "iconBg": Color(0xFFEEF2FF),
//       "badge": "LIMITLESS",
//     },
//     {
//       "headline": "Invite Friends. Unlock Rewards.",
//       "title": "Refer & Earn",
//       "offer": "Earn ₹25 Cashback Per Referral!",
//       // "description": "",
//       "type": "REFER",
//       // "icon": Icons.group_add_outlined,
//       "gradient": const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
//       ),
//       "iconBg": Color(0xFFEEF2FF),
//       "badge": "LIMITLESS",
//     },
//     {
//       "headline": "Recharge More. Earn More.",
//       "title": "Wallet Recharge",
//       "offer": "Get a Flat 10% Cashback!",
//       // "description": "",
//       "type": "WALLET",
//       // "icon": Icons.account_balance_wallet_outlined,
//       "gradient": const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFF059669), Color(0xFF10B981)],
//       ),
//       "iconBg": Color(0xFFECFDF5),
//       "badge": "HOT DEAL",
//     },
//   ];
//
//   Widget _staticCouponCard(int index) {
//     final data = staticCoupons[index];
//
//     return Container(
//       height: 120,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: data["gradient"] as LinearGradient,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 14,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Decorative Circle
//           Positioned(
//             right: -30,
//             top: -30,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top Row
//                 Row(
//                   children: [
//                     // Container(
//                     //   padding: const EdgeInsets.all(8),
//                     //   decoration: BoxDecoration(
//                     //     color: data["iconBg"] as Color,
//                     //     borderRadius: BorderRadius.circular(12),
//                     //   ),
//                     //   child: Icon(
//                     //     data["icon"] as IconData,
//                     //     size: 20,
//                     //     color:
//                     //     (data["gradient"] as LinearGradient).colors.first,
//                     //   ),
//                     // ),
//                     // const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         data["headline"],
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//
//                     // Badge
//                     // Container(
//                     //   padding:
//                     //   const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     //   decoration: BoxDecoration(
//                     //     color: Colors.white.withOpacity(0.2),
//                     //     borderRadius: BorderRadius.circular(8),
//                     //   ),
//                     //   child: Text(
//                     //     data["badge"],
//                     //     style: const TextStyle(
//                     //       color: Colors.white,
//                     //       fontSize: 10,
//                     //       fontWeight: FontWeight.w700,
//                     //       letterSpacing: 0.6,
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//
//                 // const Spacer(),
//                 const SizedBox(height: 6),
//
//                 // Offer
//                 Text(
//                   data["offer"],
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     height: 1.2,
//                   ),
//                 ),
//
//                 // Description
//                 // Text(
//                 //   data["description"],
//                 //   style: TextStyle(
//                 //     color: Colors.white.withOpacity(0.9),
//                 //     fontSize: 13,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CouponCard extends StatelessWidget {
//   final CouponModel coupon;
//   final int index;
//
//   const CouponCard({super.key, required this.coupon, required this.index});
//
//   LinearGradient get _cardGradient {
//     final gradients = [
//       const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFFC026D3), Color(0xFF7C3AED)], // Purple
//       ),
//       const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], // Blue
//       ),
//       const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFF059669), Color(0xFF10B981)], // Green
//       ),
//       const LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
//       ),
//     ];
//
//     return gradients[index % gradients.length];
//   }
//
//   Color get _iconBackground {
//     if (coupon.couponType == "PERCENTAGE") {
//       return const Color(0xFFF3E8FF);
//     } else if (coupon.couponType == "FLAT") {
//       return const Color(0xFFFEF3C7);
//     } else {
//       return const Color(0xFFE0F2FE);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         gradient: _cardGradient,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Decorative Circles
//           Positioned(
//             right: -30,
//             top: -30,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//
//           Positioned(
//             right: 10,
//             bottom: -40,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//
//           // Main Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Icon Section
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _iconBackground,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       Icons.local_offer_outlined,
//                       size: 24,
//                       color: _cardGradient.colors[0],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 16),
//
//                 // Text Content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Coupon Type Badge
//                       // Container(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 8,
//                       //     vertical: 4,
//                       //   ),
//                       //   decoration: BoxDecoration(
//                       //     color: Colors.white.withOpacity(0.2),
//                       //     borderRadius: BorderRadius.circular(6),
//                       //   ),
//                       //   child:
//                       Row(
//                         children: [
//                           Text(
//                             coupon.couponType,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//
//                           // ),
//                           const SizedBox(width: 3),
//
//                           // Discount Amount
//                           Text(
//                             coupon.discountType == "PERCENTAGE"
//                                 ? "${coupon.discountPercentage.toStringAsFixed(0)}% OFF"
//                                 : "₹${coupon.discountPercentage.toStringAsFixed(0)} OFF",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               height: 1.2,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 4),
//
//                       // Coupon Code
//                       Text(
//                         coupon.code,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.9),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 1,
//                         ),
//                       ),
//
//                       const SizedBox(height: 4),
//
//                       // Minimum Order
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.verified_outlined,
//                             size: 12,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             coupon.minimumOrderValue <= 0
//                                 ? "No minimum order"
//                                 : "Min. order ₹${coupon.minimumOrderValue.toInt()}",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Copy Button
//                 // Container(
//                 //   width: 40,
//                 //   height: 40,
//                 //   decoration: BoxDecoration(
//                 //     color: Colors.white.withOpacity(0.2),
//                 //     shape: BoxShape.circle,
//                 //   ),
//                 //   child: IconButton(
//                 //     onPressed: () {
//                 //       // Copy coupon code functionality
//                 //     },
//                 //     icon: const Icon(
//                 //       Icons.content_copy_outlined,
//                 //       size: 18,
//                 //       color: Colors.white,
//                 //     ),
//                 //     padding: EdgeInsets.zero,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
