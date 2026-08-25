import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../API/food_authservice.dart';
import '../../Models/food/dish.dart';
import '../../widgets/food/cart_button.dart';
import '../cartbutton.dart';

class DishSearchDelegate extends SearchDelegate<String> {
  final int vendorId;
  List<Dish> allDishes = [];

  DishSearchDelegate({required this.vendorId});

  /// Call this method in buildSuggestions/buildResults if list is empty
  ///
  /// @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.grey.shade200, // <<< FULL BG COLOR
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade200, // <<< Top bar background
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  Future<void> _loadDishes() async {
    if (allDishes.isNotEmpty) return; // already loaded

    try {
      allDishes = await food_Authservice.getAllDishes(vendorId);
      // notify SearchDelegate that state has changed
      // notifyListeners();
    } catch (e) {
      // print("Error loading dishes: $e");
    }
  }

  ImageProvider getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // If no URL, show placeholder
      return const AssetImage('assets/placeholder.png');
    }

    // Network image
    return NetworkImage(imageUrl);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // load dishes if not loaded yet
    _loadDishes();

    final results = allDishes
        .where(
          (dish) =>
              dish.dishName != null &&
              dish.dishName!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: [
          // LIST
          Expanded(child: _buildDishList(results)),

          // FOOTER
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // load dishes if not loaded yet
    _loadDishes();

    final suggestions = allDishes
        .where(
          (dish) =>
              dish.dishName != null &&
              dish.dishName!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: [
          Expanded(
            child: _buildDishList(suggestions),
          ), // <<< your background color
          // OrderCartFooter(),
          // OrderCart()
          Positioned(
            right: 0, // touches right edge
            bottom: 0, // touches bottom edge
            child: SizedBox(width: 140, child: food_Cart_count()),
          ),
        ],
      ),
    );
  }

  Widget _buildDishList(List<Dish> dishes) {
    final filteredDishes = dishes.where((dish) => dish.parentId != 0).toList();

    if (filteredDishes.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.white.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.shade100,
                      Colors.orangeAccent.shade200,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Search Items',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        return Card(
          color: Colors.grey.shade200,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ), // space below close icon
                            // Image
                            Stack(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(
                                    image: getImageProvider(
                                      dish.dishImage ?? '',
                                    ),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // Circular Discount Badge
                                if ((dish.discount) > 0)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${dish.discount}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Dish Name
                            Text(
                              dish.dishName ?? 'Unknown Dish',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Price Row
                            Row(
                              children: [
                                Text(
                                  '₹${dish.effectivePrice ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                if ((dish.discount) > 0)
                                  Text(
                                    '₹${dish.price ?? 0}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 10.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Description
                            Text(
                              dish.description ?? 'No description available.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 16),
                            CartButton(
                              dishId: dish.dishId,
                              balanceQuantity: dish.balanceQuantity,
                            )
                          ],
                        ),
                      ),

                      // ✖ Close Icon (Top Right)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black26,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      // Image box
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: getImageProvider(dish.dishImage ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Discount badge
                      if ((dish.discount) > 0)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${dish.discount}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
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
                          dish.dishName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Effective Price
                            Text(
                              '₹${dish.effectivePrice ?? 0}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 6.w),

                            // Original Price (strikethrough) if discount > 0
                            if ((dish.discount) > 0)
                              Text(
                                '₹${dish.price ?? 0}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10.sp,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CartButton(
                    dishId: dish.dishId,
                    balanceQuantity: dish.balanceQuantity,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
