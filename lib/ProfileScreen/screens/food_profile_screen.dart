// import 'package:flutter/material.dart';
// import '../widgets/theme.dart';
// import 'banner_section.dart';
// import 'sections.dart';
// import 'registration_screen.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // FoodProfileScreen  ←  drop this into your HomeWrapper / navigation
// //
// // From your existing app:
// //   Navigator.push(context,
// //     MaterialPageRoute(builder: (_) => const FoodProfileScreen()));
// // ─────────────────────────────────────────────────────────────────────────────
//
// class FoodProfileScreen extends StatefulWidget {
//   const FoodProfileScreen({super.key});
//
//   @override
//   State<FoodProfileScreen> createState() => _FoodProfileScreenState();
// }
//
// class _FoodProfileScreenState extends State<FoodProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabCtrl;
//   int _activeTab = 0;
//
//   final List<_TabItem> _tabs = const [
//     _TabItem(label: 'About Us', icon: Icons.info_outline_rounded),
//     _TabItem(label: 'Registration', icon: Icons.assignment_outlined),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabCtrl = TabController(length: _tabs.length, vsync: this);
//     _tabCtrl.addListener(() {
//       if (_tabCtrl.indexIsChanging) {
//         setState(() => _activeTab = _tabCtrl.index);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       body: NestedScrollView(
//         headerSliverBuilder: (ctx, _) => [
//           // ── App Bar ──────────────────────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 0,
//             floating: true,
//             snap: true,
//             pinned: false,
//             backgroundColor: kPrimary,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white, size: 20),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: const Text(
//               'Food & Beverages Profile',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 17,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh_rounded,
//                     color: Colors.white, size: 22),
//                 onPressed: () => setState(() {}),
//               ),
//             ],
//           ),
//
//           // ── Company Banner ────────────────────────────────────────────────
//           const SliverToBoxAdapter(
//             child: CompanyBannerSection(),
//           ),
//
//           // ── Tab Bar (sticky) ──────────────────────────────────────────────
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _StickyTabBarDelegate(
//               child: Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabCtrl,
//                   onTap: (i) => setState(() => _activeTab = i),
//                   indicatorColor: kPrimary,
//                   indicatorWeight: 3,
//                   labelColor: kPrimary,
//                   unselectedLabelColor: kText2,
//                   labelStyle: const TextStyle(
//                       fontWeight: FontWeight.w700, fontSize: 13),
//                   unselectedLabelStyle: const TextStyle(
//                       fontWeight: FontWeight.w500, fontSize: 13),
//                   tabs: _tabs
//                       .map((t) => Tab(
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(t.icon, size: 16),
//                                 const SizedBox(width: 6),
//                                 Text(t.label),
//                               ],
//                             ),
//                           ))
//                       .toList(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tabCtrl,
//           children: [
//             // ── About Us Tab ─────────────────────────────────────────────
//             _AboutUsTab(),
//             // ── Registration Tab ─────────────────────────────────────────
//             const RegistrationScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── About Us Tab (scrollable with all sections) ──────────────────────────────
// class _AboutUsTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.zero,
//       children: const [
//         AboutUsSection(),
//         MissionVisionSection(),
//         LeadershipSection(),
//         GallerySection(),
//         SizedBox(height: 40),
//       ],
//     );
//   }
// }
//
// // ─── Tab item data ─────────────────────────────────────────────────────────────
// class _TabItem {
//   final String label;
//   final IconData icon;
//   const _TabItem({required this.label, required this.icon});
// }
//
// // ─── Sticky tab bar delegate ───────────────────────────────────────────────────
// class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   const _StickyTabBarDelegate({required this.child});
//
//   @override
//   double get minExtent => 48;
//   @override
//   double get maxExtent => 48;
//
//   @override
//   Widget build(
//           BuildContext ctx, double shrinkOffset, bool overlapsContent) =>
//       child;
//
//   @override
//   bool shouldRebuild(_StickyTabBarDelegate old) => old.child != child;
// }
