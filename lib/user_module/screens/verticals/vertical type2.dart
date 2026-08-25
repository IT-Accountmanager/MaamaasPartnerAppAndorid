import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Fresh&Groceries/Stores_screen.dart';
import '../Logistics&supply/logistics_homepage.dart';
import '../newscreens/foodmainscreen.dart';

class QuickAccessScroll5 extends StatelessWidget {
  final List<QuickAccessItem> items = [
    QuickAccessItem(
      image: "assets/FOODBEVERAGES.webp",
      title: "Food & Beverages",
      subtitle: "Restaurants & Cafes",
      color: Color(0xFFFF6B35),
      route: MainScreenfood(),
    ),
    // QuickAccessItem(
    //   image: "assets/CATERINGSERVICES_V1.webp",
    //   title: "Events & Caterings",
    //   subtitle: "Events & Parties",
    //   color: Color(0xFF6C63FF),
    //   route: CateringsPage(),
    // ),
    QuickAccessItem(
      image: "assets/FRESHGROCERIES.webp",
      title: "Groceries & Meat",
      subtitle: "Daily Essentials",
      color: Color(0xFF4CAF50),
      route: stores(),
    ),
    QuickAccessItem(
      image: "assets/LOGISTICSANDSUPPLY.webp",
      title: "Travel & Supply",
      subtitle: "Delivery TableServices",
      color: Color(0xFF2196F3),
      route: LogisticsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),

        /// ⭐ Makes exact size adjustable on all phones
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.85, // ⭐ Prevents overflow on small screens
        ),

        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildCard(context, items[index]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, QuickAccessItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.route),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: item.color,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            /// ⭐ Responsive image section
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15.r),
                  ),
                  child: Image.asset(
                    item.image,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// ⭐ Responsive title container
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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

class QuickAccessItem {
  final String image;
  final String title;
  final String subtitle;
  final Color color;
  final IconData? icon;
  final Widget route;

  QuickAccessItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
    this.icon,
    required this.route,
  });
}

class Vertical extends StatelessWidget {
  final List<Map<String, dynamic>> verticals = [
    {
      'image': 'assets/FOODBEVERAGES.webp',
      'title': 'Food & Beverages',
      'color': Color(0xFFFF6B35),
      'route': MainScreenfood(),
    },
    {
      'image': 'assets/FRESHGROCERIES.webp',
      'title': 'Groceries & Meat',
      'color': Color(0xFF4CAF50),
      'route': stores(),
    },
    {
      'image': 'assets/LOGISTICSANDSUPPLY.webp',
      'title': 'Travel & Logistics',
      'color': Color(0xFF2196F3),
      'route': LogisticsScreen(),
    },
    // {
    //   'image': 'assets/FOODBEVERAGES.webp',
    //   'title': 'Food & Beverages',
    //   'color': Color(0xFFFF6B35),
    //   'route': MainScreenfood(),
    // },
    // {
    //   'image': 'assets/FRESHGROCERIES.webp',
    //   'title': 'Groceries & Meat',
    //   'color': Color(0xFF4CAF50),
    //   'route': stores(),
    // },
    // {
    //   'image': 'assets/LOGISTICSANDSUPPLY.webp',
    //   'title': 'Travel & Logistics',
    //   'color': Color(0xFF2196F3),
    //   'route': LogisticsScreen(),
    // },
  ];

  @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     height: 120, // 👈 REQUIRED for horizontal ListView
  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       itemCount: verticals.length,
  //       separatorBuilder: (_, __) => const SizedBox(width: 16),
  //       itemBuilder: (context, index) {
  //         return SizedBox(
  //           width: 100, // 👈 card width
  //           child: _buildCategoryCard(context, verticals[index]),
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true, // ✅ VERY IMPORTANT
        physics: const NeverScrollableScrollPhysics(), // ✅ VERY IMPORTANT
        itemCount: verticals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return _buildCategoryCard(context, verticals[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return Material(
      color: Colors.transparent, // 👈 REQUIRED
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => category['route']),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: category['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // color: category['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    category['image'],
                    width: 50, // image controls size
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 4,
                  right: 4,
                ), // adjust as needed
                child: Text(
                  category['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
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
