import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/food&beverages/orders_model.dart';
import 'Waiter_cartScreen.dart';

// ======================================================
// API CONSTANTS
// ======================================================
class ApiConstants {
  static const String baseurl = 'http://staging.maamaas.com:8080/food';
}

// ======================================================
// CART MODELS
// ======================================================
class CartItem {
  final int itemId;
  final int dishId;
  final int quantity;

  CartItem({
    required this.itemId,
    required this.dishId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] ?? 0,
      dishId: json['dishId'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

class Cart {
  final int cartId;
  final List<CartItem> items;

  Cart({required this.cartId, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'] ?? 0,
      items: (json['cartItems'] as List? ?? [])
          .map((e) => CartItem.fromJson(e))
          .toList(),
    );
  }
}

// ======================================================
// SERVICE LAYER
// ======================================================
class FoodAuthService {
  // ---------------- FETCH CART ----------------
  static Future<Cart?> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');
      final seatingId = prefs.getInt('seatingId');
      final token = prefs.getString('token');

      if (vendorId == null || seatingId == null || token == null) {
        debugPrint('❌ Missing credentials for fetchCart');
        return null;
      }

      final url = Uri.parse(
        '${ApiConstants.baseurl}/api/cart/getby/table/$vendorId/$seatingId',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        "📝 fetchCart response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        return Cart.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Exception in fetchCart: $e');
      return null;
    }
  }

  // ---------------- ADD TO CART ----------------
  static Future<bool> addToCart(int dishId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');
      final seatingId = prefs.getInt('seatingId');
      final token = prefs.getString('token');

      if (vendorId == null || seatingId == null || token == null) {
        debugPrint('❌ Missing credentials');
        return false;
      }

      final url = Uri.parse(
        '${ApiConstants.baseurl}/api/cart/waiter-order/$vendorId/$seatingId?tableCode=$seatingId',
      );

      final body = [
        {"dishId": dishId, "quantity": quantity},
      ];

      debugPrint("📤 addToCart request body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        "📝 addToCart response: ${response.statusCode} - ${response.body}",
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Exception in addToCart: $e');
      return false;
    }
  }

  // ---------------- UPDATE / REMOVE ITEM ----------------
  static Future<bool> updateItem({
    required int vendorId,
    required int cartId,
    required int itemId,
    required int quantity,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('❌ Missing token for updateItem');
        return false;
      }

      final url = Uri.parse(
        '${ApiConstants.baseurl}/api/cart/update/cart/$vendorId/$cartId?itemId=$itemId&quantity=$quantity',
      );

      debugPrint("📤 updateItem URL: $url");

      final response = await http.put(
        url,
        headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
      );

      debugPrint(
        "📝 updateItem response: ${response.statusCode} - ${response.body}",
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Exception in updateItem: $e');
      return false;
    }
  }
}

// ======================================================
// UI WIDGET
// ======================================================
class Waiter_CartButton extends StatefulWidget {
  final int dishId;
  final OrderType orderType;
  final int balanceQuantity;

  const Waiter_CartButton({
    super.key,
    required this.dishId,
    required this.orderType,
    required this.balanceQuantity,
  });

  @override
  State<Waiter_CartButton> createState() => _Waiter_CartButtonState();
}

class _Waiter_CartButtonState extends State<Waiter_CartButton> {
  int count = 0;
  bool loading = false;
  int? _cartId;
  int? _itemId;

  @override
  void initState() {
    super.initState();
    _loadFromServer();
  }

  // ---------------- LOAD CART ITEM ----------------
  Future<void> _loadFromServer() async {
    final cart = await FoodAuthService.fetchCart();

    if (cart == null) {
      setState(() {
        count = 0;
        _cartId = null;
        _itemId = null;
      });
      return;
    }

    _cartId = cart.cartId;

    final item = cart.items.where((e) => e.dishId == widget.dishId).toList();

    if (item.isNotEmpty) {
      setState(() {
        count = item.first.quantity;
        _itemId = item.first.itemId;
      });
    } else {
      setState(() {
        count = 0;
        _itemId = null;
      });
    }
  }

  // ---------------- ADD ----------------
  Future<void> _add() async {
    if (loading) return;
    if (widget.balanceQuantity <= 0) {
      _showSnackBar("Item is out of stock");
      return;
    }

    setState(() => loading = true);

    final success = await FoodAuthService.addToCart(widget.dishId, 1);

    if (success) {
      await _loadFromServer();
      _showSuccessSnackBar("Added to cart");
    } else {
      _showSnackBar("Failed to add item. Check console for details.");
      debugPrint("❌ Backend error while adding dishId ${widget.dishId}");
    }

    setState(() => loading = false);
  }

  // ---------------- UPDATE ----------------
  Future<void> _update(int newQty) async {
    if (loading) return;

    if (newQty > widget.balanceQuantity) {
      _showSnackBar("Cannot add more than ${widget.balanceQuantity} items");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId');

    if (vendorId == null || _cartId == null || _itemId == null) return;

    setState(() => loading = true);

    final success = await FoodAuthService.updateItem(
      vendorId: vendorId,
      cartId: _cartId!,
      itemId: _itemId!,
      quantity: newQty,
    );

    if (success) {
      setState(() {
        count = newQty;
        if (newQty == 0) _itemId = null;
      });
      _showSuccessSnackBar(
        newQty > 0 ? "$newQty item(s) updated" : "Item removed",
      );
    } else {
      _showSnackBar("Failed to update item. Check console for details.");
      debugPrint(
        "❌ Backend error updating itemId $_itemId to quantity $newQty",
      );
      await _loadFromServer();
    }

    setState(() => loading = false);
  }

  // ---------------- SNACKBARS ----------------
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: "View Cart",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Waiter_cartScreen()),
            );
          },
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final outOfStock = widget.balanceQuantity <= 0;

    if (count == 0) {
      return SizedBox(
        width: 120.w,
        height: 39.h,
        child: ElevatedButton(
          onPressed: outOfStock || loading ? null : _add,
          child: loading
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Colors.white,
                  ),
                )
              : Text(
                  outOfStock ? "Out of Stock" : "Add Cart",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    }

    // ---------------- Row with Expanded to fix overflow ----------------
    return SizedBox(
      width: 120.w,
      height: 39.h,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFB15DC6), width: 1.w),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30.w,
              child: IconButton(
                iconSize: 14.sp,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.remove),
                onPressed: loading
                    ? null
                    : () => _update(count > 1 ? count - 1 : 0),
              ),
            ),
            Expanded(
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: const Color(0xFFB15DC6),
                        ),
                      )
                    : Text("$count", style: TextStyle(fontSize: 12.sp)),
              ),
            ),
            SizedBox(
              width: 30.w,
              child: IconButton(
                iconSize: 14.sp,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add),
                onPressed: loading || count >= widget.balanceQuantity
                    ? null
                    : () => _update(count + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
