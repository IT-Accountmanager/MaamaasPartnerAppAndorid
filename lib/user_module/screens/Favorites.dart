import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/food_authservice.dart';
import '../Models/food/favorites_model.dart';
import '../widgets/food/cart_button.dart';
import '../widgets/food/favoritesbutton_1.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  int? userId;
  List<FavoriteDish> favoriteDishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    return const Icon(Icons.image_not_supported);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      try {
        final fetchedFavorites = await food_Authservice.getFavoritesByUserId();
        setState(() {
          favoriteDishes = fetchedFavorites;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // print("Error fetching favorites: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorites"), centerTitle: true),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : favoriteDishes.isEmpty
            ? Center(
                child: Text(
                  "No favorite dishes found.",
                  style: TextStyle(fontSize: 16.sp),
                ),
              )
            : // Inside Favorites build()
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  double width = constraints.maxWidth;

                  if (width > 1200)
                    crossAxisCount = 5;
                  else if (width > 900)
                    crossAxisCount = 4;
                  else if (width > 600)
                    crossAxisCount = 3;

                  double cardWidth =
                      (width - (crossAxisCount + 1) * 12.w) / crossAxisCount;
                  double childAspectRatio =
                      cardWidth / (cardWidth * 1.4); // proportional

                  return GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: favoriteDishes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final dish = favoriteDishes[index];
                      return ProductCard(
                        imageWidget: _buildImage(dish.dishImage),
                        name: dish.dishName ?? '',
                        price: "₹${dish.price}",
                        effectivePrice: "₹${dish.effectivePrice}",
                        favoriteButton: FavoriteButton1(
                          favId: dish.favId,
                          onFavoriteToggled: () {
                            setState(() {
                              favoriteDishes.removeAt(index);
                            });
                          },
                        ),
                        cartButton: CartButton(
                          dishId: dish.dishId?? 0,
                          balanceQuantity: dish.balanceQuantity,
                        ),
                        isOutOfStock: false,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String price;
  final String effectivePrice;
  final Widget favoriteButton;
  final Widget cartButton;
  final bool isOutOfStock;

  const ProductCard({
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.effectivePrice,
    required this.favoriteButton,
    required this.cartButton,
    required this.isOutOfStock,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double imageHeight =
            width * 0.6; // scale image height based on card width

        return AbsorbPointer(
          absorbing: isOutOfStock,
          child: Opacity(
            opacity: isOutOfStock ? 0.5 : 1.0,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                          child: imageWidget,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14.sp,
                              ),
                            ),
                            // SizedBox(width: 4.w),
                            // Text(
                            //   effectivePrice,
                            //   style: TextStyle(
                            //     decoration: TextDecoration.lineThrough,
                            //     color: Colors.black54,
                            //     fontSize: 12.sp,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: cartButton,
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
