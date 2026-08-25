import 'package:flutter/cupertino.dart';

import '../../Models/food&beverages/dish.dart';

class Utils {
  static String? selectedOrderType;
  static var cartItems = []; // ✅ Initialized with an empty list.
  static bool isOrderNowClicked = false;
  static ValueNotifier<int> itemCount = ValueNotifier<int>(0);
  static double appliedDiscount = 0.0;
  static List<Dish> fetchedCategories = [];
  static Map<String, bool> isExpandedMap = {};
  static Map<String, bool> isToggledMap = {};
  static bool isLoading = false;
}
