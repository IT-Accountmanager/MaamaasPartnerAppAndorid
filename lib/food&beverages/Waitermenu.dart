import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/Api/food_authservice.dart';
import 'package:maamaaspartner/food&beverages/premium%20additems.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/food&beverages/dish.dart';
import '../Models/food&beverages/orders_model.dart';
import '../Models/food&beverages/waiter_booking_model.dart';
import '../widgets_helper/food/utils.dart';
import 'Waiter_CartButton.dart';

class Menu_Waiter extends StatefulWidget {
  final WaiterBooking booking;

  const Menu_Waiter({super.key, required this.booking});

  @override
  State<Menu_Waiter> createState() => _Menu_ManagemnetState();
}

class _Menu_ManagemnetState extends State<Menu_Waiter> {
  int selectedTabIndex = 0;
  bool isVeg = true;
  OrderType selectedOrderType = OrderType.TABLE_DINE_IN;
  int? _cartId;

  final List<String> tabTitles = ['Menu'];

  void onTabSelect(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  void onOrderTypeSelect(OrderType orderType) {
    setState(() {
      selectedOrderType = orderType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8), // Added padding
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centered vertically
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabTitles.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedTabIndex == index;
                        return GestureDetector(
                          onTap: () => onTabSelect(index),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ), // Reduced vertical margin
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFB15DC6)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFB15DC6)
                                    : Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tabTitles[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),

            if (selectedTabIndex == 0) _buildMenuTopBar(),

            Expanded(child: _buildSelectedTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return MenuTab(
          isVeg: isVeg,
          orderType: selectedOrderType,
          booking: widget.booking,
        );
      case 1:
        return AddItemTab(isVeg: isVeg);
      case 2:
        return ItemQuantityTab();
      case 3:
        return DiscountTab();
      default:
        return MenuTab(
          isVeg: isVeg,
          orderType: selectedOrderType,
          booking: widget.booking,
        );
    }
  }

  Widget _buildMenuTopBar() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          VegNonVegToggle(
            isVeg: isVeg,
            onToggle: (val) {
              setState(() {
                isVeg = val;
              });
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildOrderTypeToggle(
                    OrderType.DINE_IN,
                    'TABLE_DINE_IN',
                    selectedOrderType == OrderType.DINE_IN,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeToggle(OrderType type, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onOrderTypeSelect(type),
      child: Container(
        height: 36,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFB15DC6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Color(0xFFB15DC6) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.grey[300],
                border: Border.all(
                  color: isSelected ? Color(0xFFB15DC6) : Colors.grey[500]!,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB15DC6),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuTab extends StatefulWidget {
  final bool isVeg;
  final OrderType orderType;
  final WaiterBooking booking;

  const MenuTab({
    super.key,
    required this.isVeg,
    required this.orderType,
    required this.booking,
  });

  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  bool isDrawerOpen = false;
  int selectedIndex = 0;
  int? selectedParentId;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Dish> categories = [];
  int? _cartId;

  @override
  void initState() {
    super.initState();
    _initializeCartForBooking();
    _loadCategories();
  }

  Future<void> _initializeCartForBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get vendorId from SharedPreferences (set in WaiterBookingsPage)
      final vendorId = prefs.getInt('vendorId') ?? 1;
      // Use seatingId from booking object
      final seatingId = widget.booking.seatingId ?? 0;

      if (vendorId == null || seatingId == null) {
        debugPrint("❌ VendorId or SeatingId is null");
        debugPrint("VendorId from prefs: $vendorId");
        debugPrint("SeatingId from booking: $seatingId");
        return;
      }

      // Save context for cart operations
      await prefs.setInt('vendorId', vendorId);
      await prefs.setInt('seatingId', seatingId);

      debugPrint("✅ Stored seatingId: $seatingId, vendorId: $vendorId");

      // Initialize or fetch existing cart
      final cart = await food_authservice.fetch_Cart();
      if (cart != null) {
        setState(() {
          _cartId = cart.cartId;
        });
      }

      debugPrint("✅ Cart initialized for booking: $_cartId");
    } catch (e) {
      debugPrint("❌ Error initializing cart: $e");
    }
  }

  Future<void> _loadCategories() async {
    final result = await food_authservice.fetchParentCategories();
    setState(() {
      categories = result;
    });
  }

  void onCategoryTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for dishes...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase().replaceAll(' ', '');
                  });
                },
              ),
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.20,
                  margin: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: _buildCategorySidebar(),
                ),

                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w, top: 5.h),
                    padding: EdgeInsets.only(left: 1, right: 1, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return FutureBuilder<List<Dish>>(
      future: food_authservice.fetchParentCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        List<Dish> categories = snapshot.data!
            .where((dish) => dish.parentId == 0)
            .toList();

        categories.sort((a, b) {
          final aOut =
              a.balanceQuantity <= 0 || a.stock?.toLowerCase() != "in_stock";
          final bOut =
              b.balanceQuantity <= 0 || b.stock?.toLowerCase() != "in_stock";
          if (aOut == bOut) return 0;
          return aOut ? 1 : -1;
        });

        List<Dish> filteredCategories = categories;
        if (searchQuery.isNotEmpty) {
          filteredCategories = categories
              .where(
                (category) => (category.dishName ?? '')
                    .toLowerCase()
                    .replaceAll(' ', '')
                    .contains(searchQuery),
              )
              .toList();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          itemCount: filteredCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedParentId = 0;
                    selectedIndex = 0;
                  });
                },
                child: Container(
                  height: 100.h,
                  width: 80.w,
                  padding: EdgeInsets.all(3.w),
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
                          'assets/allitems.jpg',
                        ),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "All Items",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final dish = filteredCategories[index - 1];
            return Sidebaritem(
              image: (dish.dishImage != null && dish.dishImage!.isNotEmpty)
                  ? (dish.dishImage!.startsWith('http')
                        ? NetworkImage(dish.dishImage!)
                        : MemoryImage(base64Decode(dish.dishImage!))
                              as ImageProvider)
                  : null,
              title: dish.dishName ?? '',
              onTap: () {
                setState(() {
                  selectedParentId = dish.dishId;
                  selectedIndex = index;
                });
              },
              isSelected: index == selectedIndex,
              color: index == selectedIndex
                  ? const Color(0xFFB15DC6)
                  : Colors.grey.withOpacity(0.4),
              textStyle: TextStyle(
                color: index == selectedIndex ? Colors.white : Colors.black,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (selectedParentId == 0) {
      return AllItemsTab(
        orderType: widget.orderType,
        searchQuery: searchQuery,
        isVegFilter: widget.isVeg,
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            widget.isVeg
                ? VegTab(
                    parentId: selectedParentId,
                    orderType: widget.orderType,
                    searchQuery: searchQuery,
                  )
                : NonVegTab(
                    parentId: selectedParentId,
                    orderType: widget.orderType,
                    filterTag: widget.isVeg ? "veg" : "non_veg",
                    searchQuery: searchQuery,
                  ),
          ],
        ),
      );
    }
  }
}

class AllItemsTab extends StatefulWidget {
  final OrderType orderType;
  final String searchQuery;
  final bool isVegFilter;

  const AllItemsTab({
    super.key,
    required this.orderType,
    required this.searchQuery,
    required this.isVegFilter,
  });

  @override
  _AllItemsTabState createState() => _AllItemsTabState();
}

class _AllItemsTabState extends State<AllItemsTab> {
  late Future<List<Dish>> dishes;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void didUpdateWidget(covariant AllItemsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _loadDishes();
    }
  }

  void _loadDishes() {
    setState(() {
      dishes = food_authservice.fetchFilteredDishes(
        searchQuery: widget.searchQuery,
        filterByMenuStatus: true,
      );
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
          return const Center(child: Text('No dishes available.'));
        }

        List<Dish> filteredDishes = snapshot.data!;

        if (widget.isVegFilter) {
          filteredDishes = filteredDishes
              .where((dish) => dish.tag?.toLowerCase() == 'veg')
              .toList();
        }

        if (filteredDishes.isEmpty) {
          return const Center(child: Text('No dishes found.'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.63,
          ),
          itemCount: filteredDishes.length,
          itemBuilder: (context, index) {
            Dish dish = filteredDishes[index];
            Widget imageWidget;
            if (dish.dishImage != null && dish.dishImage!.isNotEmpty) {
              imageWidget = Image.network(
                dish.dishImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              );
            } else {
              imageWidget = const Icon(Icons.image_not_supported, size: 50);
            }

            return ProductCard(
              imageWidget: imageWidget,
              name: dish.dishName ?? '',
              price: "₹${dish.price}",
              description: dish.description ?? '',
              effectivePrice: "₹${dish.effectivePrice}",
              Waiter_CartButton: Waiter_CartButton(
                dishId: dish.dishId ?? 0,
                orderType: widget.orderType,
                balanceQuantity: dish.balanceQuantity,
              ),
              isOutOfStock:
                  dish.stock?.toLowerCase() == 'out_of_stock' ||
                  dish.balanceQuantity <= 0,
            );
          },
        );
      },
    );
  }
}

class ItemQuantityTab extends StatefulWidget {
  @override
  _ItemQuantityTabState createState() => _ItemQuantityTabState();
}

class _ItemQuantityTabState extends State<ItemQuantityTab> {
  List<Dish> localCategories = [];
  final Map<int, bool> expandedMap = {};
  TextEditingController searchController = TextEditingController();

  String normalizeString(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadCategories() async {
    localCategories = await food_authservice.fetchDishes();
    setState(() {});
  }

  Future<void> refreshList() async {
    await _loadCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Dish>>(
            future: food_authservice.fetchDishes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading items'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories found'));
              }

              final allDishes = snapshot.data!;
              final normalizedSearchQuery = normalizeString(
                searchController.text,
              );

              List<Dish> parentCategories = allDishes
                  .where((dish) => dish.parentId == 0)
                  .where((parentCategory) {
                    if (searchController.text.isEmpty) {
                      return true;
                    }

                    final normalizedCategoryName = normalizeString(
                      parentCategory.dishName ?? '',
                    );
                    bool categoryMatches = normalizedCategoryName.contains(
                      normalizedSearchQuery,
                    );

                    bool childMatches = false;
                    final childItems = allDishes
                        .where((dish) => dish.parentId == parentCategory.dishId)
                        .toList();

                    if (childItems.isNotEmpty) {
                      childMatches = childItems.any((child) {
                        final normalizedChildName = normalizeString(
                          child.dishName ?? '',
                        );
                        return normalizedChildName.contains(
                          normalizedSearchQuery,
                        );
                      });
                    }

                    return categoryMatches || childMatches;
                  })
                  .toList();

              if (searchController.text.isNotEmpty &&
                  parentCategories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No items found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                itemCount: parentCategories.length,
                itemBuilder: (context, index) {
                  final parentCategory = parentCategories[index];

                  expandedMap[parentCategory.dishId!] =
                      expandedMap[parentCategory.dishId!] ?? true;

                  List<Dish> childItems = allDishes
                      .where((dish) => dish.parentId == parentCategory.dishId)
                      .where((child) {
                        if (searchController.text.isEmpty) {
                          return true;
                        }
                        final normalizedChildName = normalizeString(
                          child.dishName ?? '',
                        );
                        return normalizedChildName.contains(
                          normalizedSearchQuery,
                        );
                      })
                      .toList();

                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  parentCategory.dishName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  expandedMap[parentCategory.dishId!] =
                                      !expandedMap[parentCategory.dishId!]!;
                                  (context as Element).markNeedsBuild();
                                },
                                child: Icon(
                                  expandedMap[parentCategory.dishId!]!
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: expandedMap[parentCategory.dishId!]!,
                          child: childItems.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: childItems.map((child) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 14,
                                                  height: 14,
                                                  margin: EdgeInsets.only(
                                                    right: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          (child.tag ?? '')
                                                                  .toLowerCase() ==
                                                              'veg'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      width: 7,
                                                      height: 7,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            (child.tag ?? '')
                                                                    .toLowerCase() ==
                                                                'veg'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    child.dishName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '₹${child.price ?? 0}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _stockBlock(
                                                        'Quantity',
                                                        child.stockQuantity,
                                                        Colors.blue,
                                                      ),
                                                      _stockBlock(
                                                        'Consumed',
                                                        child.consumedQuantity,
                                                        Colors.orange,
                                                      ),
                                                      _stockBlock(
                                                        'Balance',
                                                        child.balanceQuantity,
                                                        Colors.green,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () {
                                                    showQuantityEditPopup(
                                                      child,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      searchController.text.isNotEmpty
                                          ? 'No matching items in this category'
                                          : 'No items in this category',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void showQuantityEditPopup(Dish dish) {
    TextEditingController quantityController = TextEditingController(
      text: dish.stockQuantity?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Quantity"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int newQuantity = int.tryParse(quantityController.text) ?? 0;

                bool success = await food_authservice.updateDish(
                  dishId: dish.dishId,
                  dishData: {'stockQuantity': newQuantity},
                  imageFile: null,
                );

                Navigator.pop(context);

                if (success) {
                  await refreshList();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _stockBlock(String title, int? value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 2),
        Text(
          '${value ?? 0}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class DiscountTab extends StatefulWidget {
  @override
  _DiscountTabState createState() => _DiscountTabState();
}

class _DiscountTabState extends State<DiscountTab> {
  final Map<int, bool> expandedMap = {};
  TextEditingController searchController = TextEditingController();

  String normalizeString(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Dish>>(
            future: food_authservice.fetchDishes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading discounts'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories found'));
              }

              final allDishes = snapshot.data!;
              final normalizedSearchQuery = normalizeString(
                searchController.text,
              );

              List<Dish> parentCategories = allDishes
                  .where((dish) => dish.parentId == 0)
                  .where((parentCategory) {
                    if (searchController.text.isEmpty) {
                      return true;
                    }

                    final normalizedCategoryName = normalizeString(
                      parentCategory.dishName ?? '',
                    );
                    bool categoryMatches = normalizedCategoryName.contains(
                      normalizedSearchQuery,
                    );

                    bool childMatches = false;
                    final childItems = allDishes
                        .where((dish) => dish.parentId == parentCategory.dishId)
                        .toList();

                    if (childItems.isNotEmpty) {
                      childMatches = childItems.any((child) {
                        final normalizedChildName = normalizeString(
                          child.dishName ?? '',
                        );
                        return normalizedChildName.contains(
                          normalizedSearchQuery,
                        );
                      });
                    }

                    return categoryMatches || childMatches;
                  })
                  .toList();

              if (searchController.text.isNotEmpty &&
                  parentCategories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No items found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                itemCount: parentCategories.length,
                itemBuilder: (context, index) {
                  final parentCategory = parentCategories[index];

                  expandedMap[parentCategory.dishId!] =
                      expandedMap[parentCategory.dishId!] ?? true;

                  List<Dish> childItems = allDishes
                      .where((dish) => dish.parentId == parentCategory.dishId)
                      .where((child) {
                        if (searchController.text.isEmpty) {
                          return true;
                        }
                        final normalizedChildName = normalizeString(
                          child.dishName ?? '',
                        );
                        return normalizedChildName.contains(
                          normalizedSearchQuery,
                        );
                      })
                      .toList();

                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  parentCategory.dishName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  expandedMap[parentCategory.dishId!] =
                                      !expandedMap[parentCategory.dishId!]!;
                                  (context as Element).markNeedsBuild();
                                },
                                child: Icon(
                                  expandedMap[parentCategory.dishId!]!
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: expandedMap[parentCategory.dishId!]!,
                          child: childItems.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: childItems.map((child) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    child.dishName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  if (child.tag != null &&
                                                      child.tag!.isNotEmpty)
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color:
                                                                  child.tag!
                                                                          .toLowerCase() ==
                                                                      'veg'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: 6,
                                                              height: 6,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    child.tag!
                                                                            .toLowerCase() ==
                                                                        'veg'
                                                                    ? Colors
                                                                          .green
                                                                    : Colors
                                                                          .red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          child.tag!.replaceAll(
                                                            '_',
                                                            ' ',
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                child.discount != null &&
                                                        child.discount! > 0
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.percent,
                                                              color: Colors.red,
                                                              size: 14,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              '${child.discount!.toStringAsFixed(0)}%',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '0%',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showDiscountDialog(
                                                      context,
                                                      child,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.purple,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      searchController.text.isNotEmpty
                                          ? 'No matching items in this category'
                                          : 'No items in this category',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDiscountDialog(BuildContext context, Dish child) {
    TextEditingController discountController = TextEditingController(
      text: child.discount != null && child.discount! > 0
          ? child.discount!.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Discount"),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Discount %'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                double discount = double.tryParse(discountController.text) ?? 0;
                Navigator.pop(context);

                food_authservice.updateDish(
                  dishId: child.dishId,
                  dishData: {'discount': discount},
                  imageFile: null,
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class VegTab extends StatefulWidget {
  final int? parentId;
  final OrderType orderType;
  final String searchQuery;

  VegTab({this.parentId, required this.orderType, this.searchQuery = ''});

  @override
  _VegTabState createState() => _VegTabState();
}

class _VegTabState extends State<VegTab> {
  late Future<List<Dish>> dishes;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void didUpdateWidget(covariant VegTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentId != widget.parentId ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadDishes();
    }
  }

  void _loadDishes() {
    setState(() {
      dishes = food_authservice.fetchFilteredDishes(
        parentId: (widget.parentId != null && widget.parentId != 0)
            ? widget.parentId
            : null,
        tag: 'veg',
        searchQuery: widget.searchQuery,
        filterByMenuStatus: true,
      );
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
          return const Center(child: Text('No Veg dishes found.'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.58,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Dish dish = snapshot.data![index];
            Widget imageWidget;
            if (dish.dishImage != null && dish.dishImage!.isNotEmpty) {
              imageWidget = Image.network(
                dish.dishImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              );
            } else {
              imageWidget = const Icon(Icons.image_not_supported, size: 50);
            }

            return ProductCard(
              imageWidget: imageWidget,
              name: dish.dishName ?? '',
              price: "₹${dish.price}",
              description: dish.description ?? '',
              effectivePrice: "₹${dish.effectivePrice}",
              Waiter_CartButton: Waiter_CartButton(
                dishId: dish.dishId ?? 0,
                orderType: widget.orderType,
                balanceQuantity: dish.balanceQuantity,
              ),
              isOutOfStock:
                  dish.stock?.toLowerCase() == 'out_of_stock' ||
                  dish.balanceQuantity <= 0,
            );
          },
        );
      },
    );
  }
}

class NonVegTab extends StatefulWidget {
  final int? parentId;
  final OrderType orderType;
  final String filterTag;
  final String searchQuery;

  const NonVegTab({
    this.parentId,
    required this.filterTag,
    required this.orderType,
    this.searchQuery = '',
  });

  @override
  State<NonVegTab> createState() => _NonVegTabState();
}

class _NonVegTabState extends State<NonVegTab> {
  late Future<List<Dish>> dishes;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void didUpdateWidget(covariant NonVegTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentId != widget.parentId ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadDishes();
    }
  }

  void _loadDishes() {
    setState(() {
      dishes = food_authservice.fetchFilteredDishes(
        parentId: (widget.parentId != null && widget.parentId != 0)
            ? widget.parentId
            : null,
        tag: widget.filterTag.toLowerCase(),
        searchQuery: widget.searchQuery,
        filterByMenuStatus: true,
      );
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
          return const Center(child: Text('No Non-Veg dishes found.'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.60,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Dish dish = snapshot.data![index];

            Widget imageWidget;
            if (dish.dishImage != null && dish.dishImage!.isNotEmpty) {
              imageWidget = Image.network(
                dish.dishImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              );
            } else {
              imageWidget = const Icon(Icons.image_not_supported, size: 50);
            }

            return ProductCard(
              imageWidget: imageWidget,
              name: dish.dishName ?? '',
              price: "₹${dish.price}",
              effectivePrice: "₹${dish.effectivePrice}",
              description: dish.description ?? '',
              Waiter_CartButton: Waiter_CartButton(
                dishId: dish.dishId ?? 0,
                orderType: widget.orderType,
                balanceQuantity: dish.balanceQuantity,
              ),
              isOutOfStock:
                  dish.stock?.toLowerCase() == 'out_of_stock' ||
                  dish.balanceQuantity <= 0,
            );
          },
        );
      },
    );
  }
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
      child: Container(
        height: 100,
        width: 75,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: image != null
                    ? Image(image: image!, fit: BoxFit.cover)
                    : Icon(icon, size: 40, color: Colors.black),
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                title,
                style: textStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
      width: 100.0,
      height: 40.0,
      toggleSize: 30.0,
      borderRadius: 20.0,
      value: isVeg,
      showOnOff: true,
      activeColor: Colors.green,
      inactiveColor: Colors.red,
      activeToggleColor: Colors.white,
      inactiveToggleColor: Colors.white,
      activeText: "Veg",
      inactiveText: "Non-Veg",
      valueFontSize: 13.0,
      toggleColor: Colors.white70,
      onToggle: onToggle,
    );
  }
}

class AddItemTab extends StatefulWidget {
  final bool isVeg;
  final int? parentId;

  const AddItemTab({super.key, required this.isVeg, this.parentId});

  @override
  State<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends State<AddItemTab> {
  int selectedTabIndex = 0;
  bool isExpanded = false;
  bool isExpanded1 = false;
  bool isToggled = false;

  TextEditingController searchController = TextEditingController();
  final TextEditingController searchController1 = TextEditingController();

  List<String> savedCategories = [];
  List<String> addedCategories = [];
  List<Dish> localCategories = [];
  String input = '';
  Map<String, bool> isExpandedMap = {};
  Map<String, bool> isToggledMap = {};
  String? selectedCategory;
  List<String> filteredCategories = [];

  File? _image;
  bool _isImageAdded = false;
  String selectedItemType = 'Veg';
  bool isexpanded = false;
  Map<String, bool> disabledMap = {};
  List<Dish> allDishes = [];
  List<Dish> disabledList = [];
  List<Dish> outOfStockList = [];

  int? selectedCategoryId;
  int? selectedParentId;

  @override
  void initState() {
    super.initState();
    fetchAndSetDishes();
    searchController.addListener(_onSearchChanged);
    localCategories = List<Dish>.from(Utils.fetchedCategories);
    for (var category in savedCategories) {
      isExpandedMap[category] = false;
      isToggledMap[category] = true;
    }
    searchController1.addListener(() {
      setState(() {
        input = searchController1.text;
        filteredCategories = addedCategories
            .where(
              (category) =>
                  category.toLowerCase().contains(input.toLowerCase()),
            )
            .toList();
      });
    });
    localCategories = List<Dish>.from(Utils.fetchedCategories);
    filteredCategories = addedCategories;
    selectedParentId = widget.parentId ?? 0;
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase().replaceAll(' ', '');

    setState(() {
      localCategories = Utils.fetchedCategories.where((dish) {
        final dishName = dish.dishName?.toLowerCase().replaceAll(' ', '') ?? '';
        return dishName.contains(query);
      }).toList();
    });
  }

  Future<void> refreshList() async {
    Utils.fetchedCategories = await food_authservice.fetchDishes();
    print("Categories refreshed");
  }

  @override
  void dispose() {
    searchController1.dispose();
    super.dispose();
  }

  void switchTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  Map<int, List<Dish>> subDishesMap = {};

  Future<void> refreshSubDishes(int parentDishId) async {
    try {
      final subDishes = await food_authservice.fetchDishes();

      final enabledDishes = subDishes
          .where((dish) => dish.menuStatus?.toLowerCase() != 'disable')
          .toList();

      setState(() {
        subDishesMap[parentDishId] = enabledDishes;
      });

      print("Subdishes refreshed for $parentDishId");
    } catch (e) {
      print("Failed to refresh subdishes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => switchTab(0),
              child: Text(
                " Category Items",
                style: TextStyle(
                  color: selectedTabIndex == 0 ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedTabIndex == 0
                    ? Colors.purple
                    : Colors.white,
                minimumSize: Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Expanded(
          child: MenuAllWidget(
            localCategories: localCategories,
            onRefresh: refreshList,
            onRefresh1: refreshSubDishes,
            onDeleteCategory: _deleteCategory,
          ),
        ),
      ],
    );
  }

  void fetchAndSetDishes() async {
    try {
      allDishes = await food_authservice.fetchDishes();

      for (var dish in allDishes) {
        final dishId = dish.dishId.toString();
        if (!disabledMap.containsKey(dishId)) {
          disabledMap[dishId] = false;
        }
      }

      disabledList = allDishes
          .where((dish) => dish.menuStatus?.toLowerCase() == 'disable')
          .toList();

      setState(() {});
    } catch (e) {
      print('Error fetching dishes: $e');
    }
  }

  void _createNewCategory(String categoryName) {
    setState(() {
      addedCategories.add(categoryName);
    });
  }

  Future<void> _openEditCategoryDialog(Dish category) async {
    final editController = TextEditingController(text: category.dishName);
    File? editImageFile;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Category"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editController,
                      decoration: const InputDecoration(
                        labelText: "Category Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(() {
                            editImageFile = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: editImageFile != null
                            ? Image.file(editImageFile!, fit: BoxFit.cover)
                            : (category.dishImage != null &&
                                  category.dishImage!.isNotEmpty)
                            ? Image.network(
                                category.dishImage!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Text("Tap to change image (Optional)"),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a category name"),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await _updateCategory(
        category.dishId!,
        editController.text,
        editImageFile,
      );
    }
  }

  Future<void> _updateCategory(
    int dishId,
    String newName,
    File? imageFile,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await food_authservice.updateCategory(
        dishId: dishId,
        dishName: newName,
        imageFile: imageFile,
      );

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Category updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        await refreshList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to update category"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCategory(Dish category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text(
            "Are you sure you want to delete '${category.dishName}'? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await food_authservice.deleteCategory(category.dishId!);

      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Category deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        await refreshList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to delete category"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void openCreateCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create Category"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController1,
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        hintText: "Type category name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          input = value;
                          filteredCategories = addedCategories
                              .where(
                                (cat) => cat.toLowerCase().contains(
                                  input.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    buildImagePicker(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (searchController1.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a category name"),
                              ),
                            );
                            return;
                          }

                          final success = await food_authservice.createCategory(
                            name: searchController1.text,
                            parentId: 0,
                            stockQuantity: 0,
                            imageFile: _image,
                          );

                          if (success) {
                            _createNewCategory(searchController1.text);

                            setState(() {
                              input = '';
                              searchController1.clear();
                              _image = null;
                              _isImageAdded = false;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Category added successfully"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Failed to save category"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget MenuAllWidget({
    required List<Dish> localCategories,
    final Future<void> Function()? onRefresh,
    final Future<void> Function(int)? onRefresh1,
    final Future<void> Function(Dish)? onDeleteCategory,
  }) {
    Map<int, List<Dish>> subDishesMap = {};
    Set<int> _currentlyEditing = Set<int>();

    List<Dish> _getUniqueSubDishes(List<Dish> dishes) {
      Map<int, Dish> uniqueDishes = {};

      for (var dish in dishes) {
        if (dish.dishId != null) {
          if (!_currentlyEditing.contains(dish.dishId)) {
            uniqueDishes[dish.dishId!] = dish;
          }
        }
      }

      return uniqueDishes.values.toList();
    }

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        List<Dish> localCategories = List.from(Utils.fetchedCategories);
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              if (onRefresh != null) {
                await onRefresh();
                setState(() {
                  localCategories = List.from(Utils.fetchedCategories);
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search for items",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Colors.black54),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: localCategories
                        .where((dish) => dish.parentId == 0)
                        .length,
                    itemBuilder: (context, index) {
                      final parentCategories = localCategories
                          .where((dish) => dish.parentId == 0)
                          .toList();
                      final category = parentCategories[index];
                      final categoryName = category.dishName!;
                      final isExpanded = isExpandedMap[categoryName] ?? false;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            categoryName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _openEditCategoryDialog(category);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            if (onDeleteCategory != null) {
                                              onDeleteCategory(category);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PremiumAddItems(
                                          onItemSaved: (dish) {
                                            setState(() {
                                              selectedParentId =
                                                  category.dishId;
                                            });
                                          },
                                          dishId: 0,
                                          isEdit: false,
                                          parentId: category.dishId,
                                          dishName: category.dishName,
                                        ),
                                      ),
                                    ).then((_) {
                                      onRefresh?.call();
                                      onRefresh1?.call(category.dishId);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                  ),
                                  onPressed: () async {
                                    if (!isExpanded) {
                                      try {
                                        final allDishes = await food_authservice
                                            .fetchDishes();
                                        final subDishes = allDishes
                                            .where(
                                              (dish) =>
                                                  dish.parentId ==
                                                  category.dishId,
                                            )
                                            .toList();
                                        setState(() {
                                          subDishesMap[category.dishId] =
                                              subDishes;
                                          isExpandedMap[categoryName] = true;
                                        });
                                      } catch (e) {
                                        print("❌ Failed to load subdishes: $e");
                                      }
                                    } else {
                                      setState(() {
                                        isExpandedMap[categoryName] = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded &&
                              subDishesMap.containsKey(category.dishId))
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: Colors.grey),
                                  ..._getUniqueSubDishes(
                                    subDishesMap[category.dishId]!,
                                  ).map((dishItem) {
                                    return Column(
                                      children: [
                                        FoodItemCard(
                                          imageurl: dishItem.dishImage,
                                          title: dishItem.dishName ?? '',
                                          price: '₹${dishItem.price ?? 0}',
                                          isVeg:
                                              (dishItem.tag ?? '')
                                                  .toLowerCase() ==
                                              'veg',
                                          initialToggleState:
                                              (dishItem.menuStatus ?? '')
                                                  .toLowerCase() ==
                                              'enable',
                                          initialStockState:
                                              (dishItem.stock?.toLowerCase() ??
                                                  '') ==
                                              'in_stock',
                                          onEdit: () async {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );

                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PremiumAddItems(
                                                      onItemSaved:
                                                          (dish) async {
                                                            return dish;
                                                          },
                                                      dishId: dishItem.dishId,
                                                      isEdit: true,
                                                      parentId: category.dishId,
                                                      dishName:
                                                          dishItem.dishName ??
                                                          '',
                                                      price:
                                                          dishItem.price ?? 0,
                                                      description:
                                                          dishItem.description,
                                                      stockQuantity:
                                                          dishItem
                                                              .stockQuantity ??
                                                          0,
                                                      dishImageBase64:
                                                          dishItem.dishImage,
                                                    ),
                                              ),
                                            ).then((savedDish) async {
                                              if (Navigator.canPop(context))
                                                Navigator.pop(context);

                                              if (savedDish != null) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) => const Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "Updating item...",
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );

                                                try {
                                                  Map<String, dynamic>
                                                  dishData = {
                                                    'dishName':
                                                        savedDish.dishName,
                                                    'price': savedDish.price,
                                                    'effectivePrice':
                                                        savedDish
                                                            .effectivePrice ??
                                                        savedDish.price,
                                                    'description':
                                                        savedDish.description ??
                                                        '',
                                                    'tag':
                                                        savedDish.tag ?? 'veg',
                                                    'stockQuantity': 0,
                                                    'discount':
                                                        savedDish.discount ??
                                                        0.0,
                                                    'stock':
                                                        savedDish.stock ??
                                                        'In_Stock',
                                                    'menuStatus':
                                                        savedDish.menuStatus ??
                                                        'enable',
                                                    'parentId': category.dishId,
                                                  };

                                                  dishData.removeWhere(
                                                    (key, value) =>
                                                        value == null,
                                                  );

                                                  debugPrint(
                                                    'PUT API Data: $dishData',
                                                  );
                                                  debugPrint(
                                                    'Dish ID: ${dishItem.dishId}',
                                                  );

                                                  final success =
                                                      await food_authservice
                                                          .updateDish(
                                                            dishId:
                                                                dishItem.dishId,
                                                            dishData: dishData,
                                                            imageFile: null,
                                                          );

                                                  if (Navigator.canPop(context))
                                                    Navigator.pop(context);

                                                  if (success) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "✅ Item updated successfully",
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                        duration: Duration(
                                                          seconds: 2,
                                                        ),
                                                      ),
                                                    );

                                                    setState(() {
                                                      subDishesMap.remove(
                                                        category.dishId,
                                                      );
                                                      isExpandedMap[categoryName] =
                                                          false;
                                                    });

                                                    if (onRefresh != null) {
                                                      await onRefresh();
                                                    }

                                                    await Future.delayed(
                                                      const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                    );

                                                    final allDishes =
                                                        await food_authservice
                                                            .fetchDishes();
                                                    final freshSubDishes = allDishes
                                                        .where(
                                                          (dish) =>
                                                              dish.parentId ==
                                                              category.dishId,
                                                        )
                                                        .where(
                                                          (dish) =>
                                                              dish.menuStatus
                                                                  ?.toLowerCase() !=
                                                              'disable',
                                                        )
                                                        .toList();

                                                    setState(() {
                                                      subDishesMap[category
                                                              .dishId] =
                                                          freshSubDishes;
                                                      isExpandedMap[categoryName] =
                                                          true;
                                                      localCategories = List.from(
                                                        Utils.fetchedCategories,
                                                      );
                                                    });

                                                    if (onRefresh1 != null) {
                                                      await onRefresh1(
                                                        category.dishId,
                                                      );
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "❌ Failed to update item",
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (Navigator.canPop(context))
                                                    Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "❌ Error: $e",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  debugPrint(
                                                    'Error in onEdit: $e',
                                                  );
                                                }
                                              }
                                            });
                                          },
                                          onDelete: () async {
                                            final success =
                                                await food_authservice
                                                    .deleteDish(
                                                      dishItem.dishId,
                                                    );
                                            if (success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Dish deleted successfully",
                                                  ),
                                                ),
                                              );
                                              onRefresh?.call();
                                              await onRefresh1?.call(
                                                category.dishId,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Failed to delete dish",
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          onToggleChanged: (enabled) async {
                                            await food_authservice
                                                .updateMenuStatus(
                                                  dishId: dishItem.dishId,
                                                  status: enabled,
                                                );
                                            await onRefresh1?.call(
                                              category.dishId,
                                            );
                                            if (onRefresh != null)
                                              await onRefresh();
                                          },
                                          onStockToggleChanged:
                                              (inStock) async {
                                                await food_authservice
                                                    .updateStockStatus(
                                                      dishId: dishItem.dishId,
                                                      status: inStock
                                                          ? 'In_Stock'
                                                          : 'Out_of_Stock',
                                                    );
                                                await onRefresh1?.call(
                                                  category.dishId,
                                                );
                                                if (onRefresh != null)
                                                  await onRefresh();
                                              },
                                        ),
                                        Divider(color: Colors.grey[200]),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    openCreateCategoryDialog();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Create Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() {
            _image = File(picked.path);
            _isImageAdded = true;
          });
        }
      },
      child: Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[200],
        child: _image == null
            ? const Center(child: Text("Tap to add image"))
            : Image.file(_image!, fit: BoxFit.cover),
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
  final Widget Waiter_CartButton;
  final bool isOutOfStock;

  const ProductCard({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.description,
    required this.effectivePrice,
    required this.Waiter_CartButton,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isOutOfStock,
      child: Opacity(
        opacity: isOutOfStock ? 0.5 : 1.0,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageWidget,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Text(
                          effectivePrice,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          price,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(child: Waiter_CartButton),
                ],
              ),
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.3),
                  child: const Text(
                    "",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: getImageProvider(),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isVeg ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: isVeg ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title), SizedBox(height: 4), Text(price)],
            ),
            Spacer(),
            SizedBox(width: 20),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          insetPadding: EdgeInsets.all(20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        onEdit();
                                                      },
                                                      splashRadius: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1),
                                              Container(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        onDelete!();
                                                      },
                                                      splashRadius: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1),
                                              Container(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Enable/Disable",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    ToggleSwitchExample(
                                                      initialValue:
                                                          initialToggleState,
                                                      onToggleChanged: (value) {
                                                        if (onToggleChanged !=
                                                            null) {
                                                          onToggleChanged!(
                                                            value,
                                                          );
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(height: 1),
                                              Container(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Stock/Out of Stock",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    StockToggleSwitch(
                                                      initialValue:
                                                          initialStockState,
                                                      onToggleChanged: (value) {
                                                        if (onStockToggleChanged !=
                                                            null) {
                                                          onStockToggleChanged!(
                                                            value,
                                                          );
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.center),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider getImageProvider() {
    if (imageurl != null && imageurl!.isNotEmpty) {
      return NetworkImage(imageurl!);
    }
    if (imagePath != null && imagePath!.isNotEmpty) {
      return AssetImage(imagePath!);
    }
    return const AssetImage('assets/gallery-img-1.jpg');
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
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.1,
      child: FlutterSwitch(
        value: initialValue,
        width: 60.0,
        height: 28.0,
        toggleSize: 18.0,
        borderRadius: 30.0,
        activeColor: Colors.green,
        inactiveColor: Colors.red,
        activeToggleColor: Colors.white,
        inactiveToggleColor: Colors.white,
        showOnOff: true,
        valueFontSize: 10.0,
        onToggle: (val) {
          if (onToggleChanged != null) {
            onToggleChanged!(val);
          }
        },
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.1,
      child: FlutterSwitch(
        value: initialValue,
        width: 70.0,
        height: 28.0,
        toggleSize: 18.0,
        borderRadius: 30.0,
        activeColor: Colors.green,
        inactiveColor: Colors.red,
        activeToggleColor: Colors.white,
        inactiveToggleColor: Colors.white,
        activeText: "In Stock",
        inactiveText: "Out Stock",
        showOnOff: true,
        valueFontSize: 8.0,
        onToggle: (val) {
          if (onToggleChanged != null) {
            onToggleChanged!(val);
          }
        },
      ),
    );
  }
}
