// class FoodItem {
//   final int dishId;
//   final double price;
//   final String dishName;
//   final String tag; // Veg/Non-Veg
//   final String? stock;
//   final int parentId;
//   final String? menuStatus;
//   final String? dishImage;
//   final String? description;
//   final double? stockQuantity;
//   final int consumedQuantity;
//   final int balanceQuantity;
//   final double effectivePrice;
//   final String chefType;
//
//   FoodItem({
//     this.dishId = 0,
//     required this.price,
//     required this.dishName,
//     required this.tag,
//     this.stock,
//     required this.parentId,
//     this.menuStatus,
//     this.dishImage,
//     this.description,
//     this.stockQuantity,
//     this.consumedQuantity = 0,
//     this.balanceQuantity = 0,
//     this.effectivePrice = 0,
//     required this.chefType,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       "dishId": dishId,
//       "price": price,
//       "dishName": dishName,
//       "tag": tag,
//       "stock": stock,
//       "parentId": parentId,
//       "menuStatus": menuStatus,
//       "dishImage": dishImage,
//       "description": description,
//       "stockQuantity": stockQuantity,
//       "consumedQuantity": consumedQuantity,
//       "balanceQuantity": balanceQuantity,
//       "effectivePrice": effectivePrice,
//     };
//   }
// }
