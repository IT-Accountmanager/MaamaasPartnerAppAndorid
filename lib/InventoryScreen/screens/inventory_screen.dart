// import 'package:flutter/material.dart';
// import '../widgets/theme.dart';
// import 'stock_management_screen.dart';
// import 'daily_consumption_screen.dart';
// import 'procurement_screen.dart';
//
//
// class InventoryScreen extends StatefulWidget {
//   const InventoryScreen({super.key});
//   @override
//   State<InventoryScreen> createState() => _InventoryScreenState();
// }
//
// class _InventoryScreenState extends State<InventoryScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabs;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabs = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabs.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: invBg,
//     appBar: AppBar(
//       backgroundColor: invCard,
//       elevation: 0,
//       centerTitle: false,
//       leading: Navigator.canPop(context)
//           ? IconButton(
//               icon: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: invBg,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: invBorder),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back_ios_rounded,
//                   size: 15,
//                   color: invText1,
//                 ),
//               ),
//               onPressed: () => Navigator.pop(context),
//             )
//           : null,
//       title: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Inventory Management',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: invText1,
//               letterSpacing: -0.3,
//             ),
//           ),
//           Text(
//             'Food & Beverages',
//             style: TextStyle(fontSize: 11, color: invText2),
//           ),
//         ],
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(46),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: invCard,
//             border: Border(bottom: BorderSide(color: invBorder)),
//           ),
//           child: TabBar(
//             controller: _tabs,
//             indicatorColor: invAccent,
//             indicatorWeight: 3,
//             labelColor: invAccent,
//             unselectedLabelColor: invText2,
//             labelStyle: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             indicatorSize: TabBarIndicatorSize.label,
//             tabs: const [
//               Tab(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.inventory_2_outlined, size: 14),
//                     SizedBox(width: 5),
//                     Text('Stock'),
//                   ],
//                 ),
//               ),
//               Tab(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.format_list_bulleted_rounded, size: 14),
//                     SizedBox(width: 5),
//                     Text('Daily'),
//                   ],
//                 ),
//               ),
//               Tab(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.local_shipping_outlined, size: 14),
//                     SizedBox(width: 5),
//                     Text('Procurement'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     body: TabBarView(
//       controller: _tabs,
//       children: const [
//         StockManagementScreen(),
//         DailyConsumptionScreen(),
//         ProcurementScreen(),
//       ],
//     ),
//   );
// }
import 'package:flutter/material.dart';
import '../widgets/theme.dart';
import 'stock_management_screen.dart';
import 'daily_consumption_screen.dart';
import 'procurement_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);

    // Add listener to rebuild when tab changes
    _tabs.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: invBg,
    appBar: AppBar(
      backgroundColor: invCard,
      elevation: 0,
      centerTitle: false,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: invBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: invBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 15,
                  color: invText1,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTabButton('Stock', Icons.inventory_2_outlined, 0),
              const SizedBox(width: 8),
              _buildTabButton('Daily', Icons.format_list_bulleted_rounded, 1),
              const SizedBox(width: 8),
              _buildTabButton('Procurement', Icons.local_shipping_outlined, 2),
            ],
          ),
        ),
      ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: const [
        StockManagementScreen(),
        DailyConsumptionScreen(),
        ProcurementScreen(),
      ],
    ),
  );

  Widget _buildTabButton(String title, IconData icon, int index) {
    final isSelected = _tabs.index == index;

    return GestureDetector(
      onTap: () {
        _tabs.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? invAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? invAccent : invBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : invText2),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : invText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
