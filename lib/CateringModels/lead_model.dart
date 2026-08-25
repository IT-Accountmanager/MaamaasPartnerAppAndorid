
class Lead {
  final int? id;
  final int? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? eventType;
  final String? eventDate;
  final String? eventTime;
  final String? fromDate;
  final String? toDate;
  final String? city;
  final String? state;
  final int? vegPlates;
  final int? nonVegPlates;
  final int? mixedPlates;
  final String? additionalRequests;
  final String? leadStatus;
  final String? createdAt;
  final Map<String, dynamic>? items; // Changed from List<String>? to Map<String, dynamic>?
  final List<AddOn>? addOns;
  final bool? masked;
  final bool? accessible;
  final double? leadPrice;
  final String? accessMessage;

  Lead({
    this.id,
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.eventType,
    this.eventDate,
    this.eventTime,
    this.fromDate,
    this.toDate,
    this.city,
    this.state,
    this.vegPlates,
    this.nonVegPlates,
    this.mixedPlates,
    this.additionalRequests,
    this.leadStatus,
    this.createdAt,
    this.items,
    this.addOns,
    this.masked,
    this.accessible,
    this.leadPrice,
    this.accessMessage,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    // Parse items - handle both Map and List cases
    Map<String, dynamic>? parsedItems;
    if (json['items'] != null) {
      if (json['items'] is Map) {
        parsedItems = Map<String, dynamic>.from(json['items'] as Map);
      } else if (json['items'] is List) {
        // If it's a list, convert to a map with a default category
        parsedItems = {
          'Items': json['items'] as List
        };
      }
    }

    // Parse addOns safely
    List<AddOn>? parsedAddOns;
    if (json['addOns'] != null && json['addOns'] is List) {
      parsedAddOns = (json['addOns'] as List)
          .map((item) => AddOn.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Lead(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      eventType: json['eventType'] as String?,
      eventDate: json['eventDate'] as String?,
      eventTime: json['eventTime'] as String?,
      fromDate: json['fromDate'] as String?,
      toDate: json['toDate'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      vegPlates: json['vegPlates'] as int?,
      nonVegPlates: json['nonVegPlates'] as int?,
      mixedPlates: json['mixedPlates'] as int?,
      additionalRequests: json['additionalRequests'] as String?,
      leadStatus: json['leadStatus'] as String?,
      createdAt: json['createdAt'] as String?,
      items: parsedItems,
      addOns: parsedAddOns,
      masked: json['masked'] as bool?,
      accessible: json['accessible'] as bool?,
      leadPrice: (json['leadPrice'] as num?)?.toDouble(),
      accessMessage: json['accessMessage'] as String?,
    );
  }

  // Helper method to flatten items for display
  List<String> get flattenedItems {
    if (items == null) return [];

    final List<String> result = [];
    items!.forEach((category, itemList) {
      if (itemList is List) {
        for (var item in itemList) {
          result.add(item.toString());
        }
      }
    });
    return result;
  }

  // Helper method to get categorized items for display
  Map<String, dynamic>? get categorizedItems {
    return items;
  }
}

class AddOn {
  final int id;
  final String addOnType;
  final int quantity;
  final bool selected;

  AddOn({
    required this.id,
    required this.addOnType,
    required this.quantity,
    required this.selected,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'] as int,
      addOnType: json['addOnType'] as String,
      quantity: json['quantity'] as int,
      selected: json['selected'] as bool,
    );
  }

  // Helper method to get display name
  String get displayName {
    switch (addOnType) {
      case 'SERVICE_BOYS':
        return 'Service Boys';
      case 'PAPER_PLATES':
        return 'Paper Plates';
      case 'WATER_BOTTLES':
        return 'Water Bottles';
      case 'DISPOSABLE_CUPS':
        return 'Disposable Cups';
      case 'TISSUE_PAPER':
        return 'Tissue Paper';
      default:
        return addOnType.replaceAll('_', ' ');
    }
  }
}

class AddOnItem {
  final int addOnId;
  final String addOnType;
  int quantity;
  double price;

  AddOnItem({
    required this.addOnId,
    required this.addOnType,
    required this.quantity,
    required this.price,
  });

  double get totalAmount => price * quantity;

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    return AddOnItem(
      addOnId: json['addOnId'] ?? json['add_on_id'] ?? 0,
      addOnType: json['addOnType'] ?? json['add_on_type'] ?? json['type'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "addOnId": addOnId,
      "addOnType": addOnType,
      "quantity": quantity,
      "price": price,
      "totalAmount": totalAmount,
    };
  }
}