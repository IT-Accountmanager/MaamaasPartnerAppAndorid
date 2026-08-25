import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../API/food_authservice.dart';
import '../../API/grocery_authservice.dart';
import '../../Models/food/aboutus_model.dart';
import '../../Models/food/category_dish.dart';
import '../../Models/food/dish.dart';
import '../../Models/food/table_confirmedlist_model.dart';
import '../../Models/food/table_waitinglist_model.dart';
import '../../Models/food/timings_model.dart';
import '../../Models/grocery/grocery_banner_model.dart';
import '../../widgets/food/cart_button.dart';
import '../../widgets/food/favorite_button.dart';
import 'package:intl/intl.dart';

class store_Screen extends StatefulWidget {
  final int? vendorId;

  const store_Screen({super.key, this.vendorId});

  @override
  State<store_Screen> createState() => _store_ScreenState();
}

class _store_ScreenState extends State<store_Screen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  Timer? _scrollTimer;
  bool _isTopVisible = true;
  bool isVeg = true;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.search, color: Colors.white),
              //     onPressed: () => _showSearch(context),
              //   ),
              // ],
            ),
            SliverToBoxAdapter(
              child: AnimatedVisibility(
                visible: _isTopVisible,
                child: TopRestaurantCard(
                  vendorId: widget.vendorId!,
                  onExpandChange: (expanded) {},
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MenuFilterBar(
                      isVeg: isVeg,
                      selectedFilterIndex: selectedTabIndex,
                      onToggle: (val) {
                        setState(() => isVeg = val);
                      },
                      vendorId: widget.vendorId!,
                      onTabChange: (index) {
                        setState(() => selectedTabIndex = index);
                      },
                    ),
                  );
                }
                return null;
              }),
            ),
          ],
        ),
        // bottomNavigationBar: food_foooter(
        //   onFilterTap: () => _openFilterBottomSheet(),
        // ),
      ),
    );
  }

  // void _showSearch(BuildContext context) async {
  //   final result = await showSearch(
  //     context: context,
  //     delegate: DishSearchDelegate(),
  //   );
  //   if (result != null && result.isNotEmpty) {
  //     // Handle search result
  //   }
  // }
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
  grocery_Banner? _bannerItem;
  AboutUsModel? _aboutUsModel;
  final List<String> _images = [];
  Timing? _todayTiming;
  bool _isLoading = true;
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchBannerData() async {
    try {
      final banner = await grocery_authservice().fetchVendorBanner(
        widget.vendorId,
      );
      if (mounted) {
        setState(() {
          _bannerItem = banner;
          _companyBanner = banner.companyBanner;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadAboutUs() async {
    final result = await food_Authservice.fetchAboutUsData(widget.vendorId);
    if (result != null && mounted) {
      print("🟩 About Us Images: ${result.allImages}");
      setState(() {
        _aboutUsModel = result;
        _images
          ..clear()
          ..addAll(result.allImages);
      });
    }
  }

  Future<void> _loadVendorTiming(int vendorId) async {
    final timing = await food_Authservice.fetchVendorTimingForToday(
      widget.vendorId,
    );

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

            // Gallery Section
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _companyBanner != null && _companyBanner!.isNotEmpty
                      ? _getImageProvider(_companyBanner!)
                      : const AssetImage('assets/gallery-img-1.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10, // above social icons
              left: 0,
              right: 0,
              child: Center(child: _buildInfoAndActionsSection(context)),
            ),

            // Restaurant name and established year
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _bannerItem?.companyName ?? "Loading...",
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

            // Social icons
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(child: _buildSocialIconsRow(_bannerItem)),
            ),
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
          // 🕒 Timings in Column (Start + End)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTimingInfo(context)],
          ),

          const SizedBox(width: 12),

          // 🎯 Action Buttons in Row
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
                    style: TextStyle(color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

          // Row for Mission and Vision
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // MISSION
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

              // VISION
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
    if (_images.isEmpty) {
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
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 80,
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
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

  Widget _buildSocialIconsRow(grocery_Banner? banner) {
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
        ],
      ),
    );
  }
}

class MenuFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final int selectedFilterIndex;
  final Function(int) onTabChange;
  final int vendorId;
  final String? orderType;

  const MenuFilterBar({
    super.key,
    required this.isVeg,
    required this.onToggle,
    required this.onTabChange,
    required this.vendorId,
    this.orderType,
    this.selectedFilterIndex = 0,
  });

  @override
  State<MenuFilterBar> createState() => _MenuFilterBarState();
}

class _MenuFilterBarState extends State<MenuFilterBar> {
  late bool _isVeg;
  late int _selectedIndex;
  int? userId;
  String planType = "";
  String orderType = "";

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
    _selectedIndex = widget.selectedFilterIndex;
    _initializeData();
  }

  // 🔹 Load both prefs + plan together
  Future<void> _initializeData() async {
    await _loadPrefs();

    final vendorIdInt = widget.vendorId;
    await _loadPlan(vendorIdInt);

    print(
      "✅ Initialized → userId: $userId, orderType: $orderType, planType: $planType",
    );
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
      orderType =
          prefs.getString('orderType')?.trim().toUpperCase() ?? "TABLE_DINE_IN";
      planType = prefs.getString('planType')?.trim().toUpperCase() ?? "";
    });
  }

  Future<void> _loadPlan(int vendorId) async {
    try {
      print("🔹 Fetching plan for vendorId: $vendorId");
      final plan = await food_Authservice.fetchUserPlanForVendor(vendorId);
      if (!mounted) return;
      setState(() => planType = (plan ?? "").trim().toUpperCase());
      print("✅ Plan Loaded → $planType");
    } catch (e) {
      print("❌ Error fetching plan: $e");
    }
  }

  void _handleTabChange(int index) {
    setState(() => _selectedIndex = index);
    widget.onTabChange(index);
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Still loading
    if (planType.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Loading your subscription plan..."),
          ],
        ),
      );
    }

    final normalizedPlan = planType.trim().toUpperCase();
    final normalizedOrderType = orderType.trim().toUpperCase();

    final showMenuTab = [
      "DINE_IN",
      "TAKEAWAY",
      "DELIVERY",
    ].contains(normalizedOrderType);
    final showTableTab =
        normalizedOrderType == "TABLE_DINE_IN" && normalizedPlan == "PREMIUM";

    // print("🧩 normalizedPlan: $normalizedPlan, orderType: $normalizedOrderType");
    // print("✅ showMenuTab: $showMenuTab, showTableTab: $showTableTab");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (!showMenuTab && showTableTab)
            _selectedIndex = 1;
          else if (showMenuTab && !showTableTab)
            _selectedIndex = 0;
        });
      }
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 10),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlutterSwitch(
                width: 85,
                height: 40,
                toggleSize: 30,
                borderRadius: 20,
                value: _isVeg,
                showOnOff: true,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
                activeText: "Veg",
                inactiveText: "Non-Veg",
                onToggle: (val) {
                  setState(() => _isVeg = val);
                  widget.onToggle(val);
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showMenuTab) _buildTab("Menu", 0),
                    if (showTableTab) _buildTab("Table", 1),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          _selectedIndex == 0
              ? MenuTabContent(
                  isVeg: _isVeg,
                  vendorId: widget.vendorId,
                  selectedVendorId: widget.vendorId,
                  favoriteButton: (dish) => FavoriteButton(dish: dish),
                  cartButton: (dish) => CartButton(
                    dishId: dish.dishId,
                    balanceQuantity: dish.balanceQuantity ?? 0,
                  ),
                  isOutOfStock: (dish) =>
                      dish.stock?.toLowerCase() != "in stock",
                )
              : showTableTab
              ? TableTabContent(vendorId: widget.vendorId)
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _handleTabChange(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuTabContent extends StatefulWidget {
  final bool isVeg;
  final int vendorId;
  final int selectedVendorId;
  final favoriteButton;
  final Widget Function(CategoryDish dish) cartButton;
  final bool Function(Dish) isOutOfStock;
  final int? parentId;

  const MenuTabContent({
    super.key,
    required this.isVeg,
    required this.vendorId,
    required this.selectedVendorId,
    required this.favoriteButton,
    required this.cartButton,
    required this.isOutOfStock,
    this.parentId,
  });

  @override
  State<MenuTabContent> createState() => _MenuTabContentState();
}

class _MenuTabContentState extends State<MenuTabContent> {
  int selectedIndex = 0;
  int? selectedParentId;
  late Future<List<CategoryDish>> _categoriesFuture;
  List<CategoryDish> categories = [];
  bool _isLoading = true;
  List<Dish> _allDishes = [];

  @override
  void initState() {
    super.initState();
    // _loadCategories();
    _loadMenu();
    // _categoriesFuture = food_Authservice.fetchCategories(widget.vendorId);
  }

  // Future<void> _loadCategories() async {
  //   try {
  //     // 1️⃣ Fetch all categories for this vendor
  //     List<CategoryDish> allCategories = await food_Authservice.fetchCategories(
  //       widget.vendorId,
  //     );
  //
  //     // 2️⃣ Filter only top-level categories (parentId = 0)
  //     if (mounted) {
  //       setState(() {
  //         categories = allCategories.where((c) => c.parentId == 0).toList();
  //       });
  //     }
  //   } catch (e) {
  //     print("Error loading categories: $e");
  //   }
  // }
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80.w,
          height: 550.h,
          margin: EdgeInsets.only(left: 10.w, top: 5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: FutureBuilder<List<CategoryDish>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories found'));
              }
              final categories = snapshot.data!
                  .where((dish) => dish.parentId == 0)
                  .toList();
              return ListView.builder(
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // 🔹 "All Items" tile
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedParentId = 0; // show all
                          selectedIndex = 0;
                        });
                      },
                      child: Container(
                        height: 100.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? const Color(0xFFB15DC6)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25.r,
                              backgroundImage: const AssetImage(
                                "assets/allitems.jpg",
                              ),
                            ),
                            SizedBox(height: 5.h),
                            const Text("All Items"),
                          ],
                        ),
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  return Sidebaritem(
                    image:
                        (category.dishImage != null &&
                            category.dishImage!.isNotEmpty)
                        ? NetworkImage(category.dishImage!)
                        : const AssetImage("assets/default.png")
                              as ImageProvider,
                    title: category.dishName ?? '',
                    onTap: () {
                      setState(() {
                        selectedParentId = category.dishId;
                        selectedIndex = index;
                      });
                    },
                    isSelected: index == selectedIndex,
                    color: index == selectedIndex
                        ? const Color(0xFFB15DC6)
                        // ignore: deprecated_member_use
                        : Colors.grey.withOpacity(0.4),
                    textStyle: TextStyle(
                      color: index == selectedIndex
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                },
              );
            },
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 5.w, top: 8.h),
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                DishGridTab(
                  parentId: selectedParentId,
                  vendorId: widget.selectedVendorId,
                  filterTag: widget.isVeg ? "veg" : "non_veg",
                  emptyMessage: widget.isVeg
                      ? "No Veg dishes found."
                      : "No Non-Veg dishes found.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DishGridTab extends StatefulWidget {
  final int? parentId;
  final int vendorId;
  final String filterTag;
  final String emptyMessage;

  const DishGridTab({
    super.key,
    this.parentId,
    required this.vendorId,
    required this.filterTag,
    required this.emptyMessage,
  });

  @override
  _DishGridTabState createState() => _DishGridTabState();
}

class _DishGridTabState extends State<DishGridTab> {
  late Future<List<Dish>> dishes;

  bool _isLoading = true;
  List<Dish> _allDishes = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void didUpdateWidget(DishGridTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parentId != oldWidget.parentId) {
      _loadDishes();
    }
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);

    final allDishes = await food_Authservice.getAllDishes(widget.vendorId);

    if (!mounted) return;

    List<Dish> filteredDishes;

    // ✅ If parentId is provided → filter
    if (widget.parentId != null && widget.parentId! > 0) {
      filteredDishes = allDishes
          .where((dish) => dish.parentId == widget.parentId)
          .toList();
    } else {
      // ✅ No parentId → show all dishes
      filteredDishes = allDishes;
    }

    setState(() {
      _allDishes = filteredDishes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dish>>(
      future: dishes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(widget.emptyMessage));
        }

        final filteredDishes = snapshot.data!
            .where(
              (dish) =>
                  dish.tag?.toLowerCase() == widget.filterTag.toLowerCase() &&
                  (dish.stockQuantity ?? 0) > 0,
            )
            .toList();

        if (filteredDishes.isEmpty) {
          return Center(child: Text(widget.emptyMessage));
        }
        final screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = screenWidth < 600
            ? 2
            : screenWidth < 900
            ? 3
            : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 25,
            childAspectRatio: screenWidth < 600 ? 0.59 : 0.75,
          ),
          itemCount: filteredDishes.length,
          itemBuilder: (context, index) {
            final dish = filteredDishes[index];
            return ProductCard(
              imageWidget: _buildImage(dish.dishImage),
              name: dish.dishName ?? '',
              price: "₹${dish.price}",
              description: dish.description ?? '',
              effectivePrice: "₹${dish.effectivePrice}",
              favoriteButton: FavoriteButton(dish: dish),
              cartButton: CartButton(
                dishId: dish.dishId,
                balanceQuantity: dish.balanceQuantity,
              ),
              isOutOfStock: (dish.balanceQuantity) == 0,
              balanceQuantity: dish.balanceQuantity,
              discount: dish.discount, // ✅ added
            );
          },
        );
      },
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    return const Icon(Icons.image_not_supported);
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
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isOutOfStock,
      child: Opacity(
        opacity: isOutOfStock ? 0.5 : 1.0,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // 🔥 auto height
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: double.infinity, // full width
                                      height: 180,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: imageWidget, // your product image
                                    ),
                                  ),
                                  if (discount > 0)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          "$discount% OFF", // e.g., "20% OFF"
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Product Name
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 10),

                              // Price & Add to Cart
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        effectivePrice,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        price, // discounted price
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 13,

                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Cart Button
                                  cartButton,
                                ],
                              ),

                              const SizedBox(height: 15),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: imageWidget,
                          ),
                          if (discount > 0)
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "$discount% OFF",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    effectivePrice,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    price,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,

                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              favoriteButton,
                            ],
                          ),
                        ),
                      ],
                    ),

                    Center(child: cartButton),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
            if (balanceQuantity <= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 50),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TableTabContent extends StatefulWidget {
  final int vendorId;
  const TableTabContent({super.key, required this.vendorId});

  @override
  State<TableTabContent> createState() => _TableTabContentState();
}

class _TableTabContentState extends State<TableTabContent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noofpeople = TextEditingController();
  TimeOfDay? selectedTime;
  List<Map<String, String>> submissions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();
    noofpeople.dispose();
    super.dispose();
  }

  void _showScheduleOrderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Schedule Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTextField(nameController, "Name"),
                const SizedBox(height: 12),
                _buildTextField(
                  phoneController,
                  "Phone Number",
                  TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildDateField(bottomSheetContext),
                const SizedBox(height: 12),
                _buildTimeField(bottomSheetContext),
                const SizedBox(height: 12),
                _buildTextField(
                  noofpeople,
                  "No of people",
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildSubmitButton(bottomSheetContext),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType? keyboardType,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime firstAllowedDate = today;
    DateTime lastAllowedDate = today.add(Duration(days: 365));
    return TextField(
      controller: dateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Select Date",
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: firstAllowedDate,
          lastDate: lastAllowedDate,
        );
        if (pickedDate != null) {
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextField(
      controller: timeController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Select Time",
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            selectedTime = picked;
            timeController.text =
                "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                await _submitBooking(context);
                setState(() => _isLoading = false);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Submit"),
      ),
    );
  }

  Future<void> _submitBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final vendorId = widget.vendorId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    if (!_areFieldsValid()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final success = await food_Authservice.submitBooking(

      vendorId: vendorId,
      guestName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      bookingDate: dateController.text.trim(),
      startTime:
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00",
      capacity: int.tryParse(noofpeople.text.trim()) ?? 0,
    );

    if (success) {
      // ✅ Close bottom sheet
      Navigator.pop(context);

      // ✅ Clear input fields
      nameController.clear();
      phoneController.clear();
      dateController.clear();
      noofpeople.clear();

      // ✅ Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Booking submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to submit booking")),
      );
    }
  }

  bool _areFieldsValid() {
    return nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty &&
        noofpeople.text.trim().isNotEmpty &&
        selectedTime != null;
  }

  Future<void> _bookNow(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController();
        final phoneCtrl = TextEditingController();
        final capacityCtrl = TextEditingController();

        return AlertDialog(
          title: const Text("Book Now"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameCtrl, "Name"),
              const SizedBox(height: 8),
              _buildTextField(phoneCtrl, "Phone", TextInputType.phone),
              const SizedBox(height: 8),
              _buildTextField(
                capacityCtrl,
                "No of People",
                TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _isLoading
                  ? null // Disable button while loading
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      await _submitBookNow(
                        context,
                        nameCtrl,
                        phoneCtrl,
                        capacityCtrl,
                      );

                      setState(() {
                        _isLoading = false;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitBookNow(
    BuildContext context,
    TextEditingController nameCtrl,
    TextEditingController phoneCtrl,
    TextEditingController capacityCtrl,
  ) async {
    final guestName = nameCtrl.text.trim();
    final phoneNumber = phoneCtrl.text.trim();
    final capacity = int.tryParse(capacityCtrl.text.trim()) ?? 0;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final vendorId = widget.vendorId;

    if (guestName.isEmpty || phoneNumber.isEmpty || capacity == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final success = await food_Authservice.bookNow(

      vendorId: vendorId,
      guestName: guestName,
      phoneNumber: phoneNumber,
      capacity: capacity,
    );

    Navigator.pop(context); // close dialog first

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Booking successful")));
      setState(() {}); // refresh lists
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Booking failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton("Book Now", () => _bookNow(context)),
            _buildActionButton("Schedule Order", _showScheduleOrderDialog),
          ],
        ),
        const SizedBox(height: 20),
        _buildTabs(),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB15DC6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 👈 circular radius
        ),
      ),
      child: Text(text),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFFB15DC6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFB15DC6),
            tabs: [
              Tab(text: "Waiting List"),
              Tab(text: "Confirmed"),
            ],
          ),
          SizedBox(
            height: 1300,
            child: TabBarView(
              children: [_buildWaitingList(), _buildConfirmedList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingList() {
    return FutureBuilder<List<WaitingItem>>(
      future: food_Authservice.fetchWaitingList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No waiting list found"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildWaitingItem(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildWaitingItem(WaitingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.types,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Name: ${item.guestName}"),
                  Text("Phone: ${item.phoneNumber}"),
                  Text("Date: ${item.bookingDate}"),
                  Text("Time: ${item.requestTime}"),
                  Text("Capacity: ${item.capacity}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmedList() {
    return FutureBuilder<List<ConfirmedList>>(
      future: food_Authservice.fetchConfirmedList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No confirmed list found"));
        }

        // Copy and sort the list
        final sortedItems = List<ConfirmedList>.from(snapshot.data!);
        sortedItems.sort((a, b) {
          bool aCompleted = a.arrivalStatus.toUpperCase() == "COMPLETED";
          bool bCompleted = b.arrivalStatus.toUpperCase() == "COMPLETED";

          if (aCompleted == bCompleted) return 0; // same status
          return aCompleted ? 1 : -1; // completed goes to bottom
        });

        return ListView.builder(
          itemCount: sortedItems.length,
          itemBuilder: (context, index) =>
              ConfirmedListCard(item: sortedItems[index]),
        );
      },
    );
  }
}

class ConfirmedListCard extends StatefulWidget {
  final ConfirmedList item;

  const ConfirmedListCard({super.key, required this.item});

  @override
  State<ConfirmedListCard> createState() => _ConfirmedListCardState();
}

class _ConfirmedListCardState extends State<ConfirmedListCard> {
  bool isArrived = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isCompleted = item.arrivalStatus.toUpperCase() == "COMPLETED";

    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0, // fade completed
      child: IgnorePointer(
        ignoring: isCompleted, // disable taps
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.types,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Table No: ${item.code}"),
                          Text("Name: ${item.guestName}"),
                          Text("Phone: ${item.phoneNumber}"),
                          Text("Date: ${item.bookingDate}"),
                          Text("Capacity: ${item.capacity}"),
                          Text("Status: ${item.arrivalStatus}"),
                        ],
                      ),
                    ),
                    _buildArrivalButton(),
                  ],
                ),
                _buildArrivalSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalButton() {
    return ElevatedButton(
      onPressed: () async {
        await food_Authservice.sendArrivalStatus(widget.item.seatingId);
        setState(() => isArrived = !isArrived);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isArrived ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(isArrived ? "Not Arrived" : "Arrived"),
    );
  }

  Widget _buildArrivalSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ClipRect(
        child: Align(
          heightFactor: isArrived ? 1.0 : 0.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isArrived ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Arrived",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () => _navigateToTableMenu(),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //   ),
                    //   child: const Text("Add Items"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _navigateToTableMenu() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => tablemenuscreen(
  //         vendorId: widget.item.vendorId,
  //         seatingId: widget.item.seatingId,
  //       ),
  //     ),
  //   );
  // }
}

class Sidebaritem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color color;
  final TextStyle textStyle;
  final ImageProvider? image;

  const Sidebaritem({
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 100.h,
          width: MediaQuery.of(context).size.height * 0.28,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: color.withOpacity(0.3),
                      blurRadius: 12.r,
                      spreadRadius: 3.r,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: image != null
                      ? Image(
                          image: image!,
                          fit: BoxFit.cover,
                          width: 60.w,
                          height: 60.h,
                        )
                      : Icon(icon, size: 40.sp, color: Colors.black),
                ),
              ),
              SizedBox(height: 5.h),
              Flexible(
                child: AutoSizeText(
                  title,
                  style: textStyle.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
