// import 'dart:async';
// import 'dart:convert';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../API/food_authservice.dart';
// import '../../Models/food/aboutus_model.dart';
// import '../../Models/food/category_dish.dart';
// import '../../Models/food/dish.dart';
// import '../../Models/food/restaurent_banner_model.dart';
// import '../../Models/food/timings_model.dart';
// import '../../widgets/food/favorite_button.dart';
// import '../../widgets/food/table_cartbutton.dart';
//
// class tablemenuscreen extends StatefulWidget {
//   final int vendorId;
//   final int seatingId;
//
//   const tablemenuscreen({
//     super.key,
//     required this.vendorId,
//     required this.seatingId,
//   });
//   @override
//   State<tablemenuscreen> createState() => _tablemenuscreenState();
// }
//
// class _tablemenuscreenState extends State<tablemenuscreen> {
//   PageController _pageController = PageController();
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey _menuFilterKey = GlobalKey();
//   Timer? _timer;
//   bool isVeg = true;
//   bool _isTopVisible = true;
//   int selectedTabIndex = 0;
//   bool _isMenuFilterSticky = false;
//   double _lastScrollOffset = 0;
//   final List<String> categories = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pageController = PageController();
//     _scrollController.addListener(() {
//       double currentOffset = _scrollController.offset;
//       if (currentOffset > _lastScrollOffset && _isTopVisible) {
//         setState(() => _isTopVisible = false);
//       } else if (currentOffset < _lastScrollOffset && !_isTopVisible) {
//         setState(() => _isTopVisible = true);
//       }
//       _lastScrollOffset = currentOffset;
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     _scrollController.removeListener(_handleScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _handleScroll() {
//     final RenderBox? filterBox =
//     _menuFilterKey.currentContext?.findRenderObject() as RenderBox?;
//     if (filterBox != null) {
//       final offset = filterBox.localToGlobal(Offset.zero).dy;
//       final double breadcrumbBottom =
//           kToolbarHeight + MediaQuery.of(context).padding.top + 50;
//       if (!_isMenuFilterSticky && offset <= breadcrumbBottom) {
//         setState(() => _isMenuFilterSticky = true);
//       } else if (_isMenuFilterSticky && offset > breadcrumbBottom) {
//         setState(() => _isMenuFilterSticky = false);
//       }
//     }
//
//     final currentOffset = _scrollController.offset;
//     const threshold = 50;
//     if (currentOffset > threshold && _isTopVisible) {
//       setState(() => _isTopVisible = false);
//     } else if (currentOffset <= threshold && !_isTopVisible) {
//       setState(() => _isTopVisible = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(50), // or your needed height
//         child: AppBar(title: Text("Menu"), centerTitle: true),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         controller: _scrollController,
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         child: Column(
//                           children: [
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                               height: _isTopVisible ? null : 0,
//                               child: TopRestaurantCard(
//                                 vendorId: widget.vendorId,
//                                 onExpandChange: (expanded) {},
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             MenuFilterBar(
//                               isVeg: isVeg,
//                               selectedFilterIndex: selectedTabIndex,
//                               onToggle: (val) {
//                                 setState(() => isVeg = val);
//                               },
//                               vendorId: widget.vendorId,
//                               onTabChange: (index) {
//                                 setState(() => selectedTabIndex = index);
//                               },
//                               seatingId: widget.seatingId,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: SafeArea(top: false, child: food_foooter()),
//     );
//   }
// }
//
// class TopRestaurantCard extends StatefulWidget {
//   final void Function(bool isExpanded) onExpandChange;
//   final int vendorId;
//
//   const TopRestaurantCard({
//     super.key,
//     required this.onExpandChange,
//     required this.vendorId,
//   });
//
//   @override
//   State<TopRestaurantCard> createState() => _TopRestaurantCardState();
// }
//
// class _TopRestaurantCardState extends State<TopRestaurantCard> {
//   bool _showKnowMore = false;
//   bool _showGallery = false;
//   Restaurent_Banner? _bannerItem;
//   AboutUsModel? _aboutUsModel;
//   final List<String> _images = [];
//   Timing? _todayTiming;
//   bool _isLoading = true;
//   String? _companyBanner;
//   List<String> imageUrls = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     try {
//       await Future.wait([
//         _fetchBannerData(),
//         _loadAboutUs(),
//         _loadVendorTiming(widget.vendorId),
//       ]);
//     } catch (e) {
//       // Handle error
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _fetchBannerData() async {
//     try {
//       final banner = await food_Authservice().fetchVendorBanner(
//         widget.vendorId,
//       );
//       if (mounted) {
//         setState(() {
//           _bannerItem = banner;
//           _companyBanner = banner.companyBanner;
//         });
//       }
//     } catch (e) {
//       // Handle error
//     }
//   }
//
//   Future<void> _loadAboutUs() async {
//     final result = await food_Authservice.fetchAboutUsData(widget.vendorId);
//     if (result != null && mounted) {
//       // print("🟩 About Us Images: ${result.allImages}");
//       setState(() {
//         _aboutUsModel = result;
//         _images
//           ..clear()
//           ..addAll(result.allImages);
//       });
//     }
//   }
//
//   Future<void> _loadVendorTiming(int vendorId) async {
//     final timing = await food_Authservice.fetchVendorTimingForToday(
//       widget.vendorId,
//     );
//
//     if (!mounted) return;
//
//     setState(() {
//       _todayTiming = timing;
//     });
//   }
//
//   String _formatTime(BuildContext context, String timeStr) {
//     try {
//       final parts = timeStr.split(":");
//       final time = TimeOfDay(
//         hour: int.parse(parts[0]),
//         minute: int.parse(parts[1]),
//       );
//       return time.format(context);
//     } catch (_) {
//       return "--";
//     }
//   }
//
//   Future<void> _launchSocialUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   ImageProvider _getImageProvider(String imageString) {
//     if (imageString.startsWith('http')) {
//       return NetworkImage(imageString);
//     } else {
//       return MemoryImage(base64Decode(imageString));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildBannerSection(),
//             AnimatedCrossFade(
//               firstChild: const SizedBox.shrink(),
//               secondChild: _buildAboutUsSection(),
//               crossFadeState: _showKnowMore
//                   ? CrossFadeState.showSecond
//                   : CrossFadeState.showFirst,
//               duration: const Duration(milliseconds: 300),
//             ),
//
//             // Gallery Section
//             AnimatedCrossFade(
//               firstChild: const SizedBox.shrink(),
//               secondChild: _buildGallerySection(),
//               crossFadeState: _showGallery
//                   ? CrossFadeState.showSecond
//                   : CrossFadeState.showFirst,
//               duration: const Duration(milliseconds: 300),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBannerSection() {
//     return Container(
//       width: double.infinity,
//       height: 200,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Background image with overlay
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: _companyBanner != null && _companyBanner!.isNotEmpty
//                       ? _getImageProvider(_companyBanner!)
//                       : const AssetImage('assets/gallery-img-1.jpg')
//                   as ImageProvider,
//                   fit: BoxFit.cover,
//                   colorFilter: ColorFilter.mode(
//                     // ignore: deprecated_member_use
//                     Colors.black.withOpacity(0.6),
//                     BlendMode.darken,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 10, // above social icons
//               left: 0,
//               right: 0,
//               child: Center(child: _buildInfoAndActionsSection(context)),
//             ),
//
//             // Restaurant name and established year
//             Positioned(
//               top: 10,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       _bannerItem?.companyName ?? "Loading...",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       _bannerItem?.establishedYear ?? "Loading...",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Social icons
//             Positioned(
//               bottom: 50,
//               left: 0,
//               right: 0,
//               child: Center(child: _buildSocialIconsRow(_bannerItem)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoAndActionsSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // 🕒 Timings in Column (Start + End)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [_buildTimingInfo(context)],
//           ),
//
//           const SizedBox(width: 12),
//
//           // 🎯 Action Buttons in Row
//           Row(
//             children: [
//               _buildActionButton(
//                 text: _showKnowMore ? 'Hide Info' : 'Know More',
//                 onPressed: () => setState(() {
//                   _showKnowMore = !_showKnowMore;
//                   if (_showKnowMore) _showGallery = false;
//                   widget.onExpandChange(_showKnowMore || _showGallery);
//                 }),
//                 color: Colors.green,
//               ),
//               const SizedBox(width: 12),
//               _buildActionButton(
//                 text: _showGallery ? 'Hide Gallery' : 'View Gallery',
//                 onPressed: () => setState(() {
//                   _showGallery = !_showGallery;
//                   if (_showGallery) _showKnowMore = false;
//                   widget.onExpandChange(_showKnowMore || _showGallery);
//                 }),
//                 color: Colors.blueAccent,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimingInfo(BuildContext context) {
//     return _todayTiming != null
//         ? Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.access_time, size: 14, color: Colors.green),
//             Text(
//               "Start: ${_formatTime(context, _todayTiming!.startTime)}",
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Row(
//           children: [
//             const Icon(
//               Icons.access_time_filled,
//               size: 14,
//               color: Colors.red,
//             ),
//             Text(
//               "End: ${_formatTime(context, _todayTiming!.lastTime)}",
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ],
//     )
//         : const Text("No timing\n available.");
//   }
//
//   Widget _buildActionButton({
//     required String text,
//     required VoidCallback onPressed,
//     required Color color,
//   }) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 3,
//         textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//       ),
//       onPressed: onPressed,
//       child: Text(text),
//     );
//   }
//
//   Widget _buildAboutUsSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Center(
//             child: Text(
//               "ABOUT US",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Center(
//             child: Text(
//               _aboutUsModel?.aboutUs ?? "No About Us info available.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // Row for Mission and Vision
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // MISSION
//               Expanded(
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.asset(
//                         'assets/misionn.jpg',
//                         height: 100,
//                         width: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Mission",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       _aboutUsModel?.mission ?? "No mission data is available",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 16),
//
//               // VISION
//               Expanded(
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.asset(
//                         'assets/vision.jpg',
//                         height: 100,
//                         width: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Vision",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       _aboutUsModel?.vision ?? "No mission data is available.",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGallerySection() {
//     if (_images.isEmpty) {
//       return Center(
//         child: Text(
//           "No images available",
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }
//
//     return Container(
//       height: 80,
//       margin: const EdgeInsets.only(top: 10),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: imageUrls.length,
//         itemBuilder: (context, index) {
//           final img = imageUrls[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: _buildNetworkImage(img),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildNetworkImage(String imageUrl) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Image.network(
//         imageUrl,
//         width: 80,
//         height: 80,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => _fallbackImage(),
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) return child;
//           return const SizedBox(
//             width: 80,
//             height: 80,
//             child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _fallbackImage() {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Icon(Icons.broken_image, color: Colors.grey),
//     );
//   }
//
//   Widget _buildSocialIconsRow(Restaurent_Banner? banner) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Wrap(
//         spacing: 20,
//         runSpacing: 10,
//         alignment: WrapAlignment.center,
//         children: [
//           if (banner?.facebookLink.isNotEmpty ?? false)
//             IconButton(
//               icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
//               iconSize: 35.0,
//               onPressed: () => _launchSocialUrl(banner!.facebookLink),
//               tooltip: "Facebook",
//             ),
//           if (banner?.instagramLink.isNotEmpty ?? false)
//             IconButton(
//               icon: const Icon(
//                 FontAwesomeIcons.instagram,
//                 color: Colors.purple,
//               ),
//               iconSize: 35.0,
//               onPressed: () => _launchSocialUrl(banner!.instagramLink),
//               tooltip: "Instagram",
//             ),
//           if (banner?.whatsappLink.isNotEmpty ?? false)
//             IconButton(
//               icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
//               iconSize: 35.0,
//               onPressed: () => _launchSocialUrl(banner!.whatsappLink),
//               tooltip: "WhatsApp",
//             ),
//           if (banner?.twitterLink.isNotEmpty ?? false)
//             IconButton(
//               icon: const Icon(
//                 FontAwesomeIcons.twitter,
//                 color: Colors.lightBlue,
//               ),
//               iconSize: 35.0,
//               onPressed: () => _launchSocialUrl(banner!.twitterLink),
//               tooltip: "Twitter",
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// class MenuFilterBar extends StatefulWidget {
//   final bool isVeg;
//   final Function(bool) onToggle;
//   final int selectedFilterIndex;
//   final Function(int) onTabChange;
//   final int vendorId;
//   final int seatingId;
//   final String? orderType;
//
//   const MenuFilterBar({
//     super.key,
//     required this.isVeg,
//     required this.onToggle,
//     required this.onTabChange,
//     this.orderType,
//     required this.vendorId,
//     required this.seatingId,
//     this.selectedFilterIndex = 0,
//   });
//
//   @override
//   State<MenuFilterBar> createState() => _MenuFilterBarState();
// }
//
// class _MenuFilterBarState extends State<MenuFilterBar> {
//   late bool _isVeg;
//   int selectedTab = 0;
//   bool isVeg = true;
//   int selectedCategory = 0;
//   String? companyLogo;
//   bool isLoading = false;
//   int? userId;
//   int? dishId;
//   String? planType;
//   int? currentSeatingId;
//   List<String> categories = ['Starters'];
//
//   @override
//   void initState() {
//     super.initState();
//     _isVeg = widget.isVeg;
//     _loadSeatingId();
//     _loadUserData(); // 👈 load userId & planType
//     _loadSeatingId();
//   }
//
//   Future<void> _loadSeatingId() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       currentSeatingId = prefs.getInt('seatingId') ?? 0; // 0 or default
//     });
//   }
//
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       userId = prefs.getInt('userId'); // from login
//       planType = prefs.getString('planType'); // optional, set if applicable
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (userId == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(right: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               FlutterSwitch(
//                 width: 85.0,
//                 height: 40.0,
//                 toggleSize: 30.0,
//                 borderRadius: 20.0,
//                 value: _isVeg,
//                 showOnOff: true,
//                 activeColor: Colors.green,
//                 inactiveColor: Colors.red,
//                 activeToggleColor: Colors.white,
//                 inactiveToggleColor: Colors.white,
//                 activeText: "Veg",
//                 inactiveText: "Non-Veg",
//                 valueFontSize: 10.0,
//                 toggleColor: Colors.white70,
//                 onToggle: (val) {
//                   setState(() {
//                     _isVeg = val;
//                   });
//                 },
//               ),
//             ],
//           ),
//
//           Divider(color: Colors.grey.shade300, thickness: 1),
//           MenuTabContent(
//             isVeg: _isVeg,
//             vendorId: widget.vendorId,
//             selectedVendorId: (widget.vendorId),
//             seatingId: widget.seatingId,
//             favoriteButton: (dish) => FavoriteButton(
//               dish: Dish(
//                 dishId: dish.dishId,
//                 dishName: dish.dishName,
//                 price: dish.price,
//                 effectivePrice: dish.effectivePrice,
//                 stock: dish.stock,
//                 balanceQuantity: dish.balanceQuantity,
//                 discount: dish.discount,
//                 menuStatus: dish.menuStatus,
//               ),
//             ),
//             cartButton: (dish) => TableCartButton(
//               dishId: dish.dishId,
//               id: currentSeatingId ?? 0, // 👈 IMPORTANT
//             ),
//
//             isOutOfStock: (dish) => dish.stock?.toLowerCase() != "in stock",
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildLogoImage(String imageData) {
//     if (imageData.startsWith('http')) {
//       return ClipOval(
//         child: Image.network(
//           imageData,
//           height: 50,
//           width: 50,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(Icons.broken_image, size: 60);
//           },
//         ),
//       );
//     } else {
//       try {
//         final bytes = base64Decode(imageData.split(',').last);
//         return ClipOval(
//           child: Image.memory(bytes, height: 50, width: 50, fit: BoxFit.cover),
//         );
//       } catch (e) {
//         return const Icon(Icons.broken_image, size: 60);
//       }
//     }
//   }
// }
//
// class MenuTabContent extends StatefulWidget {
//   final bool isVeg;
//   final int vendorId;
//   final int selectedVendorId;
//   final int seatingId;
//   final favoriteButton;
//   final Widget Function(CategoryDish dish) cartButton;
//   final bool Function(Dish) isOutOfStock;
//
//   const MenuTabContent({
//     Key? key,
//     required this.isVeg,
//     required this.vendorId,
//     required this.selectedVendorId,
//     required this.favoriteButton,
//     required this.seatingId,
//     required this.cartButton,
//     required this.isOutOfStock,
//   }) : super(key: key);
//
//   @override
//   State<MenuTabContent> createState() => _MenuTabContentState();
// }
//
// class _MenuTabContentState extends State<MenuTabContent> {
//   int selectedIndex = 0;
//   int? selectedParentId;
//   late Future<List<CategoryDish>> _categoriesFuture;
//   List<CategoryDish> categories = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//     _categoriesFuture = food_Authservice.fetchCategories(widget.vendorId);
//   }
//
//   Future<void> _loadCategories() async {
//     try {
//       // 1️⃣ Fetch all categories for this vendor
//       List<CategoryDish> allCategories = await food_Authservice.fetchCategories(
//         widget.vendorId,
//       );
//
//       // 2️⃣ Filter only top-level categories (parentId = 0)
//       if (mounted) {
//         setState(() {
//           categories = allCategories.where((c) => c.parentId == 0).toList();
//         });
//       }
//     } catch (e) {
//       // print("Error loading categories: $e");
//     }
//   }
//
//   Future<void> launchSocialUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Sidebar Column
//         Container(
//           width: 80.w,
//           height: 550.h,
//           margin: EdgeInsets.only(left: 10.w, top: 5.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: FutureBuilder<List<CategoryDish>>(
//             future: _categoriesFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No categories found'));
//               }
//               final categories = snapshot.data!
//                   .where((dish) => dish.parentId == 0)
//                   .toList();
//               return ListView.builder(
//                 itemCount: categories.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == 0) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedParentId = 0;
//                           selectedIndex = 0;
//                         });
//                       },
//                       child: Container(
//                         height: 100.h,
//                         width: 80.w,
//                         decoration: BoxDecoration(
//                           color: selectedIndex == 0
//                               ? const Color(0xFFB15DC6)
//                               : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircleAvatar(
//                               radius: 25.r,
//                               backgroundImage: const AssetImage(
//                                 "assets/allitems.jpg",
//                               ),
//                             ),
//                             SizedBox(height: 5.h),
//                             const Text("All Items"),
//                           ],
//                         ),
//                       ),
//                     );
//                   }
//                   final category = categories[index - 1];
//                   return Sidebaritem(
//                     image:
//                     (category.dishImage != null &&
//                         category.dishImage!.isNotEmpty)
//                         ? NetworkImage(category.dishImage!)
//                         : const AssetImage("assets/default.png")
//                     as ImageProvider,
//                     title: category.dishName ?? '',
//                     onTap: () {
//                       setState(() {
//                         selectedParentId = category.dishId;
//                         selectedIndex = index;
//                       });
//                     },
//                     isSelected: index == selectedIndex,
//                     color: index == selectedIndex
//                         ? const Color(0xFFB15DC6)
//                     // ignore: deprecated_member_use
//                         : Colors.grey.withOpacity(0.4),
//                     textStyle: TextStyle(
//                       color: index == selectedIndex
//                           ? Colors.white
//                           : Colors.black,
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//
//         // Right Side: Main Content (Veg or Non-Veg)
//         Expanded(
//           child: Container(
//             margin: EdgeInsets.only(left: 5.w, top: 8.h),
//             padding: EdgeInsets.all(1.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: ListView(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               children: [
//                 DishGridTab(
//                   parentId: selectedParentId,
//                   vendorId: widget.selectedVendorId,
//                   seatingId: widget.seatingId,
//                   tag: widget.isVeg ? "veg" : "non_veg",
//                   emptyMessage: widget.isVeg
//                       ? "No Veg dishes found."
//                       : "No Non-Veg dishes found.",
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class DishGridTab extends StatefulWidget {
//   final int? parentId;
//   final int vendorId;
//   final int seatingId;
//   final String tag;
//   final String emptyMessage;
//
//   const DishGridTab({
//     Key? key,
//     this.parentId,
//     required this.vendorId,
//     required this.seatingId,
//     required this.tag,
//     required this.emptyMessage,
//   }) : super(key: key);
//
//   @override
//   _DishGridTabState createState() => _DishGridTabState();
// }
//
// class _DishGridTabState extends State<DishGridTab> {
//   late Future<List<Dish>> dishes;
//   int? userId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDishes();
//     _loadUserId();
//   }
//
//   Future<void> _loadUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userId = prefs.getInt('userId');
//     });
//   }
//
//   @override
//   void didUpdateWidget(DishGridTab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.parentId != oldWidget.parentId) {
//       _loadDishes();
//     }
//   }
//
//   void _loadDishes() {
//     setState(() {
//       dishes = (widget.parentId == null || widget.parentId == 0)
//           ? food_Authservice.getAllDishes(widget.vendorId)
//           : food_Authservice.getDishesByParentId(
//         widget.parentId!,
//         widget.vendorId,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Dish>>(
//       future: dishes,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(child: Text(widget.emptyMessage));
//         }
//
//         final filteredDishes = snapshot.data!
//             .where(
//               (dish) =>
//           dish.tag?.toLowerCase() == widget.tag.toLowerCase() &&
//               dish.stockQuantity != null &&
//               dish.stockQuantity! > 0,
//         )
//             .toList();
//
//         if (filteredDishes.isEmpty) {
//           return Center(child: Text(widget.emptyMessage));
//         }
//
//         final screenWidth = MediaQuery.of(context).size.width;
//         int crossAxisCount = screenWidth < 600
//             ? 2
//             : screenWidth < 900
//             ? 3
//             : 4;
//
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             crossAxisSpacing: 6,
//             mainAxisSpacing: 20,
//             childAspectRatio: screenWidth < 600 ? 0.55 : 0.75,
//           ),
//           itemCount: filteredDishes.length,
//           itemBuilder: (context, index) {
//             final dish = filteredDishes[index];
//             return ProductCard(
//               imageWidget: _buildImage(dish.dishImage),
//               name: dish.dishName ?? '',
//               price: "₹${dish.price}",
//               description: dish.description ?? '',
//               effectivePrice: "₹${dish.effectivePrice}",
//               favoriteButton: FavoriteButton(dish: dish),
//               cartButton: TableCartButton(
//                 dishId: dish.dishId,
//                 id: widget.seatingId,
//               ),
//               isOutOfStock:
//               dish.stock?.toLowerCase().replaceAll("_", " ") != "in stock",
//               balanceQuantity: dish.balanceQuantity,
//               discount: dish.discount,
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildImage(String? imageUrl) {
//     if (imageUrl != null && imageUrl.isNotEmpty) {
//       return Image.network(
//         imageUrl,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) return child;
//           return const Center(child: CircularProgressIndicator(strokeWidth: 2));
//         },
//       );
//     }
//     return const Icon(Icons.image_not_supported);
//   }
// }
//
// class ProductCard extends StatelessWidget {
//   final Widget imageWidget;
//   final String name;
//   final String price;
//   final String description;
//   final String effectivePrice;
//   final Widget favoriteButton;
//   final Widget cartButton;
//   final bool isOutOfStock;
//   final int balanceQuantity;
//   final num discount;
//
//   const ProductCard({
//     required this.imageWidget,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.effectivePrice,
//     required this.favoriteButton,
//     required this.cartButton,
//     required this.isOutOfStock,
//     required this.balanceQuantity,
//     required this.discount,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: isOutOfStock,
//       child: Opacity(
//         opacity: isOutOfStock ? 0.5 : 1.0,
//         child: Stack(
//           children: [
//             GestureDetector(
//               onTap: () => _showProductDialog(context),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       // ignore: deprecated_member_use
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 6,
//                       offset: const Offset(2, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildThumbnail(),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 4,
//                       ),
//                       child: Text(
//                         name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           effectivePrice,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           price, // discounted price
//                           style: const TextStyle(
//                             decoration: TextDecoration.lineThrough,
//                             fontSize: 10,
//
//                             color: Colors.redAccent,
//                           ),
//                         ),
//                         const Spacer(),
//                         favoriteButton,
//                       ],
//                     ),
//
//                     const SizedBox(height: 6),
//                     Center(child: cartButton),
//                     const SizedBox(height: 6),
//                   ],
//                 ),
//               ),
//             ),
//             if (balanceQuantity <= 0) _buildOutOfStockOverlay(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildThumbnail() {
//     return SizedBox(
//       height: 100,
//       width: double.infinity,
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(10),
//             ),
//             child: imageWidget,
//           ),
//           if (discount > 0)
//             Positioned(
//               top: 2,
//               left: 2,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   "$discount% OFF",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 10,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOutOfStockOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           // ignore: deprecated_member_use
//           color: Colors.grey.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(left: 20, top: 50),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'Out of Stock',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showProductDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, -4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: SizedBox(
//                           height: 180,
//                           width: double.infinity,
//                           child: imageWidget,
//                         ),
//                       ),
//                       if (discount > 0)
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.redAccent,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               "$discount% OFF", // e.g., "20% OFF"
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         top: 8,
//                         right: 8,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           radius: 18,
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             icon: const Icon(Icons.close, size: 18),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             effectivePrice,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//
//                               color: Colors.green,
//                               fontSize: 15,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             price, // discounted price
//                             style: const TextStyle(
//                               decoration: TextDecoration.lineThrough,
//                               fontSize: 18,
//
//                               color: Colors.redAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                       cartButton,
//                     ],
//                   ),
//                   if (description.isNotEmpty) ...[
//                     const SizedBox(height: 15),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade700,
//                         height: 1.4,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class Sidebaritem extends StatelessWidget {
//   final IconData? icon;
//   final String title;
//   final VoidCallback onTap;
//   final bool isSelected;
//   final Color color;
//   final TextStyle textStyle;
//   final ImageProvider? image;
//
//   const Sidebaritem({
//     this.icon,
//     this.image,
//     required this.title,
//     required this.onTap,
//     required this.isSelected,
//     required this.color,
//     required this.textStyle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Container(
//           height: 100.h,
//           width: MediaQuery.of(context).size.height * 0.28,
//           margin: EdgeInsets.symmetric(vertical: 8.h),
//           padding: EdgeInsets.all(10.w),
//           decoration: BoxDecoration(
//             color: isSelected ? color : Colors.grey[200],
//             borderRadius: BorderRadius.circular(12.r),
//             boxShadow: isSelected
//                 ? [
//               BoxShadow(
//                 // ignore: deprecated_member_use
//                 color: color.withOpacity(0.3),
//                 blurRadius: 12.r,
//                 spreadRadius: 3.r,
//               ),
//             ]
//                 : [],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 50.w,
//                 height: 50.h,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                 ),
//                 child: ClipOval(
//                   child: image != null
//                       ? Image(
//                     image: image!,
//                     fit: BoxFit.cover,
//                     width: 60.w,
//                     height: 60.h,
//                   )
//                       : Icon(icon, size: 40.sp, color: Colors.black),
//                 ),
//               ),
//               SizedBox(height: 5.h),
//               Flexible(
//                 child: AutoSizeText(
//                   title,
//                   style: textStyle.copyWith(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   minFontSize: 8,
//                   maxFontSize: 10,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
