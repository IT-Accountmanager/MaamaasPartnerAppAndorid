// import 'package:flutter/material.dart';
// import 'package:maamaaspartner/Setting%20&%20Control/screens/role_controls_screen.dart';
// import 'CreateTable.dart';
// import 'billing_setup_screen.dart';
// import 'general_controls_screen.dart';
//
// // ─── Design tokens ────────────────────────────────────────────────────────────
// const _kWhite = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBorder = Color(0xFFEEEFF5);
// const _kPrimary = Color(0xFFE66D33);
// const _kPrimDk = Color(0xFFE66D33);
// const _kPrimLt = Color(0xFFF5E8FA);
// const _kText1 = Color(0xFF111827);
// const _kText2 = Color(0xFF6B7280);
// const _kMuted = Color(0xFFB0B3C1);
//
// const _kGrad = LinearGradient(
//   colors: [_kPrimary, _kPrimDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tc;
//   int _activeIdx = 0;
//
//
//   static const _tabs = [
//     (label: 'General'),
//     (label: 'Billing Setup'),
//     (label: 'Role & Controls'),
//     (label: 'Create Table'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tc = TabController(length: 4, vsync: this); // CHANGED: 3 to 4
//     _tc.addListener(() {
//       if (mounted) setState(() => _activeIdx = _tc.index);
//     });
//   }
//
//   @override
//   void dispose() {
//     _tc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kBg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── App bar ───────────────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
//               decoration: const BoxDecoration(
//                 color: _kWhite,
//                 border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
//               ),
//               child: Row(
//                 children: [
//                   // Back button (fixed left)
//                   if (Navigator.canPop(context))
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: 36,
//                         height: 36,
//                         margin: const EdgeInsets.only(right: 10),
//                         decoration: BoxDecoration(
//                           color: _kBg,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: _kBorder),
//                         ),
//                         child: const Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           color: _kText1,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//
//                   // Scrollable tab chips (fills the middle)
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       physics: const BouncingScrollPhysics(),
//                       child: Row(
//                         children: List.generate(_tabs.length, (i) {
//                           final isActive = _activeIdx == i;
//                           return GestureDetector(
//                             onTap: () => _tc.animateTo(i),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               margin: const EdgeInsets.only(right: 8),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isActive ? _kPrimary : _kWhite,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: isActive ? _kPrimary : _kBorder,
//                                 ),
//                               ),
//                               child: Text(
//                                 _tabs[i].label,
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: isActive
//                                       ? FontWeight.w700
//                                       : FontWeight.w500,
//                                   color: isActive ? _kWhite : _kText2,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Tab content ───────────────────────────────────────────────────
//             Expanded(
//               child: TabBarView(
//                 controller: _tc,
//                 children: const [
//                   GeneralControlsScreen(),
//                   BillingSetupScreen(),
//                   RoleControlsScreen(),
//                   // CreateTableScreen(),
//                   TableManagementScreen(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:maamaaspartner/Setting%20&%20Control/screens/role_controls_screen.dart';
import 'CreateTable.dart';
import 'billing_setup_screen.dart';
import 'general_controls_screen.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kWhite = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBorder = Color(0xFFEEEFF5);
const _kPrimary = Color(0xFFE66D33);
const _kPrimDk = Color(0xFFE66D33);
const _kPrimLt = Color(0xFFF5E8FA);
const _kText1 = Color(0xFF111827);
const _kText2 = Color(0xFF6B7280);
const _kMuted = Color(0xFFB0B3C1);

const _kGrad = LinearGradient(
  colors: [_kPrimary, _kPrimDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  int _activeIdx = 0;

  static const _tabs = [
    'General',
    'Billing Setup',
    'Role & Controls',
    'Create Table',
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 4, vsync: this);
    _tc.addListener(() {
      if (mounted) setState(() => _activeIdx = _tc.index);
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header with tab chips (styled like ReportsScreen) ─────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: _kWhite,
                border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
              ),
              child: Row(
                children: [
                  // Back button
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 15,
                          color: _kText1,
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),

                  // Scrollable tab chips (EXACT styling from ReportsScreen)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _tabs.asMap().entries.map((entry) {
                          final i = entry.key;
                          final label = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: i < _tabs.length - 1 ? 6 : 0,
                            ),
                            child: _tabChip(label: label, index: i),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab content ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tc,
                children: const [
                  GeneralControlsScreen(),
                  BillingSetupScreen(),
                  RoleControlsScreen(),
                  TableManagementScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip({required String label, required int index}) {
    final isActive = _tc.index == index;

    return GestureDetector(
      onTap: () => _tc.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : const Color(0xFFE66D33),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
