// // // import 'package:flutter/material.dart';
// // // import '../models/employee.dart';
// // // import '../services/api_service.dart';
// // // import '../widgets/theme.dart';
// // // import 'add_employee_sheet.dart';
// // // import 'edit_employee_sheet.dart';
// // //
// // // const _kW = Color(0xFFFFFFFF);
// // // const _kBg = Color(0xFFF7F8FC);
// // // const _kBrd = Color(0xFFEEEFF5);
// // // const _kP = Color(0xFFB15DC6);
// // // const _kPDk = Color(0xFF8B3FA0);
// // // const _kPLt = Color(0xFFF5E8FA);
// // // const _kSuc = Color(0xFF10B981);
// // // const _kSLt = Color(0xFFD1FAE5);
// // // const _kSDk = Color(0xFF059669);
// // // const _kDng = Color(0xFFEF4444);
// // // const _kDLt = Color(0xFFFEE2E2);
// // // const _kWrn = Color(0xFFF59E0B);
// // // const _kInf = Color(0xFF3B82F6);
// // // const _kT1 = Color(0xFF111827);
// // // const _kT2 = Color(0xFF6B7280);
// // // const _kMut = Color(0xFFB0B3C1);
// // // const _kShd = Color(0x0A000000);
// // // const _kGrd = LinearGradient(
// // //   colors: [_kP, _kPDk],
// // //   begin: Alignment.topLeft,
// // //   end: Alignment.bottomRight,
// // // );
// // //
// // // class TeamDirectoryScreen extends StatefulWidget {
// // //   const TeamDirectoryScreen({super.key});
// // //   @override
// // //   State<TeamDirectoryScreen> createState() => _TeamDirectoryScreenState();
// // // }
// // //
// // // class _TeamDirectoryScreenState extends State<TeamDirectoryScreen> {
// // //   List<Employee> _all = [];
// // //   bool _loading = true;
// // //   String? _error;
// // //   final _searchCtrl = TextEditingController();
// // //   String _searchQ = '';
// // //   String _filterRole = '';
// // //   String _filterStatus = '';
// // //   String _activeChip = '';
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _load();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _searchCtrl.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _load() async {
// // //     setState(() {
// // //       _loading = true;
// // //       _error = null;
// // //     });
// // //     try {
// // //       final list = await EmployeeApi.fetchAll();
// // //       if (mounted)
// // //         setState(() {
// // //           _all = list;
// // //           _loading = false;
// // //         });
// // //     } catch (e) {
// // //       if (mounted)
// // //         setState(() {
// // //           _error = e.toString();
// // //           _loading = false;
// // //         });
// // //     }
// // //   }
// // //
// // //   int get _total => _all.length;
// // //   int get _chefs =>
// // //       _all.where((e) => e.role.toLowerCase().contains('chef')).length;
// // //   int get _managers =>
// // //       _all.where((e) => e.role.toLowerCase().contains('manager')).length;
// // //   int get _inactive => _all.where((e) => !e.isActive).length;
// // //
// // //   List<Employee> get _filtered => _all.where((e) {
// // //     // Chip filter
// // //     if (_activeChip == 'chefs' && !e.role.toLowerCase().contains('chef'))
// // //       return false;
// // //     if (_activeChip == 'managers' && !e.role.toLowerCase().contains('manager'))
// // //       return false;
// // //     if (_activeChip == 'inactive' && e.isActive) return false;
// // //
// // //     // Search
// // //     final q = _searchQ.toLowerCase();
// // //     final ms =
// // //         q.isEmpty ||
// // //         e.name.toLowerCase().contains(q) ||
// // //         e.id.toLowerCase().contains(q) ||
// // //         e.phone.contains(q);
// // //
// // //     // Dropdown filters
// // //     final mr = _filterRole.isEmpty || e.role == _filterRole;
// // //     final mst =
// // //         _filterStatus.isEmpty ||
// // //         (_filterStatus == 'Active' && e.isActive) ||
// // //         (_filterStatus == 'Inactive' && !e.isActive);
// // //
// // //     return ms && mr && mst;
// // //   }).toList();
// // //
// // //   Future<void> _toggleStatus(Employee emp) async {
// // //     final next = !emp.isActive;
// // //     setState(() => emp.isActive = next);
// // //     try {
// // //       await EmployeeApi.updateStatus(emp.vendorId, next);
// // //       if (mounted)
// // //         showSuccess(
// // //           context,
// // //           '${emp.name} is now ${next ? "Active" : "Inactive"}',
// // //         );
// // //     } catch (err) {
// // //       setState(() => emp.isActive = !next);
// // //       if (mounted) showError(context, 'Failed: $err');
// // //     }
// // //   }
// // //
// // //   void _openSheet(Widget sheet) => showModalBottomSheet(
// // //     context: context,
// // //     isScrollControlled: true,
// // //     useSafeArea: true,
// // //     backgroundColor: Colors.transparent,
// // //     shape: const RoundedRectangleBorder(
// // //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //     ),
// // //     builder: (_) => sheet,
// // //   );
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final bottom = MediaQuery.of(context).padding.bottom;
// // //     return Scaffold(
// // //       backgroundColor: _kBg,
// // //
// // //       body: SafeArea(
// // //         child: Column(
// // //           children: [
// // //             // ── White header ────────────────────────────────────────────────
// // //             // ── White header ────────────────────────────────────────────────────────
// // //             Container(
// // //               color: _kW,
// // //               child: Column(
// // //                 children: [
// // //                   // Title row
// // //                   Padding(
// // //                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
// // //                     child: Row(
// // //                       children: [
// // //                         if (Navigator.canPop(context))
// // //                           GestureDetector(
// // //                             onTap: () => Navigator.pop(context),
// // //                             child: Container(
// // //                               width: 36,
// // //                               height: 36,
// // //                               margin: const EdgeInsets.only(right: 10),
// // //                               decoration: BoxDecoration(
// // //                                 color: _kBg,
// // //                                 borderRadius: BorderRadius.circular(10),
// // //                                 border: Border.all(color: _kBrd),
// // //                               ),
// // //                               child: const Icon(
// // //                                 Icons.arrow_back_ios_new_rounded,
// // //                                 color: _kT1,
// // //                                 size: 15,
// // //                               ),
// // //                             ),
// // //                           ),
// // //
// // //                         const SizedBox(width: 4),
// // //                         // ── Scrollable stat chips (fills middle) ────────────
// // //                         Expanded(
// // //                           child: SingleChildScrollView(
// // //                             scrollDirection: Axis.horizontal,
// // //                             physics: const BouncingScrollPhysics(),
// // //                             child: Row(
// // //                               children: [
// // //                                 GestureDetector(
// // //                                   onTap: () => setState(
// // //                                     () => _activeChip = _activeChip == 'total'
// // //                                         ? ''
// // //                                         : 'total',
// // //                                   ),
// // //                                   child:
// // //                                   _StatChip(
// // //                                     label: 'Total',
// // //                                     value: _total,
// // //                                     isActive: _activeChip == 'total' || _activeChip == '',
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(width: 6),
// // //                                 GestureDetector(
// // //                                   onTap: () => setState(
// // //                                     () => _activeChip = _activeChip == 'chefs'
// // //                                         ? ''
// // //                                         : 'chefs',
// // //                                   ),
// // //                                   child:
// // //                                   _StatChip(
// // //                                     label: 'Chefs',
// // //                                     value: _chefs,
// // //                                     isActive: _activeChip == 'chefs',
// // //                                   ),
// // //
// // //                                 ),
// // //                                 const SizedBox(width: 6),
// // //                                 GestureDetector(
// // //                                   onTap: () => setState(
// // //                                     () =>
// // //                                         _activeChip = _activeChip == 'managers'
// // //                                         ? ''
// // //                                         : 'managers',
// // //                                   ),
// // //                                   child:
// // //                                   _StatChip(
// // //                                     label: 'Managers',
// // //                                     value: _managers,
// // //                                     isActive: _activeChip == 'managers',
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(width: 6),
// // //                                 GestureDetector(
// // //                                   onTap: () => setState(
// // //                                     () =>
// // //                                         _activeChip = _activeChip == 'inactive'
// // //                                         ? ''
// // //                                         : 'inactive',
// // //                                   ),
// // //                                   child:
// // //                                   _StatChip(
// // //                                     label: 'Inactive',
// // //                                     value: _inactive,
// // //                                     isActive: _activeChip == 'inactive',
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   const Divider(height: 1, color: _kBrd),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             // ── Body ────────────────────────────────────────────────────────
// // //             Expanded(
// // //               child: RefreshIndicator(
// // //                 color: _kP,
// // //                 onRefresh: _load,
// // //                 child: _loading
// // //                     ? const Center(
// // //                         child: CircularProgressIndicator(
// // //                           color: _kP,
// // //                           strokeWidth: 2,
// // //                         ),
// // //                       )
// // //                     : _error != null
// // //                     ? _ErrView(msg: _error!, onRetry: _load)
// // //                     : CustomScrollView(
// // //                         slivers: [
// // //                           SliverToBoxAdapter(
// // //                             child: Padding(
// // //                               padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
// // //                               child: Row(
// // //                                 children: [
// // //                                   GestureDetector(
// // //                                     onTap: () => _openSheet(
// // //                                       AddEmployeeSheet(onSaved: _load),
// // //                                     ),
// // //                                     child: Container(
// // //                                       padding: const EdgeInsets.symmetric(
// // //                                         horizontal: 14,
// // //                                         vertical: 9,
// // //                                       ),
// // //                                       decoration: BoxDecoration(
// // //                                         gradient: _kGrd,
// // //                                         borderRadius: BorderRadius.circular(10),
// // //                                         boxShadow: [
// // //                                           BoxShadow(
// // //                                             color: _kP.withOpacity(0.3),
// // //                                             blurRadius: 8,
// // //                                             offset: const Offset(0, 3),
// // //                                           ),
// // //                                         ],
// // //                                       ),
// // //                                       child: const Row(
// // //                                         mainAxisSize: MainAxisSize.min,
// // //                                         children: [
// // //                                           Icon(
// // //                                             Icons.person_add_rounded,
// // //                                             color: _kW,
// // //                                             size: 15,
// // //                                           ),
// // //                                           SizedBox(width: 6),
// // //                                           Text(
// // //                                             'Add Employee',
// // //                                             style: TextStyle(
// // //                                               fontSize: 13,
// // //                                               fontWeight: FontWeight.w700,
// // //                                               color: _kW,
// // //                                             ),
// // //                                           ),
// // //                                         ],
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                   const Spacer(),
// // //                                   Container(
// // //                                     padding: const EdgeInsets.symmetric(
// // //                                       horizontal: 10,
// // //                                       vertical: 5,
// // //                                     ),
// // //                                     decoration: BoxDecoration(
// // //                                       color: _kPLt,
// // //                                       borderRadius: BorderRadius.circular(8),
// // //                                     ),
// // //                                     child: Text(
// // //                                       '${_filtered.length} employees',
// // //                                       style: const TextStyle(
// // //                                         fontSize: 11,
// // //                                         fontWeight: FontWeight.w600,
// // //                                         color: _kP,
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ),
// // //
// // //                           // Search + filter chips
// // //                           SliverToBoxAdapter(
// // //                             child: Padding(
// // //                               padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
// // //                               child: Column(
// // //                                 children: [
// // //                                   // Search bar
// // //                                   Container(
// // //                                     height: 44,
// // //                                     decoration: BoxDecoration(
// // //                                       color: _kW,
// // //                                       borderRadius: BorderRadius.circular(11),
// // //                                       border: Border.all(color: _kBrd),
// // //                                     ),
// // //                                     child: TextField(
// // //                                       controller: _searchCtrl,
// // //                                       style: const TextStyle(
// // //                                         fontSize: 13,
// // //                                         color: _kT1,
// // //                                       ),
// // //                                       onChanged: (v) =>
// // //                                           setState(() => _searchQ = v),
// // //                                       decoration: InputDecoration(
// // //                                         hintText:
// // //                                             'Search by name, ID or phone...',
// // //                                         hintStyle: const TextStyle(
// // //                                           fontSize: 13,
// // //                                           color: _kMut,
// // //                                         ),
// // //                                         prefixIcon: const Icon(
// // //                                           Icons.search_rounded,
// // //                                           color: _kMut,
// // //                                           size: 18,
// // //                                         ),
// // //                                         suffixIcon: _searchQ.isNotEmpty
// // //                                             ? IconButton(
// // //                                                 icon: const Icon(
// // //                                                   Icons.close_rounded,
// // //                                                   size: 16,
// // //                                                   color: _kMut,
// // //                                                 ),
// // //                                                 onPressed: () {
// // //                                                   _searchCtrl.clear();
// // //                                                   setState(() => _searchQ = '');
// // //                                                 },
// // //                                               )
// // //                                             : null,
// // //                                         border: InputBorder.none,
// // //                                         contentPadding:
// // //                                             const EdgeInsets.symmetric(
// // //                                               vertical: 12,
// // //                                             ),
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                   const SizedBox(height: 8),
// // //                                   // Filter chips
// // //                                   SingleChildScrollView(
// // //                                     scrollDirection: Axis.horizontal,
// // //                                     child: Row(
// // //                                       children: [
// // //                                         _FDrop(
// // //                                           label: _filterRole.isEmpty
// // //                                               ? 'All Roles'
// // //                                               : roleLabel(_filterRole),
// // //                                           active: _filterRole.isNotEmpty,
// // //                                           items: [
// // //                                             const DropdownMenuItem(
// // //                                               value: '',
// // //                                               child: Text('All Roles'),
// // //                                             ),
// // //                                             ...kEmployeeRoles.map(
// // //                                               (r) => DropdownMenuItem(
// // //                                                 value: r.value,
// // //                                                 child: Text(r.label),
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                           value: _filterRole,
// // //                                           onChanged: (v) => setState(
// // //                                             () => _filterRole = v ?? '',
// // //                                           ),
// // //                                         ),
// // //                                         const SizedBox(width: 8),
// // //                                         _FDrop(
// // //                                           label: _filterStatus.isEmpty
// // //                                               ? 'All Status'
// // //                                               : _filterStatus,
// // //                                           active: _filterStatus.isNotEmpty,
// // //                                           activeColor: _filterStatus == 'Active'
// // //                                               ? _kSuc
// // //                                               : _kDng,
// // //                                           activeBg: _filterStatus == 'Active'
// // //                                               ? _kSLt
// // //                                               : _kDLt,
// // //                                           items: const [
// // //                                             DropdownMenuItem(
// // //                                               value: '',
// // //                                               child: Text('All Status'),
// // //                                             ),
// // //                                             DropdownMenuItem(
// // //                                               value: 'Active',
// // //                                               child: Text('Active'),
// // //                                             ),
// // //                                             DropdownMenuItem(
// // //                                               value: 'Inactive',
// // //                                               child: Text('Inactive'),
// // //                                             ),
// // //                                           ],
// // //                                           value: _filterStatus,
// // //                                           onChanged: (v) => setState(
// // //                                             () => _filterStatus = v ?? '',
// // //                                           ),
// // //                                         ),
// // //                                         if (_filterRole.isNotEmpty ||
// // //                                             _filterStatus.isNotEmpty) ...[
// // //                                           const SizedBox(width: 8),
// // //                                           GestureDetector(
// // //                                             onTap: () => setState(() {
// // //                                               _filterRole = '';
// // //                                               _filterStatus = '';
// // //                                             }),
// // //                                             child: Container(
// // //                                               padding:
// // //                                                   const EdgeInsets.symmetric(
// // //                                                     horizontal: 10,
// // //                                                     vertical: 6,
// // //                                                   ),
// // //                                               decoration: BoxDecoration(
// // //                                                 color: _kDLt,
// // //                                                 borderRadius:
// // //                                                     BorderRadius.circular(20),
// // //                                                 border: Border.all(
// // //                                                   color: _kDng.withOpacity(0.3),
// // //                                                 ),
// // //                                               ),
// // //                                               child: const Row(
// // //                                                 children: [
// // //                                                   Icon(
// // //                                                     Icons.close_rounded,
// // //                                                     size: 12,
// // //                                                     color: _kDng,
// // //                                                   ),
// // //                                                   SizedBox(width: 4),
// // //                                                   Text(
// // //                                                     'Clear',
// // //                                                     style: TextStyle(
// // //                                                       fontSize: 11,
// // //                                                       color: _kDng,
// // //                                                       fontWeight:
// // //                                                           FontWeight.w700,
// // //                                                     ),
// // //                                                   ),
// // //                                                 ],
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                         ],
// // //                                       ],
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ),
// // //
// // //                           // Employee list or empty state
// // //                           if (_filtered.isEmpty)
// // //                             SliverFillRemaining(
// // //                               child: Center(
// // //                                 child: Column(
// // //                                   mainAxisSize: MainAxisSize.min,
// // //                                   children: [
// // //                                     Container(
// // //                                       width: 68,
// // //                                       height: 68,
// // //                                       decoration: BoxDecoration(
// // //                                         gradient: _kGrd,
// // //                                         shape: BoxShape.circle,
// // //                                         boxShadow: [
// // //                                           BoxShadow(
// // //                                             color: _kP.withOpacity(0.25),
// // //                                             blurRadius: 16,
// // //                                             offset: const Offset(0, 6),
// // //                                           ),
// // //                                         ],
// // //                                       ),
// // //                                       child: const Icon(
// // //                                         Icons.person_search_rounded,
// // //                                         color: _kW,
// // //                                         size: 30,
// // //                                       ),
// // //                                     ),
// // //                                     const SizedBox(height: 14),
// // //                                     const Text(
// // //                                       'No employees found',
// // //                                       style: TextStyle(
// // //                                         fontSize: 15,
// // //                                         fontWeight: FontWeight.w700,
// // //                                         color: _kT1,
// // //                                       ),
// // //                                     ),
// // //                                     const SizedBox(height: 5),
// // //                                     if (_searchQ.isNotEmpty ||
// // //                                         _filterRole.isNotEmpty ||
// // //                                         _filterStatus.isNotEmpty)
// // //                                       GestureDetector(
// // //                                         onTap: () => setState(() {
// // //                                           _searchCtrl.clear();
// // //                                           _searchQ = '';
// // //                                           _filterRole = '';
// // //                                           _filterStatus = '';
// // //                                         }),
// // //                                         child: const Text(
// // //                                           'Clear filters',
// // //                                           style: TextStyle(
// // //                                             fontSize: 12,
// // //                                             color: _kP,
// // //                                             fontWeight: FontWeight.w600,
// // //                                           ),
// // //                                         ),
// // //                                       ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             )
// // //                           else
// // //                             SliverPadding(
// // //                               padding: EdgeInsets.fromLTRB(
// // //                                 14,
// // //                                 12,
// // //                                 14,
// // //                                 bottom + 24,
// // //                               ),
// // //                               sliver: SliverList(
// // //                                 delegate: SliverChildBuilderDelegate(
// // //                                   (_, i) => _EmpCard(
// // //                                     emp: _filtered[i],
// // //                                     index: i,
// // //                                     onToggle: () => _toggleStatus(_filtered[i]),
// // //                                     onEdit: () => _openSheet(
// // //                                       EditEmployeeSheet(
// // //                                         employee: _filtered[i],
// // //                                         onSaved: _load,
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                   childCount: _filtered.length,
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                         ],
// // //                       ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ── Stat Chip (app bar) ────────────────────────────────────────────────────────
// // // class _StatChip extends StatelessWidget {
// // //   final String label;
// // //   final int value;
// // //   final bool isActive;
// // //
// // //   const _StatChip({
// // //     required this.label,
// // //     required this.value,
// // //     required this.isActive,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 200),
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //       decoration: BoxDecoration(
// // //         color: isActive
// // //             ? Colors.green // 🟢 selected
// // //             : const Color(0xFFE66D33), // 🟧 default
// // //         borderRadius: BorderRadius.circular(10),
// // //       ),
// // //       child: Text(
// // //         '$value $label',
// // //         style: const TextStyle(
// // //           fontSize: 12,
// // //           fontWeight: FontWeight.w700,
// // //           color: Colors.white, // ⚪ always white
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ── Stat Card ──────────────────────────────────────────────────────────────────
// // // class _StatCard extends StatelessWidget {
// // //   final String title;
// // //   final int value;
// // //   final IconData icon;
// // //   final Color color, bg;
// // //   const _StatCard(this.title, this.value, this.icon, this.color, this.bg);
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     padding: const EdgeInsets.all(14),
// // //     decoration: BoxDecoration(
// // //       color: _kW,
// // //       borderRadius: BorderRadius.circular(14),
// // //       border: Border.all(color: _kBrd),
// // //       boxShadow: [
// // //         BoxShadow(color: _kShd, blurRadius: 6, offset: const Offset(0, 2)),
// // //       ],
// // //     ),
// // //     child: Row(
// // //       children: [
// // //         Container(
// // //           width: 40,
// // //           height: 40,
// // //           decoration: BoxDecoration(
// // //             color: bg,
// // //             borderRadius: BorderRadius.circular(10),
// // //           ),
// // //           child: Icon(icon, color: color, size: 20),
// // //         ),
// // //         const SizedBox(width: 12),
// // //         Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Text(
// // //               title,
// // //               style: const TextStyle(
// // //                 fontSize: 11,
// // //                 color: _kT2,
// // //                 fontWeight: FontWeight.w500,
// // //               ),
// // //             ),
// // //             Text(
// // //               '$value',
// // //               style: TextStyle(
// // //                 fontSize: 22,
// // //                 fontWeight: FontWeight.w900,
// // //                 color: color,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }
// // //
// // // // ── Filter Dropdown ────────────────────────────────────────────────────────────
// // // class _FDrop extends StatelessWidget {
// // //   final String label, value;
// // //   final bool active;
// // //   final Color? activeColor, activeBg;
// // //   final List<DropdownMenuItem<String>> items;
// // //   final ValueChanged<String?> onChanged;
// // //   const _FDrop({
// // //     required this.label,
// // //     required this.value,
// // //     required this.active,
// // //     required this.items,
// // //     required this.onChanged,
// // //     this.activeColor,
// // //     this.activeBg,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final color = active ? (activeColor ?? _kP) : _kT2;
// // //     final bg = active ? (activeBg ?? _kPLt) : _kW;
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
// // //       decoration: BoxDecoration(
// // //         color: bg,
// // //         borderRadius: BorderRadius.circular(20),
// // //         border: Border.all(
// // //           color: active ? color.withOpacity(0.4) : _kBrd,
// // //           width: active ? 1.5 : 1,
// // //         ),
// // //       ),
// // //       child: DropdownButtonHideUnderline(
// // //         child: DropdownButton<String>(
// // //           value: value,
// // //           items: items,
// // //           onChanged: onChanged,
// // //           isDense: true,
// // //           style: TextStyle(
// // //             fontSize: 12,
// // //             fontWeight: FontWeight.w600,
// // //             color: color,
// // //           ),
// // //           dropdownColor: _kW,
// // //           icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ── Employee Card ──────────────────────────────────────────────────────────────
// // // class _EmpCard extends StatelessWidget {
// // //   final Employee emp;
// // //   final int index;
// // //   final VoidCallback onToggle, onEdit;
// // //   const _EmpCard({
// // //     required this.emp,
// // //     required this.index,
// // //     required this.onToggle,
// // //     required this.onEdit,
// // //   });
// // //
// // //   Color get _avatarColor {
// // //     const c = [
// // //       _kP,
// // //       Color(0xFF3B82F6),
// // //       _kWrn,
// // //       Color(0xFF64748B),
// // //       _kSuc,
// // //       Color(0xFF0891B2),
// // //     ];
// // //     return c[index % c.length];
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     margin: const EdgeInsets.only(bottom: 10),
// // //     decoration: BoxDecoration(
// // //       color: _kW,
// // //       borderRadius: BorderRadius.circular(16),
// // //       border: Border.all(color: _kBrd),
// // //       boxShadow: [
// // //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// // //       ],
// // //     ),
// // //     child: Padding(
// // //       padding: const EdgeInsets.all(14),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // Top row
// // //           Row(
// // //             children: [
// // //               Container(
// // //                 width: 48,
// // //                 height: 48,
// // //                 decoration: BoxDecoration(
// // //                   color: _avatarColor,
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 child: Center(
// // //                   child: Text(
// // //                     emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
// // //                     style: const TextStyle(
// // //                       color: _kW,
// // //                       fontWeight: FontWeight.w900,
// // //                       fontSize: 20,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 12),
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(
// // //                       emp.name,
// // //                       style: const TextStyle(
// // //                         fontSize: 14,
// // //                         fontWeight: FontWeight.w800,
// // //                         color: _kT1,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 3),
// // //                     Row(
// // //                       children: [
// // //                         Container(
// // //                           padding: const EdgeInsets.symmetric(
// // //                             horizontal: 7,
// // //                             vertical: 2,
// // //                           ),
// // //                           decoration: BoxDecoration(
// // //                             color: _kPLt,
// // //                             borderRadius: BorderRadius.circular(6),
// // //                           ),
// // //                           child: Text(
// // //                             roleLabel(emp.role).isEmpty
// // //                                 ? emp.role
// // //                                 : roleLabel(emp.role),
// // //                             style: const TextStyle(
// // //                               fontSize: 10,
// // //                               fontWeight: FontWeight.w700,
// // //                               color: _kP,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(width: 6),
// // //                         Text(
// // //                           emp.id,
// // //                           style: const TextStyle(fontSize: 10, color: _kT2),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               // _StatusBadge(active: emp.isActive),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 10),
// // //           const Divider(color: _kBrd, height: 1),
// // //           const SizedBox(height: 10),
// // //
// // //           // Info chips
// // //           Wrap(
// // //             spacing: 14,
// // //             runSpacing: 6,
// // //             children: [
// // //               _IC(Icons.phone_outlined, emp.phone),
// // //               _IC(Icons.location_on_outlined, emp.location),
// // //               _IC(Icons.calendar_today_outlined, emp.joinedDisplay),
// // //               if (emp.exitDate.isNotEmpty)
// // //                 _IC(
// // //                   Icons.exit_to_app_outlined,
// // //                   'Exit: ${emp.exitDate}',
// // //                   color: _kDng,
// // //                 ),
// // //             ],
// // //           ),
// // //
// // //           if (emp.remarks.isNotEmpty) ...[
// // //             const SizedBox(height: 8),
// // //             Container(
// // //               padding: const EdgeInsets.all(9),
// // //               decoration: BoxDecoration(
// // //                 color: _kBg,
// // //                 borderRadius: BorderRadius.circular(8),
// // //               ),
// // //               child: Row(
// // //                 children: [
// // //                   const Icon(Icons.notes_outlined, size: 13, color: _kMut),
// // //                   const SizedBox(width: 6),
// // //                   Expanded(
// // //                     child: Text(
// // //                       emp.remarks,
// // //                       style: const TextStyle(fontSize: 11, color: _kT2),
// // //                       maxLines: 2,
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //           const SizedBox(height: 10),
// // //
// // //           // Action row
// // //           Row(
// // //             children: [
// // //               const Text(
// // //                 'Status',
// // //                 style: TextStyle(
// // //                   fontSize: 11,
// // //                   color: _kT2,
// // //                   fontWeight: FontWeight.w500,
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 5),
// // //               Switch(
// // //                 value: emp.isActive,
// // //                 onChanged: (_) => onToggle(),
// // //                 activeColor: _kSuc,
// // //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // //               ),
// // //               Text(
// // //                 emp.isActive ? 'Active' : 'Inactive',
// // //                 style: TextStyle(
// // //                   fontSize: 10,
// // //                   fontWeight: FontWeight.w600,
// // //                   color: emp.isActive ? _kSDk : _kDng,
// // //                 ),
// // //               ),
// // //               const Spacer(),
// // //               GestureDetector(
// // //                 onTap: onEdit,
// // //                 child: Container(
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 12,
// // //                     vertical: 7,
// // //                   ),
// // //                   decoration: BoxDecoration(
// // //                     gradient: _kGrd,
// // //                     borderRadius: BorderRadius.circular(9),
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: _kP.withOpacity(0.25),
// // //                         blurRadius: 6,
// // //                         offset: const Offset(0, 2),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   child: const Row(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       Icon(Icons.edit_rounded, size: 13, color: _kW),
// // //                       SizedBox(width: 5),
// // //                       Text(
// // //                         'Edit',
// // //                         style: TextStyle(
// // //                           fontSize: 12,
// // //                           fontWeight: FontWeight.w700,
// // //                           color: _kW,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _StatusBadge extends StatelessWidget {
// // //   final bool active;
// // //   const _StatusBadge({required this.active});
// // //   @override
// // //   Widget build(BuildContext context) => AnimatedContainer(
// // //     duration: const Duration(milliseconds: 200),
// // //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // //     decoration: BoxDecoration(
// // //       color: active ? _kSLt : _kDLt,
// // //       borderRadius: BorderRadius.circular(20),
// // //       border: Border.all(
// // //         color: active ? _kSuc.withOpacity(0.3) : _kDng.withOpacity(0.3),
// // //       ),
// // //     ),
// // //     child: Text(
// // //       active ? 'Active' : 'Inactive',
// // //       style: TextStyle(
// // //         fontSize: 11,
// // //         fontWeight: FontWeight.w700,
// // //         color: active ? _kSDk : _kDng,
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _IC extends StatelessWidget {
// // //   final IconData icon;
// // //   final String label;
// // //   final Color color;
// // //   const _IC(this.icon, this.label, {this.color = _kT2});
// // //   @override
// // //   Widget build(BuildContext context) => Row(
// // //     mainAxisSize: MainAxisSize.min,
// // //     children: [
// // //       Icon(icon, size: 12, color: color),
// // //       const SizedBox(width: 4),
// // //       Text(
// // //         label,
// // //         style: TextStyle(
// // //           fontSize: 11,
// // //           color: color,
// // //           fontWeight: FontWeight.w500,
// // //         ),
// // //       ),
// // //     ],
// // //   );
// // // }
// // //
// // // // ── Error View ─────────────────────────────────────────────────────────────────
// // // class _ErrView extends StatelessWidget {
// // //   final String msg;
// // //   final VoidCallback onRetry;
// // //   const _ErrView({required this.msg, required this.onRetry});
// // //   @override
// // //   Widget build(BuildContext context) => Center(
// // //     child: Padding(
// // //       padding: const EdgeInsets.all(28),
// // //       child: Column(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           Container(
// // //             width: 60,
// // //             height: 60,
// // //             decoration: const BoxDecoration(
// // //               color: _kDLt,
// // //               shape: BoxShape.circle,
// // //             ),
// // //             child: const Icon(
// // //               Icons.error_outline_rounded,
// // //               color: _kDng,
// // //               size: 28,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 14),
// // //           const Text(
// // //             'Failed to load employees',
// // //             style: TextStyle(
// // //               fontSize: 15,
// // //               fontWeight: FontWeight.w700,
// // //               color: _kT1,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 6),
// // //           Text(
// // //             msg,
// // //             style: const TextStyle(fontSize: 12, color: _kT2),
// // //             textAlign: TextAlign.center,
// // //           ),
// // //           const SizedBox(height: 20),
// // //           GestureDetector(
// // //             onTap: onRetry,
// // //             child: Container(
// // //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// // //               decoration: BoxDecoration(
// // //                 gradient: _kGrd,
// // //                 borderRadius: BorderRadius.circular(10),
// // //               ),
// // //               child: const Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   Icon(Icons.refresh_rounded, color: _kW, size: 15),
// // //                   SizedBox(width: 6),
// // //                   Text(
// // //                     'Retry',
// // //                     style: TextStyle(color: _kW, fontWeight: FontWeight.w700),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     ),
// // //   );
// // // }
// // import 'package:flutter/material.dart';
// // import '../models/employee.dart';
// // import '../services/api_service.dart';
// // import '../widgets/theme.dart';
// // import 'add_employee_sheet.dart';
// // import 'edit_employee_sheet.dart';
// //
// // const _kW = Color(0xFFFFFFFF);
// // const _kBg = Color(0xFFF7F8FC);
// // const _kBrd = Color(0xFFEEEFF5);
// // const _kP = Color(0xFFE66D33);
// // const _kPDk = Color(0xFFCC5A20);
// // const _kPLt = Color(0xFFFFF0E8);
// // const _kSuc = Color(0xFF10B981);
// // const _kSLt = Color(0xFFD1FAE5);
// // const _kSDk = Color(0xFF059669);
// // const _kDng = Color(0xFFEF4444);
// // const _kDLt = Color(0xFFFEE2E2);
// // const _kWrn = Color(0xFFF59E0B);
// // const _kInf = Color(0xFF3B82F6);
// // const _kT1 = Color(0xFF111827);
// // const _kT2 = Color(0xFF6B7280);
// // const _kMut = Color(0xFFB0B3C1);
// // const _kShd = Color(0x0A000000);
// // const _kGrd = LinearGradient(
// //   colors: [_kP, _kPDk],
// //   begin: Alignment.topLeft,
// //   end: Alignment.bottomRight,
// // );
// //
// // class TeamDirectoryScreen extends StatefulWidget {
// //   const TeamDirectoryScreen({super.key});
// //   @override
// //   State<TeamDirectoryScreen> createState() => _TeamDirectoryScreenState();
// // }
// //
// // class _TeamDirectoryScreenState extends State<TeamDirectoryScreen> {
// //   List<Employee> _all = [];
// //   bool _loading = true;
// //   String? _error;
// //   final _searchCtrl = TextEditingController();
// //   String _searchQ = '';
// //   String _filterRole = '';
// //   String _filterStatus = '';
// //   String _activeChip = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _load();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _load() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final list = await EmployeeApi.fetchAll();
// //       if (mounted)
// //         setState(() {
// //           _all = list;
// //           _loading = false;
// //         });
// //     } catch (e) {
// //       if (mounted)
// //         setState(() {
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //     }
// //   }
// //
// //   int get _total => _all.length;
// //   int get _chefs =>
// //       _all.where((e) => e.role.toLowerCase().contains('chef')).length;
// //   int get _managers =>
// //       _all.where((e) => e.role.toLowerCase().contains('manager')).length;
// //   int get _inactive => _all.where((e) => !e.isActive).length;
// //
// //   List<Employee> get _filtered => _all.where((e) {
// //     // Chip filter
// //     if (_activeChip == 'chefs' && !e.role.toLowerCase().contains('chef'))
// //       return false;
// //     if (_activeChip == 'managers' && !e.role.toLowerCase().contains('manager'))
// //       return false;
// //     if (_activeChip == 'inactive' && e.isActive) return false;
// //
// //     // Search
// //     final q = _searchQ.toLowerCase();
// //     final ms =
// //         q.isEmpty ||
// //         e.name.toLowerCase().contains(q) ||
// //         e.id.toLowerCase().contains(q) ||
// //         e.phone.contains(q);
// //
// //     // Dropdown filters
// //     final mr = _filterRole.isEmpty || e.role == _filterRole;
// //     final mst =
// //         _filterStatus.isEmpty ||
// //         (_filterStatus == 'Active' && e.isActive) ||
// //         (_filterStatus == 'Inactive' && !e.isActive);
// //
// //     return ms && mr && mst;
// //   }).toList();
// //
// //   Future<void> _toggleStatus(Employee emp) async {
// //     final next = !emp.isActive;
// //     setState(() => emp.isActive = next);
// //     try {
// //       await EmployeeApi.updateStatus(emp.vendorId, next);
// //       if (mounted)
// //         showSuccess(
// //           context,
// //           '${emp.name} is now ${next ? "Active" : "Inactive"}',
// //         );
// //     } catch (err) {
// //       setState(() => emp.isActive = !next);
// //       if (mounted) showError(context, 'Failed: $err');
// //     }
// //   }
// //
// //   void _openSheet(Widget sheet) => showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     useSafeArea: true,
// //     backgroundColor: Colors.transparent,
// //     shape: const RoundedRectangleBorder(
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //     ),
// //     builder: (_) => sheet,
// //   );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final bottom = MediaQuery.of(context).padding.bottom;
// //     return Scaffold(
// //       backgroundColor: _kBg,
// //
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // ── White header ────────────────────────────────────────────────
// //             // ── White header ────────────────────────────────────────────────────────
// //             Container(
// //               color: _kW,
// //               child: Column(
// //                 children: [
// //                   // Title row
// //                   Padding(
// //                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
// //                     child: Row(
// //                       children: [
// //                         if (Navigator.canPop(context))
// //                           GestureDetector(
// //                             onTap: () => Navigator.pop(context),
// //                             child: Container(
// //                               width: 36,
// //                               height: 36,
// //                               margin: const EdgeInsets.only(right: 10),
// //                               decoration: BoxDecoration(
// //                                 color: _kBg,
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 border: Border.all(color: _kBrd),
// //                               ),
// //                               child: const Icon(
// //                                 Icons.arrow_back_ios_new_rounded,
// //                                 color: _kT1,
// //                                 size: 15,
// //                               ),
// //                             ),
// //                           ),
// //
// //                         const SizedBox(width: 4),
// //                         // ── Scrollable stat chips (fills middle) ────────────
// //                         Expanded(
// //                           child: SingleChildScrollView(
// //                             scrollDirection: Axis.horizontal,
// //                             physics: const BouncingScrollPhysics(),
// //                             child: Row(
// //                               children: [
// //                                 GestureDetector(
// //                                   onTap: () => setState(
// //                                     () => _activeChip = _activeChip == 'total'
// //                                         ? ''
// //                                         : 'total',
// //                                   ),
// //                                   child: _StatChip(
// //                                     label: 'Total',
// //                                     value: _total,
// //                                     isActive:
// //                                         _activeChip == 'total' ||
// //                                         _activeChip == '',
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 GestureDetector(
// //                                   onTap: () => setState(
// //                                     () => _activeChip = _activeChip == 'chefs'
// //                                         ? ''
// //                                         : 'chefs',
// //                                   ),
// //                                   child: _StatChip(
// //                                     label: 'Chefs',
// //                                     value: _chefs,
// //                                     isActive: _activeChip == 'chefs',
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 GestureDetector(
// //                                   onTap: () => setState(
// //                                     () =>
// //                                         _activeChip = _activeChip == 'managers'
// //                                         ? ''
// //                                         : 'managers',
// //                                   ),
// //                                   child: _StatChip(
// //                                     label: 'Managers',
// //                                     value: _managers,
// //                                     isActive: _activeChip == 'managers',
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 GestureDetector(
// //                                   onTap: () => setState(
// //                                     () =>
// //                                         _activeChip = _activeChip == 'inactive'
// //                                         ? ''
// //                                         : 'inactive',
// //                                   ),
// //                                   child: _StatChip(
// //                                     label: 'Inactive',
// //                                     value: _inactive,
// //                                     isActive: _activeChip == 'inactive',
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const Divider(height: 1, color: _kBrd),
// //                 ],
// //               ),
// //             ),
// //
// //             // ── Body ────────────────────────────────────────────────────────
// //             Expanded(
// //               child: RefreshIndicator(
// //                 color: _kP,
// //                 onRefresh: _load,
// //                 child: _loading
// //                     ? const Center(
// //                         child: CircularProgressIndicator(
// //                           color: _kP,
// //                           strokeWidth: 2,
// //                         ),
// //                       )
// //                     : _error != null
// //                     ? _ErrView(msg: _error!, onRetry: _load)
// //                     : CustomScrollView(
// //                         slivers: [
// //                           SliverToBoxAdapter(
// //                             child: Padding(
// //                               padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
// //                               child: Row(
// //                                 children: [
// //                                   GestureDetector(
// //                                     onTap: () => _openSheet(
// //                                       AddEmployeeSheet(onSaved: _load),
// //                                     ),
// //                                     child: Container(
// //                                       padding: const EdgeInsets.symmetric(
// //                                         horizontal: 14,
// //                                         vertical: 9,
// //                                       ),
// //                                       decoration: BoxDecoration(
// //                                         gradient: _kGrd,
// //                                         borderRadius: BorderRadius.circular(10),
// //                                         boxShadow: [
// //                                           BoxShadow(
// //                                             color: _kP.withOpacity(0.3),
// //                                             blurRadius: 8,
// //                                             offset: const Offset(0, 3),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                       child: const Row(
// //                                         mainAxisSize: MainAxisSize.min,
// //                                         children: [
// //                                           Icon(
// //                                             Icons.person_add_rounded,
// //                                             color: _kW,
// //                                             size: 15,
// //                                           ),
// //                                           SizedBox(width: 6),
// //                                           Text(
// //                                             'Add Employee',
// //                                             style: TextStyle(
// //                                               fontSize: 13,
// //                                               fontWeight: FontWeight.w700,
// //                                               color: _kW,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const Spacer(),
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 10,
// //                                       vertical: 5,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: _kPLt,
// //                                       borderRadius: BorderRadius.circular(8),
// //                                     ),
// //                                     child: Text(
// //                                       '${_filtered.length} employees',
// //                                       style: const TextStyle(
// //                                         fontSize: 11,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: _kP,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //
// //                           // Search + filter chips
// //                           SliverToBoxAdapter(
// //                             child: Padding(
// //                               padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
// //                               child: Column(
// //                                 children: [
// //                                   // Search bar
// //                                   Container(
// //                                     height: 44,
// //                                     decoration: BoxDecoration(
// //                                       color: _kW,
// //                                       borderRadius: BorderRadius.circular(11),
// //                                       border: Border.all(color: _kBrd),
// //                                     ),
// //                                     child: TextField(
// //                                       controller: _searchCtrl,
// //                                       style: const TextStyle(
// //                                         fontSize: 13,
// //                                         color: _kT1,
// //                                       ),
// //                                       onChanged: (v) =>
// //                                           setState(() => _searchQ = v),
// //                                       decoration: InputDecoration(
// //                                         hintText:
// //                                             'Search by name, ID or phone...',
// //                                         hintStyle: const TextStyle(
// //                                           fontSize: 13,
// //                                           color: _kMut,
// //                                         ),
// //                                         prefixIcon: const Icon(
// //                                           Icons.search_rounded,
// //                                           color: _kMut,
// //                                           size: 18,
// //                                         ),
// //                                         suffixIcon: _searchQ.isNotEmpty
// //                                             ? IconButton(
// //                                                 icon: const Icon(
// //                                                   Icons.close_rounded,
// //                                                   size: 16,
// //                                                   color: _kMut,
// //                                                 ),
// //                                                 onPressed: () {
// //                                                   _searchCtrl.clear();
// //                                                   setState(() => _searchQ = '');
// //                                                 },
// //                                               )
// //                                             : null,
// //                                         border: InputBorder.none,
// //                                         contentPadding:
// //                                             const EdgeInsets.symmetric(
// //                                               vertical: 12,
// //                                             ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 8),
// //                                   // Filter chips
// //                                   SingleChildScrollView(
// //                                     scrollDirection: Axis.horizontal,
// //                                     child: Row(
// //                                       children: [
// //                                         _FDrop(
// //                                           label: _filterRole.isEmpty
// //                                               ? 'All Roles'
// //                                               : roleLabel(_filterRole),
// //                                           active: _filterRole.isNotEmpty,
// //                                           items: [
// //                                             const DropdownMenuItem(
// //                                               value: '',
// //                                               child: Text('All Roles'),
// //                                             ),
// //                                             ...kEmployeeRoles.map(
// //                                               (r) => DropdownMenuItem(
// //                                                 value: r.value,
// //                                                 child: Text(r.label),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                           value: _filterRole,
// //                                           onChanged: (v) => setState(
// //                                             () => _filterRole = v ?? '',
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 8),
// //                                         _FDrop(
// //                                           label: _filterStatus.isEmpty
// //                                               ? 'All Status'
// //                                               : _filterStatus,
// //                                           active: _filterStatus.isNotEmpty,
// //                                           activeColor: _filterStatus == 'Active'
// //                                               ? _kSuc
// //                                               : _kDng,
// //                                           activeBg: _filterStatus == 'Active'
// //                                               ? _kSLt
// //                                               : _kDLt,
// //                                           items: const [
// //                                             DropdownMenuItem(
// //                                               value: '',
// //                                               child: Text('All Status'),
// //                                             ),
// //                                             DropdownMenuItem(
// //                                               value: 'Active',
// //                                               child: Text('Active'),
// //                                             ),
// //                                             DropdownMenuItem(
// //                                               value: 'Inactive',
// //                                               child: Text('Inactive'),
// //                                             ),
// //                                           ],
// //                                           value: _filterStatus,
// //                                           onChanged: (v) => setState(
// //                                             () => _filterStatus = v ?? '',
// //                                           ),
// //                                         ),
// //                                         if (_filterRole.isNotEmpty ||
// //                                             _filterStatus.isNotEmpty) ...[
// //                                           const SizedBox(width: 8),
// //                                           GestureDetector(
// //                                             onTap: () => setState(() {
// //                                               _filterRole = '';
// //                                               _filterStatus = '';
// //                                             }),
// //                                             child: Container(
// //                                               padding:
// //                                                   const EdgeInsets.symmetric(
// //                                                     horizontal: 10,
// //                                                     vertical: 6,
// //                                                   ),
// //                                               decoration: BoxDecoration(
// //                                                 color: _kDLt,
// //                                                 borderRadius:
// //                                                     BorderRadius.circular(20),
// //                                                 border: Border.all(
// //                                                   color: _kDng.withOpacity(0.3),
// //                                                 ),
// //                                               ),
// //                                               child: const Row(
// //                                                 children: [
// //                                                   Icon(
// //                                                     Icons.close_rounded,
// //                                                     size: 12,
// //                                                     color: _kDng,
// //                                                   ),
// //                                                   SizedBox(width: 4),
// //                                                   Text(
// //                                                     'Clear',
// //                                                     style: TextStyle(
// //                                                       fontSize: 11,
// //                                                       color: _kDng,
// //                                                       fontWeight:
// //                                                           FontWeight.w700,
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //
// //                           // Employee list or empty state
// //                           if (_filtered.isEmpty)
// //                             SliverFillRemaining(
// //                               child: Center(
// //                                 child: Column(
// //                                   mainAxisSize: MainAxisSize.min,
// //                                   children: [
// //                                     Container(
// //                                       width: 68,
// //                                       height: 68,
// //                                       decoration: BoxDecoration(
// //                                         gradient: _kGrd,
// //                                         shape: BoxShape.circle,
// //                                         boxShadow: [
// //                                           BoxShadow(
// //                                             color: _kP.withOpacity(0.25),
// //                                             blurRadius: 16,
// //                                             offset: const Offset(0, 6),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                       child: const Icon(
// //                                         Icons.person_search_rounded,
// //                                         color: _kW,
// //                                         size: 30,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 14),
// //                                     const Text(
// //                                       'No employees found',
// //                                       style: TextStyle(
// //                                         fontSize: 15,
// //                                         fontWeight: FontWeight.w700,
// //                                         color: _kT1,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 5),
// //                                     if (_searchQ.isNotEmpty ||
// //                                         _filterRole.isNotEmpty ||
// //                                         _filterStatus.isNotEmpty)
// //                                       GestureDetector(
// //                                         onTap: () => setState(() {
// //                                           _searchCtrl.clear();
// //                                           _searchQ = '';
// //                                           _filterRole = '';
// //                                           _filterStatus = '';
// //                                         }),
// //                                         child: const Text(
// //                                           'Clear filters',
// //                                           style: TextStyle(
// //                                             fontSize: 12,
// //                                             color: _kP,
// //                                             fontWeight: FontWeight.w600,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             )
// //                           else
// //                             SliverPadding(
// //                               padding: EdgeInsets.fromLTRB(
// //                                 14,
// //                                 12,
// //                                 14,
// //                                 bottom + 24,
// //                               ),
// //                               sliver: SliverList(
// //                                 delegate: SliverChildBuilderDelegate(
// //                                   (_, i) => _EmpCard(
// //                                     emp: _filtered[i],
// //                                     index: i,
// //                                     onToggle: () => _toggleStatus(_filtered[i]),
// //                                     onEdit: () => _openSheet(
// //                                       EditEmployeeSheet(
// //                                         employee: _filtered[i],
// //                                         onSaved: _load,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   childCount: _filtered.length,
// //                                 ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Stat Chip (app bar) ────────────────────────────────────────────────────────
// // class _StatChip extends StatelessWidget {
// //   final String label;
// //   final int value;
// //   final bool isActive;
// //
// //   const _StatChip({
// //     required this.label,
// //     required this.value,
// //     required this.isActive,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 200),
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: isActive
// //             ? Colors
// //                   .green // 🟢 selected
// //             : const Color(0xFFE66D33), // 🟧 default
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Text(
// //         '$value $label',
// //         style: const TextStyle(
// //           fontSize: 12,
// //           fontWeight: FontWeight.w700,
// //           color: Colors.white, // ⚪ always white
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Stat Card ──────────────────────────────────────────────────────────────────
// // class _StatCard extends StatelessWidget {
// //   final String title;
// //   final int value;
// //   final IconData icon;
// //   final Color color, bg;
// //   const _StatCard(this.title, this.value, this.icon, this.color, this.bg);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.all(14),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(14),
// //       border: Border.all(color: _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 6, offset: const Offset(0, 2)),
// //       ],
// //     ),
// //     child: Row(
// //       children: [
// //         Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: bg,
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(icon, color: color, size: 20),
// //         ),
// //         const SizedBox(width: 12),
// //         Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               title,
// //               style: const TextStyle(
// //                 fontSize: 11,
// //                 color: _kT2,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             Text(
// //               '$value',
// //               style: TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.w900,
// //                 color: color,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Filter Dropdown ────────────────────────────────────────────────────────────
// // class _FDrop extends StatelessWidget {
// //   final String label, value;
// //   final bool active;
// //   final Color? activeColor, activeBg;
// //   final List<DropdownMenuItem<String>> items;
// //   final ValueChanged<String?> onChanged;
// //   const _FDrop({
// //     required this.label,
// //     required this.value,
// //     required this.active,
// //     required this.items,
// //     required this.onChanged,
// //     this.activeColor,
// //     this.activeBg,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = active ? (activeColor ?? _kP) : _kT2;
// //     final bg = active ? (activeBg ?? _kPLt) : _kW;
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
// //       decoration: BoxDecoration(
// //         color: bg,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(
// //           color: active ? color.withOpacity(0.4) : _kBrd,
// //           width: active ? 1.5 : 1,
// //         ),
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<String>(
// //           value: value,
// //           items: items,
// //           onChanged: onChanged,
// //           isDense: true,
// //           style: TextStyle(
// //             fontSize: 12,
// //             fontWeight: FontWeight.w600,
// //             color: color,
// //           ),
// //           dropdownColor: _kW,
// //           icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Employee Card ──────────────────────────────────────────────────────────────
// // class _EmpCard extends StatelessWidget {
// //   final Employee emp;
// //   final int index;
// //   final VoidCallback onToggle, onEdit;
// //   const _EmpCard({
// //     required this.emp,
// //     required this.index,
// //     required this.onToggle,
// //     required this.onEdit,
// //   });
// //
// //   Color get _avatarColor {
// //     const c = [
// //       _kP,
// //       Color(0xFF3B82F6),
// //       _kWrn,
// //       Color(0xFF64748B),
// //       _kSuc,
// //       Color(0xFF0891B2),
// //     ];
// //     return c[index % c.length];
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     ),
// //     child: Padding(
// //       padding: const EdgeInsets.all(14),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Top row
// //           Row(
// //             children: [
// //               Container(
// //                 width: 48,
// //                 height: 48,
// //                 decoration: BoxDecoration(
// //                   color: _avatarColor,
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
// //                     style: const TextStyle(
// //                       color: _kW,
// //                       fontWeight: FontWeight.w900,
// //                       fontSize: 20,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       emp.name,
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w800,
// //                         color: _kT1,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 3),
// //                     Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 7,
// //                             vertical: 2,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: _kPLt,
// //                             borderRadius: BorderRadius.circular(6),
// //                           ),
// //                           child: Text(
// //                             roleLabel(emp.role).isEmpty
// //                                 ? emp.role
// //                                 : roleLabel(emp.role),
// //                             style: const TextStyle(
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.w700,
// //                               color: _kP,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 6),
// //                         Text(
// //                           emp.id,
// //                           style: const TextStyle(fontSize: 10, color: _kT2),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               // _StatusBadge(active: emp.isActive),
// //             ],
// //           ),
// //           const SizedBox(height: 10),
// //           const Divider(color: _kBrd, height: 1),
// //           const SizedBox(height: 10),
// //
// //           // Info chips
// //           Wrap(
// //             spacing: 14,
// //             runSpacing: 6,
// //             children: [
// //               _IC(Icons.phone_outlined, emp.phone),
// //               _IC(Icons.location_on_outlined, emp.location),
// //               _IC(Icons.calendar_today_outlined, emp.joinedDisplay),
// //               if (emp.exitDate.isNotEmpty)
// //                 _IC(
// //                   Icons.exit_to_app_outlined,
// //                   'Exit: ${emp.exitDate}',
// //                   color: _kDng,
// //                 ),
// //             ],
// //           ),
// //
// //           if (emp.remarks.isNotEmpty) ...[
// //             const SizedBox(height: 8),
// //             Container(
// //               padding: const EdgeInsets.all(9),
// //               decoration: BoxDecoration(
// //                 color: _kBg,
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(Icons.notes_outlined, size: 13, color: _kMut),
// //                   const SizedBox(width: 6),
// //                   Expanded(
// //                     child: Text(
// //                       emp.remarks,
// //                       style: const TextStyle(fontSize: 11, color: _kT2),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //           const SizedBox(height: 10),
// //
// //           // Action row
// //           Row(
// //             children: [
// //               const Text(
// //                 'Status',
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   color: _kT2,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //               const SizedBox(width: 5),
// //               Switch(
// //                 value: emp.isActive,
// //                 onChanged: (_) => onToggle(),
// //                 activeColor: _kSuc,
// //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //               ),
// //               Text(
// //                 emp.isActive ? 'Active' : 'Inactive',
// //                 style: TextStyle(
// //                   fontSize: 10,
// //                   fontWeight: FontWeight.w600,
// //                   color: emp.isActive ? _kSDk : _kDng,
// //                 ),
// //               ),
// //               const Spacer(),
// //               GestureDetector(
// //                 onTap: onEdit,
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 12,
// //                     vertical: 7,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     gradient: _kGrd,
// //                     borderRadius: BorderRadius.circular(9),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: _kP.withOpacity(0.25),
// //                         blurRadius: 6,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: const Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(Icons.edit_rounded, size: 13, color: _kW),
// //                       SizedBox(width: 5),
// //                       Text(
// //                         'Edit',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w700,
// //                           color: _kW,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // class _StatusBadge extends StatelessWidget {
// //   final bool active;
// //   const _StatusBadge({required this.active});
// //   @override
// //   Widget build(BuildContext context) => AnimatedContainer(
// //     duration: const Duration(milliseconds: 200),
// //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //     decoration: BoxDecoration(
// //       color: active ? _kSLt : _kDLt,
// //       borderRadius: BorderRadius.circular(20),
// //       border: Border.all(
// //         color: active ? _kSuc.withOpacity(0.3) : _kDng.withOpacity(0.3),
// //       ),
// //     ),
// //     child: Text(
// //       active ? 'Active' : 'Inactive',
// //       style: TextStyle(
// //         fontSize: 11,
// //         fontWeight: FontWeight.w700,
// //         color: active ? _kSDk : _kDng,
// //       ),
// //     ),
// //   );
// // }
// //
// // class _IC extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final Color color;
// //   const _IC(this.icon, this.label, {this.color = _kT2});
// //   @override
// //   Widget build(BuildContext context) => Row(
// //     mainAxisSize: MainAxisSize.min,
// //     children: [
// //       Icon(icon, size: 12, color: color),
// //       const SizedBox(width: 4),
// //       Text(
// //         label,
// //         style: TextStyle(
// //           fontSize: 11,
// //           color: color,
// //           fontWeight: FontWeight.w500,
// //         ),
// //       ),
// //     ],
// //   );
// // }
// //
// // // ── Error View ─────────────────────────────────────────────────────────────────
// // class _ErrView extends StatelessWidget {
// //   final String msg;
// //   final VoidCallback onRetry;
// //   const _ErrView({required this.msg, required this.onRetry});
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(28),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: 60,
// //             height: 60,
// //             decoration: const BoxDecoration(
// //               color: _kDLt,
// //               shape: BoxShape.circle,
// //             ),
// //             child: const Icon(
// //               Icons.error_outline_rounded,
// //               color: _kDng,
// //               size: 28,
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'Failed to load employees',
// //             style: TextStyle(
// //               fontSize: 15,
// //               fontWeight: FontWeight.w700,
// //               color: _kT1,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           Text(
// //             msg,
// //             style: const TextStyle(fontSize: 12, color: _kT2),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           GestureDetector(
// //             onTap: onRetry,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //               decoration: BoxDecoration(
// //                 gradient: _kGrd,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Icon(Icons.refresh_rounded, color: _kW, size: 15),
// //                   SizedBox(width: 6),
// //                   Text(
// //                     'Retry',
// //                     style: TextStyle(color: _kW, fontWeight: FontWeight.w700),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// import 'package:flutter/material.dart';
// import '../models/employee.dart';
// import '../services/api_service.dart';
// import '../widgets/theme.dart';
// import 'add_employee_sheet.dart';
// import 'edit_employee_sheet.dart';
//
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFE66D33);
// const _kPDk = Color(0xFFCC5A20);
// const _kPLt = Color(0xFFFFF0E8);
// const _kSuc = Color(0xFF10B981);
// const _kSLt = Color(0xFFD1FAE5);
// const _kSDk = Color(0xFF059669);
// const _kDng = Color(0xFFEF4444);
// const _kDLt = Color(0xFFFEE2E2);
// const _kWrn = Color(0xFFF59E0B);
// const _kInf = Color(0xFF3B82F6);
// const _kT1 = Color(0xFF111827);
// const _kT2 = Color(0xFF6B7280);
// const _kMut = Color(0xFFB0B3C1);
// const _kShd = Color(0x0A000000);
// const _kGrd = LinearGradient(
//   colors: [_kP, _kPDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class TeamDirectoryScreen extends StatefulWidget {
//   const TeamDirectoryScreen({super.key});
//   @override
//   State<TeamDirectoryScreen> createState() => _TeamDirectoryScreenState();
// }
//
// class _TeamDirectoryScreenState extends State<TeamDirectoryScreen> {
//   List<Employee> _all = [];
//   bool _loading = true;
//   String? _error;
//   final _searchCtrl = TextEditingController();
//   String _searchQ = '';
//   String _filterRole = '';
//   String _filterStatus = '';
//   String _activeChip = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final list = await EmployeeApi.fetchAll();
//       if (mounted)
//         setState(() {
//           _all = list;
//           _loading = false;
//         });
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//     }
//   }
//
//   int get _total => _all.length;
//   int get _chefs =>
//       _all.where((e) => e.role.toLowerCase().contains('chef')).length;
//   int get _managers =>
//       _all.where((e) => e.role.toLowerCase().contains('manager')).length;
//   int get _inactive => _all.where((e) => !e.isActive).length;
//
//   List<Employee> get _filtered => _all.where((e) {
//     // Chip filter
//     if (_activeChip == 'chefs' && !e.role.toLowerCase().contains('chef'))
//       return false;
//     if (_activeChip == 'managers' && !e.role.toLowerCase().contains('manager'))
//       return false;
//     if (_activeChip == 'inactive' && e.isActive) return false;
//
//     // Search
//     final q = _searchQ.toLowerCase();
//     final ms =
//         q.isEmpty ||
//         e.name.toLowerCase().contains(q) ||
//         e.id.toLowerCase().contains(q) ||
//         e.phone.contains(q);
//
//     // Dropdown filters
//     final mr = _filterRole.isEmpty || e.role == _filterRole;
//     final mst =
//         _filterStatus.isEmpty ||
//         (_filterStatus == 'Active' && e.isActive) ||
//         (_filterStatus == 'Inactive' && !e.isActive);
//
//     return ms && mr && mst;
//   }).toList();
//
//   Future<void> _toggleStatus(Employee emp) async {
//     final next = !emp.isActive;
//     setState(() => emp.isActive = next);
//     try {
//       await EmployeeApi.updateStatus(emp.vendorId, next);
//       if (mounted)
//         showSuccess(
//           context,
//           '${emp.name} is now ${next ? "Active" : "Inactive"}',
//         );
//     } catch (err) {
//       setState(() => emp.isActive = !next);
//       if (mounted) showError(context, 'Failed: $err');
//     }
//   }
//
//   void _openSheet(Widget sheet) => showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     useSafeArea: true,
//     backgroundColor: Colors.transparent,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) => sheet,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final bottom = MediaQuery.of(context).padding.bottom;
//     return Scaffold(
//       backgroundColor: _kBg,
//
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── White header ────────────────────────────────────────────────────────
//             Container(
//               color: _kW,
//               child: Column(
//                 children: [
//                   // Title row
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
//                     child: Row(
//                       children: [
//                         if (Navigator.canPop(context))
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Container(
//                               width: 36,
//                               height: 36,
//                               margin: const EdgeInsets.only(right: 10),
//                               decoration: BoxDecoration(
//                                 color: _kBg,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: _kBrd),
//                               ),
//                               child: const Icon(
//                                 Icons.arrow_back_ios_new_rounded,
//                                 color: _kT1,
//                                 size: 15,
//                               ),
//                             ),
//                           ),
//
//                         const SizedBox(width: 4),
//                         // ── Scrollable stat chips (fills middle) ────────────
//                         Expanded(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             physics: const BouncingScrollPhysics(),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () => setState(
//                                     () => _activeChip = _activeChip == 'total'
//                                         ? ''
//                                         : 'total',
//                                   ),
//                                   child: _StatChip(
//                                     label: 'Total',
//                                     value: _total,
//                                     isActive:
//                                         _activeChip == 'total' ||
//                                         _activeChip == '',
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 GestureDetector(
//                                   onTap: () => setState(
//                                     () => _activeChip = _activeChip == 'chefs'
//                                         ? ''
//                                         : 'chefs',
//                                   ),
//                                   child: _StatChip(
//                                     label: 'Chefs',
//                                     value: _chefs,
//                                     isActive: _activeChip == 'chefs',
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 GestureDetector(
//                                   onTap: () => setState(
//                                     () =>
//                                         _activeChip = _activeChip == 'managers'
//                                         ? ''
//                                         : 'managers',
//                                   ),
//                                   child: _StatChip(
//                                     label: 'Managers',
//                                     value: _managers,
//                                     isActive: _activeChip == 'managers',
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 GestureDetector(
//                                   onTap: () => setState(
//                                     () =>
//                                         _activeChip = _activeChip == 'inactive'
//                                         ? ''
//                                         : 'inactive',
//                                   ),
//                                   child: _StatChip(
//                                     label: 'Inactive',
//                                     value: _inactive,
//                                     isActive: _activeChip == 'inactive',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1, color: _kBrd),
//                 ],
//               ),
//             ),
//
//             // ── Body ────────────────────────────────────────────────────────
//             Expanded(
//               child: RefreshIndicator(
//                 color: _kP,
//                 onRefresh: _load,
//                 child: _loading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           color: _kP,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : _error != null
//                     ? _ErrView(msg: _error!, onRetry: _load)
//                     : CustomScrollView(
//                         slivers: [
//                           SliverToBoxAdapter(
//                             child: Padding(
//                               padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () => _openSheet(
//                                       AddEmployeeSheet(onSaved: _load),
//                                     ),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 14,
//                                         vertical: 9,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         gradient: _kGrd,
//                                         borderRadius: BorderRadius.circular(10),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: _kP.withOpacity(0.3),
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 3),
//                                           ),
//                                         ],
//                                       ),
//                                       child: const Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(
//                                             Icons.person_add_rounded,
//                                             color: _kW,
//                                             size: 15,
//                                           ),
//                                           SizedBox(width: 6),
//                                           Text(
//                                             'Add Employee',
//                                             style: TextStyle(
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w700,
//                                               color: _kW,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: _kPLt,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       '${_filtered.length} employees',
//                                       style: const TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w600,
//                                         color: _kP,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           SliverToBoxAdapter(
//                             child: Padding(
//                               padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: 44,
//                                     decoration: BoxDecoration(
//                                       color: _kW,
//                                       borderRadius: BorderRadius.circular(11),
//                                       border: Border.all(color: _kBrd),
//                                     ),
//                                     child: TextField(
//                                       controller: _searchCtrl,
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         color: _kT1,
//                                       ),
//                                       onChanged: (v) =>
//                                           setState(() => _searchQ = v),
//                                       decoration: InputDecoration(
//                                         hintText:
//                                             'Search by name, ID or phone...',
//                                         hintStyle: const TextStyle(
//                                           fontSize: 13,
//                                           color: _kMut,
//                                         ),
//                                         prefixIcon: const Icon(
//                                           Icons.search_rounded,
//                                           color: _kMut,
//                                           size: 18,
//                                         ),
//                                         suffixIcon: _searchQ.isNotEmpty
//                                             ? IconButton(
//                                                 icon: const Icon(
//                                                   Icons.close_rounded,
//                                                   size: 16,
//                                                   color: _kMut,
//                                                 ),
//                                                 onPressed: () {
//                                                   _searchCtrl.clear();
//                                                   setState(() => _searchQ = '');
//                                                 },
//                                               )
//                                             : null,
//                                         border: InputBorder.none,
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                               vertical: 12,
//                                             ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   // Filter chips
//                                   SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: Row(
//                                       children: [
//                                         _FDrop(
//                                           label: _filterRole.isEmpty
//                                               ? 'All Roles'
//                                               : roleLabel(_filterRole),
//                                           active: _filterRole.isNotEmpty,
//                                           items: [
//                                             const DropdownMenuItem(
//                                               value: '',
//                                               child: Text('All Roles'),
//                                             ),
//                                             ...kEmployeeRoles.map(
//                                               (r) => DropdownMenuItem(
//                                                 value: r.value,
//                                                 child: Text(r.label),
//                                               ),
//                                             ),
//                                           ],
//                                           value: _filterRole,
//                                           onChanged: (v) => setState(
//                                             () => _filterRole = v ?? '',
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         _FDrop(
//                                           label: _filterStatus.isEmpty
//                                               ? 'All Status'
//                                               : _filterStatus,
//                                           active: _filterStatus.isNotEmpty,
//                                           activeColor: _filterStatus == 'Active'
//                                               ? _kSuc
//                                               : _kDng,
//                                           activeBg: _filterStatus == 'Active'
//                                               ? _kSLt
//                                               : _kDLt,
//                                           items: const [
//                                             DropdownMenuItem(
//                                               value: '',
//                                               child: Text('All Status'),
//                                             ),
//                                             DropdownMenuItem(
//                                               value: 'Active',
//                                               child: Text('Active'),
//                                             ),
//                                             DropdownMenuItem(
//                                               value: 'Inactive',
//                                               child: Text('Inactive'),
//                                             ),
//                                           ],
//                                           value: _filterStatus,
//                                           onChanged: (v) => setState(
//                                             () => _filterStatus = v ?? '',
//                                           ),
//                                         ),
//                                         if (_filterRole.isNotEmpty ||
//                                             _filterStatus.isNotEmpty) ...[
//                                           const SizedBox(width: 8),
//                                           GestureDetector(
//                                             onTap: () => setState(() {
//                                               _filterRole = '';
//                                               _filterStatus = '';
//                                             }),
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 10,
//                                                     vertical: 6,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: _kDLt,
//                                                 borderRadius:
//                                                     BorderRadius.circular(20),
//                                                 border: Border.all(
//                                                   color: _kDng.withOpacity(0.3),
//                                                 ),
//                                               ),
//                                               child: const Row(
//                                                 children: [
//                                                   Icon(
//                                                     Icons.close_rounded,
//                                                     size: 12,
//                                                     color: _kDng,
//                                                   ),
//                                                   SizedBox(width: 4),
//                                                   Text(
//                                                     'Clear',
//                                                     style: TextStyle(
//                                                       fontSize: 11,
//                                                       color: _kDng,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           // Employee list or empty state
//                           if (_filtered.isEmpty)
//                             SliverFillRemaining(
//                               child: Center(
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Container(
//                                       width: 68,
//                                       height: 68,
//                                       decoration: BoxDecoration(
//                                         gradient: _kGrd,
//                                         shape: BoxShape.circle,
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: _kP.withOpacity(0.25),
//                                             blurRadius: 16,
//                                             offset: const Offset(0, 6),
//                                           ),
//                                         ],
//                                       ),
//                                       child: const Icon(
//                                         Icons.person_search_rounded,
//                                         color: _kW,
//                                         size: 30,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 14),
//                                     const Text(
//                                       'No employees found',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w700,
//                                         color: _kT1,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     if (_searchQ.isNotEmpty ||
//                                         _filterRole.isNotEmpty ||
//                                         _filterStatus.isNotEmpty)
//                                       GestureDetector(
//                                         onTap: () => setState(() {
//                                           _searchCtrl.clear();
//                                           _searchQ = '';
//                                           _filterRole = '';
//                                           _filterStatus = '';
//                                         }),
//                                         child: const Text(
//                                           'Clear filters',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: _kP,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           else
//                             SliverPadding(
//                               padding: EdgeInsets.fromLTRB(
//                                 14,
//                                 12,
//                                 14,
//                                 bottom + 24,
//                               ),
//                               sliver: SliverList(
//                                 delegate: SliverChildBuilderDelegate(
//                                   (_, i) => _EmpCard(
//                                     emp: _filtered[i],
//                                     index: i,
//                                     onToggle: () => _toggleStatus(_filtered[i]),
//                                     onEdit: () => _openSheet(
//                                       EditEmployeeSheet(
//                                         employee: _filtered[i],
//                                         onSaved: _load,
//                                       ),
//                                     ),
//                                   ),
//                                   childCount: _filtered.length,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Stat Chip (app bar) ────────────────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final String label;
//   final int value;
//   final bool isActive;
//
//   const _StatChip({
//     required this.label,
//     required this.value,
//     required this.isActive,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: isActive
//             ? Colors
//                   .green // 🟢 selected
//             : const Color(0xFFE66D33), // 🟧 default
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         '$value $label',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//           color: Colors.white, // ⚪ always white
//         ),
//       ),
//     );
//   }
// }
//
// // ── Stat Card ──────────────────────────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final IconData icon;
//   final Color color, bg;
//   const _StatCard(this.title, this.value, this.icon, this.color, this.bg);
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: _kW,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: _kBrd),
//       boxShadow: [
//         BoxShadow(color: _kShd, blurRadius: 6, offset: const Offset(0, 2)),
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: _kT2,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Text(
//               '$value',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w900,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Filter Dropdown ────────────────────────────────────────────────────────────
// class _FDrop extends StatelessWidget {
//   final String label, value;
//   final bool active;
//   final Color? activeColor, activeBg;
//   final List<DropdownMenuItem<String>> items;
//   final ValueChanged<String?> onChanged;
//   const _FDrop({
//     required this.label,
//     required this.value,
//     required this.active,
//     required this.items,
//     required this.onChanged,
//     this.activeColor,
//     this.activeBg,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = active ? (activeColor ?? _kP) : _kT2;
//     final bg = active ? (activeBg ?? _kPLt) : _kW;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: active ? color.withOpacity(0.4) : _kBrd,
//           width: active ? 1.5 : 1,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           items: items,
//           onChanged: onChanged,
//           isDense: true,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//           dropdownColor: _kW,
//           icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Employee Card ──────────────────────────────────────────────────────────────
// class _EmpCard extends StatelessWidget {
//   final Employee emp;
//   final int index;
//   final VoidCallback onToggle, onEdit;
//   const _EmpCard({
//     required this.emp,
//     required this.index,
//     required this.onToggle,
//     required this.onEdit,
//   });
//
//   Color get _avatarColor {
//     const c = [
//       _kP,
//       Color(0xFF3B82F6),
//       _kWrn,
//       Color(0xFF64748B),
//       _kSuc,
//       Color(0xFF0891B2),
//     ];
//     return c[index % c.length];
//   }
//
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: const EdgeInsets.only(bottom: 10),
//     decoration: BoxDecoration(
//       color: _kW,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: _kBrd),
//       boxShadow: [
//         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
//       ],
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top row
//           Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: _avatarColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
//                     style: const TextStyle(
//                       color: _kW,
//                       fontWeight: FontWeight.w900,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       emp.name,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: _kT1,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 7,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _kPLt,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             roleLabel(emp.role).isEmpty
//                                 ? emp.role
//                                 : roleLabel(emp.role),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                               color: _kP,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           emp.id,
//                           style: const TextStyle(fontSize: 10, color: _kT2),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Divider(color: _kBrd, height: 1),
//           const SizedBox(height: 10),
//
//           Wrap(
//             spacing: 14,
//             runSpacing: 6,
//             children: [
//               _IC(Icons.phone_outlined, emp.phone),
//               _IC(Icons.location_on_outlined, emp.location),
//
//               if (emp.username.isNotEmpty)
//                 _IC(Icons.person_pin_outlined, emp.username, color: _kInf),
//               if (emp.password.isNotEmpty)
//                 _IC(Icons.lock_outline_rounded, emp.password, color: _kWrn),
//               if (emp.exitDate.isNotEmpty)
//                 _IC(
//                   Icons.exit_to_app_outlined,
//                   'Exit: ${emp.exitDate}',
//                   color: _kDng,
//                 ),
//             ],
//           ),
//
//           if (emp.remarks.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(9),
//               decoration: BoxDecoration(
//                 color: _kBg,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.notes_outlined, size: 13, color: _kMut),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       emp.remarks,
//                       style: const TextStyle(fontSize: 11, color: _kT2),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           const SizedBox(height: 10),
//
//           // Action row
//           Row(
//             children: [
//               const Text(
//                 'Status',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: _kT2,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(width: 5),
//               Switch(
//                 value: emp.isActive,
//                 onChanged: (_) => onToggle(),
//                 activeColor: _kSuc,
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               Text(
//                 emp.isActive ? 'Active' : 'Inactive',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: emp.isActive ? _kSDk : _kDng,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: onEdit,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: _kGrd,
//                     borderRadius: BorderRadius.circular(9),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _kP.withOpacity(0.25),
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.edit_rounded, size: 13, color: _kW),
//                       SizedBox(width: 5),
//                       Text(
//                         'Edit',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: _kW,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// class _StatusBadge extends StatelessWidget {
//   final bool active;
//   const _StatusBadge({required this.active});
//   @override
//   Widget build(BuildContext context) => AnimatedContainer(
//     duration: const Duration(milliseconds: 200),
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//     decoration: BoxDecoration(
//       color: active ? _kSLt : _kDLt,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(
//         color: active ? _kSuc.withOpacity(0.3) : _kDng.withOpacity(0.3),
//       ),
//     ),
//     child: Text(
//       active ? 'Active' : 'Inactive',
//       style: TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w700,
//         color: active ? _kSDk : _kDng,
//       ),
//     ),
//   );
// }
//
// class _IC extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _IC(this.icon, this.label, {this.color = _kT2});
//   @override
//   Widget build(BuildContext context) => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(icon, size: 12, color: color),
//       const SizedBox(width: 4),
//       Text(
//         label,
//         style: TextStyle(
//           fontSize: 11,
//           color: color,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     ],
//   );
// }
//
// // ── Error View ─────────────────────────────────────────────────────────────────
// class _ErrView extends StatelessWidget {
//   final String msg;
//   final VoidCallback onRetry;
//   const _ErrView({required this.msg, required this.onRetry});
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(28),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: const BoxDecoration(
//               color: _kDLt,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               color: _kDng,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'Failed to load employees',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: _kT1,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             msg,
//             style: const TextStyle(fontSize: 12, color: _kT2),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: onRetry,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               decoration: BoxDecoration(
//                 gradient: _kGrd,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.refresh_rounded, color: _kW, size: 15),
//                   SizedBox(width: 6),
//                   Text(
//                     'Retry',
//                     style: TextStyle(color: _kW, fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';
import 'BuySlotsDialog.dart';
import 'add_employee_sheet.dart';
import 'edit_employee_sheet.dart';

const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFE66D33);
const _kPDk = Color(0xFFCC5A20);
const _kPLt = Color(0xFFFFF0E8);
const _kSuc = Color(0xFF10B981);
const _kSLt = Color(0xFFD1FAE5);
const _kSDk = Color(0xFF059669);
const _kDng = Color(0xFFEF4444);
const _kDLt = Color(0xFFFEE2E2);
const _kWrn = Color(0xFFF59E0B);
const _kInf = Color(0xFF3B82F6);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kMut = Color(0xFFB0B3C1);
const _kShd = Color(0x0A000000);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class TeamDirectoryScreen extends StatefulWidget {
  const TeamDirectoryScreen({super.key});
  @override
  State<TeamDirectoryScreen> createState() => _TeamDirectoryScreenState();
}

class _TeamDirectoryScreenState extends State<TeamDirectoryScreen> {
  List<Employee> _all = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _searchQ = '';
  String _filterRole = '';
  String _filterStatus = '';
  String _activeChip = '';
  EmployeeSlotSummary? _slotSummary;
  bool _slotLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _loadSlots() async {
    setState(() => _slotLoading = true);
    try {
      final summary = await EmployeeSlotApi.fetchSummary(_all.length);
      if (mounted) setState(() => _slotSummary = summary);
    } catch (e) {
      debugPrint('❌ loadSlots error: $e');
    } finally {
      if (mounted) setState(() => _slotLoading = false);
    }
  }

  void _openBuySlots() {
    if (_slotSummary == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          BuySlotsDialog(summary: _slotSummary!, onPurchased: _loadSlots),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await EmployeeApi.fetchAll();
      if (mounted) {
        setState(() {
          _all = list;
          _loading = false;
        });
        _loadSlots();
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  int get _total => _all.length;
  int get _chefs =>
      _all.where((e) => e.role.toLowerCase().contains('chef')).length;
  int get _managers =>
      _all.where((e) => e.role.toLowerCase().contains('manager')).length;
  int get _inactive => _all.where((e) => !e.isActive).length;

  List<Employee> get _filtered => _all.where((e) {
    // Chip filter
    if (_activeChip == 'chefs' && !e.role.toLowerCase().contains('chef'))
      return false;
    if (_activeChip == 'managers' && !e.role.toLowerCase().contains('manager'))
      return false;
    if (_activeChip == 'inactive' && e.isActive) return false;

    // Search
    final q = _searchQ.toLowerCase();
    final ms =
        q.isEmpty ||
        e.name.toLowerCase().contains(q) ||
        e.id.toLowerCase().contains(q) ||
        e.phone.contains(q);

    // Dropdown filters
    final mr = _filterRole.isEmpty || e.role == _filterRole;
    final mst =
        _filterStatus.isEmpty ||
        (_filterStatus == 'Active' && e.isActive) ||
        (_filterStatus == 'Inactive' && !e.isActive);

    return ms && mr && mst;
  }).toList();

  Future<void> _toggleStatus(Employee emp) async {
    final next = !emp.isActive;
    setState(() => emp.isActive = next);
    try {
      await EmployeeApi.updateStatus(emp.vendorId, next);
      if (mounted)
        showSuccess(
          context,
          '${emp.name} is now ${next ? "Active" : "Inactive"}',
        );
    } catch (err) {
      setState(() => emp.isActive = !next);
      if (mounted) showError(context, 'Failed: $err');
    }
  }

  void _openSheet(Widget sheet) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => sheet,
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _kBg,

      body: SafeArea(
        child: Column(
          children: [
            // ── White header ────────────────────────────────────────────────────────
            Container(
              color: _kW,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(
                      children: [
                        if (Navigator.canPop(context))
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kBrd),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: _kT1,
                                size: 15,
                              ),
                            ),
                          ),

                        const SizedBox(width: 4),
                        // ── Scrollable stat chips (fills middle) ────────────
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _activeChip = _activeChip == 'total'
                                        ? ''
                                        : 'total',
                                  ),
                                  child: _StatChip(
                                    label: 'Total',
                                    value: _total,
                                    isActive:
                                        _activeChip == 'total' ||
                                        _activeChip == '',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _activeChip = _activeChip == 'chefs'
                                        ? ''
                                        : 'chefs',
                                  ),
                                  child: _StatChip(
                                    label: 'Chefs',
                                    value: _chefs,
                                    isActive: _activeChip == 'chefs',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(
                                    () =>
                                        _activeChip = _activeChip == 'managers'
                                        ? ''
                                        : 'managers',
                                  ),
                                  child: _StatChip(
                                    label: 'Managers',
                                    value: _managers,
                                    isActive: _activeChip == 'managers',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(
                                    () =>
                                        _activeChip = _activeChip == 'inactive'
                                        ? ''
                                        : 'inactive',
                                  ),
                                  child: _StatChip(
                                    label: 'Inactive',
                                    value: _inactive,
                                    isActive: _activeChip == 'inactive',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _kBrd),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _kP,
                onRefresh: _load,
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _kP,
                          strokeWidth: 2,
                        ),
                      )
                    : _error != null
                    ? _ErrView(msg: _error!, onRetry: _load)
                    : CustomScrollView(
                        slivers: [
                          // ── Employee Slots bar ──────────────────────
                          if (!_slotLoading && _slotSummary != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  0,
                                ),
                                child: _SlotsBar(
                                  summary: _slotSummary!,
                                  onBuy: _openBuySlots,
                                ),
                              ),
                            ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: (_slotSummary?.limitReached ?? false)
                                        ? _openBuySlots
                                        : () => _openSheet(
                                            AddEmployeeSheet(onSaved: _load),
                                          ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient:
                                            (_slotSummary?.limitReached ??
                                                false)
                                            ? null
                                            : _kGrd,
                                        color:
                                            (_slotSummary?.limitReached ??
                                                false)
                                            ? _kBrd
                                            : null,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow:
                                            (_slotSummary?.limitReached ??
                                                false)
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: _kP.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            (_slotSummary?.limitReached ??
                                                    false)
                                                ? Icons.lock_outline_rounded
                                                : Icons.person_add_rounded,
                                            color:
                                                (_slotSummary?.limitReached ??
                                                    false)
                                                ? _kT2
                                                : _kW,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            (_slotSummary?.limitReached ??
                                                    false)
                                                ? 'Limit Reached'
                                                : 'Add Employee',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  (_slotSummary?.limitReached ??
                                                      false)
                                                  ? _kT2
                                                  : _kW,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kPLt,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_filtered.length} employees',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _kP,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _kW,
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(color: _kBrd),
                                    ),
                                    child: TextField(
                                      controller: _searchCtrl,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _kT1,
                                      ),
                                      onChanged: (v) =>
                                          setState(() => _searchQ = v),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search by name, ID or phone...',
                                        hintStyle: const TextStyle(
                                          fontSize: 13,
                                          color: _kMut,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          color: _kMut,
                                          size: 18,
                                        ),
                                        suffixIcon: _searchQ.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.close_rounded,
                                                  size: 16,
                                                  color: _kMut,
                                                ),
                                                onPressed: () {
                                                  _searchCtrl.clear();
                                                  setState(() => _searchQ = '');
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _FDrop(
                                          label: _filterRole.isEmpty
                                              ? 'All Roles'
                                              : roleLabel(_filterRole),
                                          active: _filterRole.isNotEmpty,
                                          items: [
                                            const DropdownMenuItem(
                                              value: '',
                                              child: Text('All Roles'),
                                            ),
                                            ...kEmployeeRoles.map(
                                              (r) => DropdownMenuItem(
                                                value: r.value,
                                                child: Text(r.label),
                                              ),
                                            ),
                                          ],
                                          value: _filterRole,
                                          onChanged: (v) => setState(
                                            () => _filterRole = v ?? '',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _FDrop(
                                          label: _filterStatus.isEmpty
                                              ? 'All Status'
                                              : _filterStatus,
                                          active: _filterStatus.isNotEmpty,
                                          activeColor: _filterStatus == 'Active'
                                              ? _kSuc
                                              : _kDng,
                                          activeBg: _filterStatus == 'Active'
                                              ? _kSLt
                                              : _kDLt,
                                          items: const [
                                            DropdownMenuItem(
                                              value: '',
                                              child: Text('All Status'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Active',
                                              child: Text('Active'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Inactive',
                                              child: Text('Inactive'),
                                            ),
                                          ],
                                          value: _filterStatus,
                                          onChanged: (v) => setState(
                                            () => _filterStatus = v ?? '',
                                          ),
                                        ),
                                        if (_filterRole.isNotEmpty ||
                                            _filterStatus.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => setState(() {
                                              _filterRole = '';
                                              _filterStatus = '';
                                            }),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _kDLt,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _kDng.withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.close_rounded,
                                                    size: 12,
                                                    color: _kDng,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Clear',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: _kDng,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Employee list or empty state
                          if (_filtered.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        gradient: _kGrd,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _kP.withOpacity(0.25),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_search_rounded,
                                        color: _kW,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No employees found',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _kT1,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    if (_searchQ.isNotEmpty ||
                                        _filterRole.isNotEmpty ||
                                        _filterStatus.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _searchCtrl.clear();
                                          _searchQ = '';
                                          _filterRole = '';
                                          _filterStatus = '';
                                        }),
                                        child: const Text(
                                          'Clear filters',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _kP,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                bottom + 24,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) => _EmpCard(
                                    emp: _filtered[i],
                                    index: i,
                                    onToggle: () => _toggleStatus(_filtered[i]),
                                    onEdit: () => _openSheet(
                                      EditEmployeeSheet(
                                        employee: _filtered[i],
                                        onSaved: _load,
                                      ),
                                    ),
                                  ),
                                  childCount: _filtered.length,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Chip (app bar) ────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final bool isActive;

  const _StatChip({
    required this.label,
    required this.value,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors
                  .green // 🟢 selected
            : const Color(0xFFE66D33), // 🟧 default
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value $label',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white, // ⚪ always white
        ),
      ),
    );
  }
}

// ── Employee Slots Bar ───────────────────────────────────────────────────────
class _SlotsBar extends StatelessWidget {
  final EmployeeSlotSummary summary;
  final VoidCallback onBuy;
  const _SlotsBar({required this.summary, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final limitReached = summary.limitReached;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: limitReached ? const Color(0xFFFEF3E2) : const Color(0xFFEFF8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: icon + title + (badge)
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 18,
                color: limitReached ? _kWrn : const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Employee Slots: ${summary.currentEmployees} / ${summary.totalAvailable}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kT1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (limitReached) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kDng,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, size: 11, color: _kW),
                      SizedBox(width: 4),
                      Text(
                        'LIMIT REACHED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kW,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: remaining-slot info (left) + Buy Slots button (right, only
          // when the limit is reached). Expanded on the text keeps the button
          // from ever being pushed off-screen on narrow devices.
          Row(
            children: [
              Expanded(
                child: Text(
                  limitReached
                      ? 'Additional slots: ₹${summary.slotPrice.toStringAsFixed(0)}/slot'
                      : '${summary.remainingSlots} slots remaining',
                  style: const TextStyle(fontSize: 11, color: _kT2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (limitReached) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onBuy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: _kGrd,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_rounded, size: 13, color: _kW),
                        SizedBox(width: 5),
                        Text(
                          'BUY SLOTS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _kW,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: summary.progress.toDouble(),
              minHeight: 6,
              backgroundColor: _kBrd,
              color: limitReached ? _kDng : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color, bg;
  const _StatCard(this.title, this.value, this.icon, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _kW,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBrd),
      boxShadow: [
        BoxShadow(color: _kShd, blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: _kT2,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Filter Dropdown ────────────────────────────────────────────────────────────
class _FDrop extends StatelessWidget {
  final String label, value;
  final bool active;
  final Color? activeColor, activeBg;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _FDrop({
    required this.label,
    required this.value,
    required this.active,
    required this.items,
    required this.onChanged,
    this.activeColor,
    this.activeBg,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? _kP) : _kT2;
    final bg = active ? (activeBg ?? _kPLt) : _kW;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color.withOpacity(0.4) : _kBrd,
          width: active ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          dropdownColor: _kW,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Employee Card ──────────────────────────────────────────────────────────────
class _EmpCard extends StatelessWidget {
  final Employee emp;
  final int index;
  final VoidCallback onToggle, onEdit;
  const _EmpCard({
    required this.emp,
    required this.index,
    required this.onToggle,
    required this.onEdit,
  });

  Color get _avatarColor {
    const c = [
      _kP,
      Color(0xFF3B82F6),
      _kWrn,
      Color(0xFF64748B),
      _kSuc,
      Color(0xFF0891B2),
    ];
    return c[index % c.length];
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: _kW,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBrd),
      boxShadow: [
        BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: _kW,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kT1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _kPLt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            roleLabel(emp.role).isEmpty
                                ? emp.role
                                : roleLabel(emp.role),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kP,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          emp.id,
                          style: const TextStyle(fontSize: 10, color: _kT2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: _kBrd, height: 1),
          const SizedBox(height: 10),

          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _IC(Icons.phone_outlined, emp.phone),
              _IC(Icons.location_on_outlined, emp.location),

              if (emp.username.isNotEmpty)
                _IC(Icons.person_pin_outlined, emp.username, color: _kInf),
              if (emp.password.isNotEmpty)
                _IC(Icons.lock_outline_rounded, emp.password, color: _kWrn),
              if (emp.exitDate.isNotEmpty)
                _IC(
                  Icons.exit_to_app_outlined,
                  'Exit: ${emp.exitDate}',
                  color: _kDng,
                ),
            ],
          ),

          if (emp.remarks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes_outlined, size: 13, color: _kMut),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      emp.remarks,
                      style: const TextStyle(fontSize: 11, color: _kT2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Action row
          Row(
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 11,
                  color: _kT2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 5),
              Switch(
                value: emp.isActive,
                onChanged: (_) => onToggle(),
                activeColor: _kSuc,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                emp.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: emp.isActive ? _kSDk : _kDng,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: _kGrd,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: _kP.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: _kW),
                      SizedBox(width: 5),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kW,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: active ? _kSLt : _kDLt,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: active ? _kSuc.withOpacity(0.3) : _kDng.withOpacity(0.3),
      ),
    ),
    child: Text(
      active ? 'Active' : 'Inactive',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: active ? _kSDk : _kDng,
      ),
    ),
  );
}

class _IC extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _IC(this.icon, this.label, {this.color = _kT2});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// ── Error View ─────────────────────────────────────────────────────────────────
class _ErrView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrView({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: _kDLt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _kDng,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Failed to load employees',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kT1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            msg,
            style: const TextStyle(fontSize: 12, color: _kT2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _kGrd,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: _kW, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Retry',
                    style: TextStyle(color: _kW, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
