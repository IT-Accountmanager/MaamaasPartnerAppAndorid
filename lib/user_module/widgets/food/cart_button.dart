import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/user_module/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/food_authservice.dart';
import '../../Models/food/cart_model.dart';
import 'cartmode.dart';
import 'currentcart_notifier.dart';

class CartButton extends StatefulWidget {
  final int dishId;
  final double? savedAmount;
  final int balanceQuantity;
  final bool? sheduleorder;

  const CartButton({
    super.key,
    required this.dishId,
    this.savedAmount,
    required this.balanceQuantity,
    this.sheduleorder,
  });

  @override
  _CartButtonState createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuantity();
  }

  Future<void> _loadQuantity() async {
    try {
      final cart = await food_Authservice.fetchCart();

      CartItem? matchedItem;
      if (cart != null) {
        for (var item in cart.cartItems) {
          if (item.dishId == widget.dishId) {
            matchedItem = item;
            break;
          }
        }
      }

      setState(() => itemCount = matchedItem?.quantity ?? 0);
    } catch (e) {
      setState(() => itemCount = 0);
    }

    // update global cart badge
    Utils.refreshCartCount();
  }

  Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
    CartNotifier.count.value += quantity;

    final success = await food_Authservice.addToCart(
      dishId: widget.dishId,
      quantity: quantity,
      sheduleorder: sheduleorder,
    );
    final itemId = await food_Authservice.getItemIdByDishId(widget.dishId);

    if (itemId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("dish_${widget.dishId}_itemId", itemId);
      await prefs.setInt("dish_${widget.dishId}_quantity", quantity);
    }
  }

  Future<void> _removeFromCart() async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dishId}_itemId");

    if (itemId == null) return;

    // INSTANT SUBTRACT FROM CART BADGE
    CartNotifier.count.value -= itemCount;

    final removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      prefs.remove("dish_${widget.dishId}_quantity");
      prefs.remove("dish_${widget.dishId}_itemId");

      setState(() => itemCount = 0);
    }
  }

  Future<void> _updateQuantity(int newQty) async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
    final cartId = prefs.getInt("cartId");

    if (itemId != null) {
      // INSTANT CART BADGE UPDATE
      CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;

      await food_Authservice.updateCartQuantity(
          itemId,
           newQty
      );

      prefs.setInt("dish_${widget.dishId}_quantity", newQty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.balanceQuantity <= 0;

    return SizedBox(
      width: 120.w,
      height: 39.h,
      child: itemCount == 0
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(color: const Color(0xFFB15DC6), width: 1.w),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              onPressed: () async {
                final schedule = widget.balanceQuantity <= 0;

                // if (schedule) {
                //   _showScheduleMessage(context);
                // }

                setState(() => itemCount = 1);
                await _addToCart(1, sheduleorder: schedule);
                CartMode.type.value = CartType.normal;
              },

              child: Text(
                widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // 👈 NEVER greyed out
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFB15DC6), width: 1.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// ➖ Minus
                  IconButton(
                    icon: Icon(Icons.remove, size: 14.sp),
                    onPressed: () async {
                      if (itemCount > 1) {
                        setState(() => itemCount--);
                        await _updateQuantity(itemCount);
                      } else {
                        await _removeFromCart();
                        setState(() => itemCount = 0);
                      }
                    },
                  ),

                  Text(
                    "$itemCount",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// ➕ Plus (WITH VALIDATION)
                  GestureDetector(
                    onTap: itemCount >= widget.balanceQuantity
                        ? () {
                            _showScheduleMessage(context);
                          }
                        : null,
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 14.sp,
                        color:
                            // itemCount >= widget.balanceQuantity
                            //     ? Colors.grey
                            //     :
                            Colors.black,
                      ),
                      onPressed:
                          // itemCount >= widget.balanceQuantity
                          //     ? null // stays disabled visually
                          //     :
                          () async {
                            setState(() => itemCount++);
                            await _updateQuantity(itemCount);
                          },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showScheduleMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📅 Item is out of stock. You can schedule it."),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
