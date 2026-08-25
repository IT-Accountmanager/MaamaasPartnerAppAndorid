//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaaspartner/Api/food_authservice.dart';
// import 'package:maamaaspartner/food&beverages/premium%20additems.dart';
// import '../DineOut Management/DineOut_Screen/DineOut_MainScreen.dart';
// import '../Models/food&beverages/dish.dart';
// import '../Models/food&beverages/orders_model.dart';
// import '../CateringModels/package_model.dart';
// import '../Catering_authservices/Auth_Services.dart';
// import '../caterings/AddPackage.dart';
// import '../caterings/UpdatePackagePage.dart';
// import '../standard Menu/screens/standard_menu_screen.dart';
// import '../widgets_helper/Home_screen_1.dart';
// import '../widgets_helper/food/utils.dart';
// import 'cart_screen.dart';
//
// // ─── Design Tokens (White Theme) ─────────────────────────────────────────────
// class AppColors {
//   static const bg = Color(0xFFF5F6FA);
//   static const surface = Color(0xFFFFFFFF);
//   static const card = Color(0xFFFFFFFF);
//   static const cardAlt = Color(0xFFF8F9FF);
//   static const border = Color(0xFFE8E9F0);
//   static const borderLight = Color(0xFFF0F1F8);
//   static const accent = Color(0xFFE66D33);
//   static const accentLight = Color(0xFFF5E6FA);
//   static const accentBlue = Color(0xFF4F8EF7);
//   static const accentBlueLight = Color(0xFFE8F0FE);
//   static const accentGreen = Color(0xFF2ECC71);
//   static const accentGreenLight = Color(0xFFE8F8F0);
//   static const accentRed = Color(0xFFE74C3C);
//   static const accentRedLight = Color(0xFFFEECEB);
//   static const accentOrange = Color(0xFFF39C12);
//   static const textPrimary = Color(0xFF1A1A2E);
//   static const textSecondary = Color(0xFF6B6B8A);
//   static const textMuted = Color(0xFFAAAAAC);
//   static const vegGreen = Color(0xFF27AE60);
//   static const nonVegRed = Color(0xFFE74C3C);
//   static const shadow = Color(0x0D000000);
//   static const shadowMd = Color(0x14000000);
// }
//
// enum MenuVertical { food, catering }
//
// enum VegFilter { all, veg, nonVeg }
//
// // ─── Main Widget ──────────────────────────────────────────────────────────────
// class Menu_Managemnet extends StatefulWidget {
//   const Menu_Managemnet({super.key});
//
//   @override
//   State<Menu_Managemnet> createState() => _Menu_ManagemnetState();
// }
//
// class _Menu_ManagemnetState extends State<Menu_Managemnet>
//     with TickerProviderStateMixin {
//   int selectedTabIndex = 0;
//   VegFilter _vegFilter = VegFilter.all;
//   OrderType selectedOrderType = OrderType.DINE_IN;
//   int _cartItemCount = 0;
//   MenuVertical _selectedVertical = MenuVertical.food;
//   int selectedCategoryIndex = 0;
//   int? selectedParentId;
//
//   final TextEditingController searchController = TextEditingController();
//   String searchQuery = '';
//
//   final ScrollController _scrollController = ScrollController();
//
//   bool _appBarVisible = true;
//   double _lastScrollOffset = 0;
//
//   Future<List<Dish>>? _categoriesFuture;
//
//   late AnimationController _fabAnimController;
//   late Animation<double> _fabAnim;
//
//   final List<IconData> tabIcons = [
//     Icons.restaurant_menu_rounded,
//     Icons.add_circle_outline_rounded,
//     Icons.inventory_2_outlined,
//     Icons.discount_outlined,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fabAnimController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _fabAnim = CurvedAnimation(
//       parent: _fabAnimController,
//       curve: Curves.elasticOut,
//     );
//
//     _loadCartCount();
//     _setupCartListener();
//     searchController.addListener(_onSearchChanged);
//     _scrollController.addListener(() {
//       final offset = _scrollController.offset;
//       final scrollingDown = offset > _lastScrollOffset + 2;
//       final scrollingUp = offset < _lastScrollOffset - 2;
//       _lastScrollOffset = offset;
//       if (scrollingDown && _appBarVisible) {
//         setState(() => _appBarVisible = false);
//       } else if (scrollingUp && !_appBarVisible) {
//         setState(() => _appBarVisible = true);
//       }
//     });
//     _categoriesFuture = food_authservice.fetchParentCategories();
//     _dishFuture = food_authservice
//         .fetchFilteredDishes(searchQuery: '', filterByMenuStatus: true)
//         .then((list) {
//           _cachedDishes = list;
//           return list;
//         });
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       searchQuery = searchController.text.toLowerCase().replaceAll(' ', '');
//     });
//     if (_selectedVertical == MenuVertical.food && selectedTabIndex == 0) {
//       _refreshDishFuture();
//     }
//   }
//
//   Future<void> _loadCartCount() async {
//     try {
//       final cart = await food_authservice.fetchCart();
//       if (cart != null) {
//         final count = cart.cartItems.fold(
//           0,
//           (sum, item) => sum + item.quantity,
//         );
//         setState(() => _cartItemCount = count);
//         if (count > 0) _fabAnimController.forward();
//       }
//     } catch (e) {
//       debugPrint('Error loading cart count: $e');
//     }
//   }
//
//   void _setupCartListener() {
//     Utils.itemCount.addListener(() {
//       if (mounted) {
//         setState(() => _cartItemCount = Utils.itemCount.value);
//         if (Utils.itemCount.value > 0) {
//           _fabAnimController.forward();
//         } else {
//           _fabAnimController.reverse();
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     _scrollController.dispose();
//     _fabAnimController.dispose();
//     super.dispose();
//   }
//
//   void onTabSelect(int index) {
//     setState(() {
//       selectedTabIndex = index;
//       if (index != 0) {
//         selectedCategoryIndex = 0;
//         selectedParentId = null;
//       }
//     });
//     if (index == 0 && _selectedVertical == MenuVertical.food) {
//       _refreshDishFuture();
//       if (_scrollController.hasClients) _scrollController.jumpTo(0);
//     }
//   }
//
//   void onCategoryTap(int index, int? parentId) {
//     setState(() {
//       selectedCategoryIndex = index;
//       selectedParentId = parentId;
//     });
//     if (_selectedVertical == MenuVertical.food && selectedTabIndex == 0) {
//       _refreshDishFuture();
//     }
//   }
//
//   void _navigateBackToHome() {
//     if (Navigator.canPop(context)) {
//       Navigator.pop(context);
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomeWrapper()),
//       );
//     }
//   }
//
//   // ─── App Bar (Back button + Title + DineIn/Takeaway + DineOut Buttons) ───────
//   Widget _buildAppBar() {
//     return Container(
//       color: AppColors.surface,
//       padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
//       child: Row(
//         children: [
//           // ── Back button ──────────────────────────────────────────────────────
//           GestureDetector(
//             onTap: _navigateBackToHome,
//             child: Container(
//               width: 38.r,
//               height: 38.r,
//               decoration: BoxDecoration(
//                 color: AppColors.bg,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: AppColors.textPrimary,
//                 size: 16.sp,
//               ),
//             ),
//           ),
//
//           // Small spacing instead of Spacer
//           SizedBox(width: 12.w),
//
//           // ── Dine In Button ──────────────────────────────────────────────────
//           _buildOrderTypeChip(
//             label: 'Dine In',
//             isActive: selectedOrderType == OrderType.DINE_IN,
//             onTap: () {
//               setState(() {
//                 selectedOrderType = OrderType.DINE_IN;
//               });
//               _refreshDishFuture();
//             },
//           ),
//
//           SizedBox(width: 8.w),
//           // ── Takeaway Button ─────────────────────────────────────────────────
//           _buildOrderTypeChip(
//             label: 'Takeaway',
//             isActive: selectedOrderType == OrderType.TAKEAWAY,
//             onTap: () {
//               setState(() {
//                 selectedOrderType = OrderType.TAKEAWAY;
//               });
//               _refreshDishFuture();
//             },
//           ),
//
//           SizedBox(width: 8.w),
//           // ── Dine Out Button ─────────────────────────────────────────────────
//           _buildDineOutButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderTypeChip({
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
//
//         decoration: BoxDecoration(
//           color: isActive ? Colors.green : const Color(0xFFE66D33),
//
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//
//         child: Text(
//           label,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 12.sp,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDineOutButton() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const DineOut()),
//         );
//       },
//
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
//
//         decoration: BoxDecoration(
//           color: const Color(0xFFE66D33), // 🟧 Same inactive style
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.table_restaurant_rounded,
//               color: Colors.white,
//               size: 13.sp,
//             ),
//
//             SizedBox(width: 5.w),
//
//             Text(
//               'Dine Out',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Sub-header row: Add Menu button + Veg/Non-Veg filters ───────────────────
//   Widget _buildSubHeaderRow() {
//     return Container(
//       color: AppColors.surface,
//       padding: EdgeInsets.fromLTRB(16.w, 0, 12.w, 10.h),
//       child: Row(
//         children: [
//           // ── Add Menu button ──────────────────────────────────────────────────
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const StandardMenuScreen()),
//             ),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.accent, Color(0xFF7B3FA0)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(10.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.accent.withOpacity(0.30),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.menu_book_rounded,
//                     color: Colors.white,
//                     size: 14.sp,
//                   ),
//                   SizedBox(width: 4.w),
//                   Text(
//                     'Add Menu',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(width: 8.w),
//
//           // ── Scrollable Veg/Non-Veg filter chips ─────────────────────────────
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               child: Row(
//                 children: [
//                   _buildFilterChip(
//                     label: 'All',
//                     isActive: _vegFilter == VegFilter.all,
//                     activeColor: AppColors.accentBlue,
//                     onTap: () {
//                       setState(() => _vegFilter = VegFilter.all);
//                       _refreshDishFuture();
//                     },
//                   ),
//                   SizedBox(width: 8.w),
//                   _buildFilterChip(
//                     label: 'Veg',
//                     isActive: _vegFilter == VegFilter.veg,
//                     activeColor: AppColors.vegGreen,
//                     onTap: () {
//                       setState(() => _vegFilter = VegFilter.veg);
//                       _refreshDishFuture();
//                     },
//                   ),
//                   SizedBox(width: 8.w),
//                   _buildFilterChip(
//                     label: 'Non-Veg',
//                     isActive: _vegFilter == VegFilter.nonVeg,
//                     activeColor: AppColors.nonVegRed,
//                     onTap: () {
//                       setState(() => _vegFilter = VegFilter.nonVeg);
//                       _refreshDishFuture();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip({
//     required String label,
//     required bool isActive,
//     required Color activeColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: isActive ? activeColor : AppColors.bg,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(color: isActive ? activeColor : AppColors.border),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isActive ? Colors.white : AppColors.textSecondary,
//             fontWeight: FontWeight.w600,
//             fontSize: 11.sp,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Search Bar ────────────────────────────────────────────────────────────────
//   Widget _buildSearchBar() {
//     return Container(
//       color: AppColors.surface,
//       padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.bg,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: TextField(
//           controller: searchController,
//
//           onChanged: (value) {
//             setState(() {
//               searchQuery = value.toLowerCase().replaceAll(' ', '');
//             });
//           },
//
//           style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
//
//           decoration: InputDecoration(
//             hintText: 'Search categories or dishes…',
//             hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
//
//             prefixIcon: Icon(
//               Icons.search_rounded,
//               color: AppColors.textMuted,
//               size: 20.sp,
//             ),
//
//             suffixIcon: searchQuery.isNotEmpty
//                 ? IconButton(
//                     icon: Icon(
//                       Icons.close_rounded,
//                       color: AppColors.textMuted,
//                       size: 18.sp,
//                     ),
//                     onPressed: () {
//                       searchController.clear();
//
//                       setState(() {
//                         searchQuery = '';
//                       });
//                     },
//                   )
//                 : null,
//
//             border: InputBorder.none,
//
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 4.w,
//               vertical: 12.h,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCatChip({
//     required int index,
//     required String name,
//     String? imageUrl,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 66.w,
//         margin: EdgeInsets.only(right: 10.w),
//         child: Column(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: 52.r,
//               height: 52.r,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isSelected ? AppColors.accentLight : AppColors.bg,
//                 border: Border.all(
//                   color: isSelected ? AppColors.accent : AppColors.border,
//                   width: isSelected ? 2 : 1,
//                 ),
//                 boxShadow: isSelected
//                     ? [
//                         BoxShadow(
//                           color: AppColors.accent.withOpacity(0.2),
//                           blurRadius: 8,
//                         ),
//                       ]
//                     : null,
//               ),
//               child: Center(child: _catImage(imageUrl)),
//             ),
//             SizedBox(height: 5.h),
//             Text(
//               name,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 color: isSelected ? AppColors.accent : AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _catImage(String? url) {
//     if (url == null || url.isEmpty) {
//       return Icon(
//         Icons.category_rounded,
//         size: 22.r,
//         color: AppColors.textMuted,
//       );
//     }
//     if (url.startsWith('http')) {
//       return ClipOval(
//         child: Image.network(
//           url,
//           width: 44.r,
//           height: 44.r,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Icon(
//             Icons.category_rounded,
//             size: 22.r,
//             color: AppColors.textMuted,
//           ),
//         ),
//       );
//     }
//     return ClipOval(
//       child: Image.memory(
//         base64Decode(url),
//         width: 44.r,
//         height: 44.r,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => Icon(
//           Icons.category_rounded,
//           size: 22.r,
//           color: AppColors.textMuted,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     switch (_selectedVertical) {
//       case MenuVertical.food:
//         switch (selectedTabIndex) {
//           case 0:
//             return const SizedBox.shrink();
//           case 1:
//             return AddItemTab(isVeg: _vegFilter == VegFilter.veg);
//           case 2:
//             return ItemQuantityTab(onCartUpdated: _loadCartCount);
//           case 3:
//             return DiscountTab(onCartUpdated: _loadCartCount);
//           default:
//             return const SizedBox.shrink();
//         }
//       case MenuVertical.catering:
//         return const CateringContent();
//     }
//   }
//
//   Widget _buildCartButton() {
//     if (_cartItemCount == 0) return const SizedBox.shrink();
//
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => food_CartScreen(
//               cartId: null,
//               savedAmount: 0,
//               showSavedPopup: false,
//             ),
//           ),
//         ),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [AppColors.accent, Color(0xFF7B3FA0)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(12.r),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.accent.withOpacity(0.4),
//                 blurRadius: 20,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.shopping_cart_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 'View Cart  •  $_cartItemCount ${_cartItemCount == 1 ? 'item' : 'items'}',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15.sp,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final showFoodHeader =
//         _selectedVertical == MenuVertical.food && selectedTabIndex == 0;
//
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateBackToHome();
//         return false;
//       },
//       child: Theme(
//         data: ThemeData.light().copyWith(
//           scaffoldBackgroundColor: AppColors.bg,
//           appBarTheme: const AppBarTheme(backgroundColor: AppColors.surface),
//         ),
//         child: Scaffold(
//           backgroundColor: AppColors.bg,
//           body: SafeArea(
//             child: Column(
//               children: [
//                 // 1. App bar (back button + title + DineIn/Takeaway + DineOut buttons)
//                 _buildAppBar(),
//                 Divider(color: AppColors.border, height: 1),
//
//                 // 2. Sub-header: Add Menu button + Veg/Non-Veg filters
//                 _buildSubHeaderRow(),
//                 Divider(color: AppColors.border, height: 1),
//
//                 // 3. Remaining content
//                 Expanded(
//                   child: showFoodHeader
//                       ? _buildScrollableFood()
//                       : _buildNonScrollableContent(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildScrollableFood() {
//     return Column(
//       children: [
//         Expanded(
//           child: NestedScrollView(
//             controller: _scrollController,
//             physics: const BouncingScrollPhysics(),
//             headerSliverBuilder: (context, innerBoxIsScrolled) => [
//               SliverToBoxAdapter(
//                 child: Column(
//                   children: [
//                     _buildSearchBar(),
//                     _buildHorizontalCategoriesStatic(),
//                   ],
//                 ),
//               ),
//             ],
//             body: FutureBuilder<List<Dish>>(
//               future: _dishFuture,
//               builder: (_, snapshot) => _buildDishListView(snapshot),
//             ),
//           ),
//         ),
//         _buildCartButton(),
//       ],
//     );
//   }
//
//   Future<List<Dish>>? _dishFuture;
//   List<Dish> _cachedDishes = [];
//
//   void _refreshDishFuture() {
//     setState(() {
//       _dishFuture = food_authservice
//           .fetchFilteredDishes(
//             searchQuery: searchQuery,
//             filterByMenuStatus: true,
//           )
//           .then((list) {
//             _cachedDishes = list;
//             return list;
//           });
//     });
//   }
//   //
//   // // ─── Dish list view with category search functionality ───────────────────────
//   // Widget _buildDishListView(AsyncSnapshot<List<Dish>> snapshot) {
//   //   if (snapshot.connectionState == ConnectionState.waiting) {
//   //     return const Center(
//   //       child: CircularProgressIndicator(color: AppColors.accent),
//   //     );
//   //   }
//   //   if (snapshot.hasError) {
//   //     return _ErrorState(message: 'Error: ${snapshot.error}');
//   //   }
//   //
//   //   List<Dish> allDishes = snapshot.data ?? [];
//   //
//   //   // ── Determine which parent categories are enabled ──────────────────────
//   //   // final enabledParentIds = allDishes
//   //   //     .where(
//   //   //       (d) => d.parentId == 0 && (d.menuStatus?.toLowerCase() == 'enable'),
//   //   //     )
//   //   //     .map((d) => d.dishId)
//   //   //     .toSet();
//   //
//   //   final enabledParentIds = allDishes
//   //       .where(
//   //         (d) => d.parentId == 0 && (d.menuStatus?.toLowerCase() == 'enable'),
//   //       )
//   //       .map((d) => d.dishId)
//   //       .toSet();
//   //
//   //   subDishes = subDishes
//   //       .where((d) => enabledParentIds.contains(d.parentId))
//   //       .toList();
//   //
//   //   // ── Keep only sub-dishes (non-root items) ────────────────────────────
//   //   List<Dish> subDishes = allDishes
//   //       .where((d) => d.parentId != null && d.parentId != 0)
//   //       .toList();
//   //
//   //   // ── Filter to enabled parent categories ──────────────────────────────
//   //   if (enabledParentIds.isNotEmpty) {
//   //     subDishes = subDishes
//   //         .where((d) => enabledParentIds.contains(d.parentId))
//   //         .toList();
//   //   }
//   //
//   //   // ── Search: match category names OR dish names ────────────────────────
//   //   if (searchQuery.isNotEmpty) {
//   //     final q = searchQuery;
//   //
//   //     // Build a set of parentIds whose category NAME matches the query
//   //     final matchingParentIds = allDishes
//   //         .where(
//   //           (d) =>
//   //               d.parentId == 0 &&
//   //               (d.dishName ?? '')
//   //                   .toLowerCase()
//   //                   .replaceAll(' ', '')
//   //                   .contains(q),
//   //         )
//   //         .map((d) => d.dishId)
//   //         .toSet();
//   //
//   //     subDishes = subDishes.where((d) {
//   //       // 1) The dish's own name matches
//   //       final nameMatch = (d.dishName ?? '')
//   //           .toLowerCase()
//   //           .replaceAll(' ', '')
//   //           .contains(q);
//   //       // 2) The dish belongs to a matched category
//   //       final categoryMatch = matchingParentIds.contains(d.parentId);
//   //       return nameMatch || categoryMatch;
//   //     }).toList();
//   //   }
//   //
//   //   // ── Veg / Non-Veg filter ──────────────────────────────────────────────
//   //   if (_vegFilter == VegFilter.veg) {
//   //     subDishes = subDishes
//   //         .where((d) => d.tag?.toLowerCase() == 'veg')
//   //         .toList();
//   //   } else if (_vegFilter == VegFilter.nonVeg) {
//   //     subDishes = subDishes
//   //         .where(
//   //           (d) =>
//   //               d.tag?.toLowerCase() == 'non_veg' ||
//   //               d.tag?.toLowerCase() == 'non-veg' ||
//   //               (d.tag != null && d.tag!.toLowerCase() != 'veg'),
//   //         )
//   //         .toList();
//   //   }
//   //
//   //   // ── Category chip filter ──────────────────────────────────────────────
//   //   if (selectedParentId != null && selectedParentId != 0) {
//   //     subDishes = subDishes
//   //         .where((d) => d.parentId == selectedParentId)
//   //         .toList();
//   //   }
//   //
//   //   if (subDishes.isEmpty) {
//   //     return _EmptyState(
//   //       icon: Icons.search_off_rounded,
//   //       message: 'No dishes found',
//   //     );
//   //   }
//   //
//   //   // ── Sort: out-of-stock items sink to the bottom ───────────────────────
//   //   subDishes.sort((a, b) {
//   //     final aOut =
//   //         a.stock?.toLowerCase() == 'out_of_stock' || a.balanceQuantity <= 0;
//   //     final bOut =
//   //         b.stock?.toLowerCase() == 'out_of_stock' || b.balanceQuantity <= 0;
//   //     if (aOut == bOut) return 0;
//   //     return aOut ? 1 : -1;
//   //   });
//
//   Widget _buildDishListView(AsyncSnapshot<List<Dish>> snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return const Center(
//         child: CircularProgressIndicator(color: AppColors.accent),
//       );
//     }
//     if (snapshot.hasError) {
//       return _ErrorState(message: 'Error: ${snapshot.error}');
//     }
//
//     final List<Dish> allDishes = snapshot.data ?? [];
//     List<Dish> list = snapshot.data ?? [];
//
//     list = list
//         .where((dish) => dish.approvalStatus?.toUpperCase() == 'APPROVED')
//         .toList();
//
//     final enabledParentIds = _cachedDishes
//         .where(
//           (d) => d.parentId == 0 && (d.menuStatus?.toLowerCase() == 'enable'),
//         )
//         .map((d) => d.dishId)
//         .toSet();
//
//     final Map<int, Dish> byId = {
//       for (final d in allDishes)
//         if (d.dishId != null) d.dishId!: d,
//     };
//
//     final Set<int> parentIds = allDishes
//         .map((d) => d.parentId)
//         .whereType<int>()
//         .toSet();
//
//     int? rootIdOf(Dish d) {
//       Dish? cur = d;
//       int guard = 0;
//       while (cur != null && cur.parentId != 0 && guard < 10) {
//         cur = byId[cur.parentId];
//         guard++;
//       }
//       return cur?.dishId;
//     }
//
//     bool chainEnabled(Dish d) {
//       Dish? cur = d;
//       int guard = 0;
//       while (cur != null && guard < 10) {
//         final status = cur.menuStatus?.toLowerCase();
//         if (status != null && status != 'enable') return false;
//
//         if (cur.parentId == 0) break;
//         cur = byId[cur.parentId];
//         guard++;
//       }
//       return true;
//     }
//
//     List<Dish> subDishes = allDishes
//         .where((d) => d.dishId != null && d.parentId != null && d.parentId != 0)
//         .where((d) => !parentIds.contains(d.dishId))
//         .where(chainEnabled)
//         .toList();
//
//     if (searchQuery.isNotEmpty) {
//       final q = searchQuery;
//
//       final matchingRootIds = allDishes
//           .where(
//             (d) =>
//                 d.parentId == 0 &&
//                 (d.dishName ?? '')
//                     .toLowerCase()
//                     .replaceAll(' ', '')
//                     .contains(q),
//           )
//           .map((d) => d.dishId)
//           .toSet();
//
//       subDishes = subDishes.where((d) {
//         final nameMatch = (d.dishName ?? '')
//             .toLowerCase()
//             .replaceAll(' ', '')
//             .contains(q);
//         final categoryMatch = matchingRootIds.contains(rootIdOf(d));
//         return nameMatch || categoryMatch;
//       }).toList();
//     }
//
//     if (_vegFilter == VegFilter.veg) {
//       subDishes = subDishes
//           .where((d) => d.tag?.toLowerCase() == 'veg')
//           .toList();
//     } else if (_vegFilter == VegFilter.nonVeg) {
//       subDishes = subDishes
//           .where(
//             (d) =>
//                 d.tag?.toLowerCase() == 'non_veg' ||
//                 d.tag?.toLowerCase() == 'non-veg' ||
//                 (d.tag != null && d.tag!.toLowerCase() != 'veg'),
//           )
//           .toList();
//     }
//
//     // ── Category chip filter: compare against the resolved ROOT id ──
//     if (selectedParentId != null && selectedParentId != 0) {
//       subDishes = subDishes
//           .where((d) => rootIdOf(d) == selectedParentId)
//           .toList();
//     }
//
//     if (subDishes.isEmpty) {
//       return _EmptyState(
//         icon: Icons.search_off_rounded,
//         message: 'No dishes found',
//       );
//     }
//
//     subDishes.sort((a, b) {
//       final aOut =
//           a.stock?.toLowerCase() == 'out_of_stock' || a.balanceQuantity <= 0;
//       final bOut =
//           b.stock?.toLowerCase() == 'out_of_stock' || b.balanceQuantity <= 0;
//       if (aOut == bOut) return 0;
//       return aOut ? 1 : -1;
//     });
//     return GridView.builder(
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.68,
//       ),
//       itemCount: subDishes.length,
//       itemBuilder: (_, i) {
//         final dish = subDishes[i];
//         final img = dish.dishImage != null && dish.dishImage!.isNotEmpty
//             ? Image.network(
//                 dish.dishImage!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Icon(
//                   Icons.broken_image,
//                   size: 40,
//                   color: AppColors.textMuted,
//                 ),
//               )
//             : Icon(
//                     Icons.image_not_supported,
//                     size: 40,
//                     color: AppColors.textMuted,
//                   )
//                   as Widget;
//         return ProductCard(
//           imageWidget: img,
//
//           name: dish.dishName ?? '',
//           price: '₹${dish.effectivePrice}',
//           description: dish.description ?? '',
//           effectivePrice: '₹${dish.effectivePrice}',
//           code: dish.code,
//           cartButton: CartButton(
//             dishId: dish.dishId ?? 0,
//             orderType: selectedOrderType,
//             balanceQuantity: dish.balanceQuantity,
//             onCartUpdated: _loadCartCount,
//           ),
//           isOutOfStock:
//               dish.stock?.toLowerCase() == 'out_of_stock' ||
//               dish.balanceQuantity <= 0,
//         );
//       },
//     );
//   }
//
//   // ── Horizontal categories with search highlighting ──────────────────────────
//   Widget _buildHorizontalCategoriesStatic() {
//     return Container(
//       color: AppColors.surface,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 86.h,
//             child: FutureBuilder<List<Dish>>(
//               future: _categoriesFuture,
//               builder: (_, snap) {
//                 if (!snap.hasData || snap.data!.isEmpty) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final parents = snap.data!
//                     .where(
//                       (d) =>
//                           d.parentId == 0 &&
//                           (d.menuStatus == null ||
//                               d.menuStatus!.toLowerCase() == 'enable'),
//                     )
//                     .toList();
//
//                 if (parents.isEmpty) return const SizedBox.shrink();
//
//                 Set<int?> matchedParentIds = {};
//                 if (searchQuery.isNotEmpty) {
//                   matchedParentIds = _cachedDishes
//                       .where(
//                         (d) =>
//                             d.parentId != null &&
//                             d.parentId != 0 &&
//                             ((d.dishName ?? '')
//                                     .toLowerCase()
//                                     .replaceAll(' ', '')
//                                     .contains(searchQuery) ||
//                                 (d.parentId != null &&
//                                     parents.any(
//                                       (p) =>
//                                           p.dishId == d.parentId &&
//                                           (p.dishName ?? '')
//                                               .toLowerCase()
//                                               .replaceAll(' ', '')
//                                               .contains(searchQuery),
//                                     ))),
//                       )
//                       .map((d) => d.parentId)
//                       .toSet();
//                 }
//
//                 return ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   itemCount: parents.length + 1,
//                   itemBuilder: (_, i) {
//                     if (i == 0) {
//                       return _buildCatChip(
//                         index: 0,
//                         name: 'All',
//                         imageUrl: null,
//                         isSelected: selectedCategoryIndex == 0,
//                         onTap: () => onCategoryTap(0, 0),
//                       );
//                     }
//                     final cat = parents[i - 1];
//                     final hasMatch =
//                         searchQuery.isEmpty ||
//                         matchedParentIds.contains(cat.dishId);
//                     return Opacity(
//                       opacity: hasMatch ? 1.0 : 0.4,
//                       child: _buildCatChip(
//                         index: i,
//                         name: cat.dishName ?? '',
//                         imageUrl: cat.dishImage,
//                         isSelected: selectedCategoryIndex == i,
//                         onTap: () => onCategoryTap(i, cat.dishId),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Divider(color: AppColors.border, height: 1, thickness: 1),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNonScrollableContent() {
//     return Column(
//       children: [
//         if (_selectedVertical == MenuVertical.food && selectedTabIndex != 0)
//           Expanded(child: _buildContent()),
//       ],
//     );
//   }
// }
//
// // ─── Catering Content ─────────────────────────────────────────────────────────
// class CateringContent extends StatefulWidget {
//   const CateringContent({super.key});
//
//   @override
//   State<CateringContent> createState() => _CateringContentState();
// }
//
// class _CateringContentState extends State<CateringContent> {
//   final List<PackageModel> packages = [];
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPackages();
//   }
//
//   Future<void> fetchPackages() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });
//     try {
//       final vendorId = await CateringService.getVendorId();
//       if (vendorId == null) throw Exception('Vendor not logged in');
//       final fetched = await CateringService.getPackagesByVendor(vendorId);
//       setState(() {
//         packages
//           ..clear()
//           ..addAll(fetched);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Failed to load: $e';
//       });
//     }
//   }
//
//   Future<void> deletePackage(int id) async {
//     final ok = await CateringService.deletePackage(id);
//     if (ok) {
//       setState(() => packages.removeWhere((p) => p.id == id));
//       _snack('Package deleted!', AppColors.accentGreen);
//     } else {
//       _snack('Failed to delete', AppColors.accentRed);
//     }
//   }
//
//   Future<void> _onEdit(PackageModel pkg) async {
//     final updated = await Navigator.push<PackageModel?>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => UpdatePackagePage(
//           packageData: {
//             'id': pkg.id,
//             'vendorId': pkg.vendorId,
//             'packageName': pkg.packageName,
//             'packageType': pkg.packageType,
//             'image': pkg.image ?? '',
//             'totalPrice': pkg.totalPrice,
//             'items': pkg.items
//                 .map(
//                   (i) => {'id': i.id, 'itemName': i.itemName, 'price': i.price},
//                 )
//                 .toList(),
//           },
//         ),
//       ),
//     );
//     if (updated != null) {
//       final idx = packages.indexWhere((p) => p.id == pkg.id);
//       if (idx != -1) setState(() => packages[idx] = updated);
//     }
//   }
//
//   Future<void> _onDelete(PackageModel pkg) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => _ConfirmDialog(
//         title: 'Delete Package',
//         message: 'Are you sure you want to delete this package?',
//       ),
//     );
//     if (ok == true) await deletePackage(pkg.id!);
//   }
//
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         _buildBody(),
//         Positioned(
//           bottom: 24,
//           right: 20,
//           child: GestureDetector(
//             onTap: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AddPackagePage(
//                     onPackageAdded: (pkg) => setState(() => packages.add(pkg)),
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.accentBlue, Color(0xFF2563EB)],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.accentBlue.withOpacity(0.35),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.add_rounded, color: Colors.white, size: 20),
//                   SizedBox(width: 8),
//                   Text(
//                     'Add Package',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBody() {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: AppColors.accent),
//       );
//     }
//     if (errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 56,
//               color: AppColors.accentRed,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               errorMessage,
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             _PrimaryButton(label: 'Retry', onTap: fetchPackages),
//           ],
//         ),
//       );
//     }
//     if (packages.isEmpty) {
//       return _EmptyState(
//         icon: Icons.restaurant_menu_rounded,
//         message: 'No packages yet',
//         subtitle: 'Tap below to create your first package',
//       );
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//       itemCount: packages.length,
//       itemBuilder: (_, i) => _PackageCard(
//         pkg: packages[i],
//         onEdit: () => _onEdit(packages[i]),
//         onDelete: () => _onDelete(packages[i]),
//       ),
//     );
//   }
// }
//
// // ─── Package Card ─────────────────────────────────────────────────────────────
// class _PackageCard extends StatelessWidget {
//   final PackageModel pkg;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const _PackageCard({
//     required this.pkg,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isVeg = pkg.packageType.toLowerCase().contains('veg');
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: pkg.image != null && pkg.image!.isNotEmpty
//                 ? Image.network(
//                     pkg.image!,
//                     height: 155,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => _noImg(),
//                   )
//                 : _noImg(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         pkg.packageName,
//                         style: const TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                     _iconBtn(Icons.edit_rounded, AppColors.accentBlue, onEdit),
//                     const SizedBox(width: 8),
//                     _iconBtn(
//                       Icons.delete_rounded,
//                       AppColors.accentRed,
//                       onDelete,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isVeg
//                         ? AppColors.accentGreenLight
//                         : AppColors.accentRedLight,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     pkg.packageType,
//                     style: TextStyle(
//                       color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Items',
//                   style: TextStyle(
//                     color: AppColors.textMuted,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 ...pkg.items.map(
//                   (item) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 4,
//                           height: 4,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColors.accent,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             item.itemName,
//                             style: const TextStyle(
//                               color: AppColors.textSecondary,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '₹${item.price.toStringAsFixed(0)}',
//                           style: const TextStyle(
//                             color: AppColors.textPrimary,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Divider(color: AppColors.border, height: 1),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       'Total  ',
//                       style: TextStyle(
//                         color: AppColors.textMuted,
//                         fontSize: 13,
//                       ),
//                     ),
//                     Text(
//                       '₹${pkg.totalPrice.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         color: AppColors.accent,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _noImg() => Container(
//     height: 110,
//     color: AppColors.bg,
//     child: Center(
//       child: Icon(
//         Icons.image_not_supported_outlined,
//         size: 36,
//         color: AppColors.textMuted,
//       ),
//     ),
//   );
//
//   Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color == AppColors.accentBlue
//                 ? AppColors.accentBlueLight
//                 : AppColors.accentRedLight,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 17),
//         ),
//       );
// }
//
// // ─── Item Quantity Tab ────────────────────────────────────────────────────────
// class ItemQuantityTab extends StatefulWidget {
//   final Function()? onCartUpdated;
//   const ItemQuantityTab({super.key, this.onCartUpdated});
//   @override
//   State<ItemQuantityTab> createState() => _ItemQuantityTabState();
// }
//
// class _ItemQuantityTabState extends State<ItemQuantityTab> {
//   final Map<int, bool> expandedMap = {};
//   final TextEditingController _search = TextEditingController();
//   String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
//
//   @override
//   void initState() {
//     super.initState();
//     _search.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SearchField(controller: _search),
//         Expanded(
//           child: FutureBuilder<List<Dish>>(
//             future: food_authservice.fetchDishes(),
//             builder: (_, snap) {
//               if (snap.connectionState == ConnectionState.waiting)
//                 return const Center(
//                   child: CircularProgressIndicator(color: AppColors.accent),
//                 );
//               if (!snap.hasData || snap.data!.isEmpty)
//                 return _EmptyState(
//                   icon: Icons.inventory_2_outlined,
//                   message: 'No items',
//                 );
//               final all = snap.data!
//                   .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
//                   .toList();
//               final q = _norm(_search.text);
//               final parents = all.where((d) => d.parentId == 0).where((p) {
//                 if (_search.text.isEmpty) return true;
//                 if (_norm(p.dishName ?? '').contains(q)) return true;
//                 return all
//                     .where((c) => c.parentId == p.dishId)
//                     .any((c) => _norm(c.dishName ?? '').contains(q));
//               }).toList();
//
//               if (parents.isEmpty)
//                 return _EmptyState(
//                   icon: Icons.search_off_rounded,
//                   message: 'No items found',
//                 );
//
//               return ListView.builder(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
//                 itemCount: parents.length,
//                 itemBuilder: (_, i) {
//                   final parent = parents[i];
//                   final isExp = expandedMap[parent.dishId!] ?? true;
//                   final children = all
//                       .where((c) => c.parentId == parent.dishId)
//                       .where(
//                         (c) =>
//                             _search.text.isEmpty ||
//                             _norm(c.dishName ?? '').contains(q),
//                       )
//                       .toList();
//                   return _CategorySection(
//                     title: parent.dishName ?? '',
//                     isExpanded: isExp,
//                     onToggle: () =>
//                         setState(() => expandedMap[parent.dishId!] = !isExp),
//                     children: isExp
//                         ? children
//                               .map(
//                                 (c) => _QuantityItem(
//                                   dish: c,
//                                   onEdit: () => _showEditDialog(c),
//                                 ),
//                               )
//                               .toList()
//                         : [],
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showEditDialog(Dish dish) {
//     final ctrl = TextEditingController(
//       text: dish.stockQuantity?.toString() ?? '0',
//     );
//     showDialog(
//       context: context,
//       builder: (_) => _InputDialog(
//         title: 'Edit Quantity',
//         controller: ctrl,
//         keyboardType: TextInputType.number,
//         hint: 'Enter quantity',
//         onSave: () async {
//           final qty = int.tryParse(ctrl.text) ?? 0;
//           await food_authservice.updateDish(
//             dishId: dish.dishId,
//             dishData: {'stockQuantity': qty},
//             imageFile: null,
//           );
//           setState(() {});
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text(
//                   'Quantity updated!',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 backgroundColor: AppColors.accentGreen,
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// // ─── Quantity Item Card ───────────────────────────────────────────────────────
// class _QuantityItem extends StatelessWidget {
//   final Dish dish;
//   final VoidCallback onEdit;
//   const _QuantityItem({required this.dish, required this.onEdit});
//
//   @override
//   Widget build(BuildContext context) {
//     final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 10,
//                 height: 10,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   dish.dishName ?? '',
//                   style: const TextStyle(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               Text(
//                 '₹${dish.price ?? 0}',
//                 style: const TextStyle(
//                   color: AppColors.accent,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _pill('Stock', dish.stockQuantity, AppColors.accentBlue),
//                     _pill(
//                       'Used',
//                       dish.consumedQuantity,
//                       AppColors.accentOrange,
//                     ),
//                     _pill(
//                       'Balance',
//                       dish.balanceQuantity,
//                       AppColors.accentGreen,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//               GestureDetector(
//                 onTap: onEdit,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.accentBlueLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.edit_rounded,
//                     size: 16,
//                     color: AppColors.accentBlue,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _pill(String label, int? value, Color color) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
//       ),
//       const SizedBox(height: 2),
//       Text(
//         '${value ?? 0}',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w800,
//           color: color,
//         ),
//       ),
//     ],
//   );
// }
//
// // ─── Discount Tab ─────────────────────────────────────────────────────────────
// class DiscountTab extends StatefulWidget {
//   final Function()? onCartUpdated;
//   const DiscountTab({super.key, this.onCartUpdated});
//   @override
//   State<DiscountTab> createState() => _DiscountTabState();
// }
//
// class _DiscountTabState extends State<DiscountTab> {
//   final Map<int, bool> expandedMap = {};
//   final TextEditingController _search = TextEditingController();
//   String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
//
//   @override
//   void initState() {
//     super.initState();
//     _search.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SearchField(controller: _search),
//         Expanded(
//           child: FutureBuilder<List<Dish>>(
//             future: food_authservice.fetchDishes(),
//             builder: (_, snap) {
//               if (snap.connectionState == ConnectionState.waiting)
//                 return const Center(
//                   child: CircularProgressIndicator(color: AppColors.accent),
//                 );
//               if (!snap.hasData || snap.data!.isEmpty)
//                 return _EmptyState(
//                   icon: Icons.discount_outlined,
//                   message: 'No items',
//                 );
//               final all = snap.data!
//                   .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
//                   .toList();
//               final q = _norm(_search.text);
//               final parents = all.where((d) => d.parentId == 0).where((p) {
//                 if (_search.text.isEmpty) return true;
//                 if (_norm(p.dishName ?? '').contains(q)) return true;
//                 return all
//                     .where((c) => c.parentId == p.dishId)
//                     .any((c) => _norm(c.dishName ?? '').contains(q));
//               }).toList();
//
//               if (parents.isEmpty)
//                 return _EmptyState(
//                   icon: Icons.search_off_rounded,
//                   message: 'No items found',
//                 );
//
//               return ListView.builder(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
//                 itemCount: parents.length,
//                 itemBuilder: (_, i) {
//                   final parent = parents[i];
//                   final isExp = expandedMap[parent.dishId!] ?? true;
//                   final children = all
//                       .where((c) => c.parentId == parent.dishId)
//                       .where(
//                         (c) =>
//                             _search.text.isEmpty ||
//                             _norm(c.dishName ?? '').contains(q),
//                       )
//                       .toList();
//                   return _CategorySection(
//                     title: parent.dishName ?? '',
//                     isExpanded: isExp,
//                     onToggle: () =>
//                         setState(() => expandedMap[parent.dishId!] = !isExp),
//                     children: isExp
//                         ? children
//                               .map(
//                                 (c) => _DiscountItem(
//                                   dish: c,
//                                   onEdit: () => _showDialog(c),
//                                 ),
//                               )
//                               .toList()
//                         : [],
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showDialog(Dish dish) {
//     final ctrl = TextEditingController(
//       text: dish.discount != null && dish.discount! > 0
//           ? dish.discount!.toStringAsFixed(0)
//           : '',
//     );
//     showDialog(
//       context: context,
//       builder: (_) => _InputDialog(
//         title: 'Set Discount',
//         controller: ctrl,
//         keyboardType: TextInputType.number,
//         hint: 'Enter percentage (0–100)',
//         onSave: () async {
//           final d = double.tryParse(ctrl.text) ?? 0;
//           await food_authservice.updateDish(
//             dishId: dish.dishId,
//             dishData: {'discount': d},
//             imageFile: null,
//           );
//           setState(() {});
//         },
//       ),
//     );
//   }
// }
//
// // ─── Discount Item ────────────────────────────────────────────────────────────
// class _DiscountItem extends StatelessWidget {
//   final Dish dish;
//   final VoidCallback onEdit;
//   const _DiscountItem({required this.dish, required this.onEdit});
//
//   @override
//   Widget build(BuildContext context) {
//     final hasDiscount = dish.discount != null && dish.discount! > 0;
//     final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               dish.dishName ?? '',
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           if (hasDiscount)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: AppColors.accentRedLight,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '${dish.discount!.toStringAsFixed(0)}% OFF',
//                 style: const TextStyle(
//                   color: AppColors.accentRed,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 12,
//                 ),
//               ),
//             )
//           else
//             const Text(
//               'No discount',
//               style: TextStyle(color: AppColors.textMuted, fontSize: 12),
//             ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: onEdit,
//             child: Container(
//               padding: const EdgeInsets.all(7),
//               decoration: BoxDecoration(
//                 color: AppColors.accentLight,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.edit_rounded,
//                 size: 15,
//                 color: AppColors.accent,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Add Item Tab ─────────────────────────────────────────────────────────────
// class AddItemTab extends StatefulWidget {
//   final bool isVeg;
//   final int? parentId;
//   const AddItemTab({super.key, required this.isVeg, this.parentId});
//
//   @override
//   State<AddItemTab> createState() => _AddItemTabState();
// }
//
// class _AddItemTabState extends State<AddItemTab> {
//   List<Dish> localCategories = [];
//   Map<String, bool> isExpandedMap = {};
//   Map<int, List<Dish>> subDishesMap = {};
//   final TextEditingController searchController = TextEditingController();
//   final TextEditingController _catNameCtrl = TextEditingController();
//   File? _image;
//   int? selectedParentId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAll();
//     searchController.addListener(_onSearch);
//     selectedParentId = widget.parentId ?? 0;
//   }
//
//   Future<void> _loadAll() async {
//     Utils.fetchedCategories = await food_authservice.fetchDishes();
//     setState(() {
//       localCategories = Utils.fetchedCategories
//           .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
//           .toList();
//     });
//   }
//
//   void _onSearch() {
//     final q = searchController.text.toLowerCase().replaceAll(' ', '');
//     setState(() {
//       localCategories = Utils.fetchedCategories
//           .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
//           .where(
//             (d) => (d.dishName?.toLowerCase().replaceAll(' ', '') ?? '')
//                 .contains(q),
//           )
//           .toList();
//     });
//   }
//
//   Future<void> _loadSubs(int parentId, String catName) async {
//     final all = await food_authservice.fetchDishes();
//     setState(() {
//       subDishesMap[parentId] = all
//           .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
//           .where((d) => d.parentId == parentId)
//           .toList();
//       isExpandedMap[catName] = true;
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     _catNameCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final parents = localCategories.where((d) => d.parentId == 0).toList();
//     return Column(
//       children: [
//         _SearchField(controller: searchController),
//         Expanded(
//           child: RefreshIndicator(
//             color: AppColors.accent,
//             onRefresh: _loadAll,
//             child: parents.isEmpty
//                 ? _EmptyState(
//                     icon: Icons.category_outlined,
//                     message: 'No categories yet',
//                     subtitle: 'Create your first category below',
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
//                     itemCount: parents.length,
//                     itemBuilder: (_, i) {
//                       final cat = parents[i];
//                       final catName = cat.dishName ?? '';
//                       final isExp = isExpandedMap[catName] ?? false;
//                       return _CategorySection(
//                         title: catName,
//                         isExpanded: isExp,
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             _miniBtn(
//                               Icons.edit_rounded,
//                               AppColors.accentBlue,
//                               () => _editCat(cat),
//                             ),
//                             const SizedBox(width: 4),
//                             _miniBtn(
//                               Icons.delete_rounded,
//                               AppColors.accentRed,
//                               () => _deleteCat(cat),
//                             ),
//                             const SizedBox(width: 4),
//                             _miniBtn(
//                               Icons.add_rounded,
//                               AppColors.accentGreen,
//                               () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => PremiumAddItems(
//                                       onItemSaved: (_) {},
//                                       dishId: 0,
//                                       isEdit: false,
//                                       parentId: cat.dishId,
//                                       dishName: cat.dishName,
//                                     ),
//                                   ),
//                                 ).then(
//                                   (_) => _loadAll().then(
//                                     (_) => _loadSubs(cat.dishId!, catName),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         onToggle: () {
//                           if (!isExp) {
//                             _loadSubs(cat.dishId!, catName);
//                           } else {
//                             setState(() => isExpandedMap[catName] = false);
//                           }
//                         },
//                         children: isExp && subDishesMap.containsKey(cat.dishId)
//                             ? subDishesMap[cat.dishId]!
//                                   .map(
//                                     (dish) => _SubDishTile(
//                                       dish: dish,
//                                       onEdit: () => _editDish(dish, cat),
//                                       onDelete: () => _deleteDish(dish, cat),
//                                       onToggle: (val) async {
//                                         await food_authservice.updateMenuStatus(
//                                           dishId: dish.dishId,
//                                           status: val,
//                                         );
//                                         await _loadSubs(cat.dishId!, catName);
//                                       },
//                                       onStock: (val) async {
//                                         await food_authservice
//                                             .updateStockStatus(
//                                               dishId: dish.dishId,
//                                               status: val
//                                                   ? 'In_Stock'
//                                                   : 'Out_of_Stock',
//                                             );
//                                         await _loadSubs(cat.dishId!, catName);
//                                       },
//                                     ),
//                                   )
//                                   .toList()
//                             : [],
//                       );
//                     },
//                   ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//           child: GestureDetector(
//             onTap: _openCreateDialog,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.accent, Color(0xFF7B3FA0)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.accent.withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.add_rounded, color: Colors.white, size: 20),
//                   SizedBox(width: 8),
//                   Text(
//                     'Create Category',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: color == AppColors.accentBlue
//                 ? AppColors.accentBlueLight
//                 : color == AppColors.accentRed
//                 ? AppColors.accentRedLight
//                 : AppColors.accentGreenLight,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Icon(icon, size: 14, color: color),
//         ),
//       );
//
//   void _openCreateDialog() {
//     _catNameCtrl.clear();
//     _image = null;
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setS) => Dialog(
//           backgroundColor: AppColors.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Create Category',
//                   style: TextStyle(
//                     color: AppColors.textPrimary,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _LightTextField(
//                   controller: _catNameCtrl,
//                   hint: 'Category name',
//                 ),
//                 const SizedBox(height: 12),
//                 GestureDetector(
//                   onTap: () async {
//                     final p = await ImagePicker().pickImage(
//                       source: ImageSource.gallery,
//                     );
//                     if (p != null) setS(() => _image = File(p.path));
//                   },
//                   child: Container(
//                     height: 90,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.bg,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: _image != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(_image!, fit: BoxFit.cover),
//                           )
//                         : Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.image_outlined,
//                                 color: AppColors.textMuted,
//                                 size: 28,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Tap to add image',
//                                 style: TextStyle(
//                                   color: AppColors.textMuted,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _OutlineButton(
//                         label: 'Cancel',
//                         onTap: () => Navigator.pop(ctx),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _PrimaryButton(
//                         label: 'Save',
//                         onTap: () async {
//                           if (_catNameCtrl.text.isEmpty) return;
//                           final ok = await food_authservice.createCategory(
//                             name: _catNameCtrl.text,
//                             parentId: 0,
//                             stockQuantity: 0,
//                             imageFile: _image,
//                           );
//                           if (ok) {
//                             Navigator.pop(ctx);
//                             await _loadAll();
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _editCat(Dish cat) async {
//     final ctrl = TextEditingController(text: cat.dishName);
//     File? img;
//     await showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setS) => Dialog(
//           backgroundColor: AppColors.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Edit Category',
//                   style: TextStyle(
//                     color: AppColors.textPrimary,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _LightTextField(controller: ctrl, hint: 'Category name'),
//                 const SizedBox(height: 12),
//                 GestureDetector(
//                   onTap: () async {
//                     final p = await ImagePicker().pickImage(
//                       source: ImageSource.gallery,
//                     );
//                     if (p != null) setS(() => img = File(p.path));
//                   },
//                   child: Container(
//                     height: 80,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.bg,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: img != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(img!, fit: BoxFit.cover),
//                           )
//                         : cat.dishImage != null && cat.dishImage!.isNotEmpty
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.network(
//                               cat.dishImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : Center(
//                             child: Text(
//                               'Tap to change image',
//                               style: TextStyle(color: AppColors.textMuted),
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _OutlineButton(
//                         label: 'Cancel',
//                         onTap: () => Navigator.pop(ctx),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _PrimaryButton(
//                         label: 'Update',
//                         onTap: () async {
//                           if (ctrl.text.isEmpty) return;
//                           final ok = await food_authservice.updateCategory(
//                             dishId: cat.dishId!,
//                             dishName: ctrl.text,
//                             imageFile: img,
//                           );
//                           if (ok) {
//                             Navigator.pop(ctx);
//                             await _loadAll();
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _deleteCat(Dish cat) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => _ConfirmDialog(
//         title: 'Delete Category',
//         message: "Delete '${cat.dishName}'? This cannot be undone.",
//       ),
//     );
//     if (ok != true) return;
//     final success = await food_authservice.deleteCategory(cat.dishId!);
//     if (success) await _loadAll();
//   }
//
//   Future<void> _editDish(Dish dish, Dish cat) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PremiumAddItems(
//           onItemSaved: (d) async => d,
//           dishId: dish.dishId,
//           isEdit: true,
//           parentId: cat.dishId,
//           dishName: dish.dishName ?? '',
//           price: dish.price ?? 0,
//           description: dish.description,
//           stockQuantity: dish.stockQuantity ?? 0,
//           dishImageBase64: dish.dishImage,
//         ),
//       ),
//     );
//     await _loadAll();
//     await _loadSubs(cat.dishId!, cat.dishName ?? '');
//   }
//
//   Future<void> _deleteDish(Dish dish, Dish cat) async {
//     final ok = await food_authservice.deleteDish(dish.dishId);
//     if (ok) await _loadSubs(cat.dishId!, cat.dishName ?? '');
//   }
// }
//
// // ─── Sub Dish Tile ─────────────────────────────────────────────────────────────
// class _SubDishTile extends StatelessWidget {
//   final Dish dish;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final Function(bool) onToggle;
//   final Function(bool) onStock;
//
//   const _SubDishTile({
//     required this.dish,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onToggle,
//     required this.onStock,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';
//     // final enabled = (dish.menuStatus ?? '').toLowerCase() == 'enable';
//     final status = dish.menuStatus?.toLowerCase();
//     final enabled = status == null || status == 'enable';
//     final inStock = (dish.stock?.toLowerCase() ?? '') == 'in_stock';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 3)],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               width: 48,
//               height: 48,
//               color: AppColors.bg,
//               child: dish.dishImage != null && dish.dishImage!.isNotEmpty
//                   ? Image.network(
//                       dish.dishImage!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Icon(
//                         Icons.fastfood_rounded,
//                         color: AppColors.textMuted,
//                         size: 22,
//                       ),
//                     )
//                   : Icon(
//                       Icons.fastfood_rounded,
//                       color: AppColors.textMuted,
//                       size: 22,
//                     ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         dish.dishName ?? '',
//                         style: const TextStyle(
//                           color: AppColors.textPrimary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '₹${dish.price ?? 0}',
//                   style: const TextStyle(
//                     color: AppColors.accent,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     _chip(
//                       enabled ? 'Enabled' : 'Disabled',
//                       enabled ? AppColors.accentGreen : AppColors.textMuted,
//                       enabled ? AppColors.accentGreenLight : AppColors.bg,
//                     ),
//                     const SizedBox(width: 5),
//                     _chip(
//                       inStock ? 'In Stock' : 'Out',
//                       inStock ? AppColors.accentBlue : AppColors.accentRed,
//                       inStock
//                           ? AppColors.accentBlueLight
//                           : AppColors.accentRedLight,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showSheet(context),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppColors.bg,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.more_horiz,
//                 color: AppColors.textSecondary,
//                 size: 18,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _chip(String label, Color color, Color bg) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//     decoration: BoxDecoration(
//       color: bg,
//       borderRadius: BorderRadius.circular(6),
//     ),
//     child: Text(
//       label,
//       style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
//     ),
//   );
//
//   void _showSheet(BuildContext ctx) {
//     // final isEnabled = (dish.menuStatus ?? '').toLowerCase() == 'enable';
//
//     final sheetStatus = dish.menuStatus?.toLowerCase();
//     final isEnabled = sheetStatus == null || sheetStatus == 'enable';
//     final inStock = (dish.stock?.toLowerCase() ?? '') == 'in_stock';
//     showModalBottomSheet(
//       context: ctx,
//       backgroundColor: AppColors.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppColors.border,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               dish.dishName ?? '',
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 14),
//             _sheetRow(
//               ctx,
//               Icons.edit_rounded,
//               'Edit',
//               AppColors.accentBlue,
//               AppColors.accentBlueLight,
//               () {
//                 Navigator.pop(ctx);
//                 onEdit();
//               },
//             ),
//             const SizedBox(height: 8),
//             _sheetRow(
//               ctx,
//               Icons.delete_rounded,
//               'Delete',
//               AppColors.accentRed,
//               AppColors.accentRedLight,
//               () {
//                 Navigator.pop(ctx);
//                 onDelete();
//               },
//             ),
//             const SizedBox(height: 8),
//             _sheetRow(
//               ctx,
//               isEnabled
//                   ? Icons.visibility_off_rounded
//                   : Icons.visibility_rounded,
//               isEnabled ? 'Disable Item' : 'Enable Item',
//               isEnabled ? AppColors.accentOrange : AppColors.accentGreen,
//               isEnabled ? const Color(0xFFFFF3E0) : AppColors.accentGreenLight,
//               () {
//                 Navigator.pop(ctx);
//                 onToggle(!isEnabled);
//               },
//             ),
//             const SizedBox(height: 8),
//             _sheetRow(
//               ctx,
//               inStock ? Icons.inventory_2_rounded : Icons.add_box_rounded,
//               inStock ? 'Mark Out of Stock' : 'Mark In Stock',
//               inStock ? AppColors.accentRed : AppColors.accentGreen,
//               inStock ? AppColors.accentRedLight : AppColors.accentGreenLight,
//               () {
//                 Navigator.pop(ctx);
//                 onStock(!inStock);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _sheetRow(
//     BuildContext ctx,
//     IconData icon,
//     String label,
//     Color color,
//     Color bg,
//     VoidCallback onTap,
//   ) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ─── Shared UI Components ─────────────────────────────────────────────────────
//
// class _CategorySection extends StatelessWidget {
//   final String title;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final List<Widget> children;
//   final Widget? trailing;
//
//   const _CategorySection({
//     required this.title,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.children,
//     this.trailing,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: onToggle,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: AppColors.accentLight,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.folder_rounded,
//                       color: AppColors.accent,
//                       size: 16,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       title,
//                       style: const TextStyle(
//                         color: AppColors.textPrimary,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   if (trailing != null) ...[
//                     trailing!,
//                     const SizedBox(width: 6),
//                   ],
//                   Icon(
//                     isExpanded
//                         ? Icons.keyboard_arrow_up_rounded
//                         : Icons.keyboard_arrow_down_rounded,
//                     color: AppColors.textMuted,
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isExpanded) ...[
//             Divider(color: AppColors.border, height: 1),
//             if (children.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//                 child: Column(children: children),
//               )
//             else
//               Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Center(
//                   child: Text(
//                     'No items in this category',
//                     style: TextStyle(
//                       color: AppColors.textMuted,
//                       fontStyle: FontStyle.italic,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _SearchField extends StatelessWidget {
//   final TextEditingController controller;
//   const _SearchField({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
//       decoration: BoxDecoration(
//         color: AppColors.bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
//         decoration: InputDecoration(
//           hintText: 'Search items…',
//           hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: AppColors.textMuted,
//             size: 20,
//           ),
//           suffixIcon: controller.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(
//                     Icons.close_rounded,
//                     color: AppColors.textMuted,
//                     size: 18,
//                   ),
//                   onPressed: () => controller.clear(),
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String message;
//   final String? subtitle;
//   const _EmptyState({required this.icon, required this.message, this.subtitle});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: AppColors.accentLight,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Icon(icon, color: AppColors.accent, size: 32),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             message,
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           if (subtitle != null) ...[
//             const SizedBox(height: 5),
//             Text(
//               subtitle!,
//               style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _ErrorState extends StatelessWidget {
//   final String message;
//   const _ErrorState({required this.message});
//
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Text(
//       message,
//       style: const TextStyle(color: AppColors.accentRed, fontSize: 14),
//     ),
//   );
// }
//
// class _PrimaryButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _PrimaryButton({required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.accent, Color(0xFF7B3FA0)],
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// class _OutlineButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _OutlineButton({required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: AppColors.textSecondary,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// class _LightTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   const _LightTextField({required this.controller, required this.hint});
//
//   @override
//   Widget build(BuildContext context) => TextField(
//     controller: controller,
//     style: const TextStyle(color: AppColors.textPrimary),
//     cursorColor: AppColors.accent,
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: AppColors.textMuted),
//       filled: true,
//       fillColor: AppColors.bg,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppColors.accent),
//       ),
//     ),
//   );
// }
//
// class _InputDialog extends StatelessWidget {
//   final String title;
//   final TextEditingController controller;
//   final TextInputType keyboardType;
//   final String hint;
//   final VoidCallback onSave;
//
//   const _InputDialog({
//     required this.title,
//     required this.controller,
//     required this.keyboardType,
//     required this.hint,
//     required this.onSave,
//   });
//
//   @override
//   Widget build(BuildContext context) => Dialog(
//     backgroundColor: AppColors.surface,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: AppColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _LightTextField(controller: controller, hint: hint),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _OutlineButton(
//                   label: 'Cancel',
//                   onTap: () => Navigator.pop(context),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _PrimaryButton(
//                   label: 'Save',
//                   onTap: () {
//                     Navigator.pop(context);
//                     onSave();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// class _ConfirmDialog extends StatelessWidget {
//   final String title;
//   final String message;
//   const _ConfirmDialog({required this.title, required this.message});
//
//   @override
//   Widget build(BuildContext context) => Dialog(
//     backgroundColor: AppColors.surface,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: const BoxDecoration(
//               color: AppColors.accentRedLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.warning_amber_rounded,
//               color: AppColors.accentRed,
//               size: 26,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               color: AppColors.textPrimary,
//               fontSize: 17,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             message,
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 13,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _OutlineButton(
//                   label: 'Cancel',
//                   onTap: () => Navigator.pop(context, false),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context, true),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: AppColors.accentRedLight,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: AppColors.accentRed.withOpacity(0.4),
//                       ),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Delete',
//                         style: TextStyle(
//                           color: AppColors.accentRed,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ─── Product Card ─────────────────────────────────────────────────────────────
// class ProductCard extends StatelessWidget {
//   final Widget imageWidget;
//   final String name;
//   final String price;
//   final String description;
//   final String effectivePrice;
//   final Widget cartButton;
//   final bool isOutOfStock;
//   final String? code;
//
//   const ProductCard({
//     super.key,
//     required this.imageWidget,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.effectivePrice,
//     required this.cartButton,
//     required this.isOutOfStock,
//     this.code,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final orig = double.tryParse(price.replaceAll('₹', '')) ?? 0;
//     final eff = double.tryParse(effectivePrice.replaceAll('₹', '')) ?? 0;
//     final hasDiscount = eff < orig;
//
//     return AbsorbPointer(
//       absorbing: isOutOfStock,
//       // child: Opacity(
//       //   opacity: isOutOfStock ? 1.0 : 1.0,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadowMd,
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(14),
//                   ),
//                   child: SizedBox(
//                     height: 100,
//                     width: double.infinity,
//                     child: imageWidget,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
//                   child: Text(
//                     name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: AppColors.textPrimary,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//                 if (code != null && code!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Row(
//                     children: [
//                       Text(
//                         hasDiscount ? effectivePrice : price,
//                         style: TextStyle(
//                           color: hasDiscount
//                               ? AppColors.accentGreen
//                               : AppColors.accent,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 13,
//                         ),
//                       ),
//                       if (hasDiscount) ...[
//                         const SizedBox(width: 4),
//                         Text(
//                           price,
//                           style: const TextStyle(
//                             color: AppColors.textMuted,
//                             fontSize: 11,
//                             decoration: TextDecoration.lineThrough,
//                             decorationColor: AppColors.textMuted,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
//                   child: Center(child: cartButton),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Cart Button ──────────────────────────────────────────────────────────────
// class CartButton extends StatefulWidget {
//   final int dishId;
//   final OrderType orderType;
//   final int balanceQuantity;
//   final Function()? onCartUpdated;
//
//   const CartButton({
//     super.key,
//     required this.dishId,
//     required this.orderType,
//     required this.balanceQuantity,
//     this.onCartUpdated,
//   });
//
//   @override
//   State<CartButton> createState() => _CartButtonState();
// }
//
// class _CartButtonState extends State<CartButton> {
//   int itemCount = 0;
//   bool _isLoading = false;
//   bool _isOutOfStock = false;
//   int? _cartItemId;
//   int? _cartId;
//   bool _isUpdating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isOutOfStock = widget.balanceQuantity <= 0;
//     _loadQty();
//     Utils.itemCount.addListener(_onCartChanged);
//   }
//
//   @override
//   void dispose() {
//     Utils.itemCount.removeListener(_onCartChanged);
//     super.dispose();
//   }
//
//   void _onCartChanged() {
//     if (!_isUpdating) _loadQty();
//   }
//
//   Future<void> _loadQty() async {
//     if (_isUpdating) return;
//     try {
//       final cart = await food_authservice.fetchCart();
//       if (!mounted) return;
//       if (cart != null) {
//         _cartId = cart.cartId;
//         bool found = false;
//         for (var item in cart.cartItems) {
//           if (item.dishId == widget.dishId) {
//             setState(() {
//               itemCount = item.quantity;
//               _cartItemId = item.itemId;
//             });
//             found = true;
//             break;
//           }
//         }
//         if (!found)
//           setState(() {
//             itemCount = 0;
//             _cartItemId = null;
//           });
//       } else {
//         setState(() {
//           itemCount = 0;
//           _cartItemId = null;
//           _cartId = null;
//         });
//       }
//     } catch (_) {
//       setState(() {
//         itemCount = 0;
//         _cartItemId = null;
//         _cartId = null;
//       });
//     }
//   }
//
//   Future<void> _addToCart() async {
//     if (_isOutOfStock) return;
//     setState(() => _isLoading = true);
//     try {
//       final cartId = await food_authservice.addToCart(
//         dishId: widget.dishId,
//         quantity: 1,
//         orderType: widget.orderType == OrderType.DINE_IN
//             ? 'DINE_IN'
//             : 'TAKEAWAY',
//       );
//       if (cartId != null) {
//         await _loadQty();
//         Utils.itemCount.value = Utils.itemCount.value + 1;
//         widget.onCartUpdated?.call();
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _updateQty(int newQty) async {
//     if (_isUpdating) return;
//     if (newQty > widget.balanceQuantity && widget.balanceQuantity > 0) return;
//
//     final oldQty = itemCount;
//     _isUpdating = true;
//     setState(() => _isLoading = true);
//
//     try {
//       await _loadQty();
//       if (_cartId != null && _cartItemId != null) {
//         if (newQty < 1) {
//           final ok = await food_authservice.removeCartItem(_cartItemId!);
//           if (ok) {
//             setState(() {
//               itemCount = 0;
//               _cartItemId = null;
//             });
//             Utils.itemCount.value = Utils.itemCount.value - 1;
//             await _loadQty();
//           }
//         } else {
//           setState(() => itemCount = newQty);
//           final diff = newQty - oldQty;
//           if (diff != 0) Utils.itemCount.value = Utils.itemCount.value + diff;
//
//           final ok = await food_authservice.updateCartQuantity(
//             _cartId!,
//             widget.dishId,
//             newQty,
//           );
//
//           if (!ok) {
//             setState(() => itemCount = oldQty);
//             final revert = oldQty - newQty;
//             if (revert != 0)
//               Utils.itemCount.value = Utils.itemCount.value + revert;
//           }
//         }
//         widget.onCartUpdated?.call();
//       } else if (newQty > 0) {
//         await _addToCart();
//       }
//     } finally {
//       _isUpdating = false;
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const SizedBox(
//         width: 22,
//         height: 22,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           color: AppColors.accent,
//         ),
//       );
//     }
//     if (itemCount == 0) {
//       return GestureDetector(
//         onTap: _isOutOfStock ? null : _addToCart,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             // color: _isOutOfStock ? AppColors.bg : AppColors.accentLight,
//             color: AppColors.accentLight,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: _isOutOfStock
//                   ? AppColors.border
//                   : AppColors.accent.withOpacity(0.4),
//             ),
//           ),
//           child: Center(
//             child: Text(
//               _isOutOfStock ? 'Out of Stock' : '+ Add',
//               style: TextStyle(
//                 color: _isOutOfStock ? AppColors.textMuted : AppColors.accent,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.accent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.remove, color: Colors.white, size: 16),
//             onPressed: _isUpdating
//                 ? null
//                 : () => _updateQty(itemCount > 1 ? itemCount - 1 : 0),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           Text(
//             '$itemCount',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w800,
//               fontSize: 14,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white, size: 16),
//             onPressed: _isUpdating
//                 ? null
//                 : () {
//                     if (itemCount < widget.balanceQuantity)
//                       _updateQty(itemCount + 1);
//                   },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Sidebar Item ─────────────────────────────────────────────────────────────
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
//     super.key,
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
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: 84,
//         width: 68,
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isSelected ? color : AppColors.border),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.2),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.bg,
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: ClipOval(
//                 child: image != null
//                     ? Image(image: image!, fit: BoxFit.cover)
//                     : Icon(
//                         icon,
//                         size: 22,
//                         color: isSelected ? color : AppColors.textMuted,
//                       ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Flexible(
//               child: Text(
//                 title,
//                 style: textStyle.copyWith(
//                   fontSize: 9,
//                   fontWeight: FontWeight.w700,
//                   color: isSelected ? color : AppColors.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Veg Non-Veg Toggle ───────────────────────────────────────────────────────
// class VegNonVegToggle extends StatelessWidget {
//   final bool isVeg;
//   final ValueChanged<bool> onToggle;
//   const VegNonVegToggle({
//     super.key,
//     required this.isVeg,
//     required this.onToggle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FlutterSwitch(
//       width: 100,
//       height: 36,
//       toggleSize: 28,
//       borderRadius: 18,
//       value: isVeg,
//       showOnOff: true,
//       activeColor: AppColors.vegGreen,
//       inactiveColor: AppColors.nonVegRed,
//       activeText: 'Veg',
//       inactiveText: 'Non-Veg',
//       valueFontSize: 11,
//       onToggle: onToggle,
//     );
//   }
// }
//
// class ToggleSwitchExample extends StatelessWidget {
//   final bool initialValue;
//   final Function(bool)? onToggleChanged;
//   const ToggleSwitchExample({
//     Key? key,
//     required this.initialValue,
//     this.onToggleChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) => FlutterSwitch(
//     value: initialValue,
//     width: 60,
//     height: 28,
//     toggleSize: 18,
//     borderRadius: 30,
//     activeColor: AppColors.accentGreen,
//     inactiveColor: AppColors.nonVegRed,
//     showOnOff: true,
//     valueFontSize: 10,
//     onToggle: onToggleChanged ?? (_) {},
//   );
// }
//
// class StockToggleSwitch extends StatelessWidget {
//   final bool initialValue;
//   final Function(bool)? onToggleChanged;
//   const StockToggleSwitch({
//     Key? key,
//     required this.initialValue,
//     this.onToggleChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) => FlutterSwitch(
//     value: initialValue,
//     width: 75,
//     height: 28,
//     toggleSize: 18,
//     borderRadius: 30,
//     activeColor: AppColors.accentGreen,
//     inactiveColor: AppColors.nonVegRed,
//     activeText: 'In Stock',
//     inactiveText: 'Out',
//     showOnOff: true,
//     valueFontSize: 9,
//     onToggle: onToggleChanged ?? (_) {},
//   );
// }
//
// // ─── Food Item Card ───────────────────────────────────────────────────────────
// class FoodItemCard extends StatelessWidget {
//   final String? imagePath;
//   final String? imageurl;
//   final String title;
//   final String price;
//   final bool isVeg;
//   final bool initialToggleState;
//   final bool initialStockState;
//   final VoidCallback onEdit;
//   final bool? isDisabled;
//   final Function(bool)? onStockToggleChanged;
//   final VoidCallback? onDelete;
//   final Function(bool)? onToggleChanged;
//
//   const FoodItemCard({
//     Key? key,
//     this.imagePath,
//     this.imageurl,
//     required this.title,
//     required this.price,
//     required this.isVeg,
//     this.isDisabled,
//     required this.initialToggleState,
//     required this.initialStockState,
//     required this.onEdit,
//     this.onToggleChanged,
//     this.onDelete,
//     this.onStockToggleChanged,
//   }) : super(key: key);
//
//   ImageProvider getImageProvider() {
//     if (imageurl != null && imageurl!.isNotEmpty)
//       return NetworkImage(imageurl!);
//     if (imagePath != null && imagePath!.isNotEmpty)
//       return AssetImage(imagePath!);
//     return const AssetImage('assets/gallery-img-1.jpg');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: getImageProvider(),
//                       fit: BoxFit.cover,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 2,
//                 right: 2,
//                 child: Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: AppColors.surface,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Center(
//                     child: Container(
//                       width: 6,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   price,
//                   style: const TextStyle(
//                     color: AppColors.accent,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showSheet(context),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppColors.bg,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.more_horiz,
//                 color: AppColors.textSecondary,
//                 size: 18,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppColors.border,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 14),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//                 onEdit();
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.accentBlueLight,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.accentBlue.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.edit_rounded,
//                       color: AppColors.accentBlue,
//                       size: 20,
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'Edit',
//                       style: TextStyle(
//                         color: AppColors.accentBlue,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//                 onDelete?.call();
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.accentRedLight,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.accentRed.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.delete_rounded,
//                       color: AppColors.accentRed,
//                       size: 20,
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'Delete',
//                       style: TextStyle(
//                         color: AppColors.accentRed,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Enable / Disable',
//                     style: const TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 ToggleSwitchExample(
//                   initialValue: initialToggleState,
//                   onToggleChanged: (v) {
//                     onToggleChanged?.call(v);
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'In Stock / Out of Stock',
//                     style: const TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 StockToggleSwitch(
//                   initialValue: initialStockState,
//                   onToggleChanged: (v) {
//                     onStockToggleChanged?.call(v);
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:maamaaspartner/Api/food_authservice.dart';
import 'package:maamaaspartner/food&beverages/premium%20additems.dart';
import '../DineOut Management/DineOut_Screen/DineOut_MainScreen.dart';
import '../Models/food&beverages/dish.dart';
import '../Models/food&beverages/orders_model.dart';
import '../CateringModels/package_model.dart';
import '../Catering_authservices/Auth_Services.dart';
import '../caterings/AddPackage.dart';
import '../caterings/UpdatePackagePage.dart';
import '../standard Menu/screens/standard_menu_screen.dart';
import '../widgets_helper/Home_screen_1.dart';
import '../widgets_helper/food/utils.dart';
import 'cart_screen.dart';

// ─── Design Tokens (White Theme) ─────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const cardAlt = Color(0xFFF8F9FF);
  static const border = Color(0xFFE8E9F0);
  static const borderLight = Color(0xFFF0F1F8);
  static const accent = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E6FA);
  static const accentBlue = Color(0xFF4F8EF7);
  static const accentBlueLight = Color(0xFFE8F0FE);
  static const accentGreen = Color(0xFF2ECC71);
  static const accentGreenLight = Color(0xFFE8F8F0);
  static const accentRed = Color(0xFFE74C3C);
  static const accentRedLight = Color(0xFFFEECEB);
  static const accentOrange = Color(0xFFF39C12);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B8A);
  static const textMuted = Color(0xFFAAAAAC);
  static const vegGreen = Color(0xFF27AE60);
  static const nonVegRed = Color(0xFFE74C3C);
  static const shadow = Color(0x0D000000);
  static const shadowMd = Color(0x14000000);
}

enum MenuVertical { food, catering }

enum VegFilter { all, veg, nonVeg }

// ─── Shimmer Helpers ──────────────────────────────────────────────────────────
// Reusable shimmer skeleton box.
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  const _ShimmerBox({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

// Wraps any skeleton layout with the shimmer sweep animation.
Widget shimmerWrap({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: AppColors.borderLight,
    highlightColor: AppColors.bg,
    child: child,
  );
}

// ─── Shimmer: Dish Grid (used while dishes are loading) ───────────────────────
class DishGridShimmer extends StatelessWidget {
  const DishGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return shimmerWrap(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 10,
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: _ShimmerBox(
                  height: 100,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: _ShimmerBox(height: 13, width: 90),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ShimmerBox(height: 12, width: 50),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: _ShimmerBox(height: 32, width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer: Horizontal Categories Row ────────────────────────────────────────
class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return shimmerWrap(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Column(
            children: [
              _ShimmerBox(
                width: 52.r,
                height: 52.r,
                borderRadius: BorderRadius.circular(26.r),
              ),
              SizedBox(height: 5.h),
              _ShimmerBox(width: 44.w, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer: Generic List Card (quantity / discount / category list rows) ────
class ListCardShimmer extends StatelessWidget {
  final int count;
  const ListCardShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return shimmerWrap(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _ShimmerBox(
                width: 30,
                height: 30,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(child: _ShimmerBox(height: 14, width: double.infinity)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer: Package Card (catering) ──────────────────────────────────────────
class PackageCardShimmer extends StatelessWidget {
  final int count;
  const PackageCardShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return shimmerWrap(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _ShimmerBox(
                  height: 155,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(height: 16, width: 140),
                    const SizedBox(height: 10),
                    _ShimmerBox(height: 20, width: 70),
                    const SizedBox(height: 16),
                    _ShimmerBox(height: 12, width: double.infinity),
                    const SizedBox(height: 8),
                    _ShimmerBox(height: 12, width: double.infinity),
                    const SizedBox(height: 8),
                    _ShimmerBox(height: 12, width: 160),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class Menu_Managemnet extends StatefulWidget {
  const Menu_Managemnet({super.key});

  @override
  State<Menu_Managemnet> createState() => _Menu_ManagemnetState();
}

class _Menu_ManagemnetState extends State<Menu_Managemnet>
    with TickerProviderStateMixin {
  int selectedTabIndex = 0;
  VegFilter _vegFilter = VegFilter.all;
  OrderType selectedOrderType = OrderType.DINE_IN;
  int _cartItemCount = 0;
  MenuVertical _selectedVertical = MenuVertical.food;
  int selectedCategoryIndex = 0;
  int? selectedParentId;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  bool _appBarVisible = true;
  double _lastScrollOffset = 0;

  Future<List<Dish>>? _categoriesFuture;

  late AnimationController _fabAnimController;
  late Animation<double> _fabAnim;

  final List<IconData> tabIcons = [
    Icons.restaurant_menu_rounded,
    Icons.add_circle_outline_rounded,
    Icons.inventory_2_outlined,
    Icons.discount_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );

    _loadCartCount();
    _setupCartListener();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final scrollingDown = offset > _lastScrollOffset + 2;
      final scrollingUp = offset < _lastScrollOffset - 2;
      _lastScrollOffset = offset;
      if (scrollingDown && _appBarVisible) {
        setState(() => _appBarVisible = false);
      } else if (scrollingUp && !_appBarVisible) {
        setState(() => _appBarVisible = true);
      }
    });
    _categoriesFuture = food_authservice.fetchParentCategories();
    _dishFuture = food_authservice
        .fetchFilteredDishes(searchQuery: '', filterByMenuStatus: true)
        .then((list) {
          _cachedDishes = list;
          return list;
        });
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase().replaceAll(' ', '');
    });
    if (_selectedVertical == MenuVertical.food && selectedTabIndex == 0) {
      _refreshDishFuture();
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await food_authservice.fetchCart();
      if (cart != null) {
        final count = cart.cartItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        setState(() => _cartItemCount = count);
        if (count > 0) _fabAnimController.forward();
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  void _setupCartListener() {
    Utils.itemCount.addListener(() {
      if (mounted) {
        setState(() => _cartItemCount = Utils.itemCount.value);
        if (Utils.itemCount.value > 0) {
          _fabAnimController.forward();
        } else {
          _fabAnimController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void onTabSelect(int index) {
    setState(() {
      selectedTabIndex = index;
      if (index != 0) {
        selectedCategoryIndex = 0;
        selectedParentId = null;
      }
    });
    if (index == 0 && _selectedVertical == MenuVertical.food) {
      _refreshDishFuture();
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  void onCategoryTap(int index, int? parentId) {
    setState(() {
      selectedCategoryIndex = index;
      selectedParentId = parentId;
    });
    if (_selectedVertical == MenuVertical.food && selectedTabIndex == 0) {
      _refreshDishFuture();
    }
  }

  void _navigateBackToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeWrapper()),
      );
    }
  }

  // ─── App Bar (Back button + Title + DineIn/Takeaway + DineOut Buttons) ───────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      child: Row(
        children: [
          // ── Back button ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: _navigateBackToHome,
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
                size: 16.sp,
              ),
            ),
          ),

          // Small spacing instead of Spacer
          SizedBox(width: 12.w),

          // ── Dine In Button ──────────────────────────────────────────────────
          _buildOrderTypeChip(
            label: 'Dine In',
            isActive: selectedOrderType == OrderType.DINE_IN,
            onTap: () {
              setState(() {
                selectedOrderType = OrderType.DINE_IN;
              });
              _refreshDishFuture();
            },
          ),

          SizedBox(width: 8.w),
          // ── Takeaway Button ─────────────────────────────────────────────────
          _buildOrderTypeChip(
            label: 'Takeaway',
            isActive: selectedOrderType == OrderType.TAKEAWAY,
            onTap: () {
              setState(() {
                selectedOrderType = OrderType.TAKEAWAY;
              });
              _refreshDishFuture();
            },
          ),

          SizedBox(width: 8.w),
          // ── Dine Out Button ─────────────────────────────────────────────────
          _buildDineOutButton(),
        ],
      ),
    );
  }

  Widget _buildOrderTypeChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),

        decoration: BoxDecoration(
          color: isActive ? Colors.green : const Color(0xFFE66D33),

          borderRadius: BorderRadius.circular(10.r),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDineOutButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DineOut()),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),

        decoration: BoxDecoration(
          color: const Color(0xFFE66D33), // 🟧 Same inactive style
          borderRadius: BorderRadius.circular(10.r),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_restaurant_rounded,
              color: Colors.white,
              size: 13.sp,
            ),

            SizedBox(width: 5.w),

            Text(
              'Dine Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sub-header row: Add Menu button + Veg/Non-Veg filters ───────────────────
  Widget _buildSubHeaderRow() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 0, 12.w, 10.h),
      child: Row(
        children: [
          // ── Add Menu button ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StandardMenuScreen()),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF7B3FA0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Add Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // ── Scrollable Veg/Non-Veg filter chips ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    isActive: _vegFilter == VegFilter.all,
                    activeColor: AppColors.accentBlue,
                    onTap: () {
                      setState(() => _vegFilter = VegFilter.all);
                      _refreshDishFuture();
                    },
                  ),
                  SizedBox(width: 8.w),
                  _buildFilterChip(
                    label: 'Veg',
                    isActive: _vegFilter == VegFilter.veg,
                    activeColor: AppColors.vegGreen,
                    onTap: () {
                      setState(() => _vegFilter = VegFilter.veg);
                      _refreshDishFuture();
                    },
                  ),
                  SizedBox(width: 8.w),
                  _buildFilterChip(
                    label: 'Non-Veg',
                    isActive: _vegFilter == VegFilter.nonVeg,
                    activeColor: AppColors.nonVegRed,
                    onTap: () {
                      setState(() => _vegFilter = VegFilter.nonVeg);
                      _refreshDishFuture();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.bg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isActive ? activeColor : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: searchController,

          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase().replaceAll(' ', '');
            });
          },

          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),

          decoration: InputDecoration(
            hintText: 'Search categories or dishes…',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),

            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20.sp,
            ),

            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                      size: 18.sp,
                    ),
                    onPressed: () {
                      searchController.clear();

                      setState(() {
                        searchQuery = '';
                      });
                    },
                  )
                : null,

            border: InputBorder.none,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatChip({
    required int index,
    required String name,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentLight : AppColors.bg,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(child: _catImage(imageUrl)),
            ),
            SizedBox(height: 5.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _catImage(String? url) {
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.category_rounded,
        size: 22.r,
        color: AppColors.textMuted,
      );
    }
    if (url.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          url,
          width: 44.r,
          height: 44.r,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.category_rounded,
            size: 22.r,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return ClipOval(
      child: Image.memory(
        base64Decode(url),
        width: 44.r,
        height: 44.r,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.category_rounded,
          size: 22.r,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedVertical) {
      case MenuVertical.food:
        switch (selectedTabIndex) {
          case 0:
            return const SizedBox.shrink();
          case 1:
            return AddItemTab(isVeg: _vegFilter == VegFilter.veg);
          case 2:
            return ItemQuantityTab(onCartUpdated: _loadCartCount);
          case 3:
            return DiscountTab(onCartUpdated: _loadCartCount);
          default:
            return const SizedBox.shrink();
        }
      case MenuVertical.catering:
        return const CateringContent();
    }
  }

  Widget _buildCartButton() {
    if (_cartItemCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => food_CartScreen(
              cartId: null,
              savedAmount: 0,
              showSavedPopup: false,
            ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, Color(0xFF7B3FA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'View Cart  •  $_cartItemCount ${_cartItemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showFoodHeader =
        _selectedVertical == MenuVertical.food && selectedTabIndex == 0;

    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHome();
        return false;
      },
      child: Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: AppColors.bg,
          appBarTheme: const AppBarTheme(backgroundColor: AppColors.surface),
        ),
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // 1. App bar (back button + title + DineIn/Takeaway + DineOut buttons)
                _buildAppBar(),
                Divider(color: AppColors.border, height: 1),

                // 2. Sub-header: Add Menu button + Veg/Non-Veg filters
                _buildSubHeaderRow(),
                Divider(color: AppColors.border, height: 1),

                // 3. Remaining content
                Expanded(
                  child: showFoodHeader
                      ? _buildScrollableFood()
                      : _buildNonScrollableContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableFood() {
    return Column(
      children: [
        Expanded(
          child: NestedScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildHorizontalCategoriesStatic(),
                  ],
                ),
              ),
            ],
            body: FutureBuilder<List<Dish>>(
              future: _dishFuture,
              builder: (_, snapshot) => _buildDishListView(snapshot),
            ),
          ),
        ),
        _buildCartButton(),
      ],
    );
  }

  Future<List<Dish>>? _dishFuture;
  List<Dish> _cachedDishes = [];

  void _refreshDishFuture() {
    setState(() {
      _dishFuture = food_authservice
          .fetchFilteredDishes(
            searchQuery: searchQuery,
            filterByMenuStatus: true,
          )
          .then((list) {
            _cachedDishes = list;
            return list;
          });
    });
  }

  // ─── Dish list view with category search functionality ───────────────────────
  Widget _buildDishListView(AsyncSnapshot<List<Dish>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const DishGridShimmer();
    }
    if (snapshot.hasError) {
      return _ErrorState(message: 'Error: ${snapshot.error}');
    }

    final List<Dish> allDishes = snapshot.data ?? [];
    List<Dish> list = snapshot.data ?? [];

    list = list
        .where((dish) => dish.approvalStatus?.toUpperCase() == 'APPROVED')
        .toList();

    final enabledParentIds = _cachedDishes
        .where(
          (d) => d.parentId == 0 && (d.menuStatus?.toLowerCase() == 'enable'),
        )
        .map((d) => d.dishId)
        .toSet();

    final Map<int, Dish> byId = {
      for (final d in allDishes)
        if (d.dishId != null) d.dishId!: d,
    };

    final Set<int> parentIds = allDishes
        .map((d) => d.parentId)
        .whereType<int>()
        .toSet();

    int? rootIdOf(Dish d) {
      Dish? cur = d;
      int guard = 0;
      while (cur != null && cur.parentId != 0 && guard < 10) {
        cur = byId[cur.parentId];
        guard++;
      }
      return cur?.dishId;
    }

    bool chainEnabled(Dish d) {
      Dish? cur = d;
      int guard = 0;
      while (cur != null && guard < 10) {
        final status = cur.menuStatus?.toLowerCase();
        if (status != null && status != 'enable') return false;

        if (cur.parentId == 0) break;
        cur = byId[cur.parentId];
        guard++;
      }
      return true;
    }

    List<Dish> subDishes = allDishes
        .where((d) => d.dishId != null && d.parentId != null && d.parentId != 0)
        .where((d) => !parentIds.contains(d.dishId))
        .where(chainEnabled)
        .toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery;

      final matchingRootIds = allDishes
          .where(
            (d) =>
                d.parentId == 0 &&
                (d.dishName ?? '')
                    .toLowerCase()
                    .replaceAll(' ', '')
                    .contains(q),
          )
          .map((d) => d.dishId)
          .toSet();

      subDishes = subDishes.where((d) {
        final nameMatch = (d.dishName ?? '')
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(q);
        final categoryMatch = matchingRootIds.contains(rootIdOf(d));
        return nameMatch || categoryMatch;
      }).toList();
    }

    if (_vegFilter == VegFilter.veg) {
      subDishes = subDishes
          .where((d) => d.tag?.toLowerCase() == 'veg')
          .toList();
    } else if (_vegFilter == VegFilter.nonVeg) {
      subDishes = subDishes
          .where(
            (d) =>
                d.tag?.toLowerCase() == 'non_veg' ||
                d.tag?.toLowerCase() == 'non-veg' ||
                (d.tag != null && d.tag!.toLowerCase() != 'veg'),
          )
          .toList();
    }

    // ── Category chip filter: compare against the resolved ROOT id ──
    if (selectedParentId != null && selectedParentId != 0) {
      subDishes = subDishes
          .where((d) => rootIdOf(d) == selectedParentId)
          .toList();
    }

    if (subDishes.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        message: 'No dishes found',
      );
    }

    subDishes.sort((a, b) {
      final aOut =
          a.stock?.toLowerCase() == 'out_of_stock' || a.balanceQuantity <= 0;
      final bOut =
          b.stock?.toLowerCase() == 'out_of_stock' || b.balanceQuantity <= 0;
      if (aOut == bOut) return 0;
      return aOut ? 1 : -1;
    });
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: subDishes.length,
      itemBuilder: (_, i) {
        final dish = subDishes[i];
        final img = dish.dishImage != null && dish.dishImage!.isNotEmpty
            ? Image.network(
                dish.dishImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image,
                  size: 40,
                  color: AppColors.textMuted,
                ),
              )
            : Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: AppColors.textMuted,
                  )
                  as Widget;
        return ProductCard(
          imageWidget: img,

          name: dish.dishName ?? '',
          price: '₹${dish.effectivePrice}',
          description: dish.description ?? '',
          effectivePrice: '₹${dish.effectivePrice}',
          code: dish.code,
          cartButton: CartButton(
            dishId: dish.dishId ?? 0,
            orderType: selectedOrderType,
            balanceQuantity: dish.balanceQuantity,
            onCartUpdated: _loadCartCount,
          ),
          isOutOfStock:
              dish.stock?.toLowerCase() == 'out_of_stock' ||
              dish.balanceQuantity <= 0,
        );
      },
    );
  }

  // ── Horizontal categories with search highlighting ──────────────────────────
  Widget _buildHorizontalCategoriesStatic() {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 86.h,
            child: FutureBuilder<List<Dish>>(
              future: _categoriesFuture,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CategoriesShimmer();
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final parents = snap.data!
                    .where(
                      (d) =>
                          d.parentId == 0 &&
                          (d.menuStatus == null ||
                              d.menuStatus!.toLowerCase() == 'enable'),
                    )
                    .toList();

                if (parents.isEmpty) return const SizedBox.shrink();

                Set<int?> matchedParentIds = {};
                if (searchQuery.isNotEmpty) {
                  matchedParentIds = _cachedDishes
                      .where(
                        (d) =>
                            d.parentId != null &&
                            d.parentId != 0 &&
                            ((d.dishName ?? '')
                                    .toLowerCase()
                                    .replaceAll(' ', '')
                                    .contains(searchQuery) ||
                                (d.parentId != null &&
                                    parents.any(
                                      (p) =>
                                          p.dishId == d.parentId &&
                                          (p.dishName ?? '')
                                              .toLowerCase()
                                              .replaceAll(' ', '')
                                              .contains(searchQuery),
                                    ))),
                      )
                      .map((d) => d.parentId)
                      .toSet();
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: parents.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return _buildCatChip(
                        index: 0,
                        name: 'All',
                        imageUrl: null,
                        isSelected: selectedCategoryIndex == 0,
                        onTap: () => onCategoryTap(0, 0),
                      );
                    }
                    final cat = parents[i - 1];
                    final hasMatch =
                        searchQuery.isEmpty ||
                        matchedParentIds.contains(cat.dishId);
                    return Opacity(
                      opacity: hasMatch ? 1.0 : 0.4,
                      child: _buildCatChip(
                        index: i,
                        name: cat.dishName ?? '',
                        imageUrl: cat.dishImage,
                        isSelected: selectedCategoryIndex == i,
                        onTap: () => onCategoryTap(i, cat.dishId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: AppColors.border, height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildNonScrollableContent() {
    return Column(
      children: [
        if (_selectedVertical == MenuVertical.food && selectedTabIndex != 0)
          Expanded(child: _buildContent()),
      ],
    );
  }
}

// ─── Catering Content ─────────────────────────────────────────────────────────
class CateringContent extends StatefulWidget {
  const CateringContent({super.key});

  @override
  State<CateringContent> createState() => _CateringContentState();
}

class _CateringContentState extends State<CateringContent> {
  final List<PackageModel> packages = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final vendorId = await CateringService.getVendorId();
      if (vendorId == null) throw Exception('Vendor not logged in');
      final fetched = await CateringService.getPackagesByVendor(vendorId);
      setState(() {
        packages
          ..clear()
          ..addAll(fetched);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load: $e';
      });
    }
  }

  Future<void> deletePackage(int id) async {
    final ok = await CateringService.deletePackage(id);
    if (ok) {
      setState(() => packages.removeWhere((p) => p.id == id));
      _snack('Package deleted!', AppColors.accentGreen);
    } else {
      _snack('Failed to delete', AppColors.accentRed);
    }
  }

  Future<void> _onEdit(PackageModel pkg) async {
    final updated = await Navigator.push<PackageModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => UpdatePackagePage(
          packageData: {
            'id': pkg.id,
            'vendorId': pkg.vendorId,
            'packageName': pkg.packageName,
            'packageType': pkg.packageType,
            'image': pkg.image ?? '',
            'totalPrice': pkg.totalPrice,
            'items': pkg.items
                .map(
                  (i) => {'id': i.id, 'itemName': i.itemName, 'price': i.price},
                )
                .toList(),
          },
        ),
      ),
    );
    if (updated != null) {
      final idx = packages.indexWhere((p) => p.id == pkg.id);
      if (idx != -1) setState(() => packages[idx] = updated);
    }
  }

  Future<void> _onDelete(PackageModel pkg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Package',
        message: 'Are you sure you want to delete this package?',
      ),
    );
    if (ok == true) await deletePackage(pkg.id!);
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBody(),
        Positioned(
          bottom: 24,
          right: 20,
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPackagePage(
                    onPackageAdded: (pkg) => setState(() => packages.add(pkg)),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Package',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const PackageCardShimmer(count: 3);
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.accentRed,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _PrimaryButton(label: 'Retry', onTap: fetchPackages),
          ],
        ),
      );
    }
    if (packages.isEmpty) {
      return _EmptyState(
        icon: Icons.restaurant_menu_rounded,
        message: 'No packages yet',
        subtitle: 'Tap below to create your first package',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: packages.length,
      itemBuilder: (_, i) => _PackageCard(
        pkg: packages[i],
        onEdit: () => _onEdit(packages[i]),
        onDelete: () => _onDelete(packages[i]),
      ),
    );
  }
}

// ─── Package Card ─────────────────────────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final PackageModel pkg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PackageCard({
    required this.pkg,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVeg = pkg.packageType.toLowerCase().contains('veg');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: pkg.image != null && pkg.image!.isNotEmpty
                ? Image.network(
                    pkg.image!,
                    height: 155,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _noImg(),
                  )
                : _noImg(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pkg.packageName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _iconBtn(Icons.edit_rounded, AppColors.accentBlue, onEdit),
                    const SizedBox(width: 8),
                    _iconBtn(
                      Icons.delete_rounded,
                      AppColors.accentRed,
                      onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isVeg
                        ? AppColors.accentGreenLight
                        : AppColors.accentRedLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg.packageType,
                    style: TextStyle(
                      color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Items',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ...pkg.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total  ',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '₹${pkg.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noImg() => Container(
    height: 110,
    color: AppColors.bg,
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 36,
        color: AppColors.textMuted,
      ),
    ),
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color == AppColors.accentBlue
                ? AppColors.accentBlueLight
                : AppColors.accentRedLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );
}

// ─── Item Quantity Tab ────────────────────────────────────────────────────────
class ItemQuantityTab extends StatefulWidget {
  final Function()? onCartUpdated;
  const ItemQuantityTab({super.key, this.onCartUpdated});
  @override
  State<ItemQuantityTab> createState() => _ItemQuantityTabState();
}

class _ItemQuantityTabState extends State<ItemQuantityTab> {
  final Map<int, bool> expandedMap = {};
  final TextEditingController _search = TextEditingController();
  String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(controller: _search),
        Expanded(
          child: FutureBuilder<List<Dish>>(
            future: food_authservice.fetchDishes(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const ListCardShimmer(count: 6);
              if (!snap.hasData || snap.data!.isEmpty)
                return _EmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No items',
                );
              final all = snap.data!
                  .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
                  .toList();
              final q = _norm(_search.text);
              final parents = all.where((d) => d.parentId == 0).where((p) {
                if (_search.text.isEmpty) return true;
                if (_norm(p.dishName ?? '').contains(q)) return true;
                return all
                    .where((c) => c.parentId == p.dishId)
                    .any((c) => _norm(c.dishName ?? '').contains(q));
              }).toList();

              if (parents.isEmpty)
                return _EmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'No items found',
                );

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: parents.length,
                itemBuilder: (_, i) {
                  final parent = parents[i];
                  final isExp = expandedMap[parent.dishId!] ?? true;
                  final children = all
                      .where((c) => c.parentId == parent.dishId)
                      .where(
                        (c) =>
                            _search.text.isEmpty ||
                            _norm(c.dishName ?? '').contains(q),
                      )
                      .toList();
                  return _CategorySection(
                    title: parent.dishName ?? '',
                    isExpanded: isExp,
                    onToggle: () =>
                        setState(() => expandedMap[parent.dishId!] = !isExp),
                    children: isExp
                        ? children
                              .map(
                                (c) => _QuantityItem(
                                  dish: c,
                                  onEdit: () => _showEditDialog(c),
                                ),
                              )
                              .toList()
                        : [],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog(Dish dish) {
    final ctrl = TextEditingController(
      text: dish.stockQuantity?.toString() ?? '0',
    );
    showDialog(
      context: context,
      builder: (_) => _InputDialog(
        title: 'Edit Quantity',
        controller: ctrl,
        keyboardType: TextInputType.number,
        hint: 'Enter quantity',
        onSave: () async {
          final qty = int.tryParse(ctrl.text) ?? 0;
          await food_authservice.updateDish(
            dishId: dish.dishId,
            dishData: {'stockQuantity': qty},
            imageFile: null,
          );
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Quantity updated!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.accentGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ─── Quantity Item Card ───────────────────────────────────────────────────────
class _QuantityItem extends StatelessWidget {
  final Dish dish;
  final VoidCallback onEdit;
  const _QuantityItem({required this.dish, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dish.dishName ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '₹${dish.price ?? 0}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _pill('Stock', dish.stockQuantity, AppColors.accentBlue),
                    _pill(
                      'Used',
                      dish.consumedQuantity,
                      AppColors.accentOrange,
                    ),
                    _pill(
                      'Balance',
                      dish.balanceQuantity,
                      AppColors.accentGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, int? value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
      const SizedBox(height: 2),
      Text(
        '${value ?? 0}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

// ─── Discount Tab ─────────────────────────────────────────────────────────────
class DiscountTab extends StatefulWidget {
  final Function()? onCartUpdated;
  const DiscountTab({super.key, this.onCartUpdated});
  @override
  State<DiscountTab> createState() => _DiscountTabState();
}

class _DiscountTabState extends State<DiscountTab> {
  final Map<int, bool> expandedMap = {};
  final TextEditingController _search = TextEditingController();
  String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(controller: _search),
        Expanded(
          child: FutureBuilder<List<Dish>>(
            future: food_authservice.fetchDishes(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const ListCardShimmer(count: 6);
              if (!snap.hasData || snap.data!.isEmpty)
                return _EmptyState(
                  icon: Icons.discount_outlined,
                  message: 'No items',
                );
              final all = snap.data!
                  .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
                  .toList();
              final q = _norm(_search.text);
              final parents = all.where((d) => d.parentId == 0).where((p) {
                if (_search.text.isEmpty) return true;
                if (_norm(p.dishName ?? '').contains(q)) return true;
                return all
                    .where((c) => c.parentId == p.dishId)
                    .any((c) => _norm(c.dishName ?? '').contains(q));
              }).toList();

              if (parents.isEmpty)
                return _EmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'No items found',
                );

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: parents.length,
                itemBuilder: (_, i) {
                  final parent = parents[i];
                  final isExp = expandedMap[parent.dishId!] ?? true;
                  final children = all
                      .where((c) => c.parentId == parent.dishId)
                      .where(
                        (c) =>
                            _search.text.isEmpty ||
                            _norm(c.dishName ?? '').contains(q),
                      )
                      .toList();
                  return _CategorySection(
                    title: parent.dishName ?? '',
                    isExpanded: isExp,
                    onToggle: () =>
                        setState(() => expandedMap[parent.dishId!] = !isExp),
                    children: isExp
                        ? children
                              .map(
                                (c) => _DiscountItem(
                                  dish: c,
                                  onEdit: () => _showDialog(c),
                                ),
                              )
                              .toList()
                        : [],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDialog(Dish dish) {
    final ctrl = TextEditingController(
      text: dish.discount != null && dish.discount! > 0
          ? dish.discount!.toStringAsFixed(0)
          : '',
    );
    showDialog(
      context: context,
      builder: (_) => _InputDialog(
        title: 'Set Discount',
        controller: ctrl,
        keyboardType: TextInputType.number,
        hint: 'Enter percentage (0–100)',
        onSave: () async {
          final d = double.tryParse(ctrl.text) ?? 0;
          await food_authservice.updateDish(
            dishId: dish.dishId,
            dishData: {'discount': d},
            imageFile: null,
          );
          setState(() {});
        },
      ),
    );
  }
}

// ─── Discount Item ────────────────────────────────────────────────────────────
class _DiscountItem extends StatelessWidget {
  final Dish dish;
  final VoidCallback onEdit;
  const _DiscountItem({required this.dish, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = dish.discount != null && dish.discount! > 0;
    final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dish.dishName ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentRedLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dish.discount!.toStringAsFixed(0)}% OFF',
                style: const TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            )
          else
            const Text(
              'No discount',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 15,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Item Tab ─────────────────────────────────────────────────────────────
class AddItemTab extends StatefulWidget {
  final bool isVeg;
  final int? parentId;
  const AddItemTab({super.key, required this.isVeg, this.parentId});

  @override
  State<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends State<AddItemTab> {
  List<Dish> localCategories = [];
  Map<String, bool> isExpandedMap = {};
  Map<int, List<Dish>> subDishesMap = {};
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _catNameCtrl = TextEditingController();
  File? _image;
  int? selectedParentId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
    searchController.addListener(_onSearch);
    selectedParentId = widget.parentId ?? 0;
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    Utils.fetchedCategories = await food_authservice.fetchDishes();
    setState(() {
      localCategories = Utils.fetchedCategories
          .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
          .toList();
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = searchController.text.toLowerCase().replaceAll(' ', '');
    setState(() {
      localCategories = Utils.fetchedCategories
          .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
          .where(
            (d) => (d.dishName?.toLowerCase().replaceAll(' ', '') ?? '')
                .contains(q),
          )
          .toList();
    });
  }

  Future<void> _loadSubs(int parentId, String catName) async {
    final all = await food_authservice.fetchDishes();
    setState(() {
      subDishesMap[parentId] = all
          .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
          .where((d) => d.parentId == parentId)
          .toList();
      isExpandedMap[catName] = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _catNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parents = localCategories.where((d) => d.parentId == 0).toList();
    return Column(
      children: [
        _SearchField(controller: searchController),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _loadAll,
            child: _isLoading
                ? const ListCardShimmer(count: 6)
                : parents.isEmpty
                ? _EmptyState(
                    icon: Icons.category_outlined,
                    message: 'No categories yet',
                    subtitle: 'Create your first category below',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: parents.length,
                    itemBuilder: (_, i) {
                      final cat = parents[i];
                      final catName = cat.dishName ?? '';
                      final isExp = isExpandedMap[catName] ?? false;
                      return _CategorySection(
                        title: catName,
                        isExpanded: isExp,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _miniBtn(
                              Icons.edit_rounded,
                              AppColors.accentBlue,
                              () => _editCat(cat),
                            ),
                            const SizedBox(width: 4),
                            _miniBtn(
                              Icons.delete_rounded,
                              AppColors.accentRed,
                              () => _deleteCat(cat),
                            ),
                            const SizedBox(width: 4),
                            _miniBtn(
                              Icons.add_rounded,
                              AppColors.accentGreen,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PremiumAddItems(
                                      onItemSaved: (_) {},
                                      dishId: 0,
                                      isEdit: false,
                                      parentId: cat.dishId,
                                      dishName: cat.dishName,
                                    ),
                                  ),
                                ).then(
                                  (_) => _loadAll().then(
                                    (_) => _loadSubs(cat.dishId!, catName),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onToggle: () {
                          if (!isExp) {
                            _loadSubs(cat.dishId!, catName);
                          } else {
                            setState(() => isExpandedMap[catName] = false);
                          }
                        },
                        children: isExp && subDishesMap.containsKey(cat.dishId)
                            ? subDishesMap[cat.dishId]!
                                  .map(
                                    (dish) => _SubDishTile(
                                      dish: dish,
                                      onEdit: () => _editDish(dish, cat),
                                      onDelete: () => _deleteDish(dish, cat),
                                      onToggle: (val) async {
                                        await food_authservice.updateMenuStatus(
                                          dishId: dish.dishId,
                                          status: val,
                                        );
                                        await _loadSubs(cat.dishId!, catName);
                                      },
                                      onStock: (val) async {
                                        await food_authservice
                                            .updateStockStatus(
                                              dishId: dish.dishId,
                                              status: val
                                                  ? 'In_Stock'
                                                  : 'Out_of_Stock',
                                            );
                                        await _loadSubs(cat.dishId!, catName);
                                      },
                                    ),
                                  )
                                  .toList()
                            : [],
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GestureDetector(
            onTap: _openCreateDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF7B3FA0)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Create Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color == AppColors.accentBlue
                ? AppColors.accentBlueLight
                : color == AppColors.accentRed
                ? AppColors.accentRedLight
                : AppColors.accentGreenLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      );

  void _openCreateDialog() {
    _catNameCtrl.clear();
    _image = null;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Category',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _LightTextField(
                  controller: _catNameCtrl,
                  hint: 'Category name',
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final p = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (p != null) setS(() => _image = File(p.path));
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: AppColors.textMuted,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to add image',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PrimaryButton(
                        label: 'Save',
                        onTap: () async {
                          if (_catNameCtrl.text.isEmpty) return;
                          final ok = await food_authservice.createCategory(
                            name: _catNameCtrl.text,
                            parentId: 0,
                            stockQuantity: 0,
                            imageFile: _image,
                          );
                          if (ok) {
                            Navigator.pop(ctx);
                            await _loadAll();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editCat(Dish cat) async {
    final ctrl = TextEditingController(text: cat.dishName);
    File? img;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Category',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _LightTextField(controller: ctrl, hint: 'Category name'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final p = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (p != null) setS(() => img = File(p.path));
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: img != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(img!, fit: BoxFit.cover),
                          )
                        : cat.dishImage != null && cat.dishImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              cat.dishImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              'Tap to change image',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PrimaryButton(
                        label: 'Update',
                        onTap: () async {
                          if (ctrl.text.isEmpty) return;
                          final ok = await food_authservice.updateCategory(
                            dishId: cat.dishId!,
                            dishName: ctrl.text,
                            imageFile: img,
                          );
                          if (ok) {
                            Navigator.pop(ctx);
                            await _loadAll();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCat(Dish cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Category',
        message: "Delete '${cat.dishName}'? This cannot be undone.",
      ),
    );
    if (ok != true) return;
    final success = await food_authservice.deleteCategory(cat.dishId!);
    if (success) await _loadAll();
  }

  Future<void> _editDish(Dish dish, Dish cat) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumAddItems(
          onItemSaved: (d) async => d,
          dishId: dish.dishId,
          isEdit: true,
          parentId: cat.dishId,
          dishName: dish.dishName ?? '',
          price: dish.price ?? 0,
          description: dish.description,
          stockQuantity: dish.stockQuantity ?? 0,
          dishImageBase64: dish.dishImage,
        ),
      ),
    );
    await _loadAll();
    await _loadSubs(cat.dishId!, cat.dishName ?? '');
  }

  Future<void> _deleteDish(Dish dish, Dish cat) async {
    final ok = await food_authservice.deleteDish(dish.dishId);
    if (ok) await _loadSubs(cat.dishId!, cat.dishName ?? '');
  }
}

// ─── Sub Dish Tile ─────────────────────────────────────────────────────────────
class _SubDishTile extends StatelessWidget {
  final Dish dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggle;
  final Function(bool) onStock;

  const _SubDishTile({
    required this.dish,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onStock,
  });

  @override
  Widget build(BuildContext context) {
    final isVeg = (dish.tag ?? '').toLowerCase() == 'veg';
    final status = dish.menuStatus?.toLowerCase();
    final enabled = status == null || status == 'enable';
    final inStock = (dish.stock?.toLowerCase() ?? '') == 'in_stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 3)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.bg,
              child: dish.dishImage != null && dish.dishImage!.isNotEmpty
                  ? Image.network(
                      dish.dishImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.textMuted,
                        size: 22,
                      ),
                    )
                  : Icon(
                      Icons.fastfood_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dish.dishName ?? '',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${dish.price ?? 0}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _chip(
                      enabled ? 'Enabled' : 'Disabled',
                      enabled ? AppColors.accentGreen : AppColors.textMuted,
                      enabled ? AppColors.accentGreenLight : AppColors.bg,
                    ),
                    const SizedBox(width: 5),
                    _chip(
                      inStock ? 'In Stock' : 'Out',
                      inStock ? AppColors.accentBlue : AppColors.accentRed,
                      inStock
                          ? AppColors.accentBlueLight
                          : AppColors.accentRedLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showSheet(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  void _showSheet(BuildContext ctx) {
    final sheetStatus = dish.menuStatus?.toLowerCase();
    final isEnabled = sheetStatus == null || sheetStatus == 'enable';
    final inStock = (dish.stock?.toLowerCase() ?? '') == 'in_stock';
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              dish.dishName ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _sheetRow(
              ctx,
              Icons.edit_rounded,
              'Edit',
              AppColors.accentBlue,
              AppColors.accentBlueLight,
              () {
                Navigator.pop(ctx);
                onEdit();
              },
            ),
            const SizedBox(height: 8),
            _sheetRow(
              ctx,
              Icons.delete_rounded,
              'Delete',
              AppColors.accentRed,
              AppColors.accentRedLight,
              () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
            _sheetRow(
              ctx,
              isEnabled
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              isEnabled ? 'Disable Item' : 'Enable Item',
              isEnabled ? AppColors.accentOrange : AppColors.accentGreen,
              isEnabled ? const Color(0xFFFFF3E0) : AppColors.accentGreenLight,
              () {
                Navigator.pop(ctx);
                onToggle(!isEnabled);
              },
            ),
            const SizedBox(height: 8),
            _sheetRow(
              ctx,
              inStock ? Icons.inventory_2_rounded : Icons.add_box_rounded,
              inStock ? 'Mark Out of Stock' : 'Mark In Stock',
              inStock ? AppColors.accentRed : AppColors.accentGreen,
              inStock ? AppColors.accentRedLight : AppColors.accentGreenLight,
              () {
                Navigator.pop(ctx);
                onStock(!inStock);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Shared UI Components ─────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final Widget? trailing;

  const _CategorySection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    trailing!,
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(color: AppColors.border, height: 1),
            if (children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(children: children),
              )
            else
              Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Text(
                    'No items in this category',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search items…',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onPressed: () => controller.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  const _EmptyState({required this.icon, required this.message, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      message,
      style: const TextStyle(color: AppColors.accentRed, fontSize: 14),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFF7B3FA0)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

class _LightTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _LightTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.textPrimary),
    cursorColor: AppColors.accent,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
    ),
  );
}

class _InputDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hint;
  final VoidCallback onSave;

  const _InputDialog({
    required this.title,
    required this.controller,
    required this.keyboardType,
    required this.hint,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _LightTextField(controller: controller, hint: hint),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrimaryButton(
                  label: 'Save',
                  onTap: () {
                    Navigator.pop(context);
                    onSave();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  const _ConfirmDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.accentRedLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accentRed,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentRedLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.accentRed.withOpacity(0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String price;
  final String description;
  final String effectivePrice;
  final Widget cartButton;
  final bool isOutOfStock;
  final String? code;

  const ProductCard({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.description,
    required this.effectivePrice,
    required this.cartButton,
    required this.isOutOfStock,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    final orig = double.tryParse(price.replaceAll('₹', '')) ?? 0;
    final eff = double.tryParse(effectivePrice.replaceAll('₹', '')) ?? 0;
    final hasDiscount = eff < orig;

    return AbsorbPointer(
      absorbing: isOutOfStock,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMd,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: imageWidget,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (code != null && code!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        hasDiscount ? effectivePrice : price,
                        style: TextStyle(
                          color: hasDiscount
                              ? AppColors.accentGreen
                              : AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  child: Center(child: cartButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart Button ──────────────────────────────────────────────────────────────
class CartButton extends StatefulWidget {
  final int dishId;
  final OrderType orderType;
  final int balanceQuantity;
  final Function()? onCartUpdated;

  const CartButton({
    super.key,
    required this.dishId,
    required this.orderType,
    required this.balanceQuantity,
    this.onCartUpdated,
  });

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  int itemCount = 0;
  bool _isLoading = false;
  bool _isOutOfStock = false;
  int? _cartItemId;
  int? _cartId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isOutOfStock = widget.balanceQuantity <= 0;
    _loadQty();
    Utils.itemCount.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    Utils.itemCount.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (!_isUpdating) _loadQty();
  }

  Future<void> _loadQty() async {
    if (_isUpdating) return;
    try {
      final cart = await food_authservice.fetchCart();
      if (!mounted) return;
      if (cart != null) {
        _cartId = cart.cartId;
        bool found = false;
        for (var item in cart.cartItems) {
          if (item.dishId == widget.dishId) {
            setState(() {
              itemCount = item.quantity;
              _cartItemId = item.itemId;
            });
            found = true;
            break;
          }
        }
        if (!found)
          setState(() {
            itemCount = 0;
            _cartItemId = null;
          });
      } else {
        setState(() {
          itemCount = 0;
          _cartItemId = null;
          _cartId = null;
        });
      }
    } catch (_) {
      setState(() {
        itemCount = 0;
        _cartItemId = null;
        _cartId = null;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_isOutOfStock) return;
    setState(() => _isLoading = true);
    try {
      final cartId = await food_authservice.addToCart(
        dishId: widget.dishId,
        quantity: 1,
        orderType: widget.orderType == OrderType.DINE_IN
            ? 'DINE_IN'
            : 'TAKEAWAY',
      );
      if (cartId != null) {
        await _loadQty();
        Utils.itemCount.value = Utils.itemCount.value + 1;
        widget.onCartUpdated?.call();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQty(int newQty) async {
    if (_isUpdating) return;
    if (newQty > widget.balanceQuantity && widget.balanceQuantity > 0) return;

    final oldQty = itemCount;
    _isUpdating = true;
    setState(() => _isLoading = true);

    try {
      await _loadQty();
      if (_cartId != null && _cartItemId != null) {
        if (newQty < 1) {
          final ok = await food_authservice.removeCartItem(_cartItemId!);
          if (ok) {
            setState(() {
              itemCount = 0;
              _cartItemId = null;
            });
            Utils.itemCount.value = Utils.itemCount.value - 1;
            await _loadQty();
          }
        } else {
          setState(() => itemCount = newQty);
          final diff = newQty - oldQty;
          if (diff != 0) Utils.itemCount.value = Utils.itemCount.value + diff;

          final ok = await food_authservice.updateCartQuantity(
            _cartId!,
            widget.dishId,
            newQty,
          );

          if (!ok) {
            setState(() => itemCount = oldQty);
            final revert = oldQty - newQty;
            if (revert != 0)
              Utils.itemCount.value = Utils.itemCount.value + revert;
          }
        }
        widget.onCartUpdated?.call();
      } else if (newQty > 0) {
        await _addToCart();
      }
    } finally {
      _isUpdating = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    }
    if (itemCount == 0) {
      return GestureDetector(
        onTap: _isOutOfStock ? null : _addToCart,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isOutOfStock
                  ? AppColors.border
                  : AppColors.accent.withOpacity(0.4),
            ),
          ),
          child: Center(
            child: Text(
              _isOutOfStock ? 'Out of Stock' : '+ Add',
              style: TextStyle(
                color: _isOutOfStock ? AppColors.textMuted : AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
            onPressed: _isUpdating
                ? null
                : () => _updateQty(itemCount > 1 ? itemCount - 1 : 0),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            '$itemCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            onPressed: _isUpdating
                ? null
                : () {
                    if (itemCount < widget.balanceQuantity)
                      _updateQty(itemCount + 1);
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar Item ─────────────────────────────────────────────────────────────
class Sidebaritem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color color;
  final TextStyle textStyle;
  final ImageProvider? image;

  const Sidebaritem({
    super.key,
    this.icon,
    this.image,
    required this.title,
    required this.onTap,
    required this.isSelected,
    required this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 84,
        width: 68,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bg,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipOval(
                child: image != null
                    ? Image(image: image!, fit: BoxFit.cover)
                    : Icon(
                        icon,
                        size: 22,
                        color: isSelected ? color : AppColors.textMuted,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: textStyle.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Veg Non-Veg Toggle ───────────────────────────────────────────────────────
class VegNonVegToggle extends StatelessWidget {
  final bool isVeg;
  final ValueChanged<bool> onToggle;
  const VegNonVegToggle({
    super.key,
    required this.isVeg,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: 100,
      height: 36,
      toggleSize: 28,
      borderRadius: 18,
      value: isVeg,
      showOnOff: true,
      activeColor: AppColors.vegGreen,
      inactiveColor: AppColors.nonVegRed,
      activeText: 'Veg',
      inactiveText: 'Non-Veg',
      valueFontSize: 11,
      onToggle: onToggle,
    );
  }
}

class ToggleSwitchExample extends StatelessWidget {
  final bool initialValue;
  final Function(bool)? onToggleChanged;
  const ToggleSwitchExample({
    Key? key,
    required this.initialValue,
    this.onToggleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FlutterSwitch(
    value: initialValue,
    width: 60,
    height: 28,
    toggleSize: 18,
    borderRadius: 30,
    activeColor: AppColors.accentGreen,
    inactiveColor: AppColors.nonVegRed,
    showOnOff: true,
    valueFontSize: 10,
    onToggle: onToggleChanged ?? (_) {},
  );
}

class StockToggleSwitch extends StatelessWidget {
  final bool initialValue;
  final Function(bool)? onToggleChanged;
  const StockToggleSwitch({
    Key? key,
    required this.initialValue,
    this.onToggleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FlutterSwitch(
    value: initialValue,
    width: 75,
    height: 28,
    toggleSize: 18,
    borderRadius: 30,
    activeColor: AppColors.accentGreen,
    inactiveColor: AppColors.nonVegRed,
    activeText: 'In Stock',
    inactiveText: 'Out',
    showOnOff: true,
    valueFontSize: 9,
    onToggle: onToggleChanged ?? (_) {},
  );
}

// ─── Food Item Card ───────────────────────────────────────────────────────────
class FoodItemCard extends StatelessWidget {
  final String? imagePath;
  final String? imageurl;
  final String title;
  final String price;
  final bool isVeg;
  final bool initialToggleState;
  final bool initialStockState;
  final VoidCallback onEdit;
  final bool? isDisabled;
  final Function(bool)? onStockToggleChanged;
  final VoidCallback? onDelete;
  final Function(bool)? onToggleChanged;

  const FoodItemCard({
    Key? key,
    this.imagePath,
    this.imageurl,
    required this.title,
    required this.price,
    required this.isVeg,
    this.isDisabled,
    required this.initialToggleState,
    required this.initialStockState,
    required this.onEdit,
    this.onToggleChanged,
    this.onDelete,
    this.onStockToggleChanged,
  }) : super(key: key);

  ImageProvider getImageProvider() {
    if (imageurl != null && imageurl!.isNotEmpty)
      return NetworkImage(imageurl!);
    if (imagePath != null && imagePath!.isNotEmpty)
      return AssetImage(imagePath!);
    return const AssetImage('assets/gallery-img-1.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: getImageProvider(),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showSheet(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlueLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.edit_rounded,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentRedLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentRed.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete_rounded,
                      color: AppColors.accentRed,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Enable / Disable',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                ToggleSwitchExample(
                  initialValue: initialToggleState,
                  onToggleChanged: (v) {
                    onToggleChanged?.call(v);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'In Stock / Out of Stock',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                StockToggleSwitch(
                  initialValue: initialStockState,
                  onToggleChanged: (v) {
                    onStockToggleChanged?.call(v);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
