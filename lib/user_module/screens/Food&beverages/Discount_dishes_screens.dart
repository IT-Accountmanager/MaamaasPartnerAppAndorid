import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../API/food_authservice.dart';
import '../../widgets/food/cart_button.dart';
import '../../Models/food/discount_model.dart';
import 'ordertypefooter.dart';

class AllDishesScreen extends StatefulWidget {
  @override
  _AllDishesScreenState createState() => _AllDishesScreenState();
}

class _AllDishesScreenState extends State<AllDishesScreen> {
  List<Discount> allDishes = [];
  bool isLoading = true;
  OrderType selectedType = OrderType.dinein;

  @override
  void initState() {
    super.initState();
    fetchDishes(); // 🔹 call the API here
  }

  Future<void> fetchDishes() async {
    // print('🔹 Fetching dishes from API...');
    try {
      final fetchedDishes = await food_Authservice.fetchAllDiscountDishes();
      // print('🔹 Fetched ${fetchedDishes.length} dishes');

      // 🔥 FILTER dishes where balanceQuantity > 0
      final filteredDishes = fetchedDishes.where((dish) {
        return dish.stockQuantity > 0 && dish.stock != "Out_of_Stock";
      }).toList();

      // print(
      //   '🔹 Filtered ${filteredDishes.length} dishes with stockQuantity > 0',
      // );

      // ignore: unused_local_variable
      for (var d in filteredDishes) {
        // print(
        //   'Dish: ${d.dishName}, Price: ${d.price}, Discount: ${d.discount}, ParentId: ${d.parentId}, Balance: ${d.balanceQuantity}',
        // );
      }

      setState(() {
        allDishes = filteredDishes;
        isLoading = false;
      });
    } catch (e) {
      // print('❌ Error fetching dishes: $e');
      setState(() => isLoading = false);
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (allDishes.isEmpty) {
      return const Scaffold(body: Center(child: Text('No dishes found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Dishes'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: allDishes.length,
        itemBuilder: (context, index) {
          final dish = allDishes[index];
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
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
                                dishId: dish.dishId ?? 0,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Dish Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: getImageProvider(dish.dishImage ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Discount Badge
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
                      dishId: dish.dishId?? 0,
                      balanceQuantity: dish.balanceQuantity,
                    )
                  ],
                ),
              ),
            ),
          ); // replace with your card widget
        },
      ),
      bottomNavigationBar: OrderCartFooter(),
    );
  }
}
