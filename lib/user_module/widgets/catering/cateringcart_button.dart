// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/catering_authservice.dart';
// import '../../API/food_authservice.dart';
// import 'package:maamaas_app/widgets/utils.dart';
// import '../../Models/caterings/packages_model.dart';
// import '../../Models/food/catering_cart_model.dart';
//
// class CateringCartButton extends StatefulWidget {
//   final Package package; // ✅ Strongly type it
//   const CateringCartButton({super.key, required this.package});
//
//   @override
//   State<CateringCartButton> createState() => _CateringCartButtonState();
// }
//
// class _CateringCartButtonState extends State<CateringCartButton> {
//   int itemCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQuantity();
//   }
//
//
//   // Future<void> _loadQuantity() async {
//   //   try {
//   //     final cart = await food_Authservice.fetchCart();
//   //
//   //     CartItem? matchedItem;
//   //     if (cart != null) {
//   //       for (var item in cart.cartItems) {
//   //         if (item.dishId == widget.dishId) {
//   //           matchedItem = item;
//   //           break;
//   //         }
//   //       }
//   //     }
//   //
//   //     setState(() => itemCount = matchedItem?.quantity ?? 0);
//   //   } catch (e) {
//   //     setState(() => itemCount = 0);
//   //   }
//   //
//   //   // update global cart badge
//   //   Utils.refreshCartCount();
//   // }
//
//   Future<void> _loadQuantity() async {
//     try {
//       setState(() => _isLoading = true);
//
//       final Cart? cart = await catering_authservice.fetchUserCart();
//       final packageId = widget.package.id;
//
//       if (cart == null || cart.items.isEmpty) {
//         setState(() => itemCount = 0);
//         return;
//       }
//
//       // 🔍 Find matching package
//       final CartPackage? packageInCart = cart.items.firstWhere(
//             (item) => item.packageId == packageId,
//         orElse: () => null,
//       );
//
//       if (packageInCart != null) {
//         final qty = packageInCart.quantity;
//         cartId = cart.id;
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setInt("package_${packageId}_quantity", qty);
//         await prefs.setInt("package_${packageId}_cartId", cartId!);
//
//         setState(() => itemCount = qty);
//
//         _updateGlobalItemCount(cart.items);
//       } else {
//         setState(() => itemCount = 0);
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching catering cart quantity: $e");
//       await _loadQuantityFromCache();
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
//     CartNotifier.count.value += quantity;
//
//     final success = await food_Authservice.addToCart(
//       dishId: widget.dishId,
//       quantity: quantity,
//       sheduleorder: sheduleorder,
//     );
//
//     if (!success) {
//       // ❌ rollback if API fails
//       CartNotifier.count.value -= quantity;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to add item. Please select your order type."),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//
//     // ✅ store itemId & quantity
//     final itemId = await food_Authservice.getItemIdByDishId(widget.dishId);
//
//     if (itemId != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt("dish_${widget.dishId}_itemId", itemId);
//       await prefs.setInt("dish_${widget.dishId}_quantity", quantity);
//     }
//   }
//
//   Future<void> _removeFromCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
//
//     if (itemId == null) return;
//
//     // INSTANT SUBTRACT FROM CART BADGE
//     CartNotifier.count.value -= itemCount;
//
//     final removed = await food_Authservice.removeCartItem(itemId);
//
//     if (removed) {
//       prefs.remove("dish_${widget.dishId}_quantity");
//       prefs.remove("dish_${widget.dishId}_itemId");
//
//       setState(() => itemCount = 0);
//     }
//   }
//
//   Future<void> _updateQuantity(int newQty) async {
//     final prefs = await SharedPreferences.getInstance();
//     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
//
//     if (itemId != null) {
//       // INSTANT CART BADGE UPDATE
//       CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;
//
//       await food_Authservice.updateCartItem(itemId: itemId, quantity: newQty);
//
//       prefs.setInt("dish_${widget.dishId}_quantity", newQty);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isOutOfStock = widget.balanceQuantity <= 0;
//
//     return SizedBox(
//       width: 120.w,
//       height: 39.h,
//       child: itemCount == 0
//           ? ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             side: BorderSide(color: const Color(0xFFB15DC6), width: 1.w),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 10.w),
//         ),
//         onPressed: () async {
//           final schedule = widget.balanceQuantity <= 0;
//
//           // if (schedule) {
//           //   _showScheduleMessage(context);
//           // }
//
//           setState(() => itemCount = 1);
//           await _addToCart(1, sheduleorder: schedule);
//         },
//
//         child: Text(
//           widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black, // 👈 NEVER greyed out
//           ),
//         ),
//       )
//           : Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(color: const Color(0xFFB15DC6), width: 1.w),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             /// ➖ Minus
//             IconButton(
//               icon: Icon(Icons.remove, size: 14.sp),
//               onPressed: () async {
//                 if (itemCount > 1) {
//                   setState(() => itemCount--);
//                   await _updateQuantity(itemCount);
//                 } else {
//                   await _removeFromCart();
//                   setState(() => itemCount = 0);
//                 }
//               },
//             ),
//
//             Text(
//               "$itemCount",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             /// ➕ Plus (WITH VALIDATION)
//             GestureDetector(
//               onTap: itemCount >= widget.balanceQuantity
//                   ? () {
//                 _showScheduleMessage(context);
//               }
//                   : null,
//               child: IconButton(
//                 icon: Icon(
//                   Icons.add,
//                   size: 14.sp,
//                   color: itemCount >= widget.balanceQuantity
//                       ? Colors.grey
//                       : Colors.black,
//                 ),
//                 onPressed: itemCount >= widget.balanceQuantity
//                     ? null // stays disabled visually
//                     : () async {
//                   setState(() => itemCount++);
//                   await _updateQuantity(itemCount);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showScheduleMessage(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("📅 Item is out of stock. You can schedule it."),
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
