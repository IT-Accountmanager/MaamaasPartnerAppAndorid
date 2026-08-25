enum OrderType { DINE_IN, TAKEAWAY }

extension OrderTypeExtension on OrderType {
  String get value {
    switch (this) {
      case OrderType.DINE_IN:
        return 'DINE_IN';
      case OrderType.TAKEAWAY:
        return 'TAKEAWAY';
    }
  }

  String get displayName {
    switch (this) {
      case OrderType.DINE_IN:
        return 'DineIn';
      case OrderType.TAKEAWAY:
        return 'TakeAway';
    }
  }

  static OrderType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DINE_IN':
        return OrderType.DINE_IN;
      case 'TAKEAWAY':
        return OrderType.TAKEAWAY;
      default:
        return OrderType.DINE_IN;
    }
  }
}
