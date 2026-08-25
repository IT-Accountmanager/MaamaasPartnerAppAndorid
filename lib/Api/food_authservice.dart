import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/Api/APIclient.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/food&beverages/TopRestaurant.dart';
import '../Models/food&beverages/aboutus_model.dart';
import '../Models/food&beverages/add_employee.dart';
import '../Models/food&beverages/bannermodel.dart';
import '../Models/food&beverages/cart_model.dart';
import '../Models/food&beverages/cash_billing_model.dart';
import '../Models/food&beverages/coupon_model.dart';
import '../Models/food&beverages/custom_model.dart';
import '../Models/food&beverages/detailed_statisticsresponse_model.dart'
    hide TopSellingItem;
import '../Models/food&beverages/dish.dart';
import '../Models/food&beverages/ticket_model.dart';
import '../Models/food&beverages/timings_model.dart';
import '../Models/statistics_model.dart';
import '../user_module/widgets/utils.dart';
import 'WebSocket.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPER – shared prefs shortcuts
// ─────────────────────────────────────────────────────────────────────────────
Future<int?> _vendorId() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('vendorId');
  if (id == null || id == 0)
    // debugPrint('⚠️ vendorId not found');
    return (id == null || id == 0) ? null : id;
}

final _ws = WebSocketManager();

class food_authservice {
  // ── CANCEL ORDER ───────────────────────────────────────────────────────────
  static Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await ApiClient.put(
        'api/orders/cancel/total/order/$orderId',
        {},
        service: 'food',
      );

      // debugPrint('cancelOrder → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is bool) return body;
        if (body is Map<String, dynamic>) {
          if (body.containsKey('success')) return body['success'] == true;
          if (body.containsKey('status'))
            return body['status'].toString().toUpperCase() == 'SUCCESS' ||
                body['status'] == true;
          if (body.containsKey('message')) return true;
        }
        return true;
      }

      // debugPrint(
      //   'cancelOrder failed — ${response.statusCode}: ${response.body}',
      // );
      return false;
    } catch (e) {
      // debugPrint('cancelOrder error: $e');
      return false;
    }
  }

  // ── TABLE DINE-IN ──────────────────────────────────────────────────────────
  //
  // /// Generic status updater – all dine-in helpers delegate here.
  // Future<bool> updateTableDineInOrderStatust(int cartId, String status) async {
  //   try {
  //     final response = await ApiClient.put(
  //       'api/cart/status/$cartId?status=$status',
  //       {},
  //       service: 'food',
  //     );
  //     debugPrint('[TABLE_DINE_IN] ${response.statusCode} → ${response.body}');
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     debugPrint('[TABLE_DINE_IN] Error updating status: $e');
  //     return false;
  //   }
  // }
  //
  // Future<bool> acceptTableDineInOrder(int cartId) =>
  //     updateTableDineInOrderStatust(cartId, 'CONFIRMED');
  //
  // Future<bool> rejectTableDineInOrder(int cartId) =>
  //     updateTableDineInOrderStatust(cartId, 'CANCELLED');
  //
  // Future<bool> markTableDineInAsPreparing(int cartId) =>
  //     updateTableDineInOrderStatust(cartId, 'BEING_PREPARED');
  //
  // Future<bool> markTableDineInAsReady(int cartId) =>
  //     updateTableDineInOrderStatust(cartId, 'ORDER_IS_READY');
  //
  // Future<bool> markTableDineInAsServed(int cartId) =>
  //     updateTableDineInOrderStatust(cartId, 'COMPLETED');

  static Future<bool> updateTableDineInOrderStatus(
    int itemId,
    String status,
  ) async {
    try {
      // debugPrint(
      //   'Updating TABLE_DINE_IN order - itemId: $itemId, status: $status',
      // );

      if (itemId <= 0) {
        // debugPrint('Invalid itemId: $itemId');
        return false;
      }

      final response = await ApiClient.put(
        'api/cart/cartitem/status/$itemId?status=$status',
        null,
        service: 'food',
      );

      // debugPrint(
      //   'TABLE_DINE_IN update response status: ${response.statusCode}',
      // );

      // debugPrint('TABLE_DINE_IN update response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('Error updating TABLE_DINE_IN order status: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchTableDineInOrderst() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/cart/get/ordertype=TABLE_DINE_IN/$vendorId/PENDING',
        service: 'food',
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final List<dynamic> raw = data is List
            ? data
            : data is Map
            ? (data['data'] ?? data['content'] ?? [data])
            : [];

        return raw.map((o) {
          if (o is! Map<String, dynamic>) return o;
          final m = Map<String, dynamic>.from(o);
          m['orderType'] ??= 'TABLE_DINE_IN';
          m['status'] ??= 'PENDING';
          m['vendorId'] ??= vendorId;
          m['grandTotal'] ??= m['total'] ?? 0.0;
          if ((m['userName'] == null || m['userName'].toString().isEmpty) &&
              m['name'] != null) {
            m['userName'] = m['name'];
          }
          return m;
        }).toList();
      }
      return [];
    } catch (e) {
      // debugPrint('TABLE_DINE_IN fetch error: $e');
      return [];
    }
  }

  // ── DELIVERY ORDER ─────────────────────────────────────────────────────────

  /// Fetch a single delivery order by ID.
  static Future<Map<String, dynamic>> getDeliveryOrder(int orderId) async {
    try {
      final response = await ApiClient.get(
        'api/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES',
        service: 'delivery',
      );
      // debugPrint('DELIVERY STATUS: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed with status ${response.statusCode}');
    } catch (e) {
      // debugPrint('getDeliveryOrder error: $e');
      rethrow;
    }
  }

  // ── CART ORDER TYPE ────────────────────────────────────────────────────────

  static Future<bool> updateCartOrderType({
    required int cartId,
    required String orderType,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.put(
        'api/cart/update/order-type/$vendorId/$cartId?orderType=$orderType',
        {'orderType': orderType},
        service: 'food',
      );
      // debugPrint(
      //   'Update Order Type: ${response.statusCode} → ${response.body}',
      // );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateCartOrderType error: $e');
      return false;
    }
  }

  // ── SUBSCRIPTION / PAYMENT ────────────────────────────────────────────────

  Future<Map<String, dynamic>> createOrderSub({required double amount}) async {
    final body = {
      'amount': amount,
      'currency': 'INR',
      'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      'notes': {'source': 'flutter_app'},
    };
    final response = await ApiClient.post(
      'api/user/create-order',
      body,
      service: 'subscription',
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Create Order Failed: ${response.body}');
  }

  Future<bool> createVendorSubscription({
    required String planType,
    required String businessVertical,
    required String billingCycle,
    required List<int> selectedModules,
    required String transactionId,
    required double totalAmount,
    required bool termsAccepted,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final body = {
        'vendorId': vendorId,
        'planType': planType,
        'businessVertical': businessVertical,
        'billingCycle': billingCycle,
        'selectedModules': selectedModules,
        'transactionId': transactionId,
        'paymentMethod': 'Online_Payment',
        'totalAmount': totalAmount,
        'termsAccepted': termsAccepted,
      };

      final response = await ApiClient.post(
        'api/vendor/subscription',
        body,
        service: 'subscription',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('createVendorSubscription error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> capturePaymentSub({
    required String paymentId,
    required double amount,
  }) async {
    final body = {
      'paymentId': paymentId,
      'amount': amount,
      'currency': 'INR',
      'receipt': 'capture_${DateTime.now().millisecondsSinceEpoch}',
    };
    final response = await ApiClient.post(
      'api/user/capture',
      body,
      service: 'subscription',
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Capture Payment Failed: ${response.body}');
  }

  // ── CART ITEM QUANTITY ─────────────────────────────────────────────────────

  static Future<bool> updateCartItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final prefs = await SharedPreferences.getInstance();
      int? cartId = prefs.getInt('cartId');

      if (cartId == null) {
        final cart = await fetchCart();
        if (cart == null || cart.cartId == 0) {
          // debugPrint('❌ Could not get cartId');
          return false;
        }
        cartId = cart.cartId;
      }
      return await updateCartQuantity(cartId, itemId, quantity);
    } catch (e, stack) {
      // debugPrint('updateCartItemQuantity error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── BILLING SETUP ──────────────────────────────────────────────────────────

  static Future<http.Response> addBillingSetup({
    required double serviceCharges,
    required String serviceChargesType,
    required String serviceChargesApply,
    required String platformChargeType,
    required String initialOrderStatus,
    required String userOrderDestination,
  }) async {
    final vendorId = (await _vendorId()) ?? 0;
    final userInitialOrderStatus = userOrderDestination == 'Vendor'
        ? 'HOLD'
        : 'CONFIRMED';

    return ApiClient.post('api/billing/add/charges/$vendorId', {
      'id': 0,
      'serviceCharges': serviceCharges,
      'serviceChargesType': serviceChargesType,
      'serviceChargesApply': serviceChargesApply,
      'platformChargeType': platformChargeType,
      'initialOrderStatus': initialOrderStatus,
      'userInitialOrderStatus': userInitialOrderStatus,
      'vendorId': vendorId,
    }, service: 'food');
  }

  static Future<void> updateBillingSetup({
    required int id,
    required double serviceCharges,
    required String serviceChargesType,
    required String serviceChargesApply,
    required String platformChargeType,
    required int vendorId,
    required String orderDestination,
    required String userOrderDestination,
  }) async {
    final initialOrderStatus = orderDestination == 'Chef'
        ? 'DELIVERED'
        : 'CONFIRMED';
    final userInitialOrderStatus = userOrderDestination == 'Vendor'
        ? 'HOLD'
        : 'CONFIRMED';

    final body = {
      'id': id,
      'serviceCharges': serviceCharges,
      'serviceChargesType': serviceChargesType,
      'serviceChargesApply': serviceChargesApply,
      'platformChargeType': platformChargeType,
      'initialOrderStatus': initialOrderStatus,
      'userInitialOrderStatus': userInitialOrderStatus,
      'vendorId': vendorId,
    };

    // debugPrint('🔹 FULL Payload (UPDATE): ${jsonEncode(body)}');
    final response = await ApiClient.put(
      'api/billing/edit/$id',
      body,
      service: 'food',
    );
    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }
  }

  // ── WAITER / TABLE CART ────────────────────────────────────────────────────

  static Future<int?> addTo_Cart({
    required int dishId,
    required int quantity,
    required String orderType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');
      final seatingId = prefs.getInt('seatingId');
      final tableCode = prefs.getInt('tableCode');

      if (vendorId == null || seatingId == null) {
        // debugPrint('❌ Missing vendorId / seatingId');
        return null;
      }

      final response = await ApiClient.post(
        'api/cart/waiter-order/$vendorId/$seatingId?tableCode=$tableCode',
        [
          {'dishId': dishId, 'quantity': quantity},
        ],
        service: 'food',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final cartId = data['cartId'] ?? data['id'];

        // 🔌 Subscribe to real-time cart updates after adding item
        if (vendorId != null) {
          _ws.subscribeVendorCartUpdates(vendorId, (update) {
            // debugPrint(
            //   '🛒 [addTo_Cart] Cart update for vendor $vendorId: $update',
            // );
          });
        }

        return cartId;
      }
      return null;
    } catch (e) {
      // debugPrint('addTo_Cart error: $e');
      return null;
    }
  }

  static Future<CartModel?> fetch_Cart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');
      final seatingId = prefs.getInt('seatingId');

      if (vendorId == null || seatingId == null) return null;

      final response = await ApiClient.get(
        'api/cart/getby/table/$vendorId/$seatingId',
        service: 'food',
      );

      if (response.statusCode == 200) {
        return CartModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      // debugPrint('fetch_Cart error: $e');
      return null;
    }
  }

  static Future<bool> updateCartItem_Quantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final prefs = await SharedPreferences.getInstance();
      int? cartId = prefs.getInt('cartId');

      if (cartId == null) {
        final cart = await fetch_Cart();
        if (cart == null) return false;
        cartId = cart.cartId;
        await prefs.setInt('cartId', cartId);
      }

      bool updated = await updateCart_Quantity(cartId, itemId, quantity);
      if (!updated) {
        final latestCart = await fetch_Cart();
        if (latestCart == null) return false;
        cartId = latestCart.cartId;
        await prefs.setInt('cartId', cartId);
        updated = await updateCart_Quantity(cartId, itemId, quantity);
      }
      return updated;
    } catch (e, stack) {
      // debugPrint('updateCartItem_Quantity error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> updateCart_Quantity(
    int cartId,
    int itemId,
    int quantity,
  ) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.put(
        'api/cart/update/cart/$vendorId/$cartId?itemId=$itemId&quantity=$quantity',
        {'quantity': quantity},
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateCart_Quantity error: $e');
      return false;
    }
  }

  // ── TABLE DINE-IN ORDERS (static variants) ────────────────────────────────

  static Future<List<dynamic>> getTableDineInOrders(
    String vendorId,
    String status,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/cart/get/ordertype=TABLE_DINE_IN/$vendorId/$status',
        service: 'food',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to fetch orders');
      }

      final carts = responseData['data']?['carts'] ?? [];
      final List<Map<String, dynamic>> transformed = [];

      for (var cart in carts) {
        final List<Map<String, dynamic>> orderItems = [];
        if (cart['cartItems'] is List) {
          for (var item in cart['cartItems']) {
            orderItems.add({
              'listId': item['itemId'],
              'dishName': item['dishName'],
              'quantity': item['quantity'],
              'price': item['price'],
              'chefType': item['chefType'],
              'orderStatus': item['orderStatus'],
              'totalPrice': item['totalPrice'],
            });
          }
        }
        transformed.add({
          'orderId': cart['cartId'],
          'cartId': cart['cartId'],
          'vendorId': cart['vendorId'],
          'orderType': cart['orderType'],
          'status': cart['cartItems']?.isNotEmpty == true
              ? cart['cartItems'][0]['orderStatus']
              : 'CONFIRMED',
          'tableCode': cart['tableCode'],
          'seatingId': cart['seatingId'],
          'orderDateAndTime': cart['cartItems']?.isNotEmpty == true
              ? cart['cartItems'][0]['createdAt']
              : DateTime.now().toString(),
          'order': orderItems,
          'items': orderItems,
          'cartItems': cart['cartItems'],
          'grandTotal': cart['grandTotal'],
          'subtotal': cart['subtotal'],
        });
      }
      return transformed;
    } catch (e) {
      // debugPrint('getTableDineInOrders error: $e');
      rethrow;
    }
  }
  //
  // static Future<bool> updateTableDineInOrderStatus(
  //   String vendorId,
  //   String orderType,
  //   Map<String, dynamic> updateData,
  // ) async {
  //   try {
  //     final response =
  //         await ApiClient.put('api/cart/update/orderType/$vendorId', {
  //           'orderType': orderType,
  //           'cartId': updateData['cartId'],
  //           'itemUpdates': updateData['itemUpdates'],
  //         }, service: 'food');
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed: ${response.statusCode} - ${response.body}');
  //     }
  //     return json.decode(response.body)['success'] == true;
  //   } catch (e) {
  //     debugPrint('updateTableDineInOrderStatus error: $e');
  //     rethrow;
  //   }
  // }

  static Future<bool> updateCart({
    required int cartId,
    required int dishId,
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await ApiClient.put(
        'api/cart/update/cart/$cartId/$dishId?dishId=$dishId&itemId=$itemId&quantity=$quantity',
        null,
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateCart error: $e');
      return false;
    }
  }

  static Future<bool> addItemToCart({
    required int cartId,
    required int dishId,
    required int quantity,
  }) async {
    try {
      final response = await ApiClient.put(
        'api/cart/update/cart/$cartId/$dishId?dishId=$dishId&quantity=$quantity',
        null,
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('addItemToCart error: $e');
      return false;
    }
  }

  static Future<bool> updateTableDineInItemStatus(
    int itemId,
    String status,
  ) async {
    try {
      final vendorId = (await _vendorId()) ?? 1;
      final response = await ApiClient.put('api/cart/update/item/status', {
        'vendorId': vendorId,
        'itemId': itemId,
        'status': status,
        'orderType': 'TABLE_DINE_IN',
      }, service: 'food');
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }
      return json.decode(response.body)['success'] == true;
    } catch (e) {
      // debugPrint('updateTableDineInItemStatus error: $e');
      rethrow;
    }
  }

  // ── DELETE CART ────────────────────────────────────────────────────────────

  static Future<bool> delete_Cart(int cartId) async {
    try {
      final response = await ApiClient.delete(
        'api/cart/delete/$cartId',
        service: 'food',
      );
      if (response.statusCode == 200) return true;
      if (response.statusCode == 404 || response.statusCode == 500) return true;
      return false;
    } catch (e) {
      // debugPrint('delete_Cart error: $e');
      return false;
    }
  }

  // ── CATEGORY / DISH ────────────────────────────────────────────────────────

  static Future<bool> updateCategory({
    required int dishId,
    required String dishName,
    File? imageFile,
  }) async {
    try {
      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/dish/edit/$dishId',
        method: 'PUT',
        service: 'food',
        data: {
          'dishData': jsonEncode({'dishName': dishName}),
        },
        files: imageFile != null ? {'image': imageFile} : null,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('updateCategory error: $e');
      return false;
    }
  }

  static Future<bool> updateSubcategory({
    required int dishId,
    String? dishName,
    String? description,
    double? price,
    double? effectivePrice,
    String? tag,
    int? stockQuantity,
    double? discount,
    String? stock,
    String? menuStatus,
    File? imageFile,
  }) async {
    try {
      final Map<String, dynamic> dishData = {};
      if (dishName != null) dishData['dishName'] = dishName;
      if (description != null) dishData['description'] = description;
      if (price != null) dishData['price'] = price;
      if (effectivePrice != null) dishData['effectivePrice'] = effectivePrice;
      if (tag != null) dishData['tag'] = tag;
      if (stockQuantity != null) dishData['stockQuantity'] = stockQuantity;
      if (discount != null) dishData['discount'] = discount;
      if (stock != null) dishData['stock'] = stock;
      if (menuStatus != null) dishData['menuStatus'] = menuStatus;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/dish/edit/$dishId',
        method: 'PUT',
        service: 'food',
        data: {'dishData': jsonEncode(dishData)},
        files: imageFile != null ? {'image': imageFile} : null,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('updateSubcategory error: $e');
      return false;
    }
  }

  static Future<bool> deleteCategory(int dishId) async {
    try {
      final response = await ApiClient.delete(
        'api/dish/delete/$dishId',
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e, stack) {
      // debugPrint('deleteCategory error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── DISHES ─────────────────────────────────────────────────────────────────
  //
  // static Future<List<Dish>> fetchDishes({
  //   int? parentId,
  //   bool filterByMenuStatus = false,
  // }) async {
  //   try {
  //     final vendorId = await _vendorId();
  //     if (vendorId == null) return [];
  //
  //     final response = await ApiClient.get(
  //       'api/dish/getbyvendor/$vendorId',
  //       service: 'food',
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       List<Dish> dishes = data.map((j) => Dish.fromJson(j)).toList();
  //
  //       if (filterByMenuStatus) {
  //         dishes = dishes
  //             .where((d) => d.menuStatus?.toLowerCase() == 'enable')
  //             .toList();
  //       }
  //       if (parentId != null && parentId != 0) {
  //         dishes = dishes.where((d) => d.parentId == parentId).toList();
  //       }
  //       return dishes;
  //     }
  //     return [];
  //   } catch (e, stack) {
  //     // debugPrint('fetchDishes error: $e');
  //     // debugPrintStack(stackTrace: stack);
  //     return [];
  //   }
  // }
  //
  // static Future<List<Dish>> fetchParentCategories() async {
  //   final dishes = await fetchDishes();
  //   return dishes.where((d) => d.parentId == 0).toList();
  // }
  //
  // static Future<List<Dish>> fetchFilteredDishes({
  //   int? parentId,
  //   String? tag,
  //   String? searchQuery,
  //   bool filterByMenuStatus = false,
  // }) async {
  //   List<Dish> dishes = await fetchDishes(
  //     parentId: (parentId != null && parentId != 0) ? parentId : null,
  //     filterByMenuStatus: filterByMenuStatus,
  //   );
  //   if (tag != null) {
  //     dishes = dishes
  //         .where((d) => d.tag?.toLowerCase() == tag.toLowerCase())
  //         .toList();
  //   }
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     dishes = dishes
  //         .where(
  //           (d) => (d.dishName ?? '')
  //               .toLowerCase()
  //               .replaceAll(' ', '')
  //               .contains(searchQuery),
  //         )
  //         .toList();
  //   }
  //   return dishes;
  // }
  //
  // static Future<List<Dish>> getAllEnabledDishes({
  //   String? searchQuery,
  //   bool? isVeg,
  // }) async {
  //   List<Dish> dishes = await fetchDishes(filterByMenuStatus: true);
  //
  //   if (isVeg == true) {
  //     dishes = dishes.where((d) => d.tag?.toLowerCase() == 'veg').toList();
  //   }
  //   if (searchQuery != null && searchQuery.isNotEmpty) {
  //     dishes = dishes
  //         .where(
  //           (d) => (d.dishName ?? '')
  //               .toLowerCase()
  //               .replaceAll(' ', '')
  //               .contains(searchQuery),
  //         )
  //         .toList();
  //   }
  //   return dishes;
  // }
  static Future<int?> _vendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final dynamic raw =
          prefs.get('vendorId') ??
          prefs.get('vendor_id') ??
          prefs.get('vendorID') ??
          prefs.get('id');

      debugPrint(
        '_vendorId: raw value from prefs = $raw (type: ${raw?.runtimeType})',
      );

      if (raw == null) {
        debugPrint('_vendorId: no vendor id found in SharedPreferences');
        return null;
      }

      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw);

      return null;
    } catch (e, stack) {
      debugPrint('_vendorId error: $e');
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // static Future<List<Dish>> fetchDishes({
  //   int? parentId,
  //   bool filterByMenuStatus = false,
  // }) async {
  //   try {
  //     final vendorId = await _vendorId();
  //     if (vendorId == null) {
  //       debugPrint('fetchDishes: vendorId is null, aborting');
  //       return [];
  //     }
  //
  //     final response = await ApiClient.get(
  //       'api/dish/getbyvendor/$vendorId',
  //       service: 'food',
  //     );
  //
  //     debugPrint('fetchDishes: status=${response.statusCode}');
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       debugPrint('fetchDishes: received ${data.length} raw items');
  //
  //       List<Dish> dishes = data.map((j) => Dish.fromJson(j)).toList();
  //
  //       if (filterByMenuStatus) {
  //         dishes = dishes
  //             .where((d) => d.menuStatus?.toLowerCase() == 'enable')
  //             .toList();
  //         debugPrint(
  //           'fetchDishes: after menuStatus filter -> ${dishes.length}',
  //         );
  //       }
  //       if (parentId != null && parentId != 0) {
  //         dishes = dishes.where((d) => d.parentId == parentId).toList();
  //         debugPrint('fetchDishes: after parentId filter -> ${dishes.length}');
  //       }
  //       return dishes;
  //     } else {
  //       debugPrint('fetchDishes: non-200 response body=${response.body}');
  //     }
  //     return [];
  //   } catch (e, stack) {
  //     debugPrint('fetchDishes error: $e');
  //     debugPrintStack(stackTrace: stack);
  //     return [];
  //   }
  // }

  static Future<List<Dish>> fetchDishes({
    int? parentId,
    bool filterByMenuStatus = false,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) {
        debugPrint('fetchDishes: vendorId is null, aborting');
        return [];
      }

      final response = await ApiClient.get(
        'api/dish/getbyvendor/$vendorId',
        service: 'food',
      );

      debugPrint('fetchDishes: status=${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('fetchDishes: received ${data.length} raw items');

        List<Dish> dishes = data.map((j) => Dish.fromJson(j)).toList();

        // ── Only ever show APPROVED dishes/categories ─────────────────────
        dishes = dishes
            .where((d) => d.approvalStatus?.toUpperCase() == 'APPROVED')
            .toList();
        debugPrint(
          'fetchDishes: after approvalStatus filter -> ${dishes.length}',
        );

        if (filterByMenuStatus) {
          dishes = dishes
              .where((d) => d.menuStatus?.toLowerCase() == 'enable')
              .toList();
          debugPrint(
            'fetchDishes: after menuStatus filter -> ${dishes.length}',
          );
        }
        if (parentId != null && parentId != 0) {
          dishes = dishes.where((d) => d.parentId == parentId).toList();
          debugPrint('fetchDishes: after parentId filter -> ${dishes.length}');
        }
        return dishes;
      } else {
        debugPrint('fetchDishes: non-200 response body=${response.body}');
      }
      return [];
    } catch (e, stack) {
      debugPrint('fetchDishes error: $e');
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<List<Dish>> fetchParentCategories() async {
    final dishes = await fetchDishes();
    final parents = dishes.where((d) => d.parentId == 0).toList();
    debugPrint('fetchParentCategories: ${parents.length} parents found');
    return parents;
  }

  static Future<List<Dish>> fetchFilteredDishes({
    int? parentId,
    String? tag,
    String? searchQuery,
    bool filterByMenuStatus = false,
  }) async {
    List<Dish> dishes = await fetchDishes(
      parentId: (parentId != null && parentId != 0) ? parentId : null,
      filterByMenuStatus: filterByMenuStatus,
    );

    if (tag != null) {
      dishes = dishes
          .where((d) => d.tag?.toLowerCase() == tag.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase().replaceAll(' ', '');
      dishes = dishes
          .where(
            (d) => (d.dishName ?? '')
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(q),
          )
          .toList();
    }

    debugPrint(
      'fetchFilteredDishes: returning ${dishes.length} dishes '
      '(parentId=$parentId, tag=$tag, search="$searchQuery", filterByMenuStatus=$filterByMenuStatus)',
    );

    return dishes;
  }

  static Future<List<Dish>> getAllEnabledDishes({
    String? searchQuery,
    bool? isVeg,
  }) async {
    List<Dish> dishes = await fetchDishes(filterByMenuStatus: true);

    if (isVeg == true) {
      dishes = dishes.where((d) => d.tag?.toLowerCase() == 'veg').toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase().replaceAll(' ', '');
      dishes = dishes
          .where(
            (d) => (d.dishName ?? '')
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(q),
          )
          .toList();
    }

    return dishes;
  }
  // ── ORDERS ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> fetchProcessingOrders(int vendorId) async {
    final response = await ApiClient.get(
      'api/orders/status-range?vendorId=$vendorId&fromStatus=CONFIRMED&toStatus=WAITING_FOR_PICKUP',
      service: 'food',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode}');
    }
    return List<dynamic>.from(json.decode(response.body));
  }

  static Future<List<dynamic>> fetchScheduledOrders(int vendorId) async {
    final response = await ApiClient.get(
      'api/orders/status-range?vendorId=$vendorId&fromStatus=HOLD&toStatus=HOLD',
      service: 'food',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode}');
    }
    return List<dynamic>.from(json.decode(response.body));
  }

  static Future<Map<String, dynamic>?> fetchVendorRegistrationDetails() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/vendors/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      // debugPrint('fetchVendorRegistrationDetails error: $e');
      return null;
    }
  }

  // ── STATISTICS ─────────────────────────────────────────────────────────────

  static Future<StatisticsResponse?> fetchVendorStatistics() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/orders/vendor/statistics/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return StatisticsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchVendorStatistics error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<CustomStatisticsResponse?> fetchCustomStatistics({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/orders/vendor/statistics/custom?vendorId=$vendorId&fromDate=$fromDate&toDate=$toDate',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return CustomStatisticsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchCustomStatistics error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<DetailedStatisticsResponse?> fetchDetailedStatistics({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/orders/vendor/statistics/custom?vendorId=$vendorId&fromDate=$fromDate&toDate=$toDate',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return DetailedStatisticsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchDetailedStatistics error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // ── TIMINGS ────────────────────────────────────────────────────────────────

  static Future<List<Timing>> fetchVendorTimings() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/timings/get/timings/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Timing.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // debugPrint('fetchVendorTimings error: $e');
      return [];
    }
  }

  static Future<http.Response> editVendorTiming({
    required int id,
    required String day,
    required String startTime,
    required String lastTime,
  }) => ApiClient.put('api/timings/edit/timings/$id', {
    'day': day,
    'startTime': startTime,
    'lastTime': lastTime,
  }, service: 'food');

  static Future<http.Response> deleteVendorTiming(int id) =>
      ApiClient.delete('api/timings/delete/day/timings/$id', service: 'food');

  static Future<http.Response> addVendorTiming({
    required String day,
    required String startTime,
    required String lastTime,
  }) async {
    final vendorId = await _vendorId();
    return ApiClient.post('api/timings/daytimings/$vendorId', {
      'day': day,
      'startTime': startTime,
      'lastTime': lastTime,
    }, service: 'food');
  }

  // ── BILLING SETUP (fetch) ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchBillingSetup() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/billing/get/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      // debugPrint('fetchBillingSetup error: $e');
      return null;
    }
  }

  // ── ABOUT US ───────────────────────────────────────────────────────────────

  static Future<bool> updateAboutUsComplete({
    required String aboutUs,
    String? mission,
    String? vision,
    File? image,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final data = {
        'aboutUs': aboutUs,
        if (mission != null) 'mission': mission,
        if (vision != null) 'vision': vision,
      };
      final files = <String, File>{};
      if (image != null && await image.exists()) files['image'] = image;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/vendor/aboutus/update/$vendorId',
        method: 'PUT',
        service: 'food',
        data: data,
        files: files.isNotEmpty ? files : null,
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateAboutUsComplete error: $e');
      return false;
    }
  }

  static Future<bool> updateAboutUsWithImage({
    required String aboutUs,
    File? image,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final aboutUsData = jsonEncode({
        'aboutUsId': 0,
        'aboutUs': aboutUs,
        'mission': '',
        'vision': '',
        'vendorId': vendorId,
      });

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/vendor/aboutus/add/$vendorId',
        method: 'POST',
        service: 'food',
        data: {'aboutUsData': aboutUsData},
        files: image != null ? {'image': image} : null,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('updateAboutUsWithImage error: $e');
      return false;
    }
  }

  static Future<bool> updateMissionAndVision({
    required String mission,
    required String vision,
    String aboutUsText = '',
    File? image,
    File? image1,
    File? image2,
    File? image3,
    File? image4,
    int aboutUsId = 0,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final aboutUsData = jsonEncode({
        'aboutUsId': aboutUsId,
        'aboutUs': aboutUsText,
        'mission': mission,
        'vision': vision,
        'vendorId': vendorId,
      });

      final files = <String, File>{};
      if (image != null) files['image'] = image;
      if (image1 != null) files['image1'] = image1;
      if (image2 != null) files['image2'] = image2;
      if (image3 != null) files['image3'] = image3;
      if (image4 != null) files['image4'] = image4;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/vendor/aboutus/add/$vendorId',
        method: 'POST',
        service: 'food',
        data: {'aboutUsData': aboutUsData},
        files: files.isNotEmpty ? files : null,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('updateMissionAndVision error: $e');
      return false;
    }
  }

  // ── DASHBOARD STATS ────────────────────────────────────────────────────────

  static Future<DashboardStatsModel?> getVendorDashboardStats(
    int vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/orders/vendor/statistics/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(json.decode(response.body));
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      // debugPrint('getVendorDashboardStats error: $e');
      return null;
    }
  }

  // ── SINGLE ORDER ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchOrderById([int? orderId]) async {
    try {
      if (orderId == null) {
        final prefs = await SharedPreferences.getInstance();
        orderId = prefs.getInt('orderId');
        if (orderId == null) return null;
      }
      final response = await ApiClient.get(
        'api/orders/order/$orderId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // debugPrint('fetchOrderById error: $e');
      return null;
    }
  }

  // ── CASH BILLING ───────────────────────────────────────────────────────────

  static Future<List<CashBilling>> fetchCashBillingData() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/cash-billing/vendor/get/$vendorId',
        service: 'food',
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((e) => CashBilling.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (decoded is Map<String, dynamic>) {
        final listEntry = decoded.values.firstWhere(
          (v) => v is List,
          orElse: () => null,
        );
        if (listEntry != null) {
          return (listEntry as List)
              .map((e) => CashBilling.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [CashBilling.fromJson(decoded)];
      }
      return [];
    } catch (e, stack) {
      // debugPrint('fetchCashBillingData error: $e');
      // debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  // ── TICKETS ────────────────────────────────────────────────────────────────

  static Future<List<Ticket>> fetchTicketsByUser() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/vendor-tickets/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return [];

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Ticket.fromJson(j)).toList();
    } catch (e, stack) {
      // debugPrint('fetchTicketsByUser error: $e');
      // debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<bool> createTicket({
    String? orderId,
    required String message,
    String? category,
    String? attachmentBase64,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final endpoint = orderId != null
          ? 'api/vendor-tickets/order/$orderId'
          : 'api/vendor-tickets/create';

      String mapTicketType(String? c) {
        switch (c) {
          case 'DELIVERY_ISSUE':
          case 'WRONG_ORDER':
            return 'ORDER_COMPLAINT';
          case 'PAYMENT_PROBLEM':
            return 'PAYOUT_ISSUE';
          case 'SERVICE_QUALITY':
            return 'TECHNICAL_SUPPORT';
          default:
            return 'OTHER';
        }
      }

      final body = {
        'vendorId': vendorId,
        'ticketType': orderId != null
            ? 'ORDER_COMPLAINT'
            : mapTicketType(category),
        'message': message.trim(),
        'attachmentUrl': attachmentBase64?.isNotEmpty == true
            ? attachmentBase64
            : null,
      };

      final response = await ApiClient.post(endpoint, body, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('createTicket error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── ALL ORDERS ─────────────────────────────────────────────────────────────

  /// Fetch all orders and subscribe to real-time vendor order updates.
  static Future<List<Map<String, dynamic>>> getAllOrders({
    Function(Map<String, dynamic>)? onRealtimeUpdate,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      // 🔌 Subscribe to real-time vendor order updates
      _ws.connectFoodSocket();
      _ws.subscribeVendorOrders(vendorId, (update) {
        // debugPrint('📦 [getAllOrders] Vendor order update: $update');
        onRealtimeUpdate?.call(update);
      });

      final response = await ApiClient.get(
        'api/orders/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (json.decode(response.body) as List)
            .cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e, stack) {
      // debugPrint('getAllOrders error: $e');
      // debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await ApiClient.put(
        'api/orders/edit-orders/$orderId/$status?status=$status',
        {},
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e, stack) {
      // debugPrint('updateOrderStatus error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> cancelOrderItem(int listId) async {
    try {
      final response = await ApiClient.put(
        'api/orderscancellationlist/edit/$listId',
        {'status': 'Cancelled'},
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e, stack) {
      // debugPrint('cancelOrderItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> deleteDish(int dishId) async {
    try {
      final response = await ApiClient.delete(
        'api/dish/delete/$dishId',
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e, stack) {
      // debugPrint('deleteDish error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── PAYMENT (food) ─────────────────────────────────────────────────────────

  static Future<String?> createOrder(double amount) async {
    try {
      final response = await ApiClient.post('api/payments/create-order/user', {
        'amount': amount,
        'currency': 'INR',
        'receipt': 'receipt#${DateTime.now().millisecondsSinceEpoch}',
        'notes': {'key1': 'value3', 'key2': 'value2'},
      }, service: 'food');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final orderId = data['orderId'] ?? data['id'];
        return orderId?.toString();
      }
      return null;
    } catch (e, stack) {
      // debugPrint('createOrder error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final response = await ApiClient.post('api/payments/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
        'receipt': 'order#${DateTime.now().millisecondsSinceEpoch}',
      }, service: 'food');
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('capturePayment error: $e');
      return false;
    }
  }

  // ── CART (vendor) ──────────────────────────────────────────────────────────

  static Future<CartModel?> fetchCart() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/cart/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CartModel.fromJson(jsonDecode(response.body));
      }
      if (response.statusCode == 404 ||
          (response.statusCode == 500 &&
              response.body.contains('No empty cart found'))) {
        return null;
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchCart error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<int?> getItemIdByDishId(int dishId) async {
    final cart = await fetchCart();
    if (cart == null) return null;
    final item = cart.cartItems
        .cast<dynamic>()
        .where((i) => i.dishId == dishId)
        .toList();
    return item.isNotEmpty ? item.first.itemId : null;
  }

  static Future<void> updateOrderTypeForCartItems(
    List<CartItem> items,
    String newOrderType,
  ) async {
    if (items.isEmpty) return;
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return;

      final response = await ApiClient.put(
        'api/cart/update/orderType/$vendorId?orderType=$newOrderType',
        {'itemIds': items.map((e) => e.itemId).toList()},
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        for (final item in items) {
          item.orderType = newOrderType;
        }
      }
    } catch (e, stack) {
      // debugPrint('updateOrderTypeForCartItems error: $e');
      // debugPrintStack(stackTrace: stack);
    }
  }

  /// Add to cart and subscribe to real-time cart updates.
  static Future<int?> addToCart({
    required int dishId,
    required int quantity,
    required String orderType,
    Function(Map<String, dynamic>)? onCartUpdate,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final cart = await fetchCart();
      if (cart != null && cart.cartItems.isNotEmpty) {
        if (cart.cartItems.any((i) => i.orderType != orderType)) {
          await updateOrderTypeForCartItems(cart.cartItems, orderType);
        }
      }

      final response = await ApiClient.post(
        'api/cart/add/vendor/$vendorId?orderType=$orderType',
        {'dishId': dishId, 'quantity': quantity},
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final cartId = data['cartId'] ?? data['id'];

        // 🔌 Subscribe to real-time cart updates after adding to cart
        _ws.connectFoodSocket();
        _ws.subscribeVendorCartUpdates(vendorId, (update) {
          // debugPrint('🛒 [addToCart] Cart update: $update');
          onCartUpdate?.call(update);
        });

        return cartId;
      }
      return null;
    } catch (e, stack) {
      // debugPrint('addToCart error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<bool> removeFromCart(int itemId) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.delete(
        'api/cart/vendor/items/$itemId?vendorId=$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) return true;
      if (response.statusCode == 500) {
        try {
          final body = jsonDecode(response.body);
          if (body['message'] == 'Cart not found') return true;
        } catch (_) {}
      }
      return false;
    } catch (e, stack) {
      // debugPrint('removeFromCart error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> removeItemFromCart(int itemId) => removeFromCart(itemId);

  // ── CASH DENOMINATIONS ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> saveCashDenominationsWithPaidStatus({
    required int orderId,
    required Map<String, dynamic> cashData,
  }) async {
    try {
      final response = await ApiClient.post(
        'api/cash-billing/addCash/$orderId',
        cashData,
        service: 'food',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final real = jsonDecode(response.body) as Map<String, dynamic>;
        final faked = Map<String, dynamic>.from(real);
        faked['paymentStatus'] = 'PAID';
        return faked;
      }
      throw Exception('Failed: ${response.statusCode}');
    } catch (e, stack) {
      // debugPrint('saveCashDenominations error: $e');
      // debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  static Future<bool> addToCartWithOrderType({
    required int dishId,
    required int vendorId,
    required String orderType,
    int quantity = 1,
  }) async {
    try {
      final response = await ApiClient.post(
        'api/cart/add/vendor/$vendorId?orderType=$orderType',
        {'dishId': dishId, 'quantity': quantity},
        service: 'food',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('addToCartWithOrderType error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── PLACE DIRECT ORDER ─────────────────────────────────────────────────────

  /// Place a direct order and subscribe to its real-time status updates.
  static Future<Map<String, dynamic>?> placeDirectOrder({
    required int vendorId,
    required int cartId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    String? walletType,
    List<Map<String, dynamic>>? cashPaymentData,
    Function(Map<String, dynamic>)? onOrderStatusUpdate,
  }) async {
    try {
      final cart = await fetchCart();
      if (cart == null || cart.cartId == 0) {
        throw Exception('Cart not found or empty');
      }

      final queryParams = {
        'vendorId': vendorId.toString(),
        'paymentMethod': paymentMethod,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        if (walletType != null) 'walletType': walletType,
      };
      final queryString = Uri(queryParameters: queryParams).query;

      final List<dynamic> body =
          (cashPaymentData != null && cashPaymentData.isNotEmpty)
          ? cashPaymentData
          : [];

      final response = await ApiClient.post(
        'api/orders/orders/vendor/create/${cart.cartId}?$queryString',
        body,
        service: 'food',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;

        // 🔌 Subscribe to real-time order status updates after placing order
        final placedOrderId = result['orderId'] ?? result['id'];
        if (placedOrderId != null) {
          _ws.connectFoodSocket();
          _ws.subscribeOrderStatus(placedOrderId, (update) {
            // debugPrint(
            //   '📦 [placeDirectOrder] Order $placedOrderId status update: $update',
            // );
            onOrderStatusUpdate?.call(update);
          });
        }

        return result;
      }
      throw Exception('Failed Direct Order: ${response.statusCode}');
    } catch (e, stack) {
      // debugPrint('placeDirectOrder error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // ── REMOVE CART ITEM ──────────────────────────────────────────────────────

  static Future<bool> removeCartItem(int itemId) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final cart = await fetchCart();
      if (cart == null || cart.cartId == 0) return false;

      final response = await ApiClient.delete(
        'api/cart/vendor/items/$vendorId/${cart.cartId}/$itemId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) return true;
      if (response.statusCode == 500) {
        try {
          final body = jsonDecode(response.body);
          if (body['message'] == 'Cart not found' ||
              body['message'] == 'Item not found')
            return true;
        } catch (_) {}
      }
      return false;
    } catch (e, stack) {
      // debugPrint('removeCartItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── CART QUANTITY ──────────────────────────────────────────────────────────

  Future<bool> updateCartQuantitycart(
    int cartId,
    int itemId,
    int quantity,
  ) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.put(
        'api/cart/update/cart/$cartId/$vendorId?dishId=$itemId&quantity=$quantity',
        {},
        service: 'food',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final cart = await fetchCart();
          if (cart != null) {
            Utils.itemCount.value = cart.cartItems.fold(
              0,
              (sum, i) => sum + i.quantity,
            );
          }
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e) {
      // debugPrint('updateCartQuantitycart error: $e');
      return false;
    }
  }

  static Future<bool> updateCartQuantity(
    int cartId,
    int dishId,
    int quantity,
  ) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null || quantity <= 0) return false;

      final response = await ApiClient.put(
        'api/cart/update/cart/$vendorId/$cartId?dishId=$dishId&quantity=$quantity',
        {},
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }
      return false;
    } catch (e, stack) {
      // debugPrint('updateCartQuantity error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> deleteCart(int cartId) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null || cartId == 0) return false;

      final response = await ApiClient.delete(
        'api/cart/delete/$vendorId/$cartId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) return true;
      if (response.statusCode == 500 || response.statusCode == 404) {
        try {
          if (jsonDecode(response.body)['message'] == 'Cart not found') {
            return true;
          }
        } catch (_) {}
      }
      return false;
    } catch (e, stack) {
      // debugPrint('deleteCart error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── SERVICE CHARGES / COUPON ───────────────────────────────────────────────

  static Future<bool> updateServiceCharges({
    required int cartId,
    required String serviceCharge,
  }) async {
    try {
      if (cartId == 0 || serviceCharge.trim().isEmpty) return false;

      final response = await ApiClient.put('api/cart/coupon/$cartId', {
        'serviceCharge': serviceCharge.trim(),
      }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('updateServiceCharges error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── CREATE CATEGORY ────────────────────────────────────────────────────────

  static Future<bool> createCategory({
    required String name,
    required int parentId,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/dish/add/$vendorId',
        method: 'POST',
        service: 'food',
        data: {
          'dishData': jsonEncode({
            'dishName': name.trim(),
            'parentId': parentId,
            'stockQuantity': stockQuantity,
            'price': 0,
          }),
        },
        files: imageFile != null ? {'image': imageFile} : null,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('createCategory error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<List<Employee>> fetchEmployees() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/get-employees/enquiry/$vendorId',
        service: 'subscription',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return [];
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => Employee.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e, stack) {
      // debugPrint('fetchEmployees error: $e');
      // debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<bool> registerVendor(Map<String, dynamic> employeeData) async {
    try {
      final response = await ApiClient.post(
        'api/vendor/enquiry',
        employeeData,
        service: 'subscription',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('registerVendor error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<List<Ticket>> fetchTickets() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/vendor-tickets/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return [];
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e, stack) {
      // debugPrint('fetchTickets error: $e');
      // debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<bool> submitTicket({
    required String ticketType,
    required String message,
    String attachmentUrl = '',
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;
      if (ticketType.trim().isEmpty || message.trim().isEmpty) return false;

      final response = await ApiClient.post('api/vendor-tickets/create', {
        'vendorId': vendorId,
        'ticketType': ticketType.trim(),
        'message': message.trim(),
        'attachmentUrl': attachmentUrl.trim(),
      }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('submitTicket error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── COUPONS ────────────────────────────────────────────────────────────────

  static Future<List<Coupon>> fetchCoupons() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/vendor/coupon/getByVendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return [];
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e, stack) {
      if (kDebugMode) {
        // debugPrint('fetchCoupons error: $e');
        // debugPrintStack(stackTrace: stack);
      }
      return [];
    }
  }

  static Future<void> updateCouponPayment(
    String vendorRequirementCouponId,
    String transactionId,
    String orderId,
  ) async {
    try {
      if (vendorRequirementCouponId.trim().isEmpty ||
          transactionId.trim().isEmpty ||
          orderId.trim().isEmpty) {
        throw Exception('Invalid coupon payment parameters');
      }

      final queryString = Uri(
        queryParameters: {
          'vendorRequirementCouponId': vendorRequirementCouponId.trim(),
          'transactionId': transactionId.trim(),
          'orderId': orderId.trim(),
        },
      ).query;

      final response = await ApiClient.put(
        'api/vendor/coupon/updatePayment?$queryString',
        {},
        service: 'food',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update coupon payment');
      }
    } catch (e, stack) {
      // debugPrint('updateCouponPayment error: $e');
      // debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  static Future<bool> createPromotion({
    required String couponCode,
    required String description,
    required double discount,
    required String discountType,
    required String couponType,
    required double minimumOrderValue,
    DateTime? startDate,
    DateTime? endDate,
    XFile? imageFile,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;
      if (couponCode.trim().isEmpty || description.trim().isEmpty) return false;

      String? base64Image;
      if (imageFile != null) {
        base64Image = base64Encode(await imageFile.readAsBytes());
      }

      final body = <String, dynamic>{
        'couponCode': couponCode.trim(),
        'description': description.trim(),
        'discount': discount,
        'discountType': discountType,
        'couponType': couponType,
        'minimumOrderValue': minimumOrderValue,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'active': true,
        if (base64Image != null) 'image': base64Image,
      };
      body.removeWhere((_, v) => v == null);

      final response = await ApiClient.post(
        'api/vendor/coupon/add/$vendorId',
        body,
        service: 'food',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('createPromotion error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> postFoodItem({
    required Map<String, dynamic> dishData,
    File? imageFile,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return false;

      final payload = Map<String, dynamic>.from(dishData);
      payload['vendorId'] = vendorId;

      final tag = payload['tag']?.toString().toLowerCase();
      if (tag != null) {
        payload['tag'] = (tag == 'non-veg' || tag == 'non_veg')
            ? 'Non_Veg'
            : 'Veg';
      }
      payload.removeWhere(
        (k, _) => k == 'image' || k == 'dishImage' || k == 'dishImageUrl',
      );

      Map<String, File>? files;
      if (imageFile != null && await imageFile.exists()) {
        files = {'image': imageFile};
      }

      final response = await ApiClient.sendMultipartRequest(
        method: 'POST',
        service: 'food',
        endpoint: 'api/dish/add/$vendorId',
        data: {'dishData': jsonEncode(payload)},
        files: files,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('postFoodItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> createDish({
    required String name,
    required int parentId,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null || name.trim().isEmpty) return false;

      Map<String, File>? files;
      if (imageFile != null && await imageFile.exists()) {
        files = {'image': imageFile};
      }

      final response = await ApiClient.sendMultipartRequest(
        method: 'POST',
        service: 'food',
        endpoint: 'api/dish/add/$vendorId',
        data: {
          'dishData': jsonEncode({
            'dishName': name.trim(),
            'parentId': parentId,
            'stockQuantity': stockQuantity,
          }),
        },
        files: files,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('createDish error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> updateDish({
    required int dishId,
    required Map<String, dynamic> dishData,
    File? imageFile,
  }) async {
    try {
      if (dishId <= 0) return false;

      final payload = Map<String, dynamic>.from(dishData);
      payload.removeWhere(
        (k, _) => k == 'image' || k == 'dishImage' || k == 'dishImageUrl',
      );

      Map<String, File>? files;
      if (imageFile != null && await imageFile.exists()) {
        files = {'image': imageFile};
      }

      final response = await ApiClient.sendMultipartRequest(
        method: 'PUT',
        service: 'food',
        endpoint: 'api/dish/edit/$dishId',
        data: {'dishData': jsonEncode(payload)},
        files: files,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('updateDish error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<void> updateMenuStatus({
    required int dishId,
    required bool status,
  }) async {
    if (dishId <= 0) throw Exception('Invalid dishId');
    final response = await ApiClient.put('api/dish/editmenu/$dishId', {
      'menuStatus': status ? 'Enable' : 'Disable',
    }, service: 'food');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update menu status');
    }
  }

  static Future<void> updateStockStatus({
    required int dishId,
    required String status,
  }) async {
    const allowed = ['In_Stock', 'Out_of_Stock'];
    if (dishId <= 0 || !allowed.contains(status)) {
      throw Exception('Invalid dishId or stock status');
    }
    final response = await ApiClient.put('api/dish/stock/$dishId', {
      'stock': status,
    }, service: 'food');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update stock status');
    }
  }

  static Future<bool> editFoodItem(
    int dishId,
    Map<String, dynamic> payload,
  ) async {
    try {
      if (dishId <= 0) return false;

      final body = Map<String, dynamic>.from(payload);
      body.removeWhere(
        (k, _) => k == 'image' || k == 'dishImage' || k == 'dishImageUrl',
      );

      final response = await ApiClient.put(
        'api/dish/edit/$dishId',
        body,
        service: 'food',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('editFoodItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── INVENTORY ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchItems() async {
    final vendorId = await _vendorId();
    if (vendorId == null) throw Exception('Vendor ID not found');

    final response = await ApiClient.get(
      'api/inventory/get-item/$vendorId',
      service: 'food',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    throw Exception('Failed to fetch items: ${response.statusCode}');
  }

  static Future<bool> deleteItem(int itemId) async {
    try {
      if (itemId <= 0) return false;
      final response = await ApiClient.delete(
        'api/inventory/delete/$itemId',
        service: 'food',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('deleteItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> saveChefInventory({
    required String chefName,
    required String itemName,
    required int consume,
    required String date,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null ||
          chefName.trim().isEmpty ||
          itemName.trim().isEmpty ||
          consume <= 0)
        return false;

      final response = await ApiClient.post('api/inventory/consume/$vendorId', {
        'id': 0,
        'chefName': chefName.trim(),
        'itemName': itemName.trim(),
        'consume': consume,
        'date': date,
        'vendorId': vendorId,
      }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('saveChefInventory error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> addItemToInventory({
    required String itemName,
    required int quantity,
    required int consumed,
    required int procurementValue,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null ||
          itemName.trim().isEmpty ||
          quantity < 0 ||
          consumed < 0 ||
          procurementValue < 0)
        return false;

      final response = await ApiClient.post('api/inventory/add/$vendorId', {
        'id': 0,
        'itemName': itemName.trim(),
        'quantity': quantity,
        'balance': quantity - consumed,
        'consumed': consumed,
        'procurementValue': procurementValue,
        'date': DateTime.now().toIso8601String(),
        'vendorId': vendorId,
      }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('addItemToInventory error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> updateItem({
    required int itemId,
    required String name,
    required int quantity,
    required int consumed,
  }) async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null ||
          itemId <= 0 ||
          name.trim().isEmpty ||
          quantity < 0 ||
          consumed < 0)
        return false;

      final response = await ApiClient.put('api/inventory/update/$itemId', {
        'itemName': name.trim(),
        'quantity': quantity,
        'consumed': consumed,
      }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('updateItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchChefInventory() async {
    final vendorId = await _vendorId();
    if (vendorId == null) throw Exception('Vendor ID not found');

    final response = await ApiClient.get(
      'api/inventory/chef/vendor/$vendorId',
      service: 'food',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (jsonDecode(response.body) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw Exception('Failed to fetch chef inventory');
  }

  static Future<String> deleteChefInventory({required int id}) async {
    if (id <= 0) throw Exception('Invalid chef inventory ID');
    final response = await ApiClient.delete(
      'api/inventory/chef/delete/$id',
      service: 'food',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }
    throw Exception('Failed to delete chef inventory');
  }

  static Future<List<Map<String, dynamic>>> fetchProcurementCart() async {
    final vendorId = await _vendorId();
    if (vendorId == null) throw Exception('Vendor ID not found');

    final response = await ApiClient.get(
      'api/inventory/procurement/vendor/$vendorId',
      service: 'food',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (jsonDecode(response.body) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw Exception('Failed to fetch procurement cart');
  }

  static Future<bool> updateProcurementItem({
    required int id,
    required String itemName,
    required int balance,
    required String date,
    required int procurementQuantity,
    required int vendorId,
  }) async {
    try {
      if (id <= 0) return false;
      final response =
          await ApiClient.put('api/inventory/procurement/update/$id', {
            'id': id,
            'itemName': itemName.trim(),
            'balance': balance,
            'date': date,
            'procurementQuantity': procurementQuantity,
            'vendorId': vendorId,
          }, service: 'food');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('updateProcurementItem error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  // ── ADVERTISEMENTS ─────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchAdvertisements() async {
    final vendorId = await _vendorId();
    if (vendorId == null) throw Exception('Vendor ID not found');

    final response = await ApiClient.get(
      'api/advertisements/getby/$vendorId',
      service: 'food',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final dynamic data =
          (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('data'))
          ? jsonResponse['data']
          : jsonResponse;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    }
    throw Exception('Failed to fetch advertisements');
  }

  // ── VENDOR BANNER ──────────────────────────────────────────────────────────

  static Future<bool> submitVendorBanner({
    required bool isEditing,
    String? bannerId,
    required String vendorId,
    required String companyName,
    required String establishedYear,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? twitter,
    File? bannerFile,
    File? logoFile,
  }) async {
    try {
      if (companyName.trim().isEmpty) return false;
      if (isEditing && (bannerId == null || bannerId.isEmpty)) return false;

      final endpoint = isEditing
          ? 'api/banner/edit/$bannerId'
          : 'api/banner/add/$vendorId';

      final bannerData = jsonEncode({
        'companyName': companyName.trim(),
        'establishedYear': establishedYear,
        'whatsappLink': whatsapp ?? '',
        'instagramLink': instagram ?? '',
        'facebookLink': facebook ?? '',
        'twitterLink': twitter ?? '',
      });

      final files = <String, File>{};
      if (bannerFile != null) files['companyBanner'] = bannerFile;
      if (logoFile != null) files['companyLogo'] = logoFile;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: endpoint,
        method: isEditing ? 'PUT' : 'POST',
        service: 'food',
        data: {'bannerData': bannerData},
        files: files.isNotEmpty ? files : null,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stack) {
      // debugPrint('submitVendorBanner error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<AboutUsModel?> fetchVendorAboutUs() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/vendor/aboutus/get/$vendorId',
        service: 'food',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AboutUsModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchVendorAboutUs error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<BannerModel?> fetchVendorBanner() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return null;

      final response = await ApiClient.get(
        'api/banner/$vendorId',
        service: 'food',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final bannerJson = decoded.containsKey('data')
            ? decoded['data']
            : decoded;
        if (bannerJson is Map<String, dynamic>) {
          return BannerModel.fromJson(bannerJson);
        }
      }
      return null;
    } catch (e, stack) {
      // debugPrint('fetchVendorBanner error: $e');
      // debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // ── WEBSOCKET HELPERS ──────────────────────────────────────────────────────

  /// Start listening to all vendor-level real-time channels at once.
  /// Call this when the vendor logs in / app starts.
  static Future<void> connectAndSubscribeAll({
    Function(Map<String, dynamic>)? onVendorOrder,
    Function(Map<String, dynamic>)? onOnlineOrder,
    Function(Map<String, dynamic>)? onOfflineOrder,
    Function(Map<String, dynamic>)? onCartUpdate,
  }) async {
    final vendorId = await _vendorId();
    if (vendorId == null) return;

    _ws.connectFoodSocket();

    if (onVendorOrder != null) {
      _ws.subscribeVendorOrders(vendorId, onVendorOrder);
    }
    if (onOnlineOrder != null) {
      _ws.subscribeOnlineOrders(vendorId, onOnlineOrder);
    }
    if (onOfflineOrder != null) {
      _ws.subscribeOfflineOrders(vendorId, onOfflineOrder);
    }
    if (onCartUpdate != null) {
      _ws.subscribeVendorCartUpdates(vendorId, onCartUpdate);
    }

    // debugPrint('✅ All WS channels subscribed for vendor $vendorId');
  }

  /// Subscribe to live status updates for a specific order.
  static Future<void> watchOrderStatus(
    int orderId,
    Function(Map<String, dynamic>) onUpdate, {
    String listenerId = 'default',
  }) async {
    _ws.connectFoodSocket();
    _ws.subscribeOrderStatus(orderId, onUpdate, listenerId: listenerId);
  }

  /// Stop watching a specific order's status.
  static void unwatchOrderStatus(int orderId, {String listenerId = 'default'}) {
    _ws.unsubscribeOrderStatus(orderId, listenerId: listenerId);
  }

  /// Disconnect all WebSocket channels (call on logout).
  static void disconnectAllSockets() {
    _ws.disconnectAll();
    // debugPrint('🛑 All vendor WebSocket channels disconnected');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Remaining service classes – unchanged except cancelOrder made static above
// ─────────────────────────────────────────────────────────────────────────────

class AdvertisementService {
  static Future<int?> postAdvertisement({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required double amount,
    required String type,
    required String resolution,
    File? image,
    File? video,
    required int vendorId,
  }) async {
    try {
      final adJson = {
        'advertisementId': 0,
        'title': title,
        'type': type,
        'description': description,
        'startDate': '${startDate}T00:00:00.000Z',
        'endDate': '${endDate}T00:00:00.000Z',
        'amount': amount,
        'vendorId': vendorId,
        'paymentStatus': 'PENDING',
        'transactionId': '',
        'orderId': '',
        'mediaUrl': '',
        'resolution': resolution,
      };

      final mediaFile = type == 'IMAGE' ? image : video;

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/vendor/advertisements/add/$vendorId',
        method: 'POST',
        service: 'food',
        data: {'advertisementData': jsonEncode(adJson)},
        files: mediaFile != null ? {'mediaFile': mediaFile} : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'] ?? data['advertisementId'];
      }
      return null;
    } catch (e) {
      // debugPrint('postAdvertisement error: $e');
      return null;
    }
  }
}

class SettlementAuthService {
  static Future<dynamic> getTransactionHistory(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'settlements/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 404) return [];
      throw Exception('Failed to load settlement history');
    } catch (e) {
      // debugPrint('getTransactionHistory error: $e');
      throw Exception('Error: $e');
    }
  }
}

class TopRestaurantService {
  static Future<List<dynamic>> getTopRestaurants(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/toprated/getby/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) return body;
        if (body is Map && body['data'] is List) return body['data'];
      }
      return [];
    } catch (e) {
      // debugPrint('getTopRestaurants error: $e');
      return [];
    }
  }
}

class TopRatedService {
  static Future<bool> addTopRestaurant(TopRestaurant topRestaurant) async {
    try {
      final response = await ApiClient.post(
        'api/vendor/toprated/add/${topRestaurant.vendorId}',
        topRestaurant.toJson(),
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('addTopRestaurant error: $e');
      return false;
    }
  }
}

class PaymentService {
  Future<bool> updateTopRestaurantPayment({
    required int id,
    required String transactionId,
    required String orderId,
  }) async {
    try {
      final response = await ApiClient.put(
        'api/vendor/toprated/update-payment/$id'
        '?transactionId=$transactionId&orderId=$orderId',
        {},
        service: 'food',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success' || data['status'] == 'captured';
      }
      return false;
    } catch (e) {
      // debugPrint('updateTopRestaurantPayment error: $e');
      return false;
    }
  }

  static Future<String?> createRazorpayOrder(double amount) async {
    try {
      final response = await ApiClient.post('api/user/create-order', {
        'amount': amount,
        'currency': 'INR',
        'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      }, service: 'subscription');
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['orderId'];
      }
      return null;
    } catch (e) {
      // debugPrint('createRazorpayOrder error: $e');
      return null;
    }
  }

  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final response = await ApiClient.post('api/user/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
        'receipt': 'order#${DateTime.now().millisecondsSinceEpoch}',
      }, service: 'subscription');
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('capturePayment error: $e');
      return false;
    }
  }

  static Future<bool> createVendorPaymentOrder({
    required double amount,
    required int planId,
    required String planType,
    required int vendorId,
    required String email,
  }) async {
    try {
      final response = await ApiClient.post('api/vendor/payment/create', {
        'id': 0,
        'amount': amount,
        'subscriptionPlanId': planId,
        'planType': planType,
        'vendorId': vendorId,
        'vendorName': '',
        'city': '',
        'businessVerticals': 'FOOD_AND_BEVERAGES',
        'email': email,
        'mobileNumber': '',
        'username': '',
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
        'status': 'PENDING',
        'approval': 'PENDING',
        'termsAndConditions': true,
      }, service: 'subscription');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('createVendorPaymentOrder error: $e');
      return false;
    }
  }
}

class AdvertisementPayment {
  final Razorpay _razorpay = Razorpay();

  void payAdvertisement(BuildContext context, Map<String, dynamic> ad) async {
    try {
      final amount = (ad['amount'] ?? 0).toDouble();
      final adId = _extractAdvertisementId(ad);

      if (adId == null || adId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid advertisement ID')),
        );
        return;
      }

      final orderId = await createAdvertisementOrder(amount);
      if (orderId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to create order')));
        return;
      }

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) async {
        final captured = await captureAdvertisementPayment(
          paymentId: response.paymentId!,
          amount: amount,
        );
        if (captured) {
          final updated = await updateAdvertisementPayment(
            adId,
            response.paymentId!,
            orderId,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updated
                    ? 'Payment successful!'
                    : 'Payment ok but status update failed',
              ),
            ),
          );
          if (updated) _refreshAdvertisements(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment capture failed')),
          );
        }
        _razorpay.clear();
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
        PaymentFailureResponse response,
      ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
        _razorpay.clear();
      });

      _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (ExternalWalletResponse _) {},
      );

      _razorpay.open({
        'key': 'rzp_live_TJDvykibQEsCuN',
        'order_id': orderId,
        'amount': (amount * 100).toInt(),
        'name': 'Advertisement Payment',
        'description': ad['title'] ?? 'Advertisement',
        'theme': {'color': '#3399cc'},
      });
    } catch (e) {
      // debugPrint('payAdvertisement error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment error: $e')));
    }
  }

  String? _extractAdvertisementId(Map<String, dynamic> ad) {
    for (final field in [
      'id',
      'advertisementId',
      'advertisementid',
      'adId',
      'adid',
      'vendorAdvertisementId',
    ]) {
      final id = ad[field]?.toString();
      if (id != null && id.isNotEmpty && id != 'null') return id;
    }
    return null;
  }

  void _refreshAdvertisements(BuildContext context) {
    // debugPrint('🔄 Refreshing advertisements list...');
  }

  void dispose() => _razorpay.clear();

  static Future<String?> createAdvertisementOrder(double amount) async {
    try {
      final response = await ApiClient.post('api/payments/create-order/user', {
        'amount': amount,
        'currency': 'INR',
        'receipt': 'receipt#${DateTime.now().millisecondsSinceEpoch}',
      }, service: 'food');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orderId'] ?? data['id'];
      }
      return null;
    } catch (e) {
      // debugPrint('createAdvertisementOrder error: $e');
      return null;
    }
  }

  static Future<bool> captureAdvertisementPayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final response = await ApiClient.post('api/payments/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
      }, service: 'food');
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('captureAdvertisementPayment error: $e');
      return false;
    }
  }

  static Future<bool> updateAdvertisementPayment(
    String adId,
    String transactionId,
    String orderId,
  ) async {
    if (adId.isEmpty || adId == 'null') return false;
    try {
      final response = await ApiClient.put(
        'api/vendor/advertisements/update-payment/$adId'
        '?transactionId=$transactionId&orderId=$orderId',
        {},
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateAdvertisementPayment error: $e');
      return false;
    }
  }
}

class DeliveryService {
  static Future<Map<String, dynamic>?> getDeliveryDetails({
    required int orderId,
  }) async {
    try {
      final response = await ApiClient.get(
        'api/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES',
        service: 'delivery',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // debugPrint('getDeliveryDetails error: $e');
      return null;
    }
  }
}

class food_authservicetable {
  static Future<List<dynamic>> getAllOrders() async {
    try {
      final vendorId = await _vendorId();
      if (vendorId == null) return [];

      final response = await ApiClient.get(
        'api/orders/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      // debugPrint('getAllOrders error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getOrdersByType({
    required String orderType,
    required int vendorId,
    required String status,
  }) async {
    try {
      final response = await ApiClient.get(
        'api/cart/get/ordertype=$orderType/$vendorId/$status',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((o) => _transformCartOrderToOrder(o))
            .toList();
      }
      return [];
    } catch (e) {
      // debugPrint('getOrdersByType error: $e');
      return [];
    }
  }

  static Map<String, dynamic> _transformCartOrderToOrder(
    Map<String, dynamic> cartOrder,
  ) {
    final cartItems = cartOrder['cartItems'] as List? ?? [];
    final transformedItems = cartItems
        .map(
          (item) => {
            'dishName': item['dishName'] ?? 'Unknown',
            'quantity': item['quantity'] ?? 1,
            'totalPrice': item['totalPrice'] ?? 0,
            'price': item['price'] ?? 0,
            'gst': item['gst'] ?? 0,
            'dishId': item['dishId'],
            'itemId': item['itemId'],
            'category': item['category'] ?? '',
            'note': item['note'],
            'orderStatus': item['orderStatus'] ?? 'PENDING',
          },
        )
        .toList();

    final orderDate = cartItems.isNotEmpty && cartItems[0]['createdAt'] != null
        ? cartItems[0]['createdAt']
        : DateTime.now().toIso8601String();

    return {
      'orderId': cartOrder['cartId'],
      'cartId': cartOrder['cartId'],
      'orderType': cartOrder['orderType'] ?? 'TABLE_DINE_IN',
      'status': 'PENDING',
      'orderDateAndTime': orderDate,
      'order': transformedItems,
      'tableCode': cartOrder['tableCode'],
      'seatingId': cartOrder['seatingId'],
      'userId': cartOrder['userId'],
      'vendorId': cartOrder['vendorId'],
      'subtotal': cartOrder['subtotal'] ?? 0,
      'gstTotal': cartOrder['gstTotal'] ?? 0,
      'grandTotal': cartOrder['grandTotal'] ?? 0,
      'total': cartOrder['total'] ?? 0,
      'platformCharges': cartOrder['platformCharges'] ?? 0,
      'packingTotal': cartOrder['packingTotal'] ?? 0,
      'serviceCharges': cartOrder['serviceCharges'] ?? 0,
      'deliveryCharges': cartOrder['deliveryCharges'],
      'cgst': cartOrder['cgst'] ?? 0,
      'sgst': cartOrder['sgst'] ?? 0,
      'couponCode': cartOrder['couponCode'],
      'discountAmount': cartOrder['discountAmount'] ?? 0,
      'customerId': cartOrder['customerId'],
      'isCartOrder': true,
    };
  }

  static Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await ApiClient.put(
        'api/orders/status/$orderId?status=$status',
        {},
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateOrderStatus error: $e');
      return false;
    }
  }

  static Future<bool> updateCartOrderStatus(int cartId, String status) async {
    try {
      final response = await ApiClient.put(
        'api/cart/status/$cartId?status=$status',
        {},
        service: 'food',
      );
      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('updateCartOrderStatus error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDeliveryOrder(int orderId) async {
    try {
      final response = await ApiClient.get(
        'api/orders/delivery/$orderId',
        service: 'food',
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {};
    } catch (e) {
      // debugPrint('getDeliveryOrder error: $e');
      return {};
    }
  }

  static Future<List<dynamic>> getAllOrdersUnified(int vendorId) async {
    final allOrders = <dynamic>[];
    try {
      allOrders.addAll(await getAllOrders());
      allOrders.addAll(
        await getOrdersByType(
          orderType: 'TABLE_DINE_IN',
          vendorId: vendorId,
          status: 'PENDING',
        ),
      );
      allOrders.sort(
        (a, b) => (b['orderId'] ?? 0).compareTo(a['orderId'] ?? 0),
      );
      return allOrders;
    } catch (e) {
      // debugPrint('getAllOrdersUnified error: $e');
      return allOrders;
    }
  }
}

class food_authservice1 {
  static Future<bool> updateCartItemQuantity1({
    required int vendorId,
    required int cartId,
    required int dishId,
    required int quantity,
  }) async {
    try {
      final response = await ApiClient.put(
        'api/cart/update/cart/$vendorId/$dishId?dishId=$dishId&quantity=$quantity',
        {},
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // debugPrint('updateCartItemQuantity1 error: $e');
      return false;
    }
  }
}

class HomeWrapperService {
  // ── TABLE DINE-IN PENDING ORDERS ──────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchTableDineInPending(
    int vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/cart/get/ordertype=TABLE_DINE_IN/$vendorId/PENDING',
        service: 'food',
      );
      if (response.statusCode != 200) return [];
      final dynamic data = jsonDecode(response.body);
      List<dynamic> raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map<String, dynamic>) {
        raw =
            data['data'] as List? ??
            data['content'] as List? ??
            data['orders'] as List? ??
            [];
        if (raw.isEmpty && data.containsKey('cartId')) raw = [data];
      }
      return raw.map((o) {
        if (o is! Map<String, dynamic>) return <String, dynamic>{};
        final m = Map<String, dynamic>.from(o);
        m['orderType'] = 'TABLE_DINE_IN';
        m['status'] = 'PENDING';
        if (m['orderId'] == null && m['cartId'] != null) {
          m['orderId'] = m['cartId'];
        }
        return m;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── CATERING PENDING ORDERS ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchCateringPending(
    int vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/vendor/getall/$vendorId',
        service: 'catering',
      );
      if (response.statusCode != 200) return [];
      final dynamic resp = jsonDecode(response.body);
      List<dynamic> all = resp is List
          ? resp
          : resp is Map<String, dynamic>
          ? (resp['data'] as List? ?? resp['orders'] as List? ?? [])
          : [];
      return all
          .where(
            (o) =>
                o is Map &&
                (o['orderStatus'] ?? '').toString().toUpperCase() == 'PENDING',
          )
          .map((o) {
            final m = Map<String, dynamic>.from(o as Map);
            m['orderType'] = 'CATERING';
            m['status'] = 'PENDING';
            return m;
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── VENDOR LOCATION / ADDRESS ─────────────────────────────────────────────
  static Future<String?> fetchVendorAddress(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/vendors/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final vendorData = jsonDecode(response.body);
        final fullAddress = vendorData['fullAddress']?.toString() ?? '';
        return fullAddress.isNotEmpty ? fullAddress : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── VENDOR DETAILS (name + logo) ──────────────────────────────────────────
  static Future<Map<String, dynamic>?> fetchVendorDetails(int vendorId) async {
    try {
      final vendorResponse = await ApiClient.get(
        'api/vendors/$vendorId',
        service: 'food',
      );
      Map<String, dynamic> vendorData = {};
      if (vendorResponse.statusCode == 200 && vendorResponse.body.isNotEmpty) {
        vendorData = jsonDecode(vendorResponse.body);
      }

      Map<String, dynamic> bannerData = {};
      try {
        final bannerResponse = await ApiClient.get(
          'api/banner/$vendorId',
          service: 'food',
          requiresAuth: false,
        );
        if (bannerResponse.statusCode == 200 &&
            bannerResponse.body.isNotEmpty) {
          final decoded = jsonDecode(bannerResponse.body);
          if (decoded is Map<String, dynamic>) {
            bannerData = decoded;
          } else if (decoded is List && decoded.isNotEmpty) {
            bannerData = decoded[0] as Map<String, dynamic>;
          }
        }
      } catch (e) {
        // debugPrint('⚠️ Banner fetch error: $e');
      }

      return {
        ...vendorData,
        'companyLogo': bannerData['companyLogo'] ?? vendorData['companyLogo'],
      };
    } catch (e) {
      // debugPrint('❌ fetchVendorDetails error: $e');
      return null;
    }
  }

  // ── BANNER / CAMPAIGNS ────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchBanners(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/banner/$vendorId',
        service: 'food',
        requiresAuth: false,
      );
      if (response.statusCode != 200 || response.body.isEmpty) return [];

      final dynamic decoded = jsonDecode(response.body);
      final List<Map<String, dynamic>> banners = [];
      if (decoded is Map<String, dynamic>) {
        banners.add(decoded);
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) banners.add(item);
        }
      }
      return banners;
    } catch (e) {
      // debugPrint('💥 fetchBanners error: $e');
      return [];
    }
  }

  // ── VENDOR ORDER STATISTICS (all-time top selling, etc.) ──────────────────
  static Future<Map<String, dynamic>?> fetchVendorOrderStatistics(
    int vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/orders/vendor/statistics/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      // debugPrint(
      //   '⚠️ fetchVendorOrderStatistics returned ${response.statusCode}',
      // );
      return null;
    } catch (e) {
      // debugPrint('❌ fetchVendorOrderStatistics error: $e');
      return null;
    }
  }

  // ── DASHBOARD STATS (custom date range) ───────────────────────────────────
  static Future<DashboardStatsModel?> fetchDashboardStats({
    required int vendorId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final from =
          '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';
      final to =
          '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}';

      final response = await ApiClient.get(
        'api/orders/vendor/statistics/custom',
        service: 'food',
        queryParams: {
          'vendorId': vendorId.toString(),
          'fromDate': from,
          'toDate': to,
        },
      );
      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      if (response.statusCode == 404) {
        throw Exception('Vendor statistics not found');
      }
      throw Exception(
        'fetchDashboardStats failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // debugPrint('❌ fetchDashboardStats error: $e');
      return null;
    }
  }

  // ── DETAILED STATISTICS (order types, payment breakdown, etc.) ─────────────
  static Future<DetailedStatisticsResponse?> fetchDetailedStatistics({
    required int vendorId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await ApiClient.get(
        'api/orders/vendor/statistics/custom?vendorId=$vendorId&fromDate=$fromDate&toDate=$toDate',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return DetailedStatisticsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      // debugPrint('❌ fetchDetailedStatistics error: $e');
      return null;
    }
  }
}
