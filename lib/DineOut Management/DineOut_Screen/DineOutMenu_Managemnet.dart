import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/Api/food_authservice.dart';
import 'package:maamaaspartner/food&beverages/premium%20additems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CateringModels/package_model.dart';
import '../../Catering_authservices/Auth_Services.dart';
import '../../Models/food&beverages/dish.dart';
import '../../Models/food&beverages/orders_model.dart';
import '../../caterings/AddPackage.dart';
import '../../caterings/UpdatePackagePage.dart';
import '../../standard Menu/screens/standard_menu_screen.dart';
import '../../widgets_helper/Home_screen_1.dart';
import '../../widgets_helper/food/utils.dart';
import '../DineOut_Services/DineOutAuthService.dart';
import 'DineOutCart_Screen.dart' hide OrderType;
import 'TableCart/screens/table_cart_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
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

class PendingItem {
  final int itemId;
  final int dishId;
  int quantity;
  int confirmedQty;

  PendingItem({
    required this.itemId,
    required this.dishId,
    required this.quantity,
    required this.confirmedQty,
  });

  int get newQty => (quantity - confirmedQty).clamp(0, quantity);
}

class PendingCartItems {
  static final Map<int, Map<int, PendingItem>> _store = {};

  static void set({
    required int bookingId,
    required int itemId,
    required int dishId,
    required int quantity,
    required int confirmedQty,
  }) {
    _store[bookingId] ??= {};
    _store[bookingId]![itemId] = PendingItem(
      itemId: itemId,
      dishId: dishId,
      quantity: quantity,
      confirmedQty: confirmedQty,
    );
  }

  static void remove({required int bookingId, required int itemId}) {
    _store[bookingId]?.remove(itemId);
  }

  static List<PendingItem> getAll(int bookingId) {
    return _store[bookingId]?.values.toList() ?? [];
  }

  static void clearBooking(int bookingId) {
    _store.remove(bookingId);
  }

  static bool has(int bookingId) {
    return (_store[bookingId]?.isNotEmpty) ?? false;
  }
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class DineOutMenu_Managemnet extends StatefulWidget {
  final int? bookingId;
  final String? tableCode;
  final int? userId;

  const DineOutMenu_Managemnet({
    super.key,
    this.bookingId,
    this.tableCode,
    this.userId,
  });

  @override
  State<DineOutMenu_Managemnet> createState() => _Menu_ManagemnetState();
}

class _Menu_ManagemnetState extends State<DineOutMenu_Managemnet>
    with TickerProviderStateMixin {
  int selectedTabIndex = 0;
  VegFilter _vegFilter = VegFilter.all;
  OrderType selectedOrderType = OrderType.DINE_IN;
  int _cartItemCount = 0;
  MenuVertical _selectedVertical = MenuVertical.food;
  int selectedCategoryIndex = 0;
  int? selectedParentId;
  bool _showAdded = false;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  bool _appBarVisible = true;
  double _lastScrollOffset = 0;

  Future<List<Dish>>? _categoriesFuture;
  Future<List<Dish>>? _dishFuture;
  List<Dish> _cachedDishes = [];

  late AnimationController _fabAnimController;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    // // ── KEY DEBUG: confirm userId arrives here ────────────────────────────
    // debugPrint('📦 bookingId: ${widget.bookingId}');
    // debugPrint('🏷️ tableCode: ${widget.tableCode}');
    // debugPrint('👤 userId from widget: ${widget.userId}');

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
    _scrollController.addListener(_onScroll);

    _categoriesFuture = food_authservice.fetchParentCategories();
    _dishFuture = food_authservice
        .fetchFilteredDishes(searchQuery: '', filterByMenuStatus: true)
        .then((list) {
          _cachedDishes = list;
          return list;
        });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final scrollingDown = offset > _lastScrollOffset + 2;
    final scrollingUp = offset < _lastScrollOffset - 2;
    _lastScrollOffset = offset;
    if (scrollingDown && _appBarVisible) {
      setState(() => _appBarVisible = false);
    } else if (scrollingUp && !_appBarVisible) {
      setState(() => _appBarVisible = true);
    }
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
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      final bookingId = widget.bookingId ?? 0;

      final cart = await DineoutAuthService.fetchCartByBooking(
        vendorId: vendorId,
        bookingId: bookingId,
      );

      if (cart != null && mounted) {
        final count = cart.cartItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        setState(() => _cartItemCount = count);
        Utils.itemCount.value = count;
        if (count > 0) _fabAnimController.forward();
      } else {
        if (mounted) setState(() => _cartItemCount = 0);
        Utils.itemCount.value = 0;
      }
    } catch (e) {
      // debugPrint('Error loading cart count: $e');
      if (mounted) setState(() => _cartItemCount = 0);
      Utils.itemCount.value = 0;
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

  // ─── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      child: Row(
        children: [
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
          SizedBox(width: 10.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildVegChip(
                    label: 'Veg',
                    activeColor: AppColors.vegGreen,
                    isActive: _vegFilter == VegFilter.veg,
                    onTap: () {
                      setState(() {
                        _vegFilter = _vegFilter == VegFilter.veg
                            ? VegFilter.all
                            : VegFilter.veg;
                      });
                      _refreshDishFuture();
                    },
                  ),
                  SizedBox(width: 8.w),
                  _buildVegChip(
                    label: 'Non-Veg',
                    activeColor: AppColors.nonVegRed,
                    isActive: _vegFilter == VegFilter.nonVeg,
                    onTap: () {
                      setState(() {
                        _vegFilter = _vegFilter == VegFilter.nonVeg
                            ? VegFilter.all
                            : VegFilter.nonVeg;
                      });
                      _refreshDishFuture();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StandardMenuScreen()),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegChip({
    required String label,
    required Color activeColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFE66D33),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  // ─── Cart Button ──────────────────────────────────────────────────────────
  Widget _buildCartButton() {
    if (_cartItemCount == 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final vendorId = prefs.getInt('vendorId') ?? 0;
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TableCartScreen(
                vendorId: vendorId,
                bookingId: widget.bookingId,
                tableCode: widget.tableCode ?? '',
                seatingId: widget.bookingId,
                authToken: '',
                onPaymentSuccess: () => Navigator.pop(context),
                onBack: () => Navigator.pop(context),
              ),
            ),
          ).then((_) => _loadCartCount());
        },
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
                widget.tableCode != null && widget.tableCode!.isNotEmpty
                    ? 'Table ${widget.tableCode}  •  $_cartItemCount ${_cartItemCount == 1 ? 'item' : 'items'}'
                    : 'View Cart  •  $_cartItemCount ${_cartItemCount == 1 ? 'item' : 'items'}',
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

  // ─── Build ────────────────────────────────────────────────────────────────
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
                _buildAppBar(),
                Divider(color: AppColors.border, height: 1),
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
                    _buildSearchBarWithOrderType(),
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

  Widget _buildDishListView(AsyncSnapshot<List<Dish>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (snapshot.hasError) {
      return _ErrorState(message: 'Error: ${snapshot.error}');
    }

    List<Dish> list = snapshot.data ?? [];

    final enabledParentIds = _cachedDishes
        .where(
          (d) => d.parentId == 0 && (d.menuStatus?.toLowerCase() == 'enable'),
        )
        .map((d) => d.dishId)
        .toSet();

    list = list.where((d) => d.parentId != null && d.parentId != 0).toList();

    if (enabledParentIds.isNotEmpty) {
      list = list.where((d) => enabledParentIds.contains(d.parentId)).toList();
    }

    if (_vegFilter == VegFilter.veg) {
      list = list.where((d) => d.tag?.toLowerCase() == 'veg').toList();
    } else if (_vegFilter == VegFilter.nonVeg) {
      list = list
          .where(
            (d) =>
                d.tag?.toLowerCase() == 'non_veg' ||
                d.tag?.toLowerCase() == 'non-veg' ||
                (d.tag != null && d.tag!.toLowerCase() != 'veg'),
          )
          .toList();
    }

    if (selectedParentId != null && selectedParentId != 0) {
      list = list.where((d) => d.parentId == selectedParentId).toList();
    }

    if (list.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        message: 'No dishes found',
      );
    }

    list.sort((a, b) {
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
      itemCount: list.length,
      itemBuilder: (_, i) {
        final dish = list[i];
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
          key: ValueKey('dish_${dish.dishId}'),
          imageWidget: img,
          name: dish.dishName ?? '',
          price: '₹${dish.price}',
          description: dish.description ?? '',
          effectivePrice: '₹${dish.effectivePrice}',
          cartButton: CartButton(
            key: ValueKey('cart_${dish.dishId}'),
            dishId: dish.dishId ?? 0,
            orderType: selectedOrderType,
            balanceQuantity: dish.balanceQuantity,
            onCartUpdated: _loadCartCount,
            bookingId: widget.bookingId,
            tableCode: widget.tableCode,
            vendorId: null,
            userId: widget.userId ?? 0,
          ),
          isOutOfStock:
              dish.stock?.toLowerCase() == 'out_of_stock' ||
              dish.balanceQuantity <= 0,
        );
      },
    );
  }

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
                if (!snap.hasData || snap.data!.isEmpty)
                  return const SizedBox.shrink();
                final parents = snap.data!
                    .where(
                      (d) =>
                          d.parentId == 0 &&
                          (d.menuStatus?.toLowerCase() == 'enable'),
                    )
                    .toList();
                if (parents.isEmpty) return const SizedBox.shrink();
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
                    return _buildCatChip(
                      index: i,
                      name: cat.dishName ?? '',
                      imageUrl: cat.dishImage,
                      isSelected: selectedCategoryIndex == i,
                      onTap: () => onCategoryTap(i, cat.dishId),
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
                fontSize: 9.sp,
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

  Widget _buildSearchBarWithOrderType() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search dishes…',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.sp,
                  ),
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
                          onPressed: () => searchController.clear(),
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
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ],
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
      builder: (_) =>
          _ConfirmDialog(title: 'Delete Package', message: 'Are you sure?'),
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
    if (isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
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
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
                const Text(
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
                    const Text(
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
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              if (!snap.hasData || snap.data!.isEmpty)
                return _EmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No items',
                );
              final all = snap.data!;
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

// ─── Quantity Item ────────────────────────────────────────────────────────────
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
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              if (!snap.hasData || snap.data!.isEmpty)
                return _EmptyState(
                  icon: Icons.discount_outlined,
                  message: 'No items',
                );
              final all = snap.data!;
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

  @override
  void initState() {
    super.initState();
    _loadAll();
    searchController.addListener(_onSearch);
    selectedParentId = widget.parentId ?? 0;
  }

  void _onSearch() {
    final q = searchController.text.toLowerCase().replaceAll(' ', '');
    setState(() {
      localCategories = Utils.fetchedCategories
          .where(
            (d) => (d.dishName?.toLowerCase().replaceAll(' ', '') ?? '')
                .contains(q),
          )
          .toList();
    });
  }

  Future<void> _loadAll() async {
    Utils.fetchedCategories = await food_authservice.fetchDishes();
    setState(() => localCategories = List.from(Utils.fetchedCategories));
  }

  Future<void> _loadSubs(int parentId, String catName) async {
    final all = await food_authservice.fetchDishes();
    setState(() {
      subDishesMap[parentId] = all
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
            child: parents.isEmpty
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
                            children: const [
                              Icon(
                                Icons.image_outlined,
                                color: AppColors.textMuted,
                                size: 28,
                              ),
                              SizedBox(height: 4),
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

// ─── Sub Dish Tile ────────────────────────────────────────────────────────────
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
    final enabled = (dish.menuStatus ?? '').toLowerCase() == 'enable';
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
    final isEnabled = (dish.menuStatus ?? '').toLowerCase() == 'enable';
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

  const ProductCard({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.description,
    required this.effectivePrice,
    required this.cartButton,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    final orig = double.tryParse(price.replaceAll('₹', '')) ?? 0;
    final eff = double.tryParse(effectivePrice.replaceAll('₹', '')) ?? 0;
    final hasDiscount = eff < orig;

    return AbsorbPointer(
      absorbing: isOutOfStock,
      child: Opacity(
        opacity: isOutOfStock ? 0.55 : 1.0,
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
              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
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
}

// ─── Cart Button ──────────────────────────────────────────────────────────────
class CartButton extends StatefulWidget {
  final int dishId;
  final OrderType orderType;
  final int balanceQuantity;
  final Function()? onCartUpdated;
  final int? bookingId;
  final String? tableCode;
  final int? vendorId;
  final int userId;

  const CartButton({
    super.key,
    required this.dishId,
    required this.orderType,
    required this.balanceQuantity,
    this.onCartUpdated,
    this.bookingId,
    this.tableCode,
    this.vendorId,
    required this.userId,
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
  void didUpdateWidget(CartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dishId != widget.dishId) _loadQty();
  }

  @override
  void dispose() {
    Utils.itemCount.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted && !_isUpdating) _loadQty(showLoading: false);
  }

  // ── Get vendorId helper ───────────────────────────────────────────────────
  Future<int> _getVendorId() async {
    int vendorId = widget.vendorId ?? 0;
    if (vendorId == 0) {
      final prefs = await SharedPreferences.getInstance();
      vendorId = prefs.getInt('vendorId') ?? 0;
    }
    return vendorId;
  }

  // ── Load qty from server ──────────────────────────────────────────────────
  Future<void> _loadQty({bool showLoading = true}) async {
    if (_isUpdating) return;
    if (showLoading && mounted) setState(() => _isLoading = true);

    try {
      final vendorId = await _getVendorId();

      final cart = await DineoutAuthService.fetchCartByBooking(
        vendorId: vendorId,
        bookingId: widget.bookingId ?? 0,
      );

      if (!mounted) return;

      if (cart != null) {
        _cartId = cart.cartId;

        final matching = cart.cartItems
            .where((i) => i.dishId == widget.dishId)
            .toList();

        if (matching.isEmpty) {
          setState(() {
            itemCount = 0;
            _cartItemId = null;
          });
        } else {
          final totalQty = matching.fold(
            0,
            (sum, i) => sum + i.quantity,
          ); // ← fix
          final latestItem = matching.last;
          setState(() {
            itemCount = totalQty;
            _cartItemId = latestItem.itemId;
          });
        }
      } else {
        setState(() {
          itemCount = 0;
          _cartItemId = null;
          _cartId = null;
        });
      }
    } catch (e) {
      // debugPrint('Error loading qty: $e');
      if (mounted) {
        setState(() {
          itemCount = 0;
          _cartItemId = null;
          _cartId = null;
        });
      }
    } finally {
      if (showLoading && mounted) setState(() => _isLoading = false);
    }
  }

  // ── Add to cart ───────────────────────────────────────────────────────────
  Future<void> _addToCart() async {
    if (_isOutOfStock || _isUpdating) return;

    setState(() => _isLoading = true);
    _isUpdating = true;

    try {
      final int seatingId = widget.bookingId ?? 0;

      // debugPrint('🛒 _addToCart called');
      // debugPrint('🍽️ dishId: ${widget.dishId}');
      // debugPrint('👤 userId: ${widget.userId}');
      // debugPrint('🪑 seatingId: $seatingId');

      final cartData = await DineoutAuthService.addToCartByTable(
        vendorId: await _getVendorId(),
        bookingId: widget.bookingId ?? 0,
        tableCode: widget.tableCode ?? '',
        items: [
          {
            "dishId": widget.dishId,
            "quantity": 1,
          }
        ],
        userId: widget.userId,
      );
      // debugPrint('🛒 cartData response: $cartData');

      if (cartData != null && mounted) {
        // ✅ FIX: Parse cartItems correctly
        final List<dynamic> cartItems = cartData['cartItems'] ?? [];

        // Calculate total items in cart
        int totalItems = 0;
        int dishItemCount = 0;
        int? newItemId;

        for (var item in cartItems) {
          totalItems += (item['quantity'] as int? ?? 0);

          if (item['dishId'] == widget.dishId) {
            dishItemCount += (item['quantity'] as int? ?? 0);
            newItemId = item['itemId'] as int?;
          }
        }

        setState(() {
          itemCount = dishItemCount;
          if (newItemId != null) {
            _cartItemId = newItemId;
          }
        });

        Utils.itemCount.value = totalItems;
        widget.onCartUpdated?.call();
      }
    } catch (e) {
      // debugPrint('💥 Error adding to cart: $e');
    } finally {
      _isUpdating = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Remove from cart ──────────────────────────────────────────────────────
  Future<void> _removeFromCart() async {
    if (_cartItemId == null || _cartId == null) return;

    setState(() => _isLoading = true);
    _isUpdating = true;

    try {
      final vendorId = await _getVendorId();
      final int bookingId = widget.bookingId ?? 0;

      final ok = await DineoutAuthService.removeCartItem(
        itemId: _cartItemId!,
        vendorId: vendorId,
        bookingId: bookingId,
      );

      if (ok && mounted) {
        final newCount = itemCount - 1;
        setState(() {
          itemCount = newCount;
          if (newCount == 0) _cartItemId = null;
        });

        Utils.itemCount.value = (Utils.itemCount.value - 1).clamp(0, 999);
        widget.onCartUpdated?.call();

        if (newCount > 0) await _loadQty(showLoading: false);
      } else {
        await _loadQty(showLoading: false);
      }
    } catch (e) {
      // debugPrint('💥 Error removing cart item: $e');
      await _loadQty(showLoading: false);
    } finally {
      _isUpdating = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
        onTap: _isOutOfStock || _isUpdating ? null : _addToCart,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isOutOfStock ? AppColors.bg : AppColors.accentLight,
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
            onPressed: _isUpdating ? null : _removeFromCart,
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
                    if (itemCount < widget.balanceQuantity ||
                        widget.balanceQuantity == -1) {
                      _addToCart();
                    }
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle Switches ──────────────────────────────────────────────────────────
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

