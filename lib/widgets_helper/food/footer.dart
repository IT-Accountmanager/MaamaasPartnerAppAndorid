import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../food&beverages/Menu_managemnet.dart';
import '../../food&beverages/Registration.dart';
import '../../food&beverages/cart_screen.dart';
import '../../food&beverages/food&beverages_homescreen.dart';
import 'navigate_transition.dart';
import '../../food&beverages/order_management.dart';

class Footer extends StatefulWidget {
  // final VoidCallback? toggleDrawer;

  const Footer({
    Key? key,
    // this.toggleDrawer
  }) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  List<String> _modules = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final prefs = await SharedPreferences.getInstance();
    final modules = prefs.getStringList('modules') ?? [];
    setState(() {
      _modules = modules;
    });
    debugPrint("📦 Loaded modules → $_modules");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      color: const Color(0xFFB15DC6),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // if (_modules.contains('Home'))
          _buildExpandedIcon(context, Icons.home, "Home", food_beverages()),

          _buildExpandedIcon(
            context,
            Icons.food_bank,
            "Menu",
            Menu_Managemnet(),
          ),

          // _buildExpandedIcon(
          //   context,
          //   Icons.shopping_cart,
          //   "cart",
          //   food_cartScreen(),
          // ),

          // if (_modules.contains('Order_Management'))
          _buildExpandedIcon(
            context,
            Icons.shopping_bag,
            "Orders",
            Order_management(),
          ),

          // _buildExpandedIcon(
          //   context,
          //   Icons.person_off,
          //   "Orders",
          //   Registration(),
          // ),
        ],
      ),
    );
  }

  Widget _buildExpandedIcon(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          navigateWithTransition(context, page, TransitionType.bottomToTop);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Special Cart Icon (decides which cart screen to show)
  // Widget _buildCartExpandedIcon(
  //     BuildContext context,
  //     IconData icon,
  //     String label,
  //     ) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () async {
  //         final orderType = await _getLastOrderType() ?? "DINE_IN";
  //
  //         if (orderType == "TABLE_DINE_IN") {
  //           navigateWithTransition(
  //               context, const table_cartscreen(), TransitionType.bottomToTop);
  //         } else {
  //           navigateWithTransition(
  //               context, const cartscreen(), TransitionType.bottomToTop);
  //         }
  //       },
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: Colors.white, size: 24.sp),
  //           SizedBox(height: 4.h),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 10.sp,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Profile icon
  Widget _buildExpandedProfileIcon(
    BuildContext context,
    VoidCallback? toggleDrawer,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: toggleDrawer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              "Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
