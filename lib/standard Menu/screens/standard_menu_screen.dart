// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../widgets/common_widgets.dart';
// import 'menu_tab.dart';
// import 'packages_tab.dart';
//
// const _kWhite = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBorder = Color(0xFFEEEFF5);
// const _kPrimary = Color(0xFFB15DC6);
// const _kPrimDk = Color(0xFF8B3FA0);
// const _kPrimLt = Color(0xFFF5E8FA);
// const _kText1 = Color(0xFF111827);
// const _kText2 = Color(0xFF6B7280);
// const _kMuted = Color(0xFFB0B3C1);
// const _kWrn = Color(0xFFF59E0B);
// const _kWLt = Color(0xFFFEF3C7);
// const _kGrad = LinearGradient(
//   colors: [_kPrimary, _kPrimDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class StandardMenuScreen extends StatefulWidget {
//   const StandardMenuScreen({super.key});
//   @override
//   State<StandardMenuScreen> createState() => _StandardMenuScreenState();
// }
//
// class _StandardMenuScreenState extends State<StandardMenuScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//   int _currentIndex = 0;
//   String _foodFilter = 'all';
//   bool _showCategories = true;
//
//   // ── Keys to call methods on MenuTab / PackagesTab ─────────────────────────
//   final _menuTabKey = GlobalKey<MenuTabState>();
//   final _packagesTabKey = GlobalKey<PackagesTabState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) return;
//       setState(() => _currentIndex = _tabController.index);
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _onAddCategory() {
//     if (_currentIndex == 0) {
//       _menuTabKey.currentState?.openAddCategory();
//     } else {
//       _packagesTabKey.currentState?.openAddCategory();
//     }
//   }
//
//   void _onBulkStock() {
//     if (_currentIndex == 0) {
//       _menuTabKey.currentState?.enableBulkMode();
//     } else {
//       _packagesTabKey.currentState?.enableBulkMode();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: _kBg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── App bar ───────────────────────────────────────────────────
//             Container(
//               color: _kWhite,
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
//                     child: Row(
//                       children: [
//                         // ── Back button ───────────────────────────────────
//                         if (Navigator.of(context).canPop())
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Container(
//                               width: 36,
//                               height: 36,
//                               margin: const EdgeInsets.only(right: 10),
//                               decoration: BoxDecoration(
//                                 color: _kBg,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: _kBorder),
//                               ),
//                               child: const Icon(
//                                 Icons.arrow_back_ios_new_rounded,
//                                 color: _kText1,
//                                 size: 15,
//                               ),
//                             ),
//                           ),
//
//                         // ── Scrollable chips row ──────────────────────────
//                         Expanded(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             physics: const BouncingScrollPhysics(),
//                             child: Row(
//                               children: [
//                                 // ── Dishes / Packages tab chips ───────────────
//                                 _TabChip(
//                                   index: 0,
//                                   current: _currentIndex,
//                                   label: 'Dishes',
//                                   onTap: () => _tabController.animateTo(0),
//                                 ),
//                                 const SizedBox(width: 4),
//
//                                 _TabChip(
//                                   index: 1,
//                                   current: _currentIndex,
//                                   label: 'Packages',
//                                   onTap: () => _tabController.animateTo(1),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // ── Action buttons row (NEW) ─────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 0, 14, 1),
//                     child: Row(
//                       children: [
//                         _AppBarBtn(
//                           label: 'Add Category',
//                           icon: Icons.add_rounded,
//                           color: _kPrimary,
//                           bg: _kPrimLt,
//                           onTap: _onAddCategory,
//                         ),
//                         const SizedBox(width: 8),
//                         _AppBarBtn(
//                           label: 'Bulk Stock',
//                           icon: Icons.edit_note_rounded,
//                           color: _kWrn,
//                           bg: _kWLt,
//                           onTap: _onBulkStock,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Tab content ───────────────────────────────────────────────
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   MenuTab(key: _menuTabKey),
//                   PackagesTab(key: _packagesTabKey),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── App bar action button ──────────────────────────────────────────────────────
// class _AppBarBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color, bg;
//   final VoidCallback onTap;
//   const _AppBarBtn({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.bg,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.35)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: color),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ── Tab chip ───────────────────────────────────────────────────────────────────
// class _TabChip extends StatelessWidget {
//   final int index, current;
//   final String label;
//   final VoidCallback onTap;
//
//   const _TabChip({
//     required this.index,
//     required this.current,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final sel = current == index;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         width: 150, // ✅ Added width here
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         height: 40,
//         decoration: BoxDecoration(
//           gradient: sel ? _kGrad : null,
//           color: sel ? null : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(7),
//           boxShadow: sel
//               ? [
//                   BoxShadow(
//                     color: _kPrimary.withOpacity(0.25),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Center(
//           child: Text(
//             label,
//             overflow: TextOverflow.ellipsis, // ✅ avoids overflow
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: sel ? _kWhite : _kText2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Filter chip ────────────────────────────────────────────────────────────────
// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color activeColor, activeBg;
//   final Color? dot;
//   final VoidCallback onTap;
//   const _FilterChip({
//     required this.label,
//     required this.active,
//     required this.activeColor,
//     required this.activeBg,
//     required this.onTap,
//     this.dot,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: active ? activeBg : _kBg,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: active ? activeColor.withOpacity(0.4) : _kBorder,
//             width: active ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (dot != null) ...[
//               Container(
//                 width: 7,
//                 height: 7,
//                 decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
//               ),
//               const SizedBox(width: 5),
//             ],
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: active ? activeColor : _kText2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/common_widgets.dart';
import 'menu_tab.dart';
import 'packages_tab.dart';

const _kWhite = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBorder = Color(0xFFEEEFF5);
const _kPrimary = Color(0xFFF97316);
const _kPrimDk = Color(0xFFC2510F);
const _kPrimLt = Color(0xFFFFF0E6);
const _kText1 = Color(0xFF111827);
const _kText2 = Color(0xFF6B7280);
const _kMuted = Color(0xFFB0B3C1);
const _kWrn = Color(0xFF16A34A);
const _kWLt = Color(0xFFDCFCE7);
const _kGrad = LinearGradient(
  colors: [_kPrimary, _kPrimDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class StandardMenuScreen extends StatefulWidget {
  const StandardMenuScreen({super.key});
  @override
  State<StandardMenuScreen> createState() => _StandardMenuScreenState();
}

class _StandardMenuScreenState extends State<StandardMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;
  String _foodFilter = 'all';
  bool _showCategories = true;

  // ── Keys to call methods on MenuTab / PackagesTab ─────────────────────────
  final _menuTabKey = GlobalKey<MenuTabState>();
  final _packagesTabKey = GlobalKey<PackagesTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _currentIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAddCategory() {
    if (_currentIndex == 0) {
      _menuTabKey.currentState?.openAddCategory();
    } else {
      _packagesTabKey.currentState?.openAddCategory();
    }
  }

  void _onBulkStock() {
    if (_currentIndex == 0) {
      _menuTabKey.currentState?.enableBulkMode();
    } else {
      _packagesTabKey.currentState?.enableBulkMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            Container(
              color: _kWhite,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      children: [
                        // ── Back button ───────────────────────────────────
                        if (Navigator.of(context).canPop())
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kBorder),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: _kText1,
                                size: 15,
                              ),
                            ),
                          ),

                        // ── Scrollable chips row ──────────────────────────
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                // ── Dishes / Packages tab chips ───────────────
                                _TabChip(
                                  index: 0,
                                  current: _currentIndex,
                                  label: 'Dishes',
                                  onTap: () => _tabController.animateTo(0),
                                ),
                                const SizedBox(width: 4),

                                _TabChip(
                                  index: 1,
                                  current: _currentIndex,
                                  label: 'Packages',
                                  onTap: () => _tabController.animateTo(1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Action buttons row (NEW) ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 1),
                    child: Row(
                      children: [
                        _AppBarBtn(
                          label: 'Add Category',
                          icon: Icons.add_rounded,
                          color: _kPrimary,
                          bg: _kPrimLt,
                          onTap: _onAddCategory,
                        ),
                        const SizedBox(width: 8),
                        _AppBarBtn(
                          label: 'Bulk Stock',
                          icon: Icons.edit_note_rounded,
                          color: _kWrn,
                          bg: _kWLt,
                          onTap: _onBulkStock,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  MenuTab(key: _menuTabKey),
                  PackagesTab(key: _packagesTabKey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar action button ──────────────────────────────────────────────────────
class _AppBarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _AppBarBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Tab chip ───────────────────────────────────────────────────────────────────
class _TabChip extends StatelessWidget {
  final int index, current;
  final String label;
  final VoidCallback onTap;

  const _TabChip({
    required this.index,
    required this.current,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sel = current == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 150, // ✅ Added width here
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 40,
        decoration: BoxDecoration(
          gradient: sel ? _kGrad : null,
          color: sel ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
          boxShadow: sel
              ? [
            BoxShadow(
              color: _kPrimary.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis, // ✅ avoids overflow
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: sel ? _kWhite : _kText2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor, activeBg;
  final Color? dot;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
    this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeBg : _kBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? activeColor.withOpacity(0.4) : _kBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? activeColor : _kText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}