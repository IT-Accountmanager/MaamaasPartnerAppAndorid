import 'package:flutter/material.dart';

// Values: 'seating', 'normal', or '' (empty for no items)
ValueNotifier<String> currentCart = ValueNotifier<String>('');

class CartNotifier {
  static ValueNotifier<int> count = ValueNotifier(0);
  static ValueNotifier<String> orderType =
  ValueNotifier<String>('dineIn');
}

