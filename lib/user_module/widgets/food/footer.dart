// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../API/food_authservice.dart';
// import '../../screens/Food&beverages/Food&beverages_homescreen.dart';
// import '../../screens/Food&beverages/food_cartscreen.dart';
// import '../../screens/profile_screen.dart';
// import '../../screens/videoscreen.dart';
// import '../profiledrawer.dart';
// import '../utils.dart';
// import 'currentcart_notifier.dart';
//
// class food_foooter extends StatefulWidget {
//   const food_foooter({super.key});
//
//   @override
//   State<food_foooter> createState() => _food_foooterState();
// }
//
// class _food_foooterState extends State<food_foooter> {
//   // int _cartcount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     Utils.itemCount.addListener(_updateCount);
//     loadCartData();
//   }
//
//   Future<void> loadCartData() async {
//     try {
//       final count = await food_Authservice.fetchCartCount();
//       CartNotifier.count.value = count;
//     } catch (e) {
//       // print("Error loading cart data: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     Utils.itemCount.removeListener(_updateCount);
//     super.dispose();
//   }
//
//   void _updateCount() {
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 55.h,
//       // color: const Color(0xFFB15DC6),
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8.w),
//       child: Row(
//         children: [
//
//
//           _buildExpandedIcon(
//             context,
//             icon: Icons.play_circle,
//             label: "ADS",
//             page: ReelsScreen(),
//           ),
//
//           ValueListenableBuilder<int>(
//             valueListenable: CartNotifier.count,
//             builder: (context, count, _) {
//               return _buildExpandedIcon(
//                 context,
//                 icon: Icons.shopping_cart,
//                 label: "Cart",
//
//                 count: count, // ✅ cart count here
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => food_cartScreen()),
//                   );
//                 },
//               );
//             },
//           ),
//
//           _buildExpandedIcon(
//             context,
//             icon: Icons.person,
//             label: "Profile",
//             onTap: () {
//               openProfileDrawer(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildExpandedIcon(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     Widget? page,
//     int count = 0,
//     VoidCallback? onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap:
//             onTap ??
//             () {
//               if (page != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => page),
//                 );
//               }
//             },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Icon(icon, color: Colors.grey, size: 24.sp),
//                 if (count > 0)
//                   Positioned(
//                     right: -6,
//                     top: -6,
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 18,
//                         minHeight: 18,
//                       ),
//                       child: Text(
//                         count > 9 ? '9+' : count.toString(),
//
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 10.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
