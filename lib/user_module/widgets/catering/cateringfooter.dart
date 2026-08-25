import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/user_module/API/catering_authservice.dart';
import '../../screens/Catering&Services/catering_cart_screen.dart';
import '../../screens/professional_user/Main_screen.dart';
import '../../screens/videoscreen.dart';

class catering_footer extends StatefulWidget {
  final VoidCallback? onFilterTap; // 👈 add this

  const catering_footer({super.key, this.onFilterTap});

  @override
  State<catering_footer> createState() => _catering_footerState();
}

class _catering_footerState extends State<catering_footer> {
  int _itemCount = 0;
  @override
  void initState() {
    super.initState();
    _loaditemCount();
  }

  Future<void> _loaditemCount() async {
    final count = await catering_authservice.fetchCartCount();
    setState(() {
      _itemCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      color: const Color(0xFFB15DC6),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      child: Row(
        children: [
          _buildExpandedIcon(context, Icons.home, /* "Home"*/ MainScreen()),
          _buildExpandedIcon(
            context,
            Icons.play_circle,
            /*"Favorites"*/ ReelsScreen(),
          ),
          _buildExpandedIcon(
            context,
            Icons.shopping_cart,
            catering_cart(),
            count: _itemCount,
          ),

          _buildExpandedIcon(
            context,
            Icons.filter_list,
            // "Profile",
            null, // no page
            onTap: widget.onFilterTap,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedIcon(
    BuildContext context,
    IconData icon,
    // String label,
    Widget? page, {
    int count = 0,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              }
            },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 24.sp),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            // SizedBox(height: 4.h),
            // Text(
            //   label,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 10.sp,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
