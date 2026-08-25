import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maamaaspartner/user_module/screens/Food&beverages/Table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../API/food_authservice.dart';
import '../../Models/food/aboutus_model.dart';
import '../../Models/food/category_dish.dart';
import '../../Models/food/dish.dart';
import '../../Models/food/restaurent_banner_model.dart';
import '../../Models/food/timings_model.dart';
import '../cart_footer_button.dart';
import '../../widgets/food/cart_button.dart';
import '../../widgets/food/favorite_button.dart';
import '../../widgets/food/switch.dart';
import '../newscreens/restaurentsnew.dart';

class MenuResponse {
  final List<CategoryDish> categories;
  final List<Dish> dishes;
  final String? errorMessage;
  final bool hasError;

  MenuResponse({
    required this.categories,
    required this.dishes,
    this.errorMessage,
    this.hasError = false,
  });
}

class MenuScreen extends StatefulWidget {
  final int vendorId;
  final int? parentId;
  final Function(int)? onTabChange; // ✅ add this line

  const MenuScreen({
    super.key,
    this.parentId,
    required this.vendorId,
    this.onTabChange, // ✅ add this
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  Timer? _scrollTimer;
  bool _isTopVisible = true;
  bool? isVeg = null;
  int selectedTabIndex = 0;
  int? selectedCategoryId; // Track selected category
  List<CategoryDish> categories = []; // Store categories
  int? userId;
  String planType = "";
  String orderType = "";
  String searchQuery = "";

  Restaurent_Banner? _bannerItem;
  String? _companyBanner;

  late Future<void> _screenFuture;

  bool _isCollapsed = false;

  bool _isLoading = true;
  List<Dish> _allDishes = [];

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadBannerData();
    _screenFuture = _loadScreenData();
    _scrollController.addListener(() {
      final collapsed =
          _scrollController.offset >
          (200 - kToolbarHeight); // expandedHeight - toolbarHeight

      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  Future<void> _loadBannerData() async {
    try {
      final banner = await food_Authservice().fetchVendorBanner(
        widget.vendorId,
      );
      setState(() {
        _bannerItem = banner;
        _companyBanner = banner.companyBanner;
      });
    } catch (e) {}
  }

  Future<void> _loadScreenData() async {
    await Future.wait([
      _initializeData(), // prefs + plan
      // _loadCategories(), // categories
      _loadMenu(),
      food_Authservice().fetchVendorBanner(widget.vendorId),
      food_Authservice.fetchAboutUsData(widget.vendorId),
      food_Authservice.fetchVendorTimingForToday(widget.vendorId),
      food_Authservice.fetchMenu(widget.vendorId),
    ]);
  }

  String get normalizedPlan => planType.trim().toUpperCase();
  String get normalizedOrderType => orderType.trim().toUpperCase();

  bool get showMenuTab =>
      ["DINE_IN", "TAKEAWAY", "DELIVERY"].contains(normalizedOrderType);

  bool get showTableTab =>
      normalizedOrderType == "TABLE_DINE_IN" && normalizedPlan == "PREMIUM";

  Future<void> _initializeData() async {
    await _loadPrefs();

    final vendorIdInt = (widget.vendorId);
    await _loadPlan(vendorIdInt);

    // print(
    //   "✅ Initialized → userId: $userId, orderType: $orderType, planType: $planType",
    // );
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orderType =
          prefs.getString('orderType')?.trim().toUpperCase() ?? "DINE_IN";
      planType = prefs.getString('planType')?.trim().toUpperCase() ?? "BASIC";
    });
  }

  Future<void> _loadPlan(int vendorId) async {
    try {
      // print("🔹 Fetching plan for vendorId: $vendorId");
      final plan = await food_Authservice.fetchUserPlanForVendor(vendorId);
      if (!mounted) return;
      setState(() => planType = (plan ?? "").trim().toUpperCase());
      // print("✅ Plan Loaded → $planType");
    } catch (e) {
      // print("❌ Error fetching plan: $e");
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 100), _handleScroll);
    });
  }

  void _handleScroll() {
    final double currentOffset = _scrollController.offset;
    const double threshold = 50;
    if (currentOffset > threshold && _isTopVisible) {
      setState(() => _isTopVisible = false);
    } else if (currentOffset <= threshold && !_isTopVisible) {
      setState(() => _isTopVisible = true);
    }
  }

  Future<void> _onRefresh() async {
    debugPrint("🔄 Refresh triggered!");
    await Future.delayed(const Duration(seconds: 1));
    await _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);

    final menu = await food_Authservice.fetchMenu(widget.vendorId);

    if (!mounted) return;

    // Top-level categories
    final topCategories = menu.categories
        .where((c) => c.parentId == 0)
        .toList();

    // Filter dishes by parentId if needed
    List<Dish> filteredDishes;
    if (widget.parentId != null && widget.parentId! > 0) {
      filteredDishes = menu.dishes
          .where((d) => d.parentId == widget.parentId)
          .toList();
    } else {
      filteredDishes = menu.dishes;
    }

    setState(() {
      categories = topCategories;
      _allDishes = filteredDishes;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _pageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _screenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MenuSkeletonScreen();
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              return _buildMainScreen();
            },
          ),

          // 👇 Floating draggable cart button
          const DraggableCartFAB(),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.blueAccent,
      displacement: 40,
      strokeWidth: 3,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            collapsedHeight: 60,
            backgroundColor: Color(0xFFF8FAFC),
            elevation: 0,

            /// 🔹 Show MenuFilterBar INSIDE collapsed height
            title: _isCollapsed
                ? SizedBox(
                    height: 60,
                    child: MenuFilterBar(
                      searchWidth: 200, // 👈 smaller
                      searchFillColor: Color(0xFFF8FAFC),
                      isVeg: isVeg ?? false,
                      vendorId: widget.vendorId,
                      selectedFilterIndex: selectedTabIndex,
                      onToggle: (val) => setState(() => isVeg = val),
                      onSearch: (val) => setState(() => searchQuery = val),
                    ),
                  )
                : null,

            centerTitle: false,
            titleSpacing: 0,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Column(
                children: [
                  /// 🔹 Banner
                  Expanded(
                    child: RestaurantBannerHeader(
                      bannerImage: _companyBanner,
                      title: _bannerItem?.companyName ?? "",
                      subtitle: _bannerItem?.establishedYear ?? "",
                    ),
                  ),

                  /// 🔹 MenuFilterBar (below banner)
                  Container(
                    height: 60,
                    color: Colors.white,
                    child: MenuFilterBar(
                      searchFillColor: Colors.grey.shade200,
                      searchWidth: 250,
                      isVeg: isVeg ?? false,
                      vendorId: widget.vendorId,
                      selectedFilterIndex: selectedTabIndex,
                      onToggle: (val) => setState(() => isVeg = val),
                      onSearch: (val) => setState(() => searchQuery = val),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _MenuFilterTabsDelegate(
              height: _calculateHeaderHeight().h,
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!showMenuTab)
                      TableTabContent(vendorId: widget.vendorId),
                    SizedBox(
                      height: 80.h,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 3,
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryTab(
                              title: "All Items",
                              image: const AssetImage("assets/allitems.jpg"),
                              isSelected: selectedCategoryId == null,
                              onTap: () =>
                                  setState(() => selectedCategoryId = null),
                            ),
                            ...categories.map(
                              (category) => _buildCategoryTab(
                                title: category.dishName ?? '',
                                image:
                                    (category.dishImage != null &&
                                        category.dishImage!.isNotEmpty)
                                    ? NetworkImage(category.dishImage!)
                                    : null,
                                isSelected:
                                    selectedCategoryId == category.dishId,
                                onTap: () => setState(
                                  () => selectedCategoryId = category.dishId,
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

          // MenuTabContent - only shows dishes now
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Builder(
                builder: (_) {
                  return MenuTabContent(
                    isVeg: isVeg,
                    vendorId: widget.vendorId,
                    selectedVendorId: widget.vendorId,
                    favoriteButton: (dish) => FavoriteButton(dish: dish),
                    cartButton: (dish) => CartButton(
                      dishId: dish.dishId,
                      balanceQuantity: dish.balanceQuantity ?? 0,
                    ),
                    isOutOfStock: (dish) =>
                        dish.stock?.toLowerCase() != "in stock",
                    selectedCategoryId: selectedCategoryId,
                    searchQuery: searchQuery,
                  );
                },

                // return const SizedBox();
                // },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateHeaderHeight() {
    double baseHeight = 80.h; // Category tabs height
    double filterBarHeight = 0.h; // MenuFilterBar height
    double tableTabHeight = 50.h; // TableTabContent height

    return (!showMenuTab)
        ? baseHeight + filterBarHeight + tableTabHeight
        : baseHeight + filterBarHeight;
  }

  Widget _buildCategoryTab({
    required String title,
    ImageProvider? image,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 60 : 55,
              height: isSelected ? 55 : 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade300,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.green.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),

              child: image != null
                  ? ClipOval(
                      child: Image(
                        image: image,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 45,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 3),

            SizedBox(
              width: 60,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.green : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuFilterTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _MenuFilterTabsDelegate({
    required this.child,
    required this.height, // Remove default value, make it required
  });

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
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _MenuFilterTabsDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: visible ? null : 0,
      child: Visibility(visible: visible, child: child),
    );
  }
}

class TopRestaurantCard extends StatefulWidget {
  final void Function(bool isExpanded) onExpandChange;
  final int vendorId;

  const TopRestaurantCard({
    super.key,
    required this.onExpandChange,
    required this.vendorId,
  });

  @override
  State<TopRestaurantCard> createState() => _TopRestaurantCardState();
}

class _TopRestaurantCardState extends State<TopRestaurantCard> {
  bool _showKnowMore = false;
  bool _showGallery = false;
  Restaurent_Banner? _bannerItem;
  AboutUsModel? _aboutUsModel;
  Timing? _todayTiming;
  String? _companyBanner;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchBannerData(),
        _loadAboutUs(),
        _loadVendorTiming(widget.vendorId),
      ]);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _fetchBannerData() async {
    try {
      final banner = await food_Authservice().fetchVendorBanner(
        widget.vendorId,
      );
      if (mounted) {
        setState(() {
          _bannerItem = banner;
          _companyBanner = banner.companyBanner;
        });
      }
    } catch (e) {
      // print("Banner Error : $e");
    }
  }

  Future<void> _loadAboutUs() async {
    final result = await food_Authservice.fetchAboutUsData(widget.vendorId);
    if (result != null && mounted) {
      setState(() {
        _aboutUsModel = result;
        imageUrls = result.allImages; // <--- FIXED
      });
    }
  }

  Future<void> _loadVendorTiming(int vendorId) async {
    final timing = await food_Authservice.fetchVendorTimingForToday(vendorId);

    if (!mounted) return;

    setState(() {
      _todayTiming = timing;
    });
  }

  String _formatTime(BuildContext context, String timeStr) {
    try {
      final parts = timeStr.split(":");
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      return time.format(context);
    } catch (_) {
      return "--";
    }
  }

  Future<void> _launchSocialUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  ImageProvider _getImageProvider(String imageString) {
    if (imageString.startsWith('http')) {
      return NetworkImage(imageString);
    } else {
      return MemoryImage(base64Decode(imageString));
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSection(),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildAboutUsSection(),
              crossFadeState: _showKnowMore
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildGallerySection(),
              crossFadeState: _showGallery
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.grey.shade200,
                image: _companyBanner != null && _companyBanner!.isNotEmpty
                    ? DecorationImage(
                        image: _getImageProvider(_companyBanner!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.6),
                          BlendMode.darken,
                        ),
                      )
                    : null, // no image if banner is empty
              ),
              child: _companyBanner == null || _companyBanner!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No Banner Image",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),

            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: Center(child: _buildInfoAndActionsSection(context)),
            // ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      (_bannerItem?.companyName ?? "Loading...").toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _bannerItem?.establishedYear ?? "Loading...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   bottom: 70,
            //   left: 0,
            //   right: 0,
            //   child: _buildSocialIconsRow(_bannerItem),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAndActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTimingInfo(context)],
          ),
          Row(
            children: [
              _buildActionButton(
                text: _showKnowMore ? 'Hide Info' : 'Know More',
                onPressed: () => setState(() {
                  _showKnowMore = !_showKnowMore;
                  if (_showKnowMore) _showGallery = false;
                  widget.onExpandChange(_showKnowMore || _showGallery);
                }),
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                text: _showGallery ? 'Hide Gallery' : 'View Gallery',
                onPressed: () => setState(() {
                  _showGallery = !_showGallery;
                  if (_showGallery) _showKnowMore = false;
                  widget.onExpandChange(_showKnowMore || _showGallery);
                }),
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimingInfo(BuildContext context) {
    return _todayTiming != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.green),
                  Text(
                    "Start: ${_formatTime(context, _todayTiming!.startTime)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    size: 14,
                    color: Colors.red,
                  ),
                  Text(
                    "End: ${_formatTime(context, _todayTiming!.lastTime)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          )
        : const Text("No timing\n available.");
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget _buildAboutUsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "ABOUT US",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _aboutUsModel?.aboutUs ?? "No About Us info available.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/misionn.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mission",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aboutUsModel?.mission ?? "No mission data is available",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/vision.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Vision",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aboutUsModel?.vision ?? "No mission data is available.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    if (imageUrls.isEmpty) {
      return Center(
        child: Text(
          "No images available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final img = imageUrls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildNetworkImage(img),
          );
        },
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildSocialIconsRow(Restaurent_Banner? banner) {
    final hasAnySocialLink = [
      banner?.facebookLink,
      banner?.instagramLink,
      banner?.whatsappLink,
      banner?.twitterLink,
    ].any((link) => link != null && link.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          if (banner?.facebookLink.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
              iconSize: 35.0,
              onPressed: () => _launchSocialUrl(banner!.facebookLink),
              tooltip: "Facebook",
            ),

          if (banner?.instagramLink.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.instagram,
                color: Colors.purple,
              ),
              iconSize: 35.0,
              onPressed: () => _launchSocialUrl(banner!.instagramLink),
              tooltip: "Instagram",
            ),

          if (banner?.whatsappLink.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              iconSize: 35.0,
              onPressed: () => _launchSocialUrl(banner!.whatsappLink),
              tooltip: "WhatsApp",
            ),

          if (banner?.twitterLink.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.twitter,
                color: Colors.lightBlue,
              ),
              iconSize: 35.0,
              onPressed: () => _launchSocialUrl(banner!.twitterLink),
              tooltip: "Twitter",
            ),

          // 👉 Show this when no social links exist
          if (!hasAnySocialLink)
            const Text(
              "No social links available",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class MenuFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final int selectedFilterIndex;

  final int vendorId;
  final String? orderType;
  final Function(String) onSearch;
  final double searchWidth;
  final Color searchFillColor;

  const MenuFilterBar({
    super.key,
    required this.isVeg,
    required this.onToggle,

    required this.vendorId,
    this.orderType,
    this.selectedFilterIndex = 0,
    required this.onSearch,
    this.searchWidth = 180,
    this.searchFillColor = const Color(0xFFF0F0F0),
  });

  @override
  State<MenuFilterBar> createState() => _MenuFilterBarState();
}

class _MenuFilterBarState extends State<MenuFilterBar> {
  late bool _isVeg;

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: widget.searchWidth,
                  height: 36,
                  child: TextField(
                    onChanged: widget.onSearch, // 🔥 inline search
                    decoration: InputDecoration(
                      hintText: "Search dishes",
                      prefixIcon: Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: widget.searchFillColor,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                CustomTextSwitch(
                  value: _isVeg,
                  onChanged: (val) {
                    setState(() => _isVeg = val);
                    widget.onToggle(val);
                  },
                  activeText: "",
                  inactiveText: "",
                  activeTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  inactiveTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  activeColor: Colors.green,
                  inactiveColor: Colors.red,
                  width: 70, // reduced for responsiveness
                  height: 30,
                  toggleSize: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuTabContent extends StatefulWidget {
  final bool? isVeg;
  final Widget Function(CategoryDish dish) cartButton;
  final bool Function(Dish) isOutOfStock;
  final int vendorId;
  final int selectedVendorId;
  final favoriteButton;
  final int? selectedCategoryId; // Add selected category
  final String searchQuery;

  const MenuTabContent({
    super.key,
    required this.isVeg,
    required this.cartButton,
    required this.isOutOfStock,
    required this.favoriteButton,
    required this.selectedVendorId,
    required this.vendorId,
    this.selectedCategoryId,
    required this.searchQuery,
  });

  @override
  State<MenuTabContent> createState() => _MenuTabContentState();
}

class _MenuTabContentState extends State<MenuTabContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DishGridTab(
        parentId: widget.selectedCategoryId,
        vendorId: widget.vendorId,
        filterTag: widget.isVeg == null
            ? null
            : widget.isVeg!
            ? "veg"
            : "non_veg",
        emptyMessage: widget.isVeg == true
            ? "No Veg dishes found."
            : widget.isVeg == false
            ? "No Non-Veg dishes found."
            : "No dishes found.",
        searchQuery: widget.searchQuery,
      ),
    );
  }
}

class DishGridTab extends StatefulWidget {
  final int? parentId;
  final int vendorId;
  final String? filterTag;
  final String emptyMessage;
  final String searchQuery;

  const DishGridTab({
    super.key,
    this.parentId,
    required this.vendorId,
    required this.filterTag,
    required this.emptyMessage,
    required this.searchQuery,
  });

  @override
  _DishGridTabState createState() => _DishGridTabState();
}

class _DishGridTabState extends State<DishGridTab> {
  bool _isLoading = true;
  List<Dish> _allDishes = [];
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // fetchMenu();
    _loadMenu();
  }

  @override
  void didUpdateWidget(DishGridTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.parentId != oldWidget.parentId ||
        widget.filterTag != oldWidget.filterTag) {
      // fetchMenu();
      _loadMenu();
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final menu = await food_Authservice.fetchMenu(widget.vendorId);

    if (!mounted) return;

    if (menu.hasError) {
      setState(() {
        _errorMessage = menu.errorMessage;
        _isLoading = false;
      });
      return;
    }

    List<Dish> filteredDishes;

    if (widget.parentId != null && widget.parentId! > 0) {
      filteredDishes = menu.dishes
          .where((d) => d.parentId == widget.parentId)
          .toList();
    } else {
      filteredDishes = menu.dishes;
    }

    setState(() {
      _allDishes = filteredDishes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 1. LOADING → skeleton (NO empty text)
    if (_isLoading) {
      return const MenuSkeletonScreen();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 Soft icon container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.15),
                        Colors.orange.withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                /// 🔹 Title
                const Text(
                  "Action Required",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔹 Message (backend-safe but user-friendly)
                // Text(
                //   _errorMessage!,
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 14,
                //     height: 1.5,
                //     color: Colors.grey[700],
                //   ),
                // ),
                const SizedBox(height: 10),

                /// 🔹 Primary CTA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Restaurentsnew(
                            scrollController: _scrollController,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${_errorMessage!}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
      );
    }

    // 🔹 2. FILTER DISHES
    final filteredDishes = _allDishes.where((dish) {
      final isEnabled = dish.menuStatus == "Enable";

      final matchesVeg =
          widget.filterTag == null ||
          dish.tag?.toLowerCase() == widget.filterTag!.toLowerCase();

      final matchesSearch =
          widget.searchQuery.isEmpty ||
          dish.dishName!.toLowerCase().contains(
            widget.searchQuery.toLowerCase(),
          );

      return isEnabled && matchesVeg && matchesSearch;
    }).toList();

    // 🔹 2.1 SORT → In-stock first, Out-of-stock last
    filteredDishes.sort((a, b) {
      final aOut =
          a.balanceQuantity <= 0 || a.stock?.toLowerCase() != "in_stock";
      final bOut =
          b.balanceQuantity <= 0 || b.stock?.toLowerCase() != "in_stock";

      if (aOut == bOut) return 0; // keep relative order
      return aOut ? 1 : -1; // out-of-stock goes down
    });

    // 🔹 3. EMPTY STATE (ONLY AFTER LOADING)
    if (filteredDishes.isEmpty) {
      return Center(
        child: Text(
          widget.emptyMessage,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    int crossAxis = width < 500
        ? 2
        : width < 800
        ? 3
        : width < 1200
        ? 4
        : 5;

    double ratio = width < 500
        ? 0.68
        : width < 800
        ? 0.75
        : width < 1200
        ? 0.82
        : 0.9;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: ratio,
      ),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        final isOut =
            dish.balanceQuantity <= 0 ||
            dish.stock?.toLowerCase() != "in_stock";

        return GestureDetector(
          onTap: () => showDishBottomSheet(context, dish),
          child: ProductCard(
            imageWidget: _buildImage(dish.dishImage),
            name: dish.dishName ?? '',
            price: "₹${dish.price}",
            effectivePrice: "₹${dish.effectivePrice}",
            description: dish.description ?? '',
            favoriteButton: FavoriteButton(dish: dish),
            cartButton: CartButton(
              dishId: dish.dishId,
              balanceQuantity: dish.balanceQuantity,
            ),
            isOutOfStock: isOut,
            balanceQuantity: dish.balanceQuantity,
            discount: dish.discount,
            tag: dish.tag,
          ),
        );
      },
    );
  }

  void showDishBottomSheet(BuildContext context, Dish dish) {
    final isOut =
        dish.balanceQuantity <= 0 || dish.stock?.toLowerCase() != "in_stock";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // ✅ important for bottom sheets
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false, // keep rounded top intact
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image
                    Stack(
                      children: [
                        /// 🖼️ Dish Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            dish.dishImage ?? '',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// 🚫 Out of Stock Overlay
                        if (isOut)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  0.6,
                                ), // better contrast
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "Out of Stock",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Name + Veg Tag
                    Row(
                      children: [
                        vegNonVegIndicator(dish.tag),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dish.dishName ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Price
                    Text(
                      "₹${dish.effectivePrice}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      dish.description ?? "No description available",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Add to Cart Button
                    CartButton(
                      dishId: dish.dishId,
                      balanceQuantity: dish.balanceQuantity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? imageUrl) {
    return Container(
      color: Colors.black, // fallback background
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                // ignore: deprecated_member_use
                Colors.black.withOpacity(0.1), // black overlay
                BlendMode.darken,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.fastfood,
                    size: 40.w,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            )
          : Container(
              color: Colors.black,
              child: Icon(
                Icons.image_not_supported,
                size: 40.w,
                color: Colors.grey[400],
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String price;
  final String description;
  final String effectivePrice;
  final Widget favoriteButton;
  final Widget cartButton;
  final bool isOutOfStock;
  final int balanceQuantity;
  final num discount;
  final String? tag;

  const ProductCard({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.description,
    required this.effectivePrice,
    required this.favoriteButton,
    required this.cartButton,
    required this.isOutOfStock,
    required this.balanceQuantity,
    required this.discount,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool small = width < 500;

    double imageHeight = small ? 120 : 150;
    double titleSize = small ? 13 : 15;
    double priceSize = small ? 16 : 18;

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // IMAGE SECTION
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: imageWidget,
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: Center(child: favoriteButton),
                ),
              ),

              // 🔥 OUT OF STOCK OVERLAY (CORRECT)
              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.transparent.withOpacity(0.6),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Out of Stock",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // DETAILS SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Dish Name (fixed height)
                  SizedBox(
                    height: small ? 36 : 42, // 👈 FIXED HEIGHT
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 Price Row (always same position)
                  Row(
                    children: [
                      if (discount > 0)
                        Text(
                          price,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: small ? 11 : 12,
                            color: Colors.red,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        effectivePrice,
                        style: TextStyle(
                          fontSize: priceSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      vegNonVegIndicator(tag),
                    ],
                  ),

                  const Spacer(), // 🔥 pushes cart button to bottom

                  Center(child: cartButton),
                ],
              ),
            ),
          ),
        ],
      ),
      // ),
      // ),
    );
  }
}

Widget vegNonVegIndicator(String? tag) {
  final isVeg = tag?.toLowerCase() == "veg";

  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1.5),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isVeg ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    ),
  );
}

class MenuSkeletonScreen extends StatelessWidget {
  const MenuSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 180), // Banner
          const SizedBox(height: 16),

          _skeletonBox(height: 20, width: 140),
          const SizedBox(height: 12),

          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _skeletonBox(height: 90),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _skeletonBox(height: 110),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({double height = 100, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class RestaurantBannerHeader extends StatelessWidget {
  final String? bannerImage;
  final String title;
  final String subtitle;

  const RestaurantBannerHeader({
    super.key,
    required this.bannerImage,
    required this.title,
    required this.subtitle,
  });

  ImageProvider _getImage(String img) {
    if (img.startsWith("http")) {
      return NetworkImage(img);
    }
    return MemoryImage(base64Decode(img));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 🔥 FULL SCREEN IMAGE
        bannerImage != null && bannerImage!.isNotEmpty
            ? Image(image: _getImage(bannerImage!), fit: BoxFit.cover)
            : Container(color: Colors.grey.shade300),

        // 🔥 DARK GRADIENT
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              // ignore: deprecated_member_use
              colors: [Colors.black.withOpacity(0.65), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
