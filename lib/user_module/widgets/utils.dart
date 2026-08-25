import 'package:flutter/cupertino.dart';


import '../API/food_authservice.dart';
import 'food/currentcart_notifier.dart';

class Utils{
  static String? selectedOrderType;
  // static var cartItems = []; // ✅ Initialized with an empty list.
  static bool isOrderNowClicked=false;
  // static ValueNotifier<int> itemCount = ValueNotifier<int>(0);
  static double appliedDiscount=0.0;
  static ValueNotifier<int> itemCount = ValueNotifier<int>(0);



  static Future<void> refreshCartCount() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.count.value = count;
    } catch (e) {
      CartNotifier.count.value = 0;
    }
  }



}


