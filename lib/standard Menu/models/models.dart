// // // ==================== MENU MODELS ====================
// //
// // class SubDish {
// //   final int dishId;
// //   final String subName;
// //   final double price;
// //   final String description;
// //   final String? image;
// //   final String tag;
// //   final double gst;
// //   final double packingCharges;
// //   final double deliveryPrice;
// //   final double effectivePrice;
// //   final double discount;
// //   final String chefType;
// //   String menuStatus;
// //   int stockQuantity;
// //   final int consumedQuantity;
// //   final int balanceQuantity;
// //
// //   SubDish({
// //     required this.dishId,
// //     required this.subName,
// //     required this.price,
// //     this.description = '',
// //     this.image,
// //     this.tag = 'Veg',
// //     this.gst = 0,
// //     this.packingCharges = 0,
// //     this.deliveryPrice = 0,
// //     this.effectivePrice = 0,
// //     this.discount = 0,
// //     this.chefType = 'Chef_All',
// //     this.menuStatus = 'Enable',
// //     this.stockQuantity = 0,
// //     this.consumedQuantity = 0,
// //     this.balanceQuantity = 0,
// //   });
// //
// //   factory SubDish.fromJson(Map<String, dynamic> json) {
// //     return SubDish(
// //       dishId: json['dishId'] ?? 0,
// //       subName: json['subName'] ?? json['dishName'] ?? '',
// //       price: (json['price'] ?? 0).toDouble(),
// //       description: json['description'] ?? '',
// //       image: json['dishImage'],
// //       tag: json['tag'] ?? 'Veg',
// //       gst: (json['gst'] ?? 0).toDouble(),
// //       packingCharges: (json['packingCharges'] ?? 0).toDouble(),
// //       deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
// //       effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
// //       discount: (json['discount'] ?? 0).toDouble(),
// //       chefType: json['chefType'] ?? 'Chef_All',
// //       menuStatus: json['menuStatus'] ?? 'Enable',
// //       stockQuantity: json['stockQuantity'] ?? 0,
// //       consumedQuantity: json['consumedQuantity'] ?? 0,
// //       balanceQuantity: json['balanceQuantity'] ?? 0,
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() => {
// //         'dishId': dishId,
// //         'dishName': subName,
// //         'price': price,
// //         'description': description,
// //         'dishImage': image,
// //         'tag': tag,
// //         'gst': gst,
// //         'packingCharges': packingCharges,
// //         'discount': discount,
// //         'chefType': chefType,
// //         'menuStatus': menuStatus,
// //         'stockQuantity': stockQuantity,
// //       };
// //
// //   SubDish copyWith({
// //     String? subName,
// //     double? price,
// //     String? description,
// //     String? image,
// //     String? tag,
// //     double? gst,
// //     double? packingCharges,
// //     double? discount,
// //     String? chefType,
// //     String? menuStatus,
// //     int? stockQuantity,
// //   }) {
// //     return SubDish(
// //       dishId: dishId,
// //       subName: subName ?? this.subName,
// //       price: price ?? this.price,
// //       description: description ?? this.description,
// //       image: image ?? this.image,
// //       tag: tag ?? this.tag,
// //       gst: gst ?? this.gst,
// //       packingCharges: packingCharges ?? this.packingCharges,
// //       deliveryPrice: deliveryPrice,
// //       effectivePrice: effectivePrice,
// //       discount: discount ?? this.discount,
// //       chefType: chefType ?? this.chefType,
// //       menuStatus: menuStatus ?? this.menuStatus,
// //       stockQuantity: stockQuantity ?? this.stockQuantity,
// //       consumedQuantity: consumedQuantity,
// //       balanceQuantity: balanceQuantity,
// //     );
// //   }
// // }
// //
// // class MenuCategory {
// //   final int dishId;
// //   final String category;
// //   final String? image;
// //   String menuStatus;
// //   List<SubDish> subcategories;
// //
// //   MenuCategory({
// //     required this.dishId,
// //     required this.category,
// //     this.image,
// //     this.menuStatus = 'Enable',
// //     this.subcategories = const [],
// //   });
// //
// //   MenuCategory copyWith({
// //     String? category,
// //     String? image,
// //     String? menuStatus,
// //     List<SubDish>? subcategories,
// //   }) {
// //     return MenuCategory(
// //       dishId: dishId,
// //       category: category ?? this.category,
// //       image: image ?? this.image,
// //       menuStatus: menuStatus ?? this.menuStatus,
// //       subcategories: subcategories ?? this.subcategories,
// //     );
// //   }
// // }
// //
// // // ==================== PACKAGE MODELS ====================
// //
// // class PackageItem {
// //   final int id;
// //   final String itemName;
// //   final double price;
// //   final String? image;
// //   final String? description;
// //
// //   PackageItem({
// //     required this.id,
// //     required this.itemName,
// //     required this.price,
// //     this.image,
// //     this.description,
// //   });
// //
// //   factory PackageItem.fromJson(Map<String, dynamic> json) {
// //     return PackageItem(
// //       id: json['id'] ?? 0,
// //       itemName: json['itemName'] ?? '',
// //       price: (json['price'] ?? 0).toDouble(),
// //       image: json['image'],
// //       description: json['description'],
// //     );
// //   }
// //
// //   PackageItem copyWith({String? itemName, double? price}) {
// //     return PackageItem(
// //       id: id,
// //       itemName: itemName ?? this.itemName,
// //       price: price ?? this.price,
// //       image: image,
// //       description: description,
// //     );
// //   }
// // }
// //
// // class MenuPackage {
// //   final int id;
// //   final String packageName;
// //   final String packageType;
// //   final String? image;
// //   final double totalPrice;
// //   final List<PackageItem> items;
// //
// //   MenuPackage({
// //     required this.id,
// //     required this.packageName,
// //     required this.packageType,
// //     this.image,
// //     required this.totalPrice,
// //     this.items = const [],
// //   });
// //
// //   factory MenuPackage.fromJson(Map<String, dynamic> json) {
// //     final itemsList = (json['items'] as List<dynamic>? ?? [])
// //         .map((i) => PackageItem.fromJson(i))
// //         .toList();
// //     return MenuPackage(
// //       id: json['id'] ?? 0,
// //       packageName: json['packageName'] ?? '',
// //       packageType: json['packageType'] ?? 'Veg',
// //       image: json['image'],
// //       totalPrice: (json['totalPrice'] ?? 0).toDouble(),
// //       items: itemsList,
// //     );
// //   }
// //
// //   double get computedTotal =>
// //       totalPrice > 0 ? totalPrice : items.fold(0, (s, i) => s + i.price);
// // }
// // ==================== MENU MODELS ====================
//
// class SubDish {
//   final int dishId;
//   final String subName;
//   final double price;
//   final String description;
//   final String? image;
//   final String tag;
//   final double gst;
//   final double packingCharges;
//   final double deliveryPrice;
//   final double effectivePrice;
//   final double discount;
//   final String chefType;
//   String menuStatus;
//   int stockQuantity;
//   final int consumedQuantity;
//   final int balanceQuantity;
//   final String? code; // ← NEW
//
//   SubDish({
//     required this.dishId,
//     required this.subName,
//     required this.price,
//     this.description = '',
//     this.image,
//     this.tag = 'Veg',
//     this.gst = 0,
//     this.packingCharges = 0,
//     this.deliveryPrice = 0,
//     this.effectivePrice = 0,
//     this.discount = 0,
//     this.chefType = 'Chef_All',
//     this.menuStatus = 'Enable',
//     this.stockQuantity = 0,
//     this.consumedQuantity = 0,
//     this.balanceQuantity = 0,
//     this.code, // ← NEW
//   });
//
//   factory SubDish.fromJson(Map<String, dynamic> json) {
//     return SubDish(
//       dishId: json['dishId'] ?? 0,
//       subName: json['subName'] ?? json['dishName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       description: json['description'] ?? '',
//       image: json['dishImage'],
//       tag: json['tag'] ?? 'Veg',
//       gst: (json['gst'] ?? 0).toDouble(),
//       packingCharges: (json['packingCharges'] ?? 0).toDouble(),
//       deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
//       effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
//       discount: (json['discount'] ?? 0).toDouble(),
//       chefType: json['chefType'] ?? 'Chef_All',
//       menuStatus: json['menuStatus'] ?? 'Enable',
//       stockQuantity: json['stockQuantity'] ?? 0,
//       consumedQuantity: json['consumedQuantity'] ?? 0,
//       balanceQuantity: json['balanceQuantity'] ?? 0,
//       code: json['code'] as String?, // ← NEW
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'dishId': dishId,
//     'dishName': subName,
//     'price': price,
//     'description': description,
//     'dishImage': image,
//     'tag': tag,
//     'gst': gst,
//     'packingCharges': packingCharges,
//     'discount': discount,
//     'chefType': chefType,
//     'menuStatus': menuStatus,
//     'stockQuantity': stockQuantity,
//     'code': code, // ← NEW
//   };
//
//   SubDish copyWith({
//     String? subName,
//     double? price,
//     String? description,
//     String? image,
//     String? tag,
//     double? gst,
//     double? packingCharges,
//     double? discount,
//     String? chefType,
//     String? menuStatus,
//     int? stockQuantity,
//     String? code, // ← NEW
//   }) {
//     return SubDish(
//       dishId: dishId,
//       subName: subName ?? this.subName,
//       price: price ?? this.price,
//       description: description ?? this.description,
//       image: image ?? this.image,
//       tag: tag ?? this.tag,
//       gst: gst ?? this.gst,
//       packingCharges: packingCharges ?? this.packingCharges,
//       deliveryPrice: deliveryPrice,
//       effectivePrice: effectivePrice,
//       discount: discount ?? this.discount,
//       chefType: chefType ?? this.chefType,
//       menuStatus: menuStatus ?? this.menuStatus,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       consumedQuantity: consumedQuantity,
//       balanceQuantity: balanceQuantity,
//       code: code ?? this.code, // ← NEW
//     );
//   }
// }
//
// class MenuCategory {
//   final int dishId;
//   final String category;
//   final String? image;
//   String menuStatus;
//   List<SubDish> subcategories;
//
//   MenuCategory({
//     required this.dishId,
//     required this.category,
//     this.image,
//     this.menuStatus = 'Enable',
//     this.subcategories = const [],
//   });
//
//   MenuCategory copyWith({
//     String? category,
//     String? image,
//     String? menuStatus,
//     List<SubDish>? subcategories,
//   }) {
//     return MenuCategory(
//       dishId: dishId,
//       category: category ?? this.category,
//       image: image ?? this.image,
//       menuStatus: menuStatus ?? this.menuStatus,
//       subcategories: subcategories ?? this.subcategories,
//     );
//   }
// }
//
// // ==================== PACKAGE MODELS ====================
//
// class PackageItem {
//   final int id;
//   final String itemName;
//   final double price;
//   final String? image;
//   final String? description;
//
//   PackageItem({
//     required this.id,
//     required this.itemName,
//     required this.price,
//     this.image,
//     this.description,
//   });
//
//   factory PackageItem.fromJson(Map<String, dynamic> json) {
//     return PackageItem(
//       id: json['id'] ?? 0,
//       itemName: json['itemName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       image: json['image'],
//       description: json['description'],
//     );
//   }
//
//   PackageItem copyWith({String? itemName, double? price}) {
//     return PackageItem(
//       id: id,
//       itemName: itemName ?? this.itemName,
//       price: price ?? this.price,
//       image: image,
//       description: description,
//     );
//   }
// }
//
// class MenuPackage {
//   final int id;
//   final String packageName;
//   final String packageType;
//   final String? image;
//   final double totalPrice;
//   final List<PackageItem> items;
//
//   MenuPackage({
//     required this.id,
//     required this.packageName,
//     required this.packageType,
//     this.image,
//     required this.totalPrice,
//     this.items = const [],
//   });
//
//   factory MenuPackage.fromJson(Map<String, dynamic> json) {
//     final itemsList = (json['items'] as List<dynamic>? ?? [])
//         .map((i) => PackageItem.fromJson(i))
//         .toList();
//     return MenuPackage(
//       id: json['id'] ?? 0,
//       packageName: json['packageName'] ?? '',
//       packageType: json['packageType'] ?? 'Veg',
//       image: json['image'],
//       totalPrice: (json['totalPrice'] ?? 0).toDouble(),
//       items: itemsList,
//     );
//   }
//
//   double get computedTotal =>
//       totalPrice > 0 ? totalPrice : items.fold(0, (s, i) => s + i.price);
// }
//
// class SubDish {
//   final int dishId;
//   final String subName;
//   final double price;
//   final String description;
//   final String? image;
//   final String tag;
//   final double gst;
//   final bool includeGst;
//   final double packingCharges;
//   final double deliveryPrice;
//   final double effectivePrice;
//   final double discount;
//   final String chefType;
//   String menuStatus;
//   int stockQuantity;
//   final int consumedQuantity;
//   final int balanceQuantity;
//   final String? code;
//
//   SubDish({
//     required this.dishId,
//     required this.subName,
//     required this.price,
//     this.description = '',
//     this.image,
//     this.tag = 'Veg',
//     this.gst = 0,
//     this.includeGst = false,
//     this.packingCharges = 0,
//     this.deliveryPrice = 0,
//     this.effectivePrice = 0,
//     this.discount = 0,
//     this.chefType = 'Chef_All',
//     this.menuStatus = 'Enable',
//     this.stockQuantity = 0,
//     this.consumedQuantity = 0,
//     this.balanceQuantity = 0,
//     this.code, // ← NEW
//   });
//
//   factory SubDish.fromJson(Map<String, dynamic> json) {
//     return SubDish(
//       dishId: json['dishId'] ?? 0,
//       subName: json['subName'] ?? json['dishName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       description: json['description'] ?? '',
//       image: json['dishImage'],
//       tag: json['tag'] ?? 'Veg',
//       gst: (json['gst'] ?? 0).toDouble(),
//       includeGst: json['includeGst'] ?? false,
//       packingCharges: (json['packingCharges'] ?? 0).toDouble(),
//       deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
//       effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
//       discount: (json['discount'] ?? 0).toDouble(),
//       chefType: json['chefType'] ?? 'Chef_All',
//       menuStatus: json['menuStatus'] ?? 'Enable',
//       stockQuantity: json['stockQuantity'] ?? 0,
//       consumedQuantity: json['consumedQuantity'] ?? 0,
//       balanceQuantity: json['balanceQuantity'] ?? 0,
//       code: json['code'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'dishId': dishId,
//     'dishName': subName,
//     'price': price,
//     'description': description,
//     'dishImage': image,
//     'tag': tag,
//     'gst': gst,
//     'includeGst': includeGst,
//     'packingCharges': packingCharges,
//     'deliveryPrice': deliveryPrice,
//     'discount': discount,
//     'chefType': chefType,
//     'menuStatus': menuStatus,
//     'stockQuantity': stockQuantity,
//     'code': code,
//   };
//
//   SubDish copyWith({
//     String? subName,
//     double? price,
//     String? description,
//     String? image,
//     String? tag,
//     double? gst,
//     bool? includeGst,
//     double? packingCharges,
//     double? deliveryPrice,
//     double? discount,
//     String? chefType,
//     String? menuStatus,
//     int? stockQuantity,
//     String? code,
//   }) {
//     return SubDish(
//       dishId: dishId,
//       subName: subName ?? this.subName,
//       price: price ?? this.price,
//       description: description ?? this.description,
//       image: image ?? this.image,
//       tag: tag ?? this.tag,
//       gst: gst ?? this.gst,
//       includeGst: includeGst ?? this.includeGst,
//       packingCharges: packingCharges ?? this.packingCharges,
//       deliveryPrice: deliveryPrice ?? this.deliveryPrice,
//       effectivePrice: effectivePrice,
//       discount: discount ?? this.discount,
//       chefType: chefType ?? this.chefType,
//       menuStatus: menuStatus ?? this.menuStatus,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       consumedQuantity: consumedQuantity,
//       balanceQuantity: balanceQuantity,
//       code: code ?? this.code,
//     );
//   }
// }
//
// class MenuCategory {
//   final int dishId;
//   final String category;
//   final String? image;
//   String menuStatus;
//   List<SubDish> subcategories;
//
//   MenuCategory({
//     required this.dishId,
//     required this.category,
//     this.image,
//     this.menuStatus = 'Enable',
//     this.subcategories = const [],
//   });
//
//   MenuCategory copyWith({
//     String? category,
//     String? image,
//     String? menuStatus,
//     List<SubDish>? subcategories,
//   }) {
//     return MenuCategory(
//       dishId: dishId,
//       category: category ?? this.category,
//       image: image ?? this.image,
//       menuStatus: menuStatus ?? this.menuStatus,
//       subcategories: subcategories ?? this.subcategories,
//     );
//   }
// }
//
// // ==================== PACKAGE MODELS ====================
//
// class PackageItem {
//   final int id;
//   final String itemName;
//   final double price;
//   final String? image;
//   final String? description;
//
//   PackageItem({
//     required this.id,
//     required this.itemName,
//     required this.price,
//     this.image,
//     this.description,
//   });
//
//   factory PackageItem.fromJson(Map<String, dynamic> json) {
//     return PackageItem(
//       id: json['id'] ?? 0,
//       itemName: json['itemName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       image: json['image'],
//       description: json['description'],
//     );
//   }
//
//   PackageItem copyWith({String? itemName, double? price}) {
//     return PackageItem(
//       id: id,
//       itemName: itemName ?? this.itemName,
//       price: price ?? this.price,
//       image: image,
//       description: description,
//     );
//   }
// }
//
// class MenuPackage {
//   final int id;
//   final String packageName;
//   final String packageType;
//   final String? image;
//   final double totalPrice;
//   final List<PackageItem> items;
//
//   MenuPackage({
//     required this.id,
//     required this.packageName,
//     required this.packageType,
//     this.image,
//     required this.totalPrice,
//     this.items = const [],
//   });
//
//   factory MenuPackage.fromJson(Map<String, dynamic> json) {
//     final itemsList = (json['items'] as List<dynamic>? ?? [])
//         .map((i) => PackageItem.fromJson(i))
//         .toList();
//     return MenuPackage(
//       id: json['id'] ?? 0,
//       packageName: json['packageName'] ?? '',
//       packageType: json['packageType'] ?? 'Veg',
//       image: json['image'],
//       totalPrice: (json['totalPrice'] ?? 0).toDouble(),
//       items: itemsList,
//     );
//   }
//
//   double get computedTotal =>
//       totalPrice > 0 ? totalPrice : items.fold(0, (s, i) => s + i.price);
// }

// ==================== SUBDISH MODEL ====================
//
// class SubDish {
//   final int dishId;
//   final String subName;
//   final double price;
//   final String description;
//   final String? image;
//   final String tag;
//   final double gst;
//   final bool includeGst;
//   final double packingCharges;
//   final double deliveryPrice;
//   final double effectivePrice;
//   final double discount;
//   final String chefType;
//   String menuStatus;
//   int stockQuantity;
//   final int consumedQuantity;
//   final int balanceQuantity;
//   final String? code;
//
//
//   SubDish({
//     required this.dishId,
//     required this.subName,
//     required this.price,
//     this.description = '',
//     this.image,
//     this.tag = 'Veg',
//     this.gst = 0,
//     this.includeGst = false,
//     this.packingCharges = 0,
//     this.deliveryPrice = 0,
//     this.effectivePrice = 0,
//     this.discount = 0,
//     this.chefType = 'Chef_All',
//     this.menuStatus = 'Enable',
//     this.stockQuantity = 0,
//     this.consumedQuantity = 0,
//     this.balanceQuantity = 0,
//     this.code,
//   });
//
//   factory SubDish.fromJson(Map<String, dynamic> json) {
//     return SubDish(
//       dishId: json['dishId'] ?? 0,
//       subName: json['subName'] ?? json['dishName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       description: json['description'] ?? '',
//       image: json['dishImage'],
//       tag: json['tag'] ?? 'Veg',
//       gst: (json['gst'] ?? 0).toDouble(),
//       includeGst: json['includeGst'] ?? false,
//       packingCharges: (json['packingCharges'] ?? 0).toDouble(),
//       deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
//       effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
//       discount: (json['discount'] ?? 0).toDouble(),
//       chefType: json['chefType'] ?? 'Chef_All',
//       menuStatus: json['menuStatus'] ?? 'Enable',
//       stockQuantity: json['stockQuantity'] ?? 0,
//       consumedQuantity: json['consumedQuantity'] ?? 0,
//       balanceQuantity: json['balanceQuantity'] ?? 0,
//       code: json['code'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'dishId': dishId,
//     'dishName': subName,
//     'price': price,
//     'description': description,
//     'dishImage': image,
//     'tag': tag,
//     'gst': gst,
//     'includeGst': includeGst,
//     'packingCharges': packingCharges,
//     'deliveryPrice': deliveryPrice,
//     'discount': discount,
//     'chefType': chefType,
//     'menuStatus': menuStatus,
//     'stockQuantity': stockQuantity,
//     'code': code,
//   };
//
//   SubDish copyWith({
//     String? subName,
//     double? price,
//     String? description,
//     String? image,
//     String? tag,
//     double? gst,
//     bool? includeGst,
//     double? packingCharges,
//     double? deliveryPrice,
//     double? discount,
//     String? chefType,
//     String? menuStatus,
//     int? stockQuantity,
//     String? code,
//   }) {
//     return SubDish(
//       dishId: dishId,
//       subName: subName ?? this.subName,
//       price: price ?? this.price,
//       description: description ?? this.description,
//       image: image ?? this.image,
//       tag: tag ?? this.tag,
//       gst: gst ?? this.gst,
//       includeGst: includeGst ?? this.includeGst,
//       packingCharges: packingCharges ?? this.packingCharges,
//       deliveryPrice: deliveryPrice ?? this.deliveryPrice,
//       effectivePrice: effectivePrice,
//       discount: discount ?? this.discount,
//       chefType: chefType ?? this.chefType,
//       menuStatus: menuStatus ?? this.menuStatus,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       consumedQuantity: consumedQuantity,
//       balanceQuantity: balanceQuantity,
//       code: code ?? this.code,
//     );
//   }
// }
// class SubDish {
//   final int dishId;
//   final String subName;
//   final double price;
//   final String description;
//   final String? image;
//   final String tag;
//   final double gst;
//   final bool includeGst;
//   final double packingCharges;
//   final double deliveryPrice;
//   final double effectivePrice;
//   final double discount;
//   final String chefType;
//   String menuStatus;
//   int stockQuantity;
//   final int consumedQuantity;
//   final int balanceQuantity;
//   final String? code;
//   final List<Addon> addons;
//   final bool resetQuantity;
//   final double deliveryGst;
//   final double packingGst;
//   final bool unlimited;
//   final String metrics;
//   final int metricQuantity;
//   final String? approvalStatus; // 👈 NEW
//   final String? rejectionReason; // 👈 NEW
//
//   SubDish({
//     required this.dishId,
//     required this.subName,
//     required this.price,
//     this.description = '',
//     this.image,
//     this.tag = 'Veg',
//     this.gst = 0,
//     this.includeGst = false,
//     this.packingCharges = 0,
//     this.deliveryPrice = 0,
//     this.effectivePrice = 0,
//     this.discount = 0,
//     this.chefType = 'Chef_All',
//     this.menuStatus = 'Enable',
//     this.stockQuantity = 0,
//     this.consumedQuantity = 0,
//     this.balanceQuantity = 0,
//     this.code,
//     this.addons = const [],
//     this.resetQuantity = false,
//     this.deliveryGst = 0,
//     this.packingGst = 0,
//     this.unlimited = false,
//     this.metrics = 'KG',
//     this.metricQuantity = 0,
//     this.approvalStatus, // 👈 NEW
//     this.rejectionReason, // 👈 NEW
//   });
//
//   factory SubDish.fromJson(Map<String, dynamic> json) {
//     return SubDish(
//       dishId: json['dishId'] ?? 0,
//       subName: json['subName'] ?? json['dishName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       description: json['description'] ?? '',
//       image: json['dishImage'],
//       tag: json['tag'] ?? 'Veg',
//       gst: (json['gst'] ?? 0).toDouble(),
//       includeGst: json['includeGst'] ?? false,
//       packingCharges: (json['packingCharges'] ?? 0).toDouble(),
//       deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
//       effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
//       discount: (json['discount'] ?? 0).toDouble(),
//       chefType: json['chefType'] ?? 'Chef_All',
//       menuStatus: json['menuStatus'] ?? 'Enable',
//       stockQuantity: json['stockQuantity'] ?? 0,
//       consumedQuantity: json['consumedQuantity'] ?? 0,
//       balanceQuantity: json['balanceQuantity'] ?? 0,
//       code: json['code'] as String?,
//       addons: (json['addons'] as List<dynamic>? ?? [])
//           .map((a) => Addon.fromJson(a as Map<String, dynamic>))
//           .toList(),
//       resetQuantity: json['resetQuantity'] ?? false,
//       deliveryGst: (json['deliveryGst'] ?? 0).toDouble(),
//       packingGst: (json['packingGst'] ?? 0).toDouble(),
//       unlimited: json['unlimited'] ?? false,
//       metrics: json['metrics'] ?? 'KG',
//       metricQuantity: json['metricQuantity'] ?? 0,
//       approvalStatus: json['approvalStatus'] as String?, // 👈 NEW
//       rejectionReason: json['rejectionReason'] as String?, // 👈 NEW
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'dishId': dishId,
//     'dishName': subName,
//     'price': price,
//     'description': description,
//     'dishImage': image,
//     'tag': tag,
//     'gst': gst,
//     'includeGst': includeGst,
//     'packingCharges': packingCharges,
//     'deliveryPrice': deliveryPrice,
//     'discount': discount,
//     'chefType': chefType,
//     'menuStatus': menuStatus,
//     'stockQuantity': stockQuantity,
//     'code': code,
//     'addons': addons.map((a) => a.toJson()).toList(),
//     'resetQuantity': resetQuantity,
//     'deliveryGst': deliveryGst,
//     'packingGst': packingGst,
//     'unlimited': unlimited,
//     'metrics': metrics,
//     'metricQuantity': metricQuantity,
//     // approvalStatus/rejectionReason intentionally omitted from toJson —
//     // these are server-set/read-only fields, not something the app writes back.
//   };
//
//   SubDish copyWith({
//     String? subName,
//     double? price,
//     String? description,
//     String? image,
//     String? tag,
//     double? gst,
//     bool? includeGst,
//     double? packingCharges,
//     double? deliveryPrice,
//     double? discount,
//     String? chefType,
//     String? menuStatus,
//     int? stockQuantity,
//     String? code,
//     List<Addon>? addons,
//     bool? resetQuantity,
//     double? deliveryGst,
//     double? packingGst,
//     bool? unlimited,
//     String? metrics,
//     int? metricQuantity,
//     String? approvalStatus, // 👈 NEW
//     String? rejectionReason, // 👈 NEW
//   }) {
//     return SubDish(
//       dishId: dishId,
//       subName: subName ?? this.subName,
//       price: price ?? this.price,
//       description: description ?? this.description,
//       image: image ?? this.image,
//       tag: tag ?? this.tag,
//       gst: gst ?? this.gst,
//       includeGst: includeGst ?? this.includeGst,
//       packingCharges: packingCharges ?? this.packingCharges,
//       deliveryPrice: deliveryPrice ?? this.deliveryPrice,
//       effectivePrice: effectivePrice,
//       discount: discount ?? this.discount,
//       chefType: chefType ?? this.chefType,
//       menuStatus: menuStatus ?? this.menuStatus,
//       stockQuantity: stockQuantity ?? this.stockQuantity,
//       consumedQuantity: consumedQuantity,
//       balanceQuantity: balanceQuantity,
//       code: code ?? this.code,
//       addons: addons ?? this.addons,
//       resetQuantity: resetQuantity ?? this.resetQuantity,
//       deliveryGst: deliveryGst ?? this.deliveryGst,
//       packingGst: packingGst ?? this.packingGst,
//       unlimited: unlimited ?? this.unlimited,
//       metrics: metrics ?? this.metrics,
//       metricQuantity: metricQuantity ?? this.metricQuantity,
//       approvalStatus: approvalStatus ?? this.approvalStatus,
//       rejectionReason: rejectionReason ?? this.rejectionReason,
//     );
//   }
// }
//
// class SubCategory {
//   final int dishId;
//   final String name;
//   final String? image;
//   String menuStatus;
//   List<SubDish> dishes;
//   final String? approvalStatus;
//   final String? rejectionReason;
//
//   SubCategory({
//     required this.dishId,
//     required this.name,
//     this.image,
//     this.menuStatus = 'Enable',
//     this.dishes = const [],
//     this.approvalStatus,
//     this.rejectionReason,
//   });
//
//   SubCategory copyWith({
//     String? name,
//     String? image,
//     String? menuStatus,
//     List<SubDish>? dishes,
//     String? approvalStatus,
//     String? rejectionReason,
//   }) {
//     return SubCategory(
//       dishId: dishId,
//       name: name ?? this.name,
//       image: image ?? this.image,
//       menuStatus: menuStatus ?? this.menuStatus,
//       dishes: dishes ?? this.dishes,
//       approvalStatus: approvalStatus ?? this.approvalStatus,
//       rejectionReason: rejectionReason ?? this.rejectionReason,
//     );
//   }
//
//   int get totalDishCount => dishes.length;
// }
//
// class Addon {
//   final int addonId;
//   final String addonName;
//   final double addonPrice;
//   final bool available;
//
//   Addon({
//     this.addonId = 0,
//     required this.addonName,
//     required this.addonPrice,
//     this.available = true,
//   });
//
//   factory Addon.fromJson(Map<String, dynamic> json) => Addon(
//     addonId: json['addonId'] ?? 0,
//     addonName: json['addonName'] ?? '',
//     addonPrice: (json['addonPrice'] ?? 0).toDouble(),
//     available: json['available'] ?? true,
//   );
//
//   Map<String, dynamic> toJson() => {
//     'addonId': addonId,
//     'addonName': addonName,
//     'addonPrice': addonPrice,
//     'available': available,
//   };
//
//   Addon copyWith({String? addonName, double? addonPrice, bool? available}) =>
//       Addon(
//         addonId: addonId,
//         addonName: addonName ?? this.addonName,
//         addonPrice: addonPrice ?? this.addonPrice,
//         available: available ?? this.available,
//       );
// }
//
// // ==================== MENU CATEGORY MODEL (Level 1: e.g. "Tiffines") ====================
// class MenuCategory {
//   final int dishId;
//   final String category;
//   final String? image;
//   String menuStatus;
//   List<SubCategory> subcategories;
//   final String? approvalStatus;
//   final String? rejectionReason;
//
//   List<SubDish> get allDishes =>
//       subcategories.expand((sc) => sc.dishes).toList();
//
//   MenuCategory({
//     required this.dishId,
//     required this.category,
//     this.image,
//     this.menuStatus = 'Enable',
//     this.subcategories = const [],
//     this.approvalStatus,
//     this.rejectionReason,
//   });
//
//   MenuCategory copyWith({
//     String? category,
//     String? image,
//     String? menuStatus,
//     List<SubCategory>? subcategories,
//     String? approvalStatus,
//     String? rejectionReason,
//   }) {
//     return MenuCategory(
//       dishId: dishId,
//       category: category ?? this.category,
//       image: image ?? this.image,
//       menuStatus: menuStatus ?? this.menuStatus,
//       subcategories: subcategories ?? this.subcategories,
//       approvalStatus: approvalStatus ?? this.approvalStatus,
//       rejectionReason: rejectionReason ?? this.rejectionReason,
//     );
//   }
// }
// // ==================== PACKAGE MODELS ====================
//
// class PackageItem {
//   final int id;
//   final String itemName;
//   final double price;
//   final String? image;
//   final String? description;
//
//   PackageItem({
//     required this.id,
//     required this.itemName,
//     required this.price,
//     this.image,
//     this.description,
//   });
//
//   factory PackageItem.fromJson(Map<String, dynamic> json) {
//     return PackageItem(
//       id: json['id'] ?? 0,
//       itemName: json['itemName'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       image: json['image'],
//       description: json['description'],
//     );
//   }
//
//   PackageItem copyWith({String? itemName, double? price}) {
//     return PackageItem(
//       id: id,
//       itemName: itemName ?? this.itemName,
//       price: price ?? this.price,
//       image: image,
//       description: description,
//     );
//   }
// }
//
// class MenuPackage {
//   final int id;
//   final String packageName;
//   final String packageType;
//   final String? image;
//   final double totalPrice;
//   final List<PackageItem> items;
//
//   MenuPackage({
//     required this.id,
//     required this.packageName,
//     required this.packageType,
//     this.image,
//     required this.totalPrice,
//     this.items = const [],
//   });
//
//   factory MenuPackage.fromJson(Map<String, dynamic> json) {
//     final itemsList = (json['items'] as List<dynamic>? ?? [])
//         .map((i) => PackageItem.fromJson(i))
//         .toList();
//     return MenuPackage(
//       id: json['id'] ?? 0,
//       packageName: json['packageName'] ?? '',
//       packageType: json['packageType'] ?? 'Veg',
//       image: json['image'],
//       totalPrice: (json['totalPrice'] ?? 0).toDouble(),
//       items: itemsList,
//     );
//   }
//
//   double get computedTotal =>
//       totalPrice > 0 ? totalPrice : items.fold(0, (s, i) => s + i.price);
// }

class SubDish {
  final int dishId;
  final String subName;
  final double price;
  final String description;
  final String? image;
  final String tag;
  final double gst;
  final bool includeGst;
  final double packingCharges;
  final double deliveryPrice;
  final double effectivePrice;
  final double discount;
  final String chefType;
  String menuStatus;
  int stockQuantity;
  final int consumedQuantity;
  final int balanceQuantity;
  final String? code;
  final List<Addon> addons;
  final bool resetQuantity;
  final double deliveryGst;
  final double packingGst;
  final bool
  deliveryIncludeGst; // 👈 NEW — mirrors `includeGst` but for delivery price
  final bool unlimited;
  final String metrics;
  final int metricQuantity;
  final String? approvalStatus; // 👈 NEW
  final String? rejectionReason; // 👈 NEW

  SubDish({
    required this.dishId,
    required this.subName,
    required this.price,
    this.description = '',
    this.image,
    this.tag = 'Veg',
    this.gst = 0,
    this.includeGst = false,
    this.packingCharges = 0,
    this.deliveryPrice = 0,
    this.effectivePrice = 0,
    this.discount = 0,
    this.chefType = 'Chef_All',
    this.menuStatus = 'Enable',
    this.stockQuantity = 0,
    this.consumedQuantity = 0,
    this.balanceQuantity = 0,
    this.code,
    this.addons = const [],
    this.resetQuantity = false,
    this.deliveryGst = 0,
    this.packingGst = 0,
    this.deliveryIncludeGst = false, // 👈 NEW
    this.unlimited = false,
    this.metrics = 'KG',
    this.metricQuantity = 0,
    this.approvalStatus, // 👈 NEW
    this.rejectionReason, // 👈 NEW
  });

  factory SubDish.fromJson(Map<String, dynamic> json) {
    return SubDish(
      dishId: json['dishId'] ?? 0,
      subName: json['subName'] ?? json['dishName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      image: json['dishImage'],
      tag: json['tag'] ?? 'Veg',
      gst: (json['gst'] ?? 0).toDouble(),
      includeGst: json['includeGst'] ?? false,
      packingCharges: (json['packingCharges'] ?? 0).toDouble(),
      deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
      effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      chefType: json['chefType'] ?? 'Chef_All',
      menuStatus: json['menuStatus'] ?? 'Enable',
      stockQuantity: json['stockQuantity'] ?? 0,
      consumedQuantity: json['consumedQuantity'] ?? 0,
      balanceQuantity: json['balanceQuantity'] ?? 0,
      code: json['code'] as String?,
      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((a) => Addon.fromJson(a as Map<String, dynamic>))
          .toList(),
      resetQuantity: json['resetQuantity'] ?? false,
      deliveryGst: (json['deliveryGst'] ?? 0).toDouble(),
      packingGst: (json['packingGst'] ?? 0).toDouble(),
      deliveryIncludeGst: json['deliveryIncludeGst'] ?? false, // 👈 NEW
      unlimited: json['unlimited'] ?? false,
      metrics: json['metrics'] ?? 'KG',
      metricQuantity: json['metricQuantity'] ?? 0,
      approvalStatus: json['approvalStatus'] as String?, // 👈 NEW
      rejectionReason: json['rejectionReason'] as String?, // 👈 NEW
    );
  }

  Map<String, dynamic> toJson() => {
    'dishId': dishId,
    'dishName': subName,
    'price': price,
    'description': description,
    'dishImage': image,
    'tag': tag,
    'gst': gst,
    'includeGst': includeGst,
    'packingCharges': packingCharges,
    'deliveryPrice': deliveryPrice,
    'discount': discount,
    'chefType': chefType,
    'menuStatus': menuStatus,
    'stockQuantity': stockQuantity,
    'code': code,
    'addons': addons.map((a) => a.toJson()).toList(),
    'resetQuantity': resetQuantity,
    'deliveryGst': deliveryGst,
    'packingGst': packingGst,
    'deliveryIncludeGst': deliveryIncludeGst, // 👈 NEW
    'unlimited': unlimited,
    'metrics': metrics,
    'metricQuantity': metricQuantity,
    // approvalStatus/rejectionReason intentionally omitted from toJson —
    // these are server-set/read-only fields, not something the app writes back.
  };

  SubDish copyWith({
    String? subName,
    double? price,
    String? description,
    String? image,
    String? tag,
    double? gst,
    bool? includeGst,
    double? packingCharges,
    double? deliveryPrice,
    double? discount,
    String? chefType,
    String? menuStatus,
    int? stockQuantity,
    String? code,
    List<Addon>? addons,
    bool? resetQuantity,
    double? deliveryGst,
    double? packingGst,
    bool? deliveryIncludeGst, // 👈 NEW
    bool? unlimited,
    String? metrics,
    int? metricQuantity,
    String? approvalStatus, // 👈 NEW
    String? rejectionReason, // 👈 NEW
  }) {
    return SubDish(
      dishId: dishId,
      subName: subName ?? this.subName,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      tag: tag ?? this.tag,
      gst: gst ?? this.gst,
      includeGst: includeGst ?? this.includeGst,
      packingCharges: packingCharges ?? this.packingCharges,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      effectivePrice: effectivePrice,
      discount: discount ?? this.discount,
      chefType: chefType ?? this.chefType,
      menuStatus: menuStatus ?? this.menuStatus,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      consumedQuantity: consumedQuantity,
      balanceQuantity: balanceQuantity,
      code: code ?? this.code,
      addons: addons ?? this.addons,
      resetQuantity: resetQuantity ?? this.resetQuantity,
      deliveryGst: deliveryGst ?? this.deliveryGst,
      packingGst: packingGst ?? this.packingGst,
      deliveryIncludeGst:
          deliveryIncludeGst ?? this.deliveryIncludeGst, // 👈 NEW
      unlimited: unlimited ?? this.unlimited,
      metrics: metrics ?? this.metrics,
      metricQuantity: metricQuantity ?? this.metricQuantity,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class SubCategory {
  final int dishId;
  final String name;
  final String? image;
  String menuStatus;
  List<SubDish> dishes;
  final String? approvalStatus;
  final String? rejectionReason;

  SubCategory({
    required this.dishId,
    required this.name,
    this.image,
    this.menuStatus = 'Enable',
    this.dishes = const [],
    this.approvalStatus,
    this.rejectionReason,
  });

  SubCategory copyWith({
    String? name,
    String? image,
    String? menuStatus,
    List<SubDish>? dishes,
    String? approvalStatus,
    String? rejectionReason,
  }) {
    return SubCategory(
      dishId: dishId,
      name: name ?? this.name,
      image: image ?? this.image,
      menuStatus: menuStatus ?? this.menuStatus,
      dishes: dishes ?? this.dishes,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  int get totalDishCount => dishes.length;
}

class Addon {
  final int addonId;
  final String addonName;
  final double addonPrice;
  final bool available;

  Addon({
    this.addonId = 0,
    required this.addonName,
    required this.addonPrice,
    this.available = true,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    addonId: json['addonId'] ?? 0,
    addonName: json['addonName'] ?? '',
    addonPrice: (json['addonPrice'] ?? 0).toDouble(),
    available: json['available'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'addonId': addonId,
    'addonName': addonName,
    'addonPrice': addonPrice,
    'available': available,
  };

  Addon copyWith({String? addonName, double? addonPrice, bool? available}) =>
      Addon(
        addonId: addonId,
        addonName: addonName ?? this.addonName,
        addonPrice: addonPrice ?? this.addonPrice,
        available: available ?? this.available,
      );
}

// ==================== MENU CATEGORY MODEL (Level 1: e.g. "Tiffines") ====================
class MenuCategory {
  final int dishId;
  final String category;
  final String? image;
  String menuStatus;
  List<SubCategory> subcategories;
  final String? approvalStatus;
  final String? rejectionReason;

  List<SubDish> get allDishes =>
      subcategories.expand((sc) => sc.dishes).toList();

  MenuCategory({
    required this.dishId,
    required this.category,
    this.image,
    this.menuStatus = 'Enable',
    this.subcategories = const [],
    this.approvalStatus,
    this.rejectionReason,
  });

  MenuCategory copyWith({
    String? category,
    String? image,
    String? menuStatus,
    List<SubCategory>? subcategories,
    String? approvalStatus,
    String? rejectionReason,
  }) {
    return MenuCategory(
      dishId: dishId,
      category: category ?? this.category,
      image: image ?? this.image,
      menuStatus: menuStatus ?? this.menuStatus,
      subcategories: subcategories ?? this.subcategories,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
// ==================== PACKAGE MODELS ====================

class PackageItem {
  final int id;
  final String itemName;
  final double price;
  final String? image;
  final String? description;

  PackageItem({
    required this.id,
    required this.itemName,
    required this.price,
    this.image,
    this.description,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'] ?? 0,
      itemName: json['itemName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      description: json['description'],
    );
  }

  PackageItem copyWith({String? itemName, double? price}) {
    return PackageItem(
      id: id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      image: image,
      description: description,
    );
  }
}

class MenuPackage {
  final int id;
  final String packageName;
  final String packageType;
  final String? image;
  final double totalPrice;
  final List<PackageItem> items;

  MenuPackage({
    required this.id,
    required this.packageName,
    required this.packageType,
    this.image,
    required this.totalPrice,
    this.items = const [],
  });

  factory MenuPackage.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((i) => PackageItem.fromJson(i))
        .toList();
    return MenuPackage(
      id: json['id'] ?? 0,
      packageName: json['packageName'] ?? '',
      packageType: json['packageType'] ?? 'Veg',
      image: json['image'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      items: itemsList,
    );
  }

  double get computedTotal =>
      totalPrice > 0 ? totalPrice : items.fold(0, (s, i) => s + i.price);
}
