// import 'package:flutter/material.dart';
// import '../Catering&TableServices/Caterings.dart';
// import '../Food&beverages/Food&beverages_homescreen.dart';
// import '../Fresh&Groceries/Stores_screen.dart';
// import '../Logistics&supply/logistics_homepage.dart';
// import '../newscreens/restaurentsnew.dart';
//
// class QuickAccessScroll extends StatelessWidget {
//   final List<String> items = [
//     "assets/FOODBEVERAGES.webp",
//     "assets/CATERINGSERVICES_V1.webp",
//     "assets/FRESHGROCERIES.webp",
//     "assets/LOGISTICSANDSUPPLY.webp",
//   ];
//
//   QuickAccessScroll({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 6,
//           mainAxisSpacing: 8,
//           childAspectRatio: 1.2,
//         ),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               switch (index) {
//                 case 0:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => Restaurentsnew()),
//                   );
//                   break;
//                 case 1:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => CateringsPage()),
//                   );
//                   break;
//                 case 2:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => stores()),
//                   );
//                   break;
//                 case 3:
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => LogisticsScreen()),
//                   );
//                   break;
//                 }
//             },
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 2,
//               color: Colors.white,
//               child: Container(
//                 child: SizedBox(
//                   height: 120,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.asset(
//                       items[index],
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }