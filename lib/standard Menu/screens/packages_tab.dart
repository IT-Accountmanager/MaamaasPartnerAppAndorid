// // //
// // // import 'package:flutter/material.dart';
// // // import '../models/models.dart';
// // // import '../services/api_service.dart';
// // // import '../widgets/common_widgets.dart';
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
// // // const _kInf = Color(0xFF3B82F6);
// // // const _kILt = Color(0xFFDBEAFE);
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
// // // class PackagesTab extends StatefulWidget {
// // //   const PackagesTab({super.key});
// // //   @override
// // //   State<PackagesTab> createState() => PackagesTabState();
// // // }
// // //
// // // class PackagesTabState extends State<PackagesTab> {
// // //   List<MenuPackage> _data = [];
// // //   List<MenuPackage> _filtered = [];
// // //   bool _loading = true;
// // //   String? _error;
// // //   final _searchCtrl = TextEditingController();
// // //   String _searchQuery = '';
// // //   String? _selectedType;
// // //   String? _selectedPackage;
// // //   final Set<int> _expanded = {};
// // //
// // //   void openAddCategory() {
// // //     _showAddPackageSheet();
// // //   }
// // //
// // //   void enableBulkMode() {
// // //   }
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchData();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _searchCtrl.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _fetchData() async {
// // //     setState(() {
// // //       _loading = true;
// // //       _error = null;
// // //     });
// // //     try {
// // //       final result = await ApiService.fetchPackages();
// // //       if (mounted) {
// // //         setState(() {
// // //           _data = result;
// // //           _loading = false;
// // //         });
// // //         _applyFilter();
// // //       }
// // //     } catch (e) {
// // //       if (mounted)
// // //         setState(() {
// // //           _error = e.toString();
// // //           _loading = false;
// // //         });
// // //     }
// // //   }
// // //
// // //   void _applyFilter() {
// // //     var f = [..._data];
// // //     if (_selectedType != null)
// // //       f = f.where((p) => p.packageType == _selectedType).toList();
// // //     if (_selectedPackage != null)
// // //       f = f.where((p) => p.packageName == _selectedPackage).toList();
// // //     if (_searchQuery.isNotEmpty) {
// // //       final q = _searchQuery.toLowerCase();
// // //       f = f
// // //           .map((p) {
// // //             final pm = p.packageName.toLowerCase().contains(q);
// // //             final items = p.items
// // //                 .where(
// // //                   (i) =>
// // //                       i.itemName.toLowerCase().contains(q) ||
// // //                       (i.description?.toLowerCase().contains(q) ?? false),
// // //                 )
// // //                 .toList();
// // //             if (pm || items.isNotEmpty)
// // //               return MenuPackage(
// // //                 id: p.id,
// // //                 packageName: p.packageName,
// // //                 packageType: p.packageType,
// // //                 image: p.image,
// // //                 totalPrice: p.totalPrice,
// // //                 items: pm ? p.items : items,
// // //               );
// // //             return null;
// // //           })
// // //           .whereType<MenuPackage>()
// // //           .toList();
// // //     }
// // //     setState(() => _filtered = f);
// // //   }
// // //
// // //   Future<void> _deletePackage(MenuPackage pkg) async {
// // //     final ok = await showConfirmDialog(
// // //       context,
// // //       title: 'Delete Package',
// // //       message: 'Delete "${pkg.packageName}"? This cannot be undone.',
// // //     );
// // //     if (!ok) return;
// // //     try {
// // //       await ApiService.deletePackage(pkg.id);
// // //       await _fetchData();
// // //     } catch (_) {
// // //       if (mounted)
// // //         showAppDialog(
// // //           context,
// // //           title: 'Error',
// // //           message: 'Failed to delete package.',
// // //         );
// // //     }
// // //   }
// // //
// // //   Future<void> _deleteItem(PackageItem item, int packageId) async {
// // //     final ok = await showConfirmDialog(
// // //       context,
// // //       title: 'Delete Item',
// // //       message: 'Delete "${item.itemName}"?',
// // //     );
// // //     if (!ok) return;
// // //     try {
// // //       await ApiService.deletePackageItem(item.id, packageId);
// // //       await _fetchData();
// // //     } catch (_) {
// // //       if (mounted)
// // //         showAppDialog(
// // //           context,
// // //           title: 'Error',
// // //           message: 'Failed to delete item.',
// // //         );
// // //     }
// // //   }
// // //
// // //   void _showEditItemSheet(PackageItem item, int packageId) =>
// // //       showModalBottomSheet(
// // //         context: context,
// // //         isScrollControlled: true,
// // //         useSafeArea: true,
// // //         backgroundColor: Colors.transparent,
// // //         shape: const RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //         ),
// // //         builder: (_) => _EditItemSheet(
// // //           item: item,
// // //           packageId: packageId,
// // //           onSaved: _fetchData,
// // //         ),
// // //       );
// // //
// // //   void _showAddPackageSheet() => showModalBottomSheet(
// // //     context: context,
// // //     isScrollControlled: true,
// // //     useSafeArea: true,
// // //     backgroundColor: Colors.transparent,
// // //     shape: const RoundedRectangleBorder(
// // //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //     ),
// // //     builder: (_) => _AddPackageSheet(onSaved: _fetchData),
// // //   );
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         // ── Filter bar ──────────────────────────────────────────────────────
// // //         Container(
// // //           color: _kW,
// // //           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
// // //           child: Column(
// // //             children: [
// // //               Container(
// // //                 height: 42,
// // //                 decoration: BoxDecoration(
// // //                   color: _kBg,
// // //                   borderRadius: BorderRadius.circular(11),
// // //                   border: Border.all(color: _kBrd),
// // //                 ),
// // //                 child: TextField(
// // //                   controller: _searchCtrl,
// // //                   style: const TextStyle(fontSize: 13, color: _kT1),
// // //                   onChanged: (v) {
// // //                     _searchQuery = v;
// // //                     _applyFilter();
// // //                     setState(() {});
// // //                   },
// // //                   decoration: InputDecoration(
// // //                     hintText: 'Search packages or items...',
// // //                     hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// // //                     prefixIcon: const Icon(
// // //                       Icons.search_rounded,
// // //                       color: _kMut,
// // //                       size: 18,
// // //                     ),
// // //                     suffixIcon: _searchCtrl.text.isNotEmpty
// // //                         ? IconButton(
// // //                             icon: const Icon(
// // //                               Icons.close_rounded,
// // //                               size: 16,
// // //                               color: _kMut,
// // //                             ),
// // //                             onPressed: () {
// // //                               _searchCtrl.clear();
// // //                               _searchQuery = '';
// // //                               _applyFilter();
// // //                               setState(() {});
// // //                             },
// // //                           )
// // //                         : null,
// // //                     border: InputBorder.none,
// // //                     contentPadding: const EdgeInsets.symmetric(vertical: 11),
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               SingleChildScrollView(
// // //                 scrollDirection: Axis.horizontal,
// // //                 child: Row(
// // //                   children: [
// // //                     for (final e in [
// // //                       _TEntry(null, 'All', _kP, _kPLt),
// // //                       _TEntry('Veg', '🟢 Veg', _kSuc, _kSLt),
// // //                       _TEntry('Non_veg', '🔴 Non-Veg', _kDng, _kDLt),
// // //                       _TEntry('Drinks', '🔵 Drinks', _kInf, _kILt),
// // //                     ]) ...[
// // //                       _TypeChip(
// // //                         e: e,
// // //                         active: _selectedType == e.type,
// // //                         onTap: () {
// // //                           setState(() => _selectedType = e.type);
// // //                           _applyFilter();
// // //                         },
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                     ],
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               const Divider(color: _kBrd, height: 1),
// // //             ],
// // //           ),
// // //         ),
// // //
// // //         const Divider(color: _kBrd, height: 1),
// // //         // ── Content ─────────────────────────────────────────────────────────
// // //         Expanded(
// // //           child: _loading
// // //               ? const Center(
// // //                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
// // //                 )
// // //               : _error != null
// // //               ? _ErrWidget(msg: _error!, onRetry: _fetchData)
// // //               : _filtered.isEmpty
// // //               ? _EmptyWidget()
// // //               : RefreshIndicator(
// // //                   color: _kP,
// // //                   onRefresh: _fetchData,
// // //                   child: ListView.builder(
// // //                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
// // //                     itemCount: _filtered.length,
// // //                     itemBuilder: (_, i) {
// // //                       final pkg = _filtered[i];
// // //                       return _PackageCard(
// // //                         package: pkg,
// // //                         isExpanded: _expanded.contains(pkg.id),
// // //                         onToggleExpand: () => setState(() {
// // //                           _expanded.contains(pkg.id)
// // //                               ? _expanded.remove(pkg.id)
// // //                               : _expanded.add(pkg.id);
// // //                         }),
// // //                         onDelete: () => _deletePackage(pkg),
// // //                         onEditItem: (item) => _showEditItemSheet(item, pkg.id),
// // //                         onDeleteItem: (item) => _deleteItem(item, pkg.id),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }
// // //
// // // class _TEntry {
// // //   final String? type;
// // //   final String label;
// // //   final Color color, bg;
// // //   const _TEntry(this.type, this.label, this.color, this.bg);
// // // }
// // //
// // // class _TypeChip extends StatelessWidget {
// // //   final _TEntry e;
// // //   final bool active;
// // //   final VoidCallback onTap;
// // //   const _TypeChip({required this.e, required this.active, required this.onTap});
// // //   @override
// // //   Widget build(BuildContext context) => GestureDetector(
// // //     onTap: onTap,
// // //     child: AnimatedContainer(
// // //       duration: const Duration(milliseconds: 200),
// // //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// // //       decoration: BoxDecoration(
// // //         color: active ? e.bg : _kBg,
// // //         borderRadius: BorderRadius.circular(9),
// // //         border: Border.all(
// // //           color: active ? e.color.withOpacity(0.4) : _kBrd,
// // //           width: active ? 1.5 : 1,
// // //         ),
// // //       ),
// // //       child: Text(
// // //         e.label,
// // //         style: TextStyle(
// // //           fontSize: 11,
// // //           fontWeight: FontWeight.w700,
// // //           color: active ? e.color : _kT2,
// // //         ),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _ErrWidget extends StatelessWidget {
// // //   final String msg;
// // //   final VoidCallback onRetry;
// // //   const _ErrWidget({required this.msg, required this.onRetry});
// // //   @override
// // //   Widget build(BuildContext context) => Center(
// // //     child: Padding(
// // //       padding: const EdgeInsets.all(28),
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
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
// // //             'Failed to load packages',
// // //             style: TextStyle(
// // //               fontSize: 15,
// // //               fontWeight: FontWeight.w700,
// // //               color: _kT1,
// // //             ),
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
// // //
// // // class _EmptyWidget extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) => Center(
// // //     child: Column(
// // //       mainAxisAlignment: MainAxisAlignment.center,
// // //       children: [
// // //         Container(
// // //           width: 68,
// // //           height: 68,
// // //           decoration: BoxDecoration(
// // //             gradient: _kGrd,
// // //             shape: BoxShape.circle,
// // //             boxShadow: [
// // //               BoxShadow(
// // //                 color: _kP.withOpacity(0.3),
// // //                 blurRadius: 16,
// // //                 offset: const Offset(0, 6),
// // //               ),
// // //             ],
// // //           ),
// // //           child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
// // //         ),
// // //         const SizedBox(height: 14),
// // //         const Text(
// // //           'No packages found',
// // //           style: TextStyle(
// // //             fontSize: 15,
// // //             fontWeight: FontWeight.w700,
// // //             color: _kT1,
// // //           ),
// // //         ),
// // //         const SizedBox(height: 5),
// // //         const Text(
// // //           'Tap Add Package to create one',
// // //           style: TextStyle(fontSize: 12, color: _kT2),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }
// // //
// // // // ── Package Card ───────────────────────────────────────────────────────────────
// // // class _PackageCard extends StatelessWidget {
// // //   final MenuPackage package;
// // //   final bool isExpanded;
// // //   final VoidCallback onToggleExpand, onDelete;
// // //   final Function(PackageItem) onEditItem, onDeleteItem;
// // //   const _PackageCard({
// // //     required this.package,
// // //     required this.isExpanded,
// // //     required this.onToggleExpand,
// // //     required this.onDelete,
// // //     required this.onEditItem,
// // //     required this.onDeleteItem,
// // //   });
// // //
// // //   Color get _tc {
// // //     switch (package.packageType) {
// // //       case 'Veg':
// // //         return _kSuc;
// // //       case 'Non_veg':
// // //         return _kDng;
// // //       default:
// // //         return _kInf;
// // //     }
// // //   }
// // //
// // //   Color get _tb {
// // //     switch (package.packageType) {
// // //       case 'Veg':
// // //         return _kSLt;
// // //       case 'Non_veg':
// // //         return _kDLt;
// // //       default:
// // //         return _kILt;
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     margin: const EdgeInsets.only(bottom: 10),
// // //     decoration: BoxDecoration(
// // //       color: _kW,
// // //       borderRadius: BorderRadius.circular(16),
// // //       border: Border.all(color: isExpanded ? _tc.withOpacity(0.2) : _kBrd),
// // //       boxShadow: [
// // //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// // //       ],
// // //     ),
// // //     child: Column(
// // //       children: [
// // //         GestureDetector(
// // //           onTap: onToggleExpand,
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(12),
// // //             child: Row(
// // //               children: [
// // //                 ClipRRect(
// // //                   borderRadius: BorderRadius.circular(10),
// // //                   child: Container(
// // //                     width: 52,
// // //                     height: 52,
// // //                     color: _kBg,
// // //                     child: package.image != null && package.image!.isNotEmpty
// // //                         ? Image.network(
// // //                             package.image!,
// // //                             fit: BoxFit.cover,
// // //                             errorBuilder: (_, __, ___) => const Icon(
// // //                               Icons.inventory_2_rounded,
// // //                               color: _kMut,
// // //                               size: 22,
// // //                             ),
// // //                           )
// // //                         : const Icon(
// // //                             Icons.inventory_2_rounded,
// // //                             color: _kMut,
// // //                             size: 22,
// // //                           ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text(
// // //                         package.packageName,
// // //                         style: const TextStyle(
// // //                           fontWeight: FontWeight.w800,
// // //                           fontSize: 14,
// // //                           color: _kT1,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       Row(
// // //                         children: [
// // //                           Container(
// // //                             padding: const EdgeInsets.symmetric(
// // //                               horizontal: 8,
// // //                               vertical: 2,
// // //                             ),
// // //                             decoration: BoxDecoration(
// // //                               color: _tb,
// // //                               borderRadius: BorderRadius.circular(6),
// // //                               border: Border.all(color: _tc.withOpacity(0.2)),
// // //                             ),
// // //                             child: Text(
// // //                               package.packageType == 'Non_veg'
// // //                                   ? 'Non-Veg'
// // //                                   : package.packageType,
// // //                               style: TextStyle(
// // //                                 fontSize: 10,
// // //                                 color: _tc,
// // //                                 fontWeight: FontWeight.w700,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                           const SizedBox(width: 8),
// // //                           Text(
// // //                             '${package.items.length} items',
// // //                             style: const TextStyle(fontSize: 11, color: _kT2),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.end,
// // //                   children: [
// // //                     Text(
// // //                       '₹${package.computedTotal.toStringAsFixed(0)}',
// // //                       style: const TextStyle(
// // //                         fontSize: 17,
// // //                         fontWeight: FontWeight.w900,
// // //                         color: _kP,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 4),
// // //                     Row(
// // //                       mainAxisSize: MainAxisSize.min,
// // //                       children: [
// // //                         GestureDetector(
// // //                           onTap: onDelete,
// // //                           child: Container(
// // //                             padding: const EdgeInsets.all(6),
// // //                             decoration: BoxDecoration(
// // //                               color: _kDLt,
// // //                               borderRadius: BorderRadius.circular(7),
// // //                             ),
// // //                             child: const Icon(
// // //                               Icons.delete_outline_rounded,
// // //                               size: 15,
// // //                               color: _kDng,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(width: 6),
// // //                         AnimatedRotation(
// // //                           turns: isExpanded ? 0.5 : 0,
// // //                           duration: const Duration(milliseconds: 200),
// // //                           child: Icon(
// // //                             Icons.keyboard_arrow_down_rounded,
// // //                             color: isExpanded ? _kP : _kMut,
// // //                             size: 20,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //         if (isExpanded) ...[
// // //           Divider(
// // //             color: _kBrd.withOpacity(0.6),
// // //             height: 1,
// // //             indent: 12,
// // //             endIndent: 12,
// // //           ),
// // //           if (package.items.isEmpty)
// // //             Padding(
// // //               padding: const EdgeInsets.all(14),
// // //               child: Center(
// // //                 child: Text(
// // //                   'No items',
// // //                   style: TextStyle(
// // //                     fontSize: 12,
// // //                     color: _kMut,
// // //                     fontStyle: FontStyle.italic,
// // //                   ),
// // //                 ),
// // //               ),
// // //             )
// // //           else
// // //             ...package.items.asMap().entries.map(
// // //               (e) => _ItemRow(
// // //                 item: e.value,
// // //                 index: e.key,
// // //                 onEdit: () => onEditItem(e.value),
// // //                 onDelete: () => onDeleteItem(e.value),
// // //                 isLast: e.key == package.items.length - 1,
// // //               ),
// // //             ),
// // //         ],
// // //       ],
// // //     ),
// // //   );
// // // }
// // //
// // // // ── Item Row ───────────────────────────────────────────────────────────────────
// // // class _ItemRow extends StatelessWidget {
// // //   final PackageItem item;
// // //   final int index;
// // //   final VoidCallback onEdit, onDelete;
// // //   final bool isLast;
// // //   const _ItemRow({
// // //     required this.item,
// // //     required this.index,
// // //     required this.onEdit,
// // //     required this.onDelete,
// // //     this.isLast = false,
// // //   });
// // //   @override
// // //   Widget build(BuildContext context) => Column(
// // //     children: [
// // //       Padding(
// // //         padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
// // //         child: Row(
// // //           children: [
// // //             Container(
// // //               width: 2,
// // //               height: 36,
// // //               margin: const EdgeInsets.only(right: 10),
// // //               decoration: BoxDecoration(
// // //                 color: _kP.withOpacity(0.2),
// // //                 borderRadius: BorderRadius.circular(2),
// // //               ),
// // //             ),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     item.itemName,
// // //                     style: const TextStyle(
// // //                       fontWeight: FontWeight.w700,
// // //                       fontSize: 13,
// // //                       color: _kT1,
// // //                     ),
// // //                   ),
// // //                   if (item.description != null && item.description!.isNotEmpty)
// // //                     Text(
// // //                       item.description!,
// // //                       style: const TextStyle(fontSize: 11, color: _kT2),
// // //                       maxLines: 1,
// // //                       overflow: TextOverflow.ellipsis,
// // //                     ),
// // //                 ],
// // //               ),
// // //             ),
// // //             Text(
// // //               '₹${item.price.toStringAsFixed(0)}',
// // //               style: const TextStyle(
// // //                 fontWeight: FontWeight.w800,
// // //                 color: _kP,
// // //                 fontSize: 13,
// // //               ),
// // //             ),
// // //             const SizedBox(width: 10),
// // //             GestureDetector(
// // //               onTap: onEdit,
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(6),
// // //                 decoration: BoxDecoration(
// // //                   color: _kILt,
// // //                   borderRadius: BorderRadius.circular(6),
// // //                 ),
// // //                 child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
// // //               ),
// // //             ),
// // //             const SizedBox(width: 6),
// // //             GestureDetector(
// // //               onTap: onDelete,
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(6),
// // //                 decoration: BoxDecoration(
// // //                   color: _kDLt,
// // //                   borderRadius: BorderRadius.circular(6),
// // //                 ),
// // //                 child: const Icon(
// // //                   Icons.delete_outline_rounded,
// // //                   size: 14,
// // //                   color: _kDng,
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //       if (!isLast)
// // //         Divider(
// // //           color: _kBrd.withOpacity(0.5),
// // //           height: 1,
// // //           indent: 16,
// // //           endIndent: 12,
// // //         ),
// // //     ],
// // //   );
// // // }
// // //
// // // // ── Edit Item Sheet ────────────────────────────────────────────────────────────
// // // class _EditItemSheet extends StatefulWidget {
// // //   final PackageItem item;
// // //   final int packageId;
// // //   final VoidCallback onSaved;
// // //   const _EditItemSheet({
// // //     required this.item,
// // //     required this.packageId,
// // //     required this.onSaved,
// // //   });
// // //   @override
// // //   State<_EditItemSheet> createState() => __EditItemSheetState();
// // // }
// // //
// // // class __EditItemSheetState extends State<_EditItemSheet> {
// // //   late final TextEditingController _nameCtrl, _priceCtrl;
// // //   bool _saving = false;
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _nameCtrl = TextEditingController(text: widget.item.itemName);
// // //     _priceCtrl = TextEditingController(
// // //       text: widget.item.price.toStringAsFixed(0),
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _nameCtrl.dispose();
// // //     _priceCtrl.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _save() async {
// // //     if (_nameCtrl.text.trim().isEmpty) {
// // //       showAppDialog(
// // //         context,
// // //         title: 'Required',
// // //         message: 'Please enter an item name.',
// // //       );
// // //       return;
// // //     }
// // //     setState(() => _saving = true);
// // //     try {
// // //       final updated = widget.item.copyWith(
// // //         itemName: _nameCtrl.text.trim(),
// // //         price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
// // //       );
// // //       await ApiService.updatePackageItem(updated, widget.packageId);
// // //       widget.onSaved();
// // //       if (mounted) Navigator.pop(context);
// // //     } catch (_) {
// // //       if (mounted)
// // //         showAppDialog(
// // //           context,
// // //           title: 'Error',
// // //           message: 'Failed to update item.',
// // //         );
// // //     } finally {
// // //       if (mounted) setState(() => _saving = false);
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) => SafeArea(
// // //     child: Padding(
// // //       // SafeArea handles home indicator; viewInsets.bottom handles keyboard
// // //       padding: EdgeInsets.only(
// // //         bottom: MediaQuery.of(context).viewInsets.bottom,
// // //       ),
// // //       child: Container(
// // //         decoration: const BoxDecoration(
// // //           color: _kW,
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //         ),
// // //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             _Handle(),
// // //             Row(
// // //               children: [
// // //                 Container(
// // //                   width: 34,
// // //                   height: 34,
// // //                   decoration: BoxDecoration(
// // //                     color: _kPLt,
// // //                     borderRadius: BorderRadius.circular(9),
// // //                   ),
// // //                   child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 const Text(
// // //                   'Edit Item',
// // //                   style: TextStyle(
// // //                     fontSize: 16,
// // //                     fontWeight: FontWeight.w800,
// // //                     color: _kT1,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 16),
// // //             _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
// // //             const SizedBox(height: 10),
// // //             _Field(
// // //               _priceCtrl,
// // //               'Price (₹)',
// // //               Icons.currency_rupee_rounded,
// // //               type: TextInputType.number,
// // //             ),
// // //             const SizedBox(height: 20),
// // //             _SaveRow(
// // //               () => Navigator.pop(context),
// // //               _saving ? null : _save,
// // //               'Save Item',
// // //               _saving,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // // ── Add Package Sheet ──────────────────────────────────────────────────────────
// // // class _AddPackageSheet extends StatefulWidget {
// // //   final VoidCallback onSaved;
// // //   const _AddPackageSheet({required this.onSaved});
// // //   @override
// // //   State<_AddPackageSheet> createState() => __AddPackageSheetState();
// // // }
// // //
// // // class __AddPackageSheetState extends State<_AddPackageSheet> {
// // //   final _nameCtrl = TextEditingController();
// // //   String _type = 'Veg';
// // //   final List<Map<String, TextEditingController>> _items = [];
// // //   bool _saving = false;
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _addItem();
// // //   }
// // //
// // //   void _addItem() {
// // //     _items.add({
// // //       'name': TextEditingController(),
// // //       'price': TextEditingController(),
// // //     });
// // //     setState(() {});
// // //   }
// // //
// // //   void _removeItem(int i) {
// // //     _items[i]['name']!.dispose();
// // //     _items[i]['price']!.dispose();
// // //     _items.removeAt(i);
// // //     setState(() {});
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _nameCtrl.dispose();
// // //     for (final item in _items) {
// // //       item['name']!.dispose();
// // //       item['price']!.dispose();
// // //     }
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _save() async {
// // //     if (_nameCtrl.text.trim().isEmpty) {
// // //       showAppDialog(
// // //         context,
// // //         title: 'Required',
// // //         message: 'Please enter a package name.',
// // //       );
// // //       return;
// // //     }
// // //     final valid = _items
// // //         .where(
// // //           (i) =>
// // //               i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
// // //         )
// // //         .map(
// // //           (i) => PackageItem(
// // //             id: 0,
// // //             itemName: i['name']!.text.trim(),
// // //             price: double.tryParse(i['price']!.text) ?? 0,
// // //           ),
// // //         )
// // //         .toList();
// // //     if (valid.isEmpty) {
// // //       showAppDialog(
// // //         context,
// // //         title: 'Items Required',
// // //         message: 'Please add at least one valid item.',
// // //       );
// // //       return;
// // //     }
// // //     setState(() => _saving = true);
// // //     try {
// // //       final pkg = MenuPackage(
// // //         id: 0,
// // //         packageName: _nameCtrl.text.trim(),
// // //         packageType: _type,
// // //         totalPrice: valid.fold(0, (s, i) => s + i.price),
// // //         items: valid,
// // //       );
// // //       await ApiService.addPackage(pkg: pkg);
// // //       widget.onSaved();
// // //       if (mounted) Navigator.pop(context);
// // //     } catch (_) {
// // //       if (mounted)
// // //         showAppDialog(
// // //           context,
// // //           title: 'Error',
// // //           message: 'Failed to add package.',
// // //         );
// // //     } finally {
// // //       if (mounted) setState(() => _saving = false);
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) => SafeArea(
// // //     child: Padding(
// // //       padding: EdgeInsets.only(
// // //         bottom: MediaQuery.of(context).viewInsets.bottom,
// // //       ),
// // //       child: Container(
// // //         decoration: const BoxDecoration(
// // //           color: _kW,
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //         ),
// // //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// // //         child: SingleChildScrollView(
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               _Handle(),
// // //               Row(
// // //                 children: [
// // //                   Container(
// // //                     width: 34,
// // //                     height: 34,
// // //                     decoration: BoxDecoration(
// // //                       color: _kPLt,
// // //                       borderRadius: BorderRadius.circular(9),
// // //                     ),
// // //                     child: const Icon(
// // //                       Icons.inventory_2_rounded,
// // //                       color: _kP,
// // //                       size: 17,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   const Text(
// // //                     'Add New Package',
// // //                     style: TextStyle(
// // //                       fontSize: 16,
// // //                       fontWeight: FontWeight.w800,
// // //                       color: _kT1,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 16),
// // //               _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
// // //               const SizedBox(height: 10),
// // //               Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   const Text(
// // //                     'Package Type',
// // //                     style: TextStyle(
// // //                       fontSize: 12,
// // //                       fontWeight: FontWeight.w600,
// // //                       color: _kT2,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 5),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// // //                     decoration: BoxDecoration(
// // //                       color: _kBg,
// // //                       borderRadius: BorderRadius.circular(10),
// // //                       border: Border.all(color: _kBrd),
// // //                     ),
// // //                     child: DropdownButtonHideUnderline(
// // //                       child: DropdownButton<String>(
// // //                         value: _type,
// // //                         isExpanded: true,
// // //                         icon: const Icon(
// // //                           Icons.keyboard_arrow_down_rounded,
// // //                           color: _kP,
// // //                           size: 18,
// // //                         ),
// // //                         style: const TextStyle(fontSize: 13, color: _kT1),
// // //                         onChanged: (v) => setState(() => _type = v ?? 'Veg'),
// // //                         items: const [
// // //                           DropdownMenuItem(value: 'Veg', child: Text('Veg')),
// // //                           DropdownMenuItem(
// // //                             value: 'Non_veg',
// // //                             child: Text('Non-Veg'),
// // //                           ),
// // //                           DropdownMenuItem(
// // //                             value: 'Drinks',
// // //                             child: Text('Drinks'),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 14),
// // //               Row(
// // //                 children: [
// // //                   const Text(
// // //                     'Items',
// // //                     style: TextStyle(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.w700,
// // //                       color: _kT1,
// // //                     ),
// // //                   ),
// // //                   const Spacer(),
// // //                   GestureDetector(
// // //                     onTap: _addItem,
// // //                     child: Container(
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 10,
// // //                         vertical: 5,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         color: _kPLt,
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                       child: const Row(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           Icon(Icons.add_rounded, color: _kP, size: 13),
// // //                           SizedBox(width: 4),
// // //                           Text(
// // //                             'Add Item',
// // //                             style: TextStyle(
// // //                               fontSize: 11,
// // //                               fontWeight: FontWeight.w700,
// // //                               color: _kP,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 8),
// // //               ..._items.asMap().entries.map(
// // //                 (e) => Padding(
// // //                   padding: const EdgeInsets.only(bottom: 8),
// // //                   child: Row(
// // //                     children: [
// // //                       Expanded(
// // //                         flex: 3,
// // //                         child: _TF(e.value['name']!, 'Item name'),
// // //                       ),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                         flex: 2,
// // //                         child: _TF(
// // //                           e.value['price']!,
// // //                           '₹ Price',
// // //                           TextInputType.number,
// // //                         ),
// // //                       ),
// // //                       if (_items.length > 1) ...[
// // //                         const SizedBox(width: 6),
// // //                         GestureDetector(
// // //                           onTap: () => _removeItem(e.key),
// // //                           child: Container(
// // //                             padding: const EdgeInsets.all(7),
// // //                             decoration: BoxDecoration(
// // //                               color: _kDLt,
// // //                               borderRadius: BorderRadius.circular(8),
// // //                             ),
// // //                             child: const Icon(
// // //                               Icons.close_rounded,
// // //                               size: 14,
// // //                               color: _kDng,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 18),
// // //               _SaveRow(
// // //                 () => Navigator.pop(context),
// // //                 _saving ? null : _save,
// // //                 'Save Package',
// // //                 _saving,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // // ── Shared bottom sheet helpers ────────────────────────────────────────────────
// // // class _Handle extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) => Center(
// // //     child: Container(
// // //       width: 36,
// // //       height: 4,
// // //       margin: const EdgeInsets.only(bottom: 14),
// // //       decoration: BoxDecoration(
// // //         color: _kBrd,
// // //         borderRadius: BorderRadius.circular(2),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _Field extends StatelessWidget {
// // //   final TextEditingController ctrl;
// // //   final String hint;
// // //   final IconData icon;
// // //   final TextInputType type;
// // //   const _Field(
// // //     this.ctrl,
// // //     this.hint,
// // //     this.icon, {
// // //     this.type = TextInputType.text,
// // //   });
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     decoration: BoxDecoration(
// // //       color: _kBg,
// // //       borderRadius: BorderRadius.circular(10),
// // //       border: Border.all(color: _kBrd),
// // //     ),
// // //     child: TextField(
// // //       controller: ctrl,
// // //       keyboardType: type,
// // //       style: const TextStyle(fontSize: 13, color: _kT1),
// // //       decoration: InputDecoration(
// // //         hintText: hint,
// // //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// // //         prefixIcon: Icon(icon, color: _kP, size: 17),
// // //         border: InputBorder.none,
// // //         contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _TF extends StatelessWidget {
// // //   final TextEditingController ctrl;
// // //   final String hint;
// // //   final TextInputType type;
// // //   const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     decoration: BoxDecoration(
// // //       color: _kBg,
// // //       borderRadius: BorderRadius.circular(9),
// // //       border: Border.all(color: _kBrd),
// // //     ),
// // //     child: TextField(
// // //       controller: ctrl,
// // //       keyboardType: type,
// // //       style: const TextStyle(fontSize: 13, color: _kT1),
// // //       decoration: InputDecoration(
// // //         hintText: hint,
// // //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// // //         border: InputBorder.none,
// // //         contentPadding: const EdgeInsets.symmetric(
// // //           horizontal: 10,
// // //           vertical: 10,
// // //         ),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _SaveRow extends StatelessWidget {
// // //   final VoidCallback onCancel;
// // //   final VoidCallback? onSave;
// // //   final String label;
// // //   final bool saving;
// // //   const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);
// // //   @override
// // //   Widget build(BuildContext context) => Row(
// // //     children: [
// // //       Expanded(
// // //         child: GestureDetector(
// // //           onTap: onCancel,
// // //           child: Container(
// // //             height: 44,
// // //             decoration: BoxDecoration(
// // //               color: _kBg,
// // //               borderRadius: BorderRadius.circular(10),
// // //               border: Border.all(color: _kBrd),
// // //             ),
// // //             child: const Center(
// // //               child: Text(
// // //                 'Cancel',
// // //                 style: TextStyle(
// // //                   fontSize: 13,
// // //                   fontWeight: FontWeight.w600,
// // //                   color: _kT2,
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //       const SizedBox(width: 10),
// // //       Expanded(
// // //         child: GestureDetector(
// // //           onTap: onSave,
// // //           child: AnimatedContainer(
// // //             duration: const Duration(milliseconds: 180),
// // //             height: 44,
// // //             decoration: BoxDecoration(
// // //               gradient: onSave != null ? _kGrd : null,
// // //               color: onSave == null ? _kBrd : null,
// // //               borderRadius: BorderRadius.circular(10),
// // //               boxShadow: onSave != null
// // //                   ? [
// // //                       BoxShadow(
// // //                         color: _kP.withOpacity(0.3),
// // //                         blurRadius: 8,
// // //                         offset: const Offset(0, 3),
// // //                       ),
// // //                     ]
// // //                   : null,
// // //             ),
// // //             child: Center(
// // //               child: saving
// // //                   ? const SizedBox(
// // //                       width: 18,
// // //                       height: 18,
// // //                       child: CircularProgressIndicator(
// // //                         color: _kW,
// // //                         strokeWidth: 2,
// // //                       ),
// // //                     )
// // //                   : Text(
// // //                       label,
// // //                       style: const TextStyle(
// // //                         color: _kW,
// // //                         fontSize: 13,
// // //                         fontWeight: FontWeight.w700,
// // //                       ),
// // //                     ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     ],
// // //   );
// // // }
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../models/models.dart';
// // import '../services/api_service.dart';
// // import '../widgets/common_widgets.dart';
// //
// // const _kW = Color(0xFFFFFFFF);
// // const _kBg = Color(0xFFF7F8FC);
// // const _kBrd = Color(0xFFEEEFF5);
// // const _kP = Color(0xFFB15DC6);
// // const _kPDk = Color(0xFF8B3FA0);
// // const _kPLt = Color(0xFFF5E8FA);
// // const _kSuc = Color(0xFF10B981);
// // const _kSLt = Color(0xFFD1FAE5);
// // const _kSDk = Color(0xFF059669);
// // const _kDng = Color(0xFFEF4444);
// // const _kDLt = Color(0xFFFEE2E2);
// // const _kInf = Color(0xFF3B82F6);
// // const _kILt = Color(0xFFDBEAFE);
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
// // class PackagesTab extends StatefulWidget {
// //   const PackagesTab({super.key});
// //   @override
// //   State<PackagesTab> createState() => PackagesTabState();
// // }
// //
// // class PackagesTabState extends State<PackagesTab> {
// //   List<MenuPackage> _data = [];
// //   List<MenuPackage> _filtered = [];
// //   bool _loading = true;
// //   String? _error;
// //   final _searchCtrl = TextEditingController();
// //   String _searchQuery = '';
// //   String? _selectedType;
// //   String? _selectedPackage;
// //   final Set<int> _expanded = {};
// //
// //   void openAddCategory() {
// //     _showAddPackageSheet();
// //   }
// //
// //   void enableBulkMode() {}
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _fetchData() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final result = await MenuService.fetchPackages();
// //       if (mounted) {
// //         setState(() {
// //           _data = result;
// //           _loading = false;
// //         });
// //         _applyFilter();
// //       }
// //     } catch (e) {
// //       if (mounted)
// //         setState(() {
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //     }
// //   }
// //
// //   void _applyFilter() {
// //     var f = [..._data];
// //     if (_selectedType != null)
// //       f = f.where((p) => p.packageType == _selectedType).toList();
// //     if (_selectedPackage != null)
// //       f = f.where((p) => p.packageName == _selectedPackage).toList();
// //     if (_searchQuery.isNotEmpty) {
// //       final q = _searchQuery.toLowerCase();
// //       f = f
// //           .map((p) {
// //             final pm = p.packageName.toLowerCase().contains(q);
// //             final items = p.items
// //                 .where(
// //                   (i) =>
// //                       i.itemName.toLowerCase().contains(q) ||
// //                       (i.description?.toLowerCase().contains(q) ?? false),
// //                 )
// //                 .toList();
// //             if (pm || items.isNotEmpty)
// //               return MenuPackage(
// //                 id: p.id,
// //                 packageName: p.packageName,
// //                 packageType: p.packageType,
// //                 image: p.image,
// //                 totalPrice: p.totalPrice,
// //                 items: pm ? p.items : items,
// //               );
// //             return null;
// //           })
// //           .whereType<MenuPackage>()
// //           .toList();
// //     }
// //     setState(() => _filtered = f);
// //   }
// //
// //   Future<void> _deletePackage(MenuPackage pkg) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Package',
// //       message: 'Delete "${pkg.packageName}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deletePackage(pkg.id);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete package.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteItem(PackageItem item, int packageId) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Item',
// //       message: 'Delete "${item.itemName}"?',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deletePackageItem(item.id, packageId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete item.',
// //         );
// //     }
// //   }
// //
// //   void _showEditItemSheet(PackageItem item, int packageId) =>
// //       showModalBottomSheet(
// //         context: context,
// //         isScrollControlled: true,
// //         useSafeArea: true,
// //         backgroundColor: Colors.transparent,
// //         shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         builder: (_) => _EditItemSheet(
// //           item: item,
// //           packageId: packageId,
// //           onSaved: _fetchData,
// //         ),
// //       );
// //
// //   void _showAddPackageSheet() => showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     useSafeArea: true,
// //     backgroundColor: Colors.transparent,
// //     shape: const RoundedRectangleBorder(
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //     ),
// //     builder: (_) => _AddPackageSheet(onSaved: _fetchData),
// //   );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // ── Filter bar ──────────────────────────────────────────────────────
// //         Container(
// //           color: _kW,
// //           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
// //           child: Column(
// //             children: [
// //               Container(
// //                 height: 42,
// //                 decoration: BoxDecoration(
// //                   color: _kBg,
// //                   borderRadius: BorderRadius.circular(11),
// //                   border: Border.all(color: _kBrd),
// //                 ),
// //                 child: TextField(
// //                   controller: _searchCtrl,
// //                   style: const TextStyle(fontSize: 13, color: _kT1),
// //                   onChanged: (v) {
// //                     _searchQuery = v;
// //                     _applyFilter();
// //                     setState(() {});
// //                   },
// //                   decoration: InputDecoration(
// //                     hintText: 'Search packages or items...',
// //                     hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //                     prefixIcon: const Icon(
// //                       Icons.search_rounded,
// //                       color: _kMut,
// //                       size: 18,
// //                     ),
// //                     suffixIcon: _searchCtrl.text.isNotEmpty
// //                         ? IconButton(
// //                             icon: const Icon(
// //                               Icons.close_rounded,
// //                               size: 16,
// //                               color: _kMut,
// //                             ),
// //                             onPressed: () {
// //                               _searchCtrl.clear();
// //                               _searchQuery = '';
// //                               _applyFilter();
// //                               setState(() {});
// //                             },
// //                           )
// //                         : null,
// //                     border: InputBorder.none,
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 11),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               SingleChildScrollView(
// //                 scrollDirection: Axis.horizontal,
// //                 child: Row(
// //                   children: [
// //                     for (final e in [
// //                       _TEntry(null, 'All', _kP, _kPLt),
// //                       _TEntry('Veg', '🟢 Veg', _kSuc, _kSLt),
// //                       _TEntry('Non_veg', '🔴 Non-Veg', _kDng, _kDLt),
// //                       _TEntry('Drinks', '🔵 Drinks', _kInf, _kILt),
// //                     ]) ...[
// //                       _TypeChip(
// //                         e: e,
// //                         active: _selectedType == e.type,
// //                         onTap: () {
// //                           setState(() => _selectedType = e.type);
// //                           _applyFilter();
// //                         },
// //                       ),
// //                       const SizedBox(width: 6),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               const Divider(color: _kBrd, height: 1),
// //             ],
// //           ),
// //         ),
// //
// //         const Divider(color: _kBrd, height: 1),
// //         // ── Content ─────────────────────────────────────────────────────────
// //         Expanded(
// //           child: _loading
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
// //                 )
// //               : _error != null
// //               ? _ErrWidget(msg: _error!, onRetry: _fetchData)
// //               : _filtered.isEmpty
// //               ? _EmptyWidget()
// //               : RefreshIndicator(
// //                   color: _kP,
// //                   onRefresh: _fetchData,
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
// //                     itemCount: _filtered.length,
// //                     itemBuilder: (_, i) {
// //                       final pkg = _filtered[i];
// //                       return _PackageCard(
// //                         package: pkg,
// //                         isExpanded: _expanded.contains(pkg.id),
// //                         onToggleExpand: () => setState(() {
// //                           _expanded.contains(pkg.id)
// //                               ? _expanded.remove(pkg.id)
// //                               : _expanded.add(pkg.id);
// //                         }),
// //                         onDelete: () => _deletePackage(pkg),
// //                         onEditItem: (item) => _showEditItemSheet(item, pkg.id),
// //                         onDeleteItem: (item) => _deleteItem(item, pkg.id),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class _TEntry {
// //   final String? type;
// //   final String label;
// //   final Color color, bg;
// //   const _TEntry(this.type, this.label, this.color, this.bg);
// // }
// //
// // class _TypeChip extends StatelessWidget {
// //   final _TEntry e;
// //   final bool active;
// //   final VoidCallback onTap;
// //   const _TypeChip({required this.e, required this.active, required this.onTap});
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: AnimatedContainer(
// //       duration: const Duration(milliseconds: 200),
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: active ? e.bg : _kBg,
// //         borderRadius: BorderRadius.circular(9),
// //         border: Border.all(
// //           color: active ? e.color.withOpacity(0.4) : _kBrd,
// //           width: active ? 1.5 : 1,
// //         ),
// //       ),
// //       child: Text(
// //         e.label,
// //         style: TextStyle(
// //           fontSize: 11,
// //           fontWeight: FontWeight.w700,
// //           color: active ? e.color : _kT2,
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _ErrWidget extends StatelessWidget {
// //   final String msg;
// //   final VoidCallback onRetry;
// //   const _ErrWidget({required this.msg, required this.onRetry});
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(28),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
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
// //             'Failed to load packages',
// //             style: TextStyle(
// //               fontSize: 15,
// //               fontWeight: FontWeight.w700,
// //               color: _kT1,
// //             ),
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
// //
// // class _EmptyWidget extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Container(
// //           width: 68,
// //           height: 68,
// //           decoration: BoxDecoration(
// //             gradient: _kGrd,
// //             shape: BoxShape.circle,
// //             boxShadow: [
// //               BoxShadow(
// //                 color: _kP.withOpacity(0.3),
// //                 blurRadius: 16,
// //                 offset: const Offset(0, 6),
// //               ),
// //             ],
// //           ),
// //           child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
// //         ),
// //         const SizedBox(height: 14),
// //         const Text(
// //           'No packages found',
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.w700,
// //             color: _kT1,
// //           ),
// //         ),
// //         const SizedBox(height: 5),
// //         const Text(
// //           'Tap Add Package to create one',
// //           style: TextStyle(fontSize: 12, color: _kT2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Package Card ───────────────────────────────────────────────────────────────
// // class _PackageCard extends StatelessWidget {
// //   final MenuPackage package;
// //   final bool isExpanded;
// //   final VoidCallback onToggleExpand, onDelete;
// //   final Function(PackageItem) onEditItem, onDeleteItem;
// //   const _PackageCard({
// //     required this.package,
// //     required this.isExpanded,
// //     required this.onToggleExpand,
// //     required this.onDelete,
// //     required this.onEditItem,
// //     required this.onDeleteItem,
// //   });
// //
// //   Color get _tc {
// //     switch (package.packageType) {
// //       case 'Veg':
// //         return _kSuc;
// //       case 'Non_veg':
// //         return _kDng;
// //       default:
// //         return _kInf;
// //     }
// //   }
// //
// //   Color get _tb {
// //     switch (package.packageType) {
// //       case 'Veg':
// //         return _kSLt;
// //       case 'Non_veg':
// //         return _kDLt;
// //       default:
// //         return _kILt;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: isExpanded ? _tc.withOpacity(0.2) : _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     ),
// //     child: Column(
// //       children: [
// //         GestureDetector(
// //           onTap: onToggleExpand,
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Row(
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(10),
// //                   child: Container(
// //                     width: 52,
// //                     height: 52,
// //                     color: _kBg,
// //                     child: package.image != null && package.image!.isNotEmpty
// //                         ? Image.network(
// //                             package.image!,
// //                             fit: BoxFit.cover,
// //                             errorBuilder: (_, __, ___) => const Icon(
// //                               Icons.inventory_2_rounded,
// //                               color: _kMut,
// //                               size: 22,
// //                             ),
// //                           )
// //                         : const Icon(
// //                             Icons.inventory_2_rounded,
// //                             color: _kMut,
// //                             size: 22,
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         package.packageName,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 14,
// //                           color: _kT1,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         children: [
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 2,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: _tb,
// //                               borderRadius: BorderRadius.circular(6),
// //                               border: Border.all(color: _tc.withOpacity(0.2)),
// //                             ),
// //                             child: Text(
// //                               package.packageType == 'Non_veg'
// //                                   ? 'Non-Veg'
// //                                   : package.packageType,
// //                               style: TextStyle(
// //                                 fontSize: 10,
// //                                 color: _tc,
// //                                 fontWeight: FontWeight.w700,
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 8),
// //                           Text(
// //                             '${package.items.length} items',
// //                             style: const TextStyle(fontSize: 11, color: _kT2),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       '₹${package.computedTotal.toStringAsFixed(0)}',
// //                       style: const TextStyle(
// //                         fontSize: 17,
// //                         fontWeight: FontWeight.w900,
// //                         color: _kP,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         GestureDetector(
// //                           onTap: onDelete,
// //                           child: Container(
// //                             padding: const EdgeInsets.all(6),
// //                             decoration: BoxDecoration(
// //                               color: _kDLt,
// //                               borderRadius: BorderRadius.circular(7),
// //                             ),
// //                             child: const Icon(
// //                               Icons.delete_outline_rounded,
// //                               size: 15,
// //                               color: _kDng,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 6),
// //                         AnimatedRotation(
// //                           turns: isExpanded ? 0.5 : 0,
// //                           duration: const Duration(milliseconds: 200),
// //                           child: Icon(
// //                             Icons.keyboard_arrow_down_rounded,
// //                             color: isExpanded ? _kP : _kMut,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         if (isExpanded) ...[
// //           Divider(
// //             color: _kBrd.withOpacity(0.6),
// //             height: 1,
// //             indent: 12,
// //             endIndent: 12,
// //           ),
// //           if (package.items.isEmpty)
// //             Padding(
// //               padding: const EdgeInsets.all(14),
// //               child: Center(
// //                 child: Text(
// //                   'No items',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _kMut,
// //                     fontStyle: FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...package.items.asMap().entries.map(
// //               (e) => _ItemRow(
// //                 item: e.value,
// //                 index: e.key,
// //                 onEdit: () => onEditItem(e.value),
// //                 onDelete: () => onDeleteItem(e.value),
// //                 isLast: e.key == package.items.length - 1,
// //               ),
// //             ),
// //         ],
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Item Row ───────────────────────────────────────────────────────────────────
// // class _ItemRow extends StatelessWidget {
// //   final PackageItem item;
// //   final int index;
// //   final VoidCallback onEdit, onDelete;
// //   final bool isLast;
// //   const _ItemRow({
// //     required this.item,
// //     required this.index,
// //     required this.onEdit,
// //     required this.onDelete,
// //     this.isLast = false,
// //   });
// //   @override
// //   Widget build(BuildContext context) => Column(
// //     children: [
// //       Padding(
// //         padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 2,
// //               height: 36,
// //               margin: const EdgeInsets.only(right: 10),
// //               decoration: BoxDecoration(
// //                 color: _kP.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     item.itemName,
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 13,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                   if (item.description != null && item.description!.isNotEmpty)
// //                     Text(
// //                       item.description!,
// //                       style: const TextStyle(fontSize: 11, color: _kT2),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             Text(
// //               '₹${item.price.toStringAsFixed(0)}',
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.w800,
// //                 color: _kP,
// //                 fontSize: 13,
// //               ),
// //             ),
// //             const SizedBox(width: 10),
// //             GestureDetector(
// //               onTap: onEdit,
// //               child: Container(
// //                 padding: const EdgeInsets.all(6),
// //                 decoration: BoxDecoration(
// //                   color: _kILt,
// //                   borderRadius: BorderRadius.circular(6),
// //                 ),
// //                 child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
// //               ),
// //             ),
// //             const SizedBox(width: 6),
// //             GestureDetector(
// //               onTap: onDelete,
// //               child: Container(
// //                 padding: const EdgeInsets.all(6),
// //                 decoration: BoxDecoration(
// //                   color: _kDLt,
// //                   borderRadius: BorderRadius.circular(6),
// //                 ),
// //                 child: const Icon(
// //                   Icons.delete_outline_rounded,
// //                   size: 14,
// //                   color: _kDng,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       if (!isLast)
// //         Divider(
// //           color: _kBrd.withOpacity(0.5),
// //           height: 1,
// //           indent: 16,
// //           endIndent: 12,
// //         ),
// //     ],
// //   );
// // }
// //
// // // ── Edit Item Sheet ────────────────────────────────────────────────────────────
// // class _EditItemSheet extends StatefulWidget {
// //   final PackageItem item;
// //   final int packageId;
// //   final VoidCallback onSaved;
// //   const _EditItemSheet({
// //     required this.item,
// //     required this.packageId,
// //     required this.onSaved,
// //   });
// //   @override
// //   State<_EditItemSheet> createState() => __EditItemSheetState();
// // }
// //
// // class __EditItemSheetState extends State<_EditItemSheet> {
// //   late final TextEditingController _nameCtrl, _priceCtrl;
// //   bool _saving = false;
// //   @override
// //   void initState() {
// //     super.initState();
// //     _nameCtrl = TextEditingController(text: widget.item.itemName);
// //     _priceCtrl = TextEditingController(
// //       text: widget.item.price.toStringAsFixed(0),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     _priceCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     if (_nameCtrl.text.trim().isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Required',
// //         message: 'Please enter an item name.',
// //       );
// //       return;
// //     }
// //     setState(() => _saving = true);
// //     try {
// //       final updated = widget.item.copyWith(
// //         itemName: _nameCtrl.text.trim(),
// //         price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
// //       );
// //       await MenuService.updatePackageItem(updated, widget.packageId);
// //       widget.onSaved();
// //       if (mounted) Navigator.pop(context);
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to update item.',
// //         );
// //     } finally {
// //       if (mounted) setState(() => _saving = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Padding(
// //       // SafeArea handles home indicator; viewInsets.bottom handles keyboard
// //       padding: EdgeInsets.only(
// //         bottom: MediaQuery.of(context).viewInsets.bottom,
// //       ),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _Handle(),
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 34,
// //                   height: 34,
// //                   decoration: BoxDecoration(
// //                     color: _kPLt,
// //                     borderRadius: BorderRadius.circular(9),
// //                   ),
// //                   child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 const Text(
// //                   'Edit Item',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w800,
// //                     color: _kT1,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
// //             const SizedBox(height: 10),
// //             _Field(
// //               _priceCtrl,
// //               'Price (₹)',
// //               Icons.currency_rupee_rounded,
// //               type: TextInputType.number,
// //             ),
// //             const SizedBox(height: 20),
// //             _SaveRow(
// //               () => Navigator.pop(context),
// //               _saving ? null : _save,
// //               'Save Item',
// //               _saving,
// //             ),
// //           ],
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // // ── Add Package Sheet ──────────────────────────────────────────────────────────
// // class _AddPackageSheet extends StatefulWidget {
// //   final VoidCallback onSaved;
// //   const _AddPackageSheet({required this.onSaved});
// //   @override
// //   State<_AddPackageSheet> createState() => __AddPackageSheetState();
// // }
// //
// // class __AddPackageSheetState extends State<_AddPackageSheet> {
// //   final _nameCtrl = TextEditingController();
// //   String _type = 'Veg';
// //   final List<Map<String, TextEditingController>> _items = [];
// //   bool _saving = false;
// //   File? _imageFile;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _addItem();
// //   }
// //
// //   Future<void> _pickImage() async {
// //     final picked = await ImagePicker().pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 85,
// //       maxWidth: 1024,
// //       maxHeight: 1024,
// //     );
// //     if (picked != null && mounted)
// //       setState(() => _imageFile = File(picked.path));
// //   }
// //
// //   void _addItem() {
// //     _items.add({
// //       'name': TextEditingController(),
// //       'price': TextEditingController(),
// //     });
// //     setState(() {});
// //   }
// //
// //   void _removeItem(int i) {
// //     _items[i]['name']!.dispose();
// //     _items[i]['price']!.dispose();
// //     _items.removeAt(i);
// //     setState(() {});
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     for (final item in _items) {
// //       item['name']!.dispose();
// //       item['price']!.dispose();
// //     }
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     if (_nameCtrl.text.trim().isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Required',
// //         message: 'Please enter a package name.',
// //       );
// //       return;
// //     }
// //     final valid = _items
// //         .where(
// //           (i) =>
// //               i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
// //         )
// //         .map(
// //           (i) => PackageItem(
// //             id: 0,
// //             itemName: i['name']!.text.trim(),
// //             price: double.tryParse(i['price']!.text) ?? 0,
// //           ),
// //         )
// //         .toList();
// //     if (valid.isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Items Required',
// //         message: 'Please add at least one valid item.',
// //       );
// //       return;
// //     }
// //     setState(() => _saving = true);
// //     try {
// //       final pkg = MenuPackage(
// //         id: 0,
// //         packageName: _nameCtrl.text.trim(),
// //         packageType: _type,
// //         totalPrice: valid.fold(0, (s, i) => s + i.price),
// //         items: valid,
// //       );
// //       List<int>? imageBytes;
// //       String imageFileName = 'package.jpg';
// //       if (_imageFile != null) {
// //         imageBytes = await _imageFile!.readAsBytes();
// //         imageFileName = _imageFile!.path.split('/').last;
// //       }
// //       await MenuService.addPackage(
// //         pkg: pkg,
// //         imageBytes: imageBytes,
// //         imageFileName: imageFileName,
// //       );
// //       widget.onSaved();
// //       if (mounted) Navigator.pop(context);
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to add package.',
// //         );
// //     } finally {
// //       if (mounted) setState(() => _saving = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Padding(
// //       padding: EdgeInsets.only(
// //         bottom: MediaQuery.of(context).viewInsets.bottom,
// //       ),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               _Handle(),
// //               Row(
// //                 children: [
// //                   Container(
// //                     width: 34,
// //                     height: 34,
// //                     decoration: BoxDecoration(
// //                       color: _kPLt,
// //                       borderRadius: BorderRadius.circular(9),
// //                     ),
// //                     child: const Icon(
// //                       Icons.inventory_2_rounded,
// //                       color: _kP,
// //                       size: 17,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'Add New Package',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w800,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
// //               const SizedBox(height: 10),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Package Type',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                       color: _kT2,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// //                     decoration: BoxDecoration(
// //                       color: _kBg,
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: _kBrd),
// //                     ),
// //                     child: DropdownButtonHideUnderline(
// //                       child: DropdownButton<String>(
// //                         value: _type,
// //                         isExpanded: true,
// //                         icon: const Icon(
// //                           Icons.keyboard_arrow_down_rounded,
// //                           color: _kP,
// //                           size: 18,
// //                         ),
// //                         style: const TextStyle(fontSize: 13, color: _kT1),
// //                         onChanged: (v) => setState(() => _type = v ?? 'Veg'),
// //                         items: const [
// //                           DropdownMenuItem(value: 'Veg', child: Text('Veg')),
// //                           DropdownMenuItem(
// //                             value: 'Non_veg',
// //                             child: Text('Non-Veg'),
// //                           ),
// //                           DropdownMenuItem(
// //                             value: 'Drinks',
// //                             child: Text('Drinks'),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 14),
// //               // ── Package Image ────────────────────────────────────────────
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Package Image (optional)',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                       color: _kT2,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 6),
// //                   GestureDetector(
// //                     onTap: _pickImage,
// //                     child: Container(
// //                       height: 110,
// //                       width: double.infinity,
// //                       decoration: BoxDecoration(
// //                         color: _kBg,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: _imageFile != null ? _kP : _kBrd,
// //                           width: _imageFile != null ? 1.5 : 1,
// //                         ),
// //                       ),
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(11),
// //                         child: _imageFile != null
// //                             ? Stack(
// //                                 fit: StackFit.expand,
// //                                 children: [
// //                                   Image.file(_imageFile!, fit: BoxFit.cover),
// //                                   Positioned(
// //                                     bottom: 0,
// //                                     left: 0,
// //                                     right: 0,
// //                                     child: Container(
// //                                       color: Colors.black54,
// //                                       padding: const EdgeInsets.symmetric(
// //                                         vertical: 5,
// //                                       ),
// //                                       child: const Row(
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.center,
// //                                         children: [
// //                                           Icon(
// //                                             Icons.camera_alt_rounded,
// //                                             color: _kW,
// //                                             size: 13,
// //                                           ),
// //                                           SizedBox(width: 5),
// //                                           Text(
// //                                             'Tap to change',
// //                                             style: TextStyle(
// //                                               color: _kW,
// //                                               fontSize: 11,
// //                                               fontWeight: FontWeight.w600,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               )
// //                             : Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: const [
// //                                   Icon(
// //                                     Icons.add_photo_alternate_outlined,
// //                                     color: _kMut,
// //                                     size: 32,
// //                                   ),
// //                                   SizedBox(height: 6),
// //                                   Text(
// //                                     'Tap to upload image',
// //                                     style: TextStyle(
// //                                       fontSize: 12,
// //                                       color: _kMut,
// //                                       fontWeight: FontWeight.w500,
// //                                     ),
// //                                   ),
// //                                   SizedBox(height: 2),
// //                                   Text(
// //                                     'JPG, PNG • Max 5MB',
// //                                     style: TextStyle(
// //                                       fontSize: 10,
// //                                       color: _kBrd,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 14),
// //               Row(
// //                 children: [
// //                   const Text(
// //                     'Items',
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   GestureDetector(
// //                     onTap: _addItem,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 5,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _kPLt,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: const Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(Icons.add_rounded, color: _kP, size: 13),
// //                           SizedBox(width: 4),
// //                           Text(
// //                             'Add Item',
// //                             style: TextStyle(
// //                               fontSize: 11,
// //                               fontWeight: FontWeight.w700,
// //                               color: _kP,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               ..._items.asMap().entries.map(
// //                 (e) => Padding(
// //                   padding: const EdgeInsets.only(bottom: 8),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: _TF(e.value['name']!, 'Item name'),
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Expanded(
// //                         flex: 2,
// //                         child: _TF(
// //                           e.value['price']!,
// //                           '₹ Price',
// //                           TextInputType.number,
// //                         ),
// //                       ),
// //                       if (_items.length > 1) ...[
// //                         const SizedBox(width: 6),
// //                         GestureDetector(
// //                           onTap: () => _removeItem(e.key),
// //                           child: Container(
// //                             padding: const EdgeInsets.all(7),
// //                             decoration: BoxDecoration(
// //                               color: _kDLt,
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: const Icon(
// //                               Icons.close_rounded,
// //                               size: 14,
// //                               color: _kDng,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 18),
// //               _SaveRow(
// //                 () => Navigator.pop(context),
// //                 _saving ? null : _save,
// //                 'Save Package',
// //                 _saving,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // // ── Shared bottom sheet helpers ────────────────────────────────────────────────
// // class _Handle extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Container(
// //       width: 36,
// //       height: 4,
// //       margin: const EdgeInsets.only(bottom: 14),
// //       decoration: BoxDecoration(
// //         color: _kBrd,
// //         borderRadius: BorderRadius.circular(2),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _Field extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final String hint;
// //   final IconData icon;
// //   final TextInputType type;
// //   const _Field(
// //     this.ctrl,
// //     this.hint,
// //     this.icon, {
// //     this.type = TextInputType.text,
// //   });
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: _kBg,
// //       borderRadius: BorderRadius.circular(10),
// //       border: Border.all(color: _kBrd),
// //     ),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: type,
// //       style: const TextStyle(fontSize: 13, color: _kT1),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //         prefixIcon: Icon(icon, color: _kP, size: 17),
// //         border: InputBorder.none,
// //         contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _TF extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final String hint;
// //   final TextInputType type;
// //   const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: _kBg,
// //       borderRadius: BorderRadius.circular(9),
// //       border: Border.all(color: _kBrd),
// //     ),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: type,
// //       style: const TextStyle(fontSize: 13, color: _kT1),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //         border: InputBorder.none,
// //         contentPadding: const EdgeInsets.symmetric(
// //           horizontal: 10,
// //           vertical: 10,
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _SaveRow extends StatelessWidget {
// //   final VoidCallback onCancel;
// //   final VoidCallback? onSave;
// //   final String label;
// //   final bool saving;
// //   const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);
// //   @override
// //   Widget build(BuildContext context) => Row(
// //     children: [
// //       Expanded(
// //         child: GestureDetector(
// //           onTap: onCancel,
// //           child: Container(
// //             height: 44,
// //             decoration: BoxDecoration(
// //               color: _kBg,
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: _kBrd),
// //             ),
// //             child: const Center(
// //               child: Text(
// //                 'Cancel',
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: _kT2,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       const SizedBox(width: 10),
// //       Expanded(
// //         child: GestureDetector(
// //           onTap: onSave,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 180),
// //             height: 44,
// //             decoration: BoxDecoration(
// //               gradient: onSave != null ? _kGrd : null,
// //               color: onSave == null ? _kBrd : null,
// //               borderRadius: BorderRadius.circular(10),
// //               boxShadow: onSave != null
// //                   ? [
// //                       BoxShadow(
// //                         color: _kP.withOpacity(0.3),
// //                         blurRadius: 8,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ]
// //                   : null,
// //             ),
// //             child: Center(
// //               child: saving
// //                   ? const SizedBox(
// //                       width: 18,
// //                       height: 18,
// //                       child: CircularProgressIndicator(
// //                         color: _kW,
// //                         strokeWidth: 2,
// //                       ),
// //                     )
// //                   : Text(
// //                       label,
// //                       style: const TextStyle(
// //                         color: _kW,
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../widgets/common_widgets.dart';
//
// // ─── tokens ───────────────────────────────────────────────────────────────────
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFB15DC6);
// const _kPDk = Color(0xFF8B3FA0);
// const _kPLt = Color(0xFFF5E8FA);
// const _kSuc = Color(0xFF10B981);
// const _kSLt = Color(0xFFD1FAE5);
// const _kSDk = Color(0xFF059669);
// const _kDng = Color(0xFFEF4444);
// const _kDLt = Color(0xFFFEE2E2);
// const _kInf = Color(0xFF3B82F6);
// const _kILt = Color(0xFFDBEAFE);
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
// class PackagesTab extends StatefulWidget {
//   const PackagesTab({super.key});
//   @override
//   State<PackagesTab> createState() => PackagesTabState();
// }
//
// class PackagesTabState extends State<PackagesTab> {
//   List<MenuPackage> _data = [];
//   List<MenuPackage> _filtered = [];
//   bool _loading = true;
//   String? _error;
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//   String? _selectedType; // null = All
//   final Set<int> _expanded = {};
//
//   // ── Overlay filter state ──────────────────────────────────────────────────
//   bool _filtersExpanded = false;
//   final LayerLink _filterLayerLink = LayerLink();
//   OverlayEntry? _filterOverlay;
//
//   void _showFilterOverlay() {
//     _filterOverlay = OverlayEntry(
//       builder: (_) => GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: _removeFilterOverlay,
//         child: Stack(
//           children: [
//             CompositedTransformFollower(
//               link: _filterLayerLink,
//               showWhenUnlinked: false,
//               offset: const Offset(-160, 48),
//               child: GestureDetector(
//                 onTap: () {},
//                 child: Material(
//                   color: Colors.transparent,
//                   child: _FilterDropdown(
//                     selectedType: _selectedType,
//                     onSelect: (type) {
//                       setState(() => _selectedType = type);
//                       _applyFilter();
//                       _removeFilterOverlay();
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//     Overlay.of(context).insert(_filterOverlay!);
//     setState(() => _filtersExpanded = true);
//   }
//
//   void _removeFilterOverlay({bool updateState = true}) {
//     _filterOverlay?.remove();
//     _filterOverlay = null;
//     if (updateState && mounted) setState(() => _filtersExpanded = false);
//   }
//
//   void openAddCategory() => _showAddPackageSheet();
//   void enableBulkMode() {}
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   @override
//   void dispose() {
//     _removeFilterOverlay(updateState: false);
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchData() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final result = await MenuService.fetchPackages();
//       if (mounted) {
//         setState(() {
//           _data = result;
//           _loading = false;
//         });
//         _applyFilter();
//       }
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//     }
//   }
//
//   void _applyFilter() {
//     var f = [..._data];
//     if (_selectedType != null)
//       f = f.where((p) => p.packageType == _selectedType).toList();
//     if (_searchQuery.isNotEmpty) {
//       final q = _searchQuery.toLowerCase();
//       f = f
//           .map((p) {
//             final pm = p.packageName.toLowerCase().contains(q);
//             final items = p.items
//                 .where(
//                   (i) =>
//                       i.itemName.toLowerCase().contains(q) ||
//                       (i.description?.toLowerCase().contains(q) ?? false),
//                 )
//                 .toList();
//             if (pm || items.isNotEmpty)
//               return MenuPackage(
//                 id: p.id,
//                 packageName: p.packageName,
//                 packageType: p.packageType,
//                 image: p.image,
//                 totalPrice: p.totalPrice,
//                 items: pm ? p.items : items,
//               );
//             return null;
//           })
//           .whereType<MenuPackage>()
//           .toList();
//     }
//     setState(() => _filtered = f);
//   }
//
//   Future<void> _deletePackage(MenuPackage pkg) async {
//     final ok = await showConfirmDialog(
//       context,
//       title: 'Delete Package',
//       message: 'Delete "${pkg.packageName}"? This cannot be undone.',
//     );
//     if (!ok) return;
//     try {
//       await MenuService.deletePackage(pkg.id);
//       await _fetchData();
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to delete package.',
//         );
//     }
//   }
//
//   Future<void> _deleteItem(PackageItem item, int packageId) async {
//     final ok = await showConfirmDialog(
//       context,
//       title: 'Delete Item',
//       message: 'Delete "${item.itemName}"?',
//     );
//     if (!ok) return;
//     try {
//       await MenuService.deletePackageItem(item.id, packageId);
//       await _fetchData();
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to delete item.',
//         );
//     }
//   }
//
//   void _showEditItemSheet(PackageItem item, int packageId) =>
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         useSafeArea: true,
//         backgroundColor: Colors.transparent,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) => _EditItemSheet(
//           item: item,
//           packageId: packageId,
//           onSaved: _fetchData,
//         ),
//       );
//
//   void _showAddPackageSheet() => showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     useSafeArea: true,
//     backgroundColor: Colors.transparent,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) => _AddPackageSheet(onSaved: _fetchData),
//   );
//
//   // String? get _activeFilterLabel {
//   //   switch (_selectedType) {
//   //     case 'Veg':
//   //       return '🟢 Veg';
//   //     case 'Non_veg':
//   //       return '🔴 Non-Veg';
//   //     case 'Drinks':
//   //       return '🔵 Drinks';
//   //     default:
//   //       return null;
//   //   }
//   // }
//
//   Color get _activeFilterColor {
//     switch (_selectedType) {
//       case 'Veg':
//         return _kSuc;
//       case 'Non_veg':
//         return _kDng;
//       case 'Drinks':
//         return _kInf;
//       default:
//         return _kP;
//     }
//   }
//
//   Color get _activeFilterBg {
//     switch (_selectedType) {
//       case 'Veg':
//         return _kSLt;
//       case 'Non_veg':
//         return _kDLt;
//       case 'Drinks':
//         return _kILt;
//       default:
//         return _kPLt;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool filterActive = _filtersExpanded || _selectedType != null;
//     return Column(
//       children: [
//         // ── Filter bar ──────────────────────────────────────────────────────
//         Container(
//           color: _kW,
//           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//           child: Column(
//             children: [
//               // Search row + filter icon button
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: 42,
//                       decoration: BoxDecoration(
//                         color: _kBg,
//                         borderRadius: BorderRadius.circular(11),
//                         border: Border.all(color: _kBrd),
//                       ),
//                       child: TextField(
//                         controller: _searchCtrl,
//                         style: const TextStyle(fontSize: 13, color: _kT1),
//                         onChanged: (v) {
//                           _searchQuery = v;
//                           _applyFilter();
//                           setState(() {});
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Search packages or items...',
//                           hintStyle: const TextStyle(
//                             color: _kMut,
//                             fontSize: 13,
//                           ),
//                           prefixIcon: const Icon(
//                             Icons.search_rounded,
//                             color: _kMut,
//                             size: 18,
//                           ),
//                           suffixIcon: _searchCtrl.text.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(
//                                     Icons.close_rounded,
//                                     size: 16,
//                                     color: _kMut,
//                                   ),
//                                   onPressed: () {
//                                     _searchCtrl.clear();
//                                     _searchQuery = '';
//                                     _applyFilter();
//                                     setState(() {});
//                                   },
//                                 )
//                               : null,
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 11,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   // ── Overlay filter button ──────────────────────────────
//                   CompositedTransformTarget(
//                     link: _filterLayerLink,
//                     child: GestureDetector(
//                       onTap: () => _filtersExpanded
//                           ? _removeFilterOverlay()
//                           : _showFilterOverlay(),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           color: filterActive ? _kPLt : _kBg,
//                           borderRadius: BorderRadius.circular(11),
//                           border: Border.all(
//                             color: filterActive ? _kP : _kBrd,
//                             width: filterActive ? 1.5 : 1,
//                           ),
//                         ),
//                         child: Icon(
//                           Icons.tune_rounded,
//                           size: 18,
//                           color: filterActive ? _kP : _kT2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Active filter chip
//               if (_selectedType != null) ...[
//                 const SizedBox(height: 8),
//                 // Row(
//                 //   children: [
//                 //     _FChip(
//                 //       label: _activeFilterLabel!,
//                 //       active: true,
//                 //       activeColor: _activeFilterColor,
//                 //       activeBg: _activeFilterBg,
//                 //       onTap: () {
//                 //         setState(() => _selectedType = null);
//                 //         _applyFilter();
//                 //       },
//                 //       onClear: () {
//                 //         setState(() => _selectedType = null);
//                 //         _applyFilter();
//                 //       },
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//
//               const SizedBox(height: 8),
//               const Divider(color: _kBrd, height: 1),
//             ],
//           ),
//         ),
//
//         const Divider(color: _kBrd, height: 1),
//
//         // ── Content ─────────────────────────────────────────────────────────
//         Expanded(
//           child: _loading
//               ? const Center(
//                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
//                 )
//               : _error != null
//               ? _ErrWidget(msg: _error!, onRetry: _fetchData)
//               : _filtered.isEmpty
//               ? _EmptyWidget()
//               : RefreshIndicator(
//                   color: _kP,
//                   onRefresh: _fetchData,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
//                     itemCount: _filtered.length,
//                     itemBuilder: (_, i) {
//                       final pkg = _filtered[i];
//                       return _PackageCard(
//                         package: pkg,
//                         isExpanded: _expanded.contains(pkg.id),
//                         onToggleExpand: () => setState(() {
//                           _expanded.contains(pkg.id)
//                               ? _expanded.remove(pkg.id)
//                               : _expanded.add(pkg.id);
//                         }),
//                         onDelete: () => _deletePackage(pkg),
//                         onEditItem: (item) => _showEditItemSheet(item, pkg.id),
//                         onDeleteItem: (item) => _deleteItem(item, pkg.id),
//                       );
//                     },
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }
//
// // ── Filter Dropdown (overlay) ─────────────────────────────────────────────────
// class _FilterDropdown extends StatelessWidget {
//   final String? selectedType;
//   final Function(String?) onSelect;
//
//   const _FilterDropdown({required this.selectedType, required this.onSelect});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 200,
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: _kW,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBrd),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.10),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _DropItem(
//             icon: Icons.apps_rounded,
//             label: 'All',
//             isActive: selectedType == null,
//             activeColor: _kP,
//             activeBg: _kPLt,
//             onTap: () => onSelect(null),
//           ),
//           const SizedBox(height: 3),
//           _DropItem(
//             dotColor: _kSuc,
//             label: 'Veg',
//             isActive: selectedType == 'Veg',
//             activeColor: _kSuc,
//             activeBg: _kSLt,
//             onTap: () => onSelect(selectedType == 'Veg' ? null : 'Veg'),
//           ),
//           const SizedBox(height: 3),
//           _DropItem(
//             dotColor: _kDng,
//             label: 'Non-Veg',
//             isActive: selectedType == 'Non_veg',
//             activeColor: _kDng,
//             activeBg: _kDLt,
//             onTap: () => onSelect(selectedType == 'Non_veg' ? null : 'Non_veg'),
//           ),
//           const SizedBox(height: 3),
//           _DropItem(
//             dotColor: _kInf,
//             label: 'Drinks',
//             isActive: selectedType == 'Drinks',
//             activeColor: _kInf,
//             activeBg: _kILt,
//             onTap: () => onSelect(selectedType == 'Drinks' ? null : 'Drinks'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DropItem extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final Color activeColor, activeBg;
//   final VoidCallback onTap;
//   final IconData? icon;
//   final Color? dotColor;
//
//   const _DropItem({
//     required this.label,
//     required this.isActive,
//     required this.activeColor,
//     required this.activeBg,
//     required this.onTap,
//     this.icon,
//     this.dotColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           color: isActive ? activeBg : Colors.transparent,
//           borderRadius: BorderRadius.circular(9),
//         ),
//         child: Row(
//           children: [
//             if (dotColor != null)
//               Container(
//                 width: 9,
//                 height: 9,
//                 decoration: BoxDecoration(
//                   color: dotColor,
//                   shape: BoxShape.circle,
//                 ),
//               )
//             else
//               Icon(icon, size: 15, color: isActive ? activeColor : _kT2),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: isActive ? activeColor : _kT1,
//                 ),
//               ),
//             ),
//             if (isActive)
//               Icon(Icons.check_rounded, size: 14, color: activeColor),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Active filter chip ────────────────────────────────────────────────────────
// class _FChip extends StatelessWidget {
//   final String label;
//   final bool active;
//   final Color? activeColor, activeBg;
//   final VoidCallback onTap;
//   final VoidCallback? onClear;
//
//   const _FChip({
//     required this.label,
//     required this.active,
//     required this.onTap,
//     this.activeColor,
//     this.activeBg,
//     this.onClear,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = activeColor ?? _kP;
//     final bg = activeBg ?? _kPLt;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: active ? bg : _kBg,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: active ? color.withOpacity(0.4) : _kBrd,
//             width: active ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: active ? color : _kT2,
//               ),
//             ),
//             if (onClear != null) ...[
//               const SizedBox(width: 4),
//               GestureDetector(
//                 onTap: onClear,
//                 child: Icon(Icons.close_rounded, size: 11, color: color),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Error / Empty states ─────────────────────────────────────────────────────
// class _ErrWidget extends StatelessWidget {
//   final String msg;
//   final VoidCallback onRetry;
//   const _ErrWidget({required this.msg, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(28),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
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
//             'Failed to load packages',
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
//
// class _EmptyWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 68,
//           height: 68,
//           decoration: BoxDecoration(
//             gradient: _kGrd,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: _kP.withOpacity(0.3),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
//         ),
//         const SizedBox(height: 14),
//         const Text(
//           'No packages found',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             color: _kT1,
//           ),
//         ),
//         const SizedBox(height: 5),
//         const Text(
//           'Tap Add Package to create one',
//           style: TextStyle(fontSize: 12, color: _kT2),
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Package Card ───────────────────────────────────────────────────────────────
// class _PackageCard extends StatelessWidget {
//   final MenuPackage package;
//   final bool isExpanded;
//   final VoidCallback onToggleExpand, onDelete;
//   final Function(PackageItem) onEditItem, onDeleteItem;
//
//   const _PackageCard({
//     required this.package,
//     required this.isExpanded,
//     required this.onToggleExpand,
//     required this.onDelete,
//     required this.onEditItem,
//     required this.onDeleteItem,
//   });
//
//   Color get _tc {
//     switch (package.packageType) {
//       case 'Veg':
//         return _kSuc;
//       case 'Non_veg':
//         return _kDng;
//       default:
//         return _kInf;
//     }
//   }
//
//   Color get _tb {
//     switch (package.packageType) {
//       case 'Veg':
//         return _kSLt;
//       case 'Non_veg':
//         return _kDLt;
//       default:
//         return _kILt;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => AnimatedContainer(
//     duration: const Duration(milliseconds: 250),
//     margin: const EdgeInsets.only(bottom: 10),
//     decoration: BoxDecoration(
//       color: _kW,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(
//         color: isExpanded ? _tc.withOpacity(0.25) : _kBrd,
//         width: isExpanded ? 1.5 : 1,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: isExpanded ? _tc.withOpacity(0.08) : _kShd,
//           blurRadius: isExpanded ? 12 : 8,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(15),
//       child: Column(
//         children: [
//           // Header
//           GestureDetector(
//             onTap: onToggleExpand,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
//               decoration: BoxDecoration(
//                 color: isExpanded ? _tb.withOpacity(0.35) : _kW,
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       width: 52,
//                       height: 52,
//                       color: _kBg,
//                       child: package.image != null && package.image!.isNotEmpty
//                           ? Image.network(
//                               package.image!,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Icon(
//                                 Icons.inventory_2_rounded,
//                                 color: _kMut,
//                                 size: 22,
//                               ),
//                             )
//                           : const Icon(
//                               Icons.inventory_2_rounded,
//                               color: _kMut,
//                               size: 22,
//                             ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           package.packageName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                             color: _kT1,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _tb,
//                                 borderRadius: BorderRadius.circular(6),
//                                 border: Border.all(color: _tc.withOpacity(0.2)),
//                               ),
//                               child: Text(
//                                 package.packageType == 'Non_veg'
//                                     ? 'Non-Veg'
//                                     : package.packageType,
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: _tc,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               '${package.items.length} item${package.items.length == 1 ? '' : 's'}',
//                               style: const TextStyle(fontSize: 11, color: _kT2),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '₹${package.computedTotal.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w900,
//                           color: _tc,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           GestureDetector(
//                             onTap: onDelete,
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: _kDLt,
//                                 borderRadius: BorderRadius.circular(7),
//                               ),
//                               child: const Icon(
//                                 Icons.delete_outline_rounded,
//                                 size: 15,
//                                 color: _kDng,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           AnimatedRotation(
//                             turns: isExpanded ? 0.5 : 0,
//                             duration: const Duration(milliseconds: 250),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: isExpanded ? _tc : _kMut,
//                               size: 22,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Expandable items
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 250),
//             sizeCurve: Curves.easeInOut,
//             crossFadeState: isExpanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             firstChild: const SizedBox.shrink(),
//             secondChild: Column(
//               children: [
//                 Divider(
//                   color: _kBrd.withOpacity(0.7),
//                   height: 1,
//                   indent: 12,
//                   endIndent: 12,
//                 ),
//                 if (package.items.isEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Center(
//                       child: Text(
//                         'No items in this package',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: _kMut,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   ...package.items.asMap().entries.map(
//                     (e) => _ItemRow(
//                       item: e.value,
//                       index: e.key,
//                       isLast: e.key == package.items.length - 1,
//                       onEdit: () => onEditItem(e.value),
//                       onDelete: () => onDeleteItem(e.value),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ── Item Row ───────────────────────────────────────────────────────────────────
// class _ItemRow extends StatelessWidget {
//   final PackageItem item;
//   final int index;
//   final VoidCallback onEdit, onDelete;
//   final bool isLast;
//
//   const _ItemRow({
//     required this.item,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//     this.isLast = false,
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
//         child: Row(
//           children: [
//             Container(
//               width: 2,
//               height: 36,
//               margin: const EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: _kP.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.itemName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13,
//                       color: _kT1,
//                     ),
//                   ),
//                   if (item.description != null && item.description!.isNotEmpty)
//                     Text(
//                       item.description!,
//                       style: const TextStyle(fontSize: 11, color: _kT2),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                 ],
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.only(right: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: _kPLt,
//                 borderRadius: BorderRadius.circular(7),
//               ),
//               child: Text(
//                 '₹${item.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   color: _kP,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: onEdit,
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: _kILt,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
//               ),
//             ),
//             const SizedBox(width: 6),
//             GestureDetector(
//               onTap: onDelete,
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: _kDLt,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(
//                   Icons.delete_outline_rounded,
//                   size: 14,
//                   color: _kDng,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       if (!isLast)
//         Divider(
//           color: _kBrd.withOpacity(0.5),
//           height: 1,
//           indent: 16,
//           endIndent: 12,
//         ),
//     ],
//   );
// }
//
// // ── Edit Item Sheet ────────────────────────────────────────────────────────────
// class _EditItemSheet extends StatefulWidget {
//   final PackageItem item;
//   final int packageId;
//   final VoidCallback onSaved;
//   const _EditItemSheet({
//     required this.item,
//     required this.packageId,
//     required this.onSaved,
//   });
//   @override
//   State<_EditItemSheet> createState() => __EditItemSheetState();
// }
//
// class __EditItemSheetState extends State<_EditItemSheet> {
//   late final TextEditingController _nameCtrl, _priceCtrl;
//   bool _saving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.item.itemName);
//     _priceCtrl = TextEditingController(
//       text: widget.item.price.toStringAsFixed(0),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _priceCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (_nameCtrl.text.trim().isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter an item name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final updated = widget.item.copyWith(
//         itemName: _nameCtrl.text.trim(),
//         price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
//       );
//       await MenuService.updatePackageItem(updated, widget.packageId);
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to update item.',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => SafeArea(
//     child: Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _Handle(),
//             Row(
//               children: [
//                 Container(
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: _kPLt,
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Edit Item',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: _kT1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
//             const SizedBox(height: 10),
//             _Field(
//               _priceCtrl,
//               'Price (₹)',
//               Icons.currency_rupee_rounded,
//               type: TextInputType.number,
//             ),
//             const SizedBox(height: 20),
//             _SaveRow(
//               () => Navigator.pop(context),
//               _saving ? null : _save,
//               'Save Item',
//               _saving,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Add Package Sheet ──────────────────────────────────────────────────────────
// class _AddPackageSheet extends StatefulWidget {
//   final VoidCallback onSaved;
//   const _AddPackageSheet({required this.onSaved});
//   @override
//   State<_AddPackageSheet> createState() => __AddPackageSheetState();
// }
//
// class __AddPackageSheetState extends State<_AddPackageSheet> {
//   final _nameCtrl = TextEditingController();
//   String _type = 'Veg';
//   final List<Map<String, TextEditingController>> _items = [];
//   bool _saving = false;
//   File? _imageFile;
//
//   @override
//   void initState() {
//     super.initState();
//     _addItem();
//   }
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 1024,
//       maxHeight: 1024,
//     );
//     if (picked != null && mounted)
//       setState(() => _imageFile = File(picked.path));
//   }
//
//   void _addItem() {
//     _items.add({
//       'name': TextEditingController(),
//       'price': TextEditingController(),
//     });
//     setState(() {});
//   }
//
//   void _removeItem(int i) {
//     _items[i]['name']!.dispose();
//     _items[i]['price']!.dispose();
//     _items.removeAt(i);
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     for (final item in _items) {
//       item['name']!.dispose();
//       item['price']!.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (_nameCtrl.text.trim().isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter a package name.',
//       );
//       return;
//     }
//     final valid = _items
//         .where(
//           (i) =>
//               i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
//         )
//         .map(
//           (i) => PackageItem(
//             id: 0,
//             itemName: i['name']!.text.trim(),
//             price: double.tryParse(i['price']!.text) ?? 0,
//           ),
//         )
//         .toList();
//     if (valid.isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Items Required',
//         message: 'Please add at least one valid item.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final pkg = MenuPackage(
//         id: 0,
//         packageName: _nameCtrl.text.trim(),
//         packageType: _type,
//         totalPrice: valid.fold(0, (s, i) => s + i.price),
//         items: valid,
//       );
//       // CHANGED: Pass imageFile directly
//       await MenuService.addPackage(
//         pkg: pkg,
//         imageFile: _imageFile, // Changed from imageBytes
//         // imageFileName removed
//       );
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to add package.',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => SafeArea(
//     child: Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _Handle(),
//               Row(
//                 children: [
//                   Container(
//                     width: 34,
//                     height: 34,
//                     decoration: BoxDecoration(
//                       color: _kPLt,
//                       borderRadius: BorderRadius.circular(9),
//                     ),
//                     child: const Icon(
//                       Icons.inventory_2_rounded,
//                       color: _kP,
//                       size: 17,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Add New Package',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: _kT1,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
//               const SizedBox(height: 10),
//               // Type dropdown
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Package Type',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: _kBg,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _kBrd),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _type,
//                         isExpanded: true,
//                         icon: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: _kP,
//                           size: 18,
//                         ),
//                         style: const TextStyle(fontSize: 13, color: _kT1),
//                         onChanged: (v) => setState(() => _type = v ?? 'Veg'),
//                         items: const [
//                           DropdownMenuItem(value: 'Veg', child: Text('Veg')),
//                           DropdownMenuItem(
//                             value: 'Non_veg',
//                             child: Text('Non-Veg'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Drinks',
//                             child: Text('Drinks'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               // Image picker
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Package Image (optional)',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       height: 110,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: _kBg,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _imageFile != null ? _kP : _kBrd,
//                           width: _imageFile != null ? 1.5 : 1,
//                         ),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(11),
//                         child: _imageFile != null
//                             ? Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Image.file(_imageFile!, fit: BoxFit.cover),
//                                   Positioned(
//                                     bottom: 0,
//                                     left: 0,
//                                     right: 0,
//                                     child: Container(
//                                       color: Colors.black54,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 5,
//                                       ),
//                                       child: const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.camera_alt_rounded,
//                                             color: _kW,
//                                             size: 13,
//                                           ),
//                                           SizedBox(width: 5),
//                                           Text(
//                                             'Tap to change',
//                                             style: TextStyle(
//                                               color: _kW,
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.add_photo_alternate_outlined,
//                                     color: _kMut,
//                                     size: 32,
//                                   ),
//                                   SizedBox(height: 6),
//                                   Text(
//                                     'Tap to upload image',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: _kMut,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Text(
//                                     'JPG, PNG • Max 5MB',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: _kBrd,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               // Items header
//               Row(
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: _kT1,
//                     ),
//                   ),
//                   const Spacer(),
//                   GestureDetector(
//                     onTap: _addItem,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _kPLt,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.add_rounded, color: _kP, size: 13),
//                           SizedBox(width: 4),
//                           Text(
//                             'Add Item',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: _kP,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               ..._items.asMap().entries.map(
//                 (e) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: _TF(e.value['name']!, 'Item name'),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         flex: 2,
//                         child: _TF(
//                           e.value['price']!,
//                           '₹ Price',
//                           TextInputType.number,
//                         ),
//                       ),
//                       if (_items.length > 1) ...[
//                         const SizedBox(width: 6),
//                         GestureDetector(
//                           onTap: () => _removeItem(e.key),
//                           child: Container(
//                             padding: const EdgeInsets.all(7),
//                             decoration: BoxDecoration(
//                               color: _kDLt,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.close_rounded,
//                               size: 14,
//                               color: _kDng,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 18),
//               _SaveRow(
//                 () => Navigator.pop(context),
//                 _saving ? null : _save,
//                 'Save Package',
//                 _saving,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Shared bottom sheet helpers ────────────────────────────────────────────────
// class _Handle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Container(
//       width: 36,
//       height: 4,
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: _kBrd,
//         borderRadius: BorderRadius.circular(2),
//       ),
//     ),
//   );
// }
//
// class _Field extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final IconData icon;
//   final TextInputType type;
//   const _Field(
//     this.ctrl,
//     this.hint,
//     this.icon, {
//     this.type = TextInputType.text,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: _kBg,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: _kBrd),
//     ),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: type,
//       style: const TextStyle(fontSize: 13, color: _kT1),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//         prefixIcon: Icon(icon, color: _kP, size: 17),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
//       ),
//     ),
//   );
// }
//
// class _TF extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final TextInputType type;
//   const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);
//
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: _kBg,
//       borderRadius: BorderRadius.circular(9),
//       border: Border.all(color: _kBrd),
//     ),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: type,
//       style: const TextStyle(fontSize: 13, color: _kT1),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 10,
//           vertical: 10,
//         ),
//       ),
//     ),
//   );
// }
//
// class _SaveRow extends StatelessWidget {
//   final VoidCallback onCancel;
//   final VoidCallback? onSave;
//   final String label;
//   final bool saving;
//   const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);
//
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Expanded(
//         child: GestureDetector(
//           onTap: onCancel,
//           child: Container(
//             height: 44,
//             decoration: BoxDecoration(
//               color: _kBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _kBrd),
//             ),
//             child: const Center(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: _kT2,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(width: 10),
//       Expanded(
//         child: GestureDetector(
//           onTap: onSave,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             height: 44,
//             decoration: BoxDecoration(
//               gradient: onSave != null ? _kGrd : null,
//               color: onSave == null ? _kBrd : null,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: onSave != null
//                   ? [
//                       BoxShadow(
//                         color: _kP.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Center(
//               child: saving
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         color: _kW,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       label,
//                       style: const TextStyle(
//                         color: _kW,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
// //
// // import 'package:flutter/material.dart';
// // import '../models/models.dart';
// // import '../services/api_service.dart';
// // import '../widgets/common_widgets.dart';
// //
// // const _kW = Color(0xFFFFFFFF);
// // const _kBg = Color(0xFFF7F8FC);
// // const _kBrd = Color(0xFFEEEFF5);
// // const _kP = Color(0xFFF97316);
// // const _kPDk = Color(0xFFC2510F);
// // const _kPLt = Color(0xFFFFF0E6);
// // const _kSuc = Color(0xFF10B981);
// // const _kSLt = Color(0xFFD1FAE5);
// // const _kSDk = Color(0xFF059669);
// // const _kDng = Color(0xFFEF4444);
// // const _kDLt = Color(0xFFFEE2E2);
// // const _kInf = Color(0xFF3B82F6);
// // const _kILt = Color(0xFFDBEAFE);
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
// // class PackagesTab extends StatefulWidget {
// //   const PackagesTab({super.key});
// //   @override
// //   State<PackagesTab> createState() => PackagesTabState();
// // }
// //
// // class PackagesTabState extends State<PackagesTab> {
// //   List<MenuPackage> _data = [];
// //   List<MenuPackage> _filtered = [];
// //   bool _loading = true;
// //   String? _error;
// //   final _searchCtrl = TextEditingController();
// //   String _searchQuery = '';
// //   String? _selectedType;
// //   String? _selectedPackage;
// //   final Set<int> _expanded = {};
// //
// //   void openAddCategory() {
// //     _showAddPackageSheet();
// //   }
// //
// //   void enableBulkMode() {
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchData();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _fetchData() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final result = await ApiService.fetchPackages();
// //       if (mounted) {
// //         setState(() {
// //           _data = result;
// //           _loading = false;
// //         });
// //         _applyFilter();
// //       }
// //     } catch (e) {
// //       if (mounted)
// //         setState(() {
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //     }
// //   }
// //
// //   void _applyFilter() {
// //     var f = [..._data];
// //     if (_selectedType != null)
// //       f = f.where((p) => p.packageType == _selectedType).toList();
// //     if (_selectedPackage != null)
// //       f = f.where((p) => p.packageName == _selectedPackage).toList();
// //     if (_searchQuery.isNotEmpty) {
// //       final q = _searchQuery.toLowerCase();
// //       f = f
// //           .map((p) {
// //             final pm = p.packageName.toLowerCase().contains(q);
// //             final items = p.items
// //                 .where(
// //                   (i) =>
// //                       i.itemName.toLowerCase().contains(q) ||
// //                       (i.description?.toLowerCase().contains(q) ?? false),
// //                 )
// //                 .toList();
// //             if (pm || items.isNotEmpty)
// //               return MenuPackage(
// //                 id: p.id,
// //                 packageName: p.packageName,
// //                 packageType: p.packageType,
// //                 image: p.image,
// //                 totalPrice: p.totalPrice,
// //                 items: pm ? p.items : items,
// //               );
// //             return null;
// //           })
// //           .whereType<MenuPackage>()
// //           .toList();
// //     }
// //     setState(() => _filtered = f);
// //   }
// //
// //   Future<void> _deletePackage(MenuPackage pkg) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Package',
// //       message: 'Delete "${pkg.packageName}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await ApiService.deletePackage(pkg.id);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete package.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteItem(PackageItem item, int packageId) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Item',
// //       message: 'Delete "${item.itemName}"?',
// //     );
// //     if (!ok) return;
// //     try {
// //       await ApiService.deletePackageItem(item.id, packageId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete item.',
// //         );
// //     }
// //   }
// //
// //   void _showEditItemSheet(PackageItem item, int packageId) =>
// //       showModalBottomSheet(
// //         context: context,
// //         isScrollControlled: true,
// //         useSafeArea: true,
// //         backgroundColor: Colors.transparent,
// //         shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         builder: (_) => _EditItemSheet(
// //           item: item,
// //           packageId: packageId,
// //           onSaved: _fetchData,
// //         ),
// //       );
// //
// //   void _showAddPackageSheet() => showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     useSafeArea: true,
// //     backgroundColor: Colors.transparent,
// //     shape: const RoundedRectangleBorder(
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //     ),
// //     builder: (_) => _AddPackageSheet(onSaved: _fetchData),
// //   );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // ── Filter bar ──────────────────────────────────────────────────────
// //         Container(
// //           color: _kW,
// //           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
// //           child: Column(
// //             children: [
// //               Container(
// //                 height: 42,
// //                 decoration: BoxDecoration(
// //                   color: _kBg,
// //                   borderRadius: BorderRadius.circular(11),
// //                   border: Border.all(color: _kBrd),
// //                 ),
// //                 child: TextField(
// //                   controller: _searchCtrl,
// //                   style: const TextStyle(fontSize: 13, color: _kT1),
// //                   onChanged: (v) {
// //                     _searchQuery = v;
// //                     _applyFilter();
// //                     setState(() {});
// //                   },
// //                   decoration: InputDecoration(
// //                     hintText: 'Search packages or items...',
// //                     hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //                     prefixIcon: const Icon(
// //                       Icons.search_rounded,
// //                       color: _kMut,
// //                       size: 18,
// //                     ),
// //                     suffixIcon: _searchCtrl.text.isNotEmpty
// //                         ? IconButton(
// //                             icon: const Icon(
// //                               Icons.close_rounded,
// //                               size: 16,
// //                               color: _kMut,
// //                             ),
// //                             onPressed: () {
// //                               _searchCtrl.clear();
// //                               _searchQuery = '';
// //                               _applyFilter();
// //                               setState(() {});
// //                             },
// //                           )
// //                         : null,
// //                     border: InputBorder.none,
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 11),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               SingleChildScrollView(
// //                 scrollDirection: Axis.horizontal,
// //                 child: Row(
// //                   children: [
// //                     for (final e in [
// //                       _TEntry(null, 'All', _kP, _kPLt),
// //                       _TEntry('Veg', '🟢 Veg', _kSuc, _kSLt),
// //                       _TEntry('Non_veg', '🔴 Non-Veg', _kDng, _kDLt),
// //                       _TEntry('Drinks', '🔵 Drinks', _kInf, _kILt),
// //                     ]) ...[
// //                       _TypeChip(
// //                         e: e,
// //                         active: _selectedType == e.type,
// //                         onTap: () {
// //                           setState(() => _selectedType = e.type);
// //                           _applyFilter();
// //                         },
// //                       ),
// //                       const SizedBox(width: 6),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               const Divider(color: _kBrd, height: 1),
// //             ],
// //           ),
// //         ),
// //
// //         const Divider(color: _kBrd, height: 1),
// //         // ── Content ─────────────────────────────────────────────────────────
// //         Expanded(
// //           child: _loading
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
// //                 )
// //               : _error != null
// //               ? _ErrWidget(msg: _error!, onRetry: _fetchData)
// //               : _filtered.isEmpty
// //               ? _EmptyWidget()
// //               : RefreshIndicator(
// //                   color: _kP,
// //                   onRefresh: _fetchData,
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
// //                     itemCount: _filtered.length,
// //                     itemBuilder: (_, i) {
// //                       final pkg = _filtered[i];
// //                       return _PackageCard(
// //                         package: pkg,
// //                         isExpanded: _expanded.contains(pkg.id),
// //                         onToggleExpand: () => setState(() {
// //                           _expanded.contains(pkg.id)
// //                               ? _expanded.remove(pkg.id)
// //                               : _expanded.add(pkg.id);
// //                         }),
// //                         onDelete: () => _deletePackage(pkg),
// //                         onEditItem: (item) => _showEditItemSheet(item, pkg.id),
// //                         onDeleteItem: (item) => _deleteItem(item, pkg.id),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class _TEntry {
// //   final String? type;
// //   final String label;
// //   final Color color, bg;
// //   const _TEntry(this.type, this.label, this.color, this.bg);
// // }
// //
// // class _TypeChip extends StatelessWidget {
// //   final _TEntry e;
// //   final bool active;
// //   final VoidCallback onTap;
// //   const _TypeChip({required this.e, required this.active, required this.onTap});
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: AnimatedContainer(
// //       duration: const Duration(milliseconds: 200),
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: active ? e.bg : _kBg,
// //         borderRadius: BorderRadius.circular(9),
// //         border: Border.all(
// //           color: active ? e.color.withOpacity(0.4) : _kBrd,
// //           width: active ? 1.5 : 1,
// //         ),
// //       ),
// //       child: Text(
// //         e.label,
// //         style: TextStyle(
// //           fontSize: 11,
// //           fontWeight: FontWeight.w700,
// //           color: active ? e.color : _kT2,
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _ErrWidget extends StatelessWidget {
// //   final String msg;
// //   final VoidCallback onRetry;
// //   const _ErrWidget({required this.msg, required this.onRetry});
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(28),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
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
// //             'Failed to load packages',
// //             style: TextStyle(
// //               fontSize: 15,
// //               fontWeight: FontWeight.w700,
// //               color: _kT1,
// //             ),
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
// //
// // class _EmptyWidget extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Container(
// //           width: 68,
// //           height: 68,
// //           decoration: BoxDecoration(
// //             gradient: _kGrd,
// //             shape: BoxShape.circle,
// //             boxShadow: [
// //               BoxShadow(
// //                 color: _kP.withOpacity(0.3),
// //                 blurRadius: 16,
// //                 offset: const Offset(0, 6),
// //               ),
// //             ],
// //           ),
// //           child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
// //         ),
// //         const SizedBox(height: 14),
// //         const Text(
// //           'No packages found',
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.w700,
// //             color: _kT1,
// //           ),
// //         ),
// //         const SizedBox(height: 5),
// //         const Text(
// //           'Tap Add Package to create one',
// //           style: TextStyle(fontSize: 12, color: _kT2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Package Card ───────────────────────────────────────────────────────────────
// // class _PackageCard extends StatelessWidget {
// //   final MenuPackage package;
// //   final bool isExpanded;
// //   final VoidCallback onToggleExpand, onDelete;
// //   final Function(PackageItem) onEditItem, onDeleteItem;
// //   const _PackageCard({
// //     required this.package,
// //     required this.isExpanded,
// //     required this.onToggleExpand,
// //     required this.onDelete,
// //     required this.onEditItem,
// //     required this.onDeleteItem,
// //   });
// //
// //   Color get _tc {
// //     switch (package.packageType) {
// //       case 'Veg':
// //         return _kSuc;
// //       case 'Non_veg':
// //         return _kDng;
// //       default:
// //         return _kInf;
// //     }
// //   }
// //
// //   Color get _tb {
// //     switch (package.packageType) {
// //       case 'Veg':
// //         return _kSLt;
// //       case 'Non_veg':
// //         return _kDLt;
// //       default:
// //         return _kILt;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: isExpanded ? _tc.withOpacity(0.2) : _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     ),
// //     child: Column(
// //       children: [
// //         GestureDetector(
// //           onTap: onToggleExpand,
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Row(
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(10),
// //                   child: Container(
// //                     width: 52,
// //                     height: 52,
// //                     color: _kBg,
// //                     child: package.image != null && package.image!.isNotEmpty
// //                         ? Image.network(
// //                             package.image!,
// //                             fit: BoxFit.cover,
// //                             errorBuilder: (_, __, ___) => const Icon(
// //                               Icons.inventory_2_rounded,
// //                               color: _kMut,
// //                               size: 22,
// //                             ),
// //                           )
// //                         : const Icon(
// //                             Icons.inventory_2_rounded,
// //                             color: _kMut,
// //                             size: 22,
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         package.packageName,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 14,
// //                           color: _kT1,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         children: [
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 2,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: _tb,
// //                               borderRadius: BorderRadius.circular(6),
// //                               border: Border.all(color: _tc.withOpacity(0.2)),
// //                             ),
// //                             child: Text(
// //                               package.packageType == 'Non_veg'
// //                                   ? 'Non-Veg'
// //                                   : package.packageType,
// //                               style: TextStyle(
// //                                 fontSize: 10,
// //                                 color: _tc,
// //                                 fontWeight: FontWeight.w700,
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 8),
// //                           Text(
// //                             '${package.items.length} items',
// //                             style: const TextStyle(fontSize: 11, color: _kT2),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       '₹${package.computedTotal.toStringAsFixed(0)}',
// //                       style: const TextStyle(
// //                         fontSize: 17,
// //                         fontWeight: FontWeight.w900,
// //                         color: _kP,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         GestureDetector(
// //                           onTap: onDelete,
// //                           child: Container(
// //                             padding: const EdgeInsets.all(6),
// //                             decoration: BoxDecoration(
// //                               color: _kDLt,
// //                               borderRadius: BorderRadius.circular(7),
// //                             ),
// //                             child: const Icon(
// //                               Icons.delete_outline_rounded,
// //                               size: 15,
// //                               color: _kDng,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 6),
// //                         AnimatedRotation(
// //                           turns: isExpanded ? 0.5 : 0,
// //                           duration: const Duration(milliseconds: 200),
// //                           child: Icon(
// //                             Icons.keyboard_arrow_down_rounded,
// //                             color: isExpanded ? _kP : _kMut,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         if (isExpanded) ...[
// //           Divider(
// //             color: _kBrd.withOpacity(0.6),
// //             height: 1,
// //             indent: 12,
// //             endIndent: 12,
// //           ),
// //           if (package.items.isEmpty)
// //             Padding(
// //               padding: const EdgeInsets.all(14),
// //               child: Center(
// //                 child: Text(
// //                   'No items',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _kMut,
// //                     fontStyle: FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...package.items.asMap().entries.map(
// //               (e) => _ItemRow(
// //                 item: e.value,
// //                 index: e.key,
// //                 onEdit: () => onEditItem(e.value),
// //                 onDelete: () => onDeleteItem(e.value),
// //                 isLast: e.key == package.items.length - 1,
// //               ),
// //             ),
// //         ],
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Item Row ───────────────────────────────────────────────────────────────────
// // class _ItemRow extends StatelessWidget {
// //   final PackageItem item;
// //   final int index;
// //   final VoidCallback onEdit, onDelete;
// //   final bool isLast;
// //   const _ItemRow({
// //     required this.item,
// //     required this.index,
// //     required this.onEdit,
// //     required this.onDelete,
// //     this.isLast = false,
// //   });
// //   @override
// //   Widget build(BuildContext context) => Column(
// //     children: [
// //       Padding(
// //         padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 2,
// //               height: 36,
// //               margin: const EdgeInsets.only(right: 10),
// //               decoration: BoxDecoration(
// //                 color: _kP.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     item.itemName,
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 13,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                   if (item.description != null && item.description!.isNotEmpty)
// //                     Text(
// //                       item.description!,
// //                       style: const TextStyle(fontSize: 11, color: _kT2),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             Text(
// //               '₹${item.price.toStringAsFixed(0)}',
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.w800,
// //                 color: _kP,
// //                 fontSize: 13,
// //               ),
// //             ),
// //             const SizedBox(width: 10),
// //             GestureDetector(
// //               onTap: onEdit,
// //               child: Container(
// //                 padding: const EdgeInsets.all(6),
// //                 decoration: BoxDecoration(
// //                   color: _kILt,
// //                   borderRadius: BorderRadius.circular(6),
// //                 ),
// //                 child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
// //               ),
// //             ),
// //             const SizedBox(width: 6),
// //             GestureDetector(
// //               onTap: onDelete,
// //               child: Container(
// //                 padding: const EdgeInsets.all(6),
// //                 decoration: BoxDecoration(
// //                   color: _kDLt,
// //                   borderRadius: BorderRadius.circular(6),
// //                 ),
// //                 child: const Icon(
// //                   Icons.delete_outline_rounded,
// //                   size: 14,
// //                   color: _kDng,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       if (!isLast)
// //         Divider(
// //           color: _kBrd.withOpacity(0.5),
// //           height: 1,
// //           indent: 16,
// //           endIndent: 12,
// //         ),
// //     ],
// //   );
// // }
// //
// // // ── Edit Item Sheet ────────────────────────────────────────────────────────────
// // class _EditItemSheet extends StatefulWidget {
// //   final PackageItem item;
// //   final int packageId;
// //   final VoidCallback onSaved;
// //   const _EditItemSheet({
// //     required this.item,
// //     required this.packageId,
// //     required this.onSaved,
// //   });
// //   @override
// //   State<_EditItemSheet> createState() => __EditItemSheetState();
// // }
// //
// // class __EditItemSheetState extends State<_EditItemSheet> {
// //   late final TextEditingController _nameCtrl, _priceCtrl;
// //   bool _saving = false;
// //   @override
// //   void initState() {
// //     super.initState();
// //     _nameCtrl = TextEditingController(text: widget.item.itemName);
// //     _priceCtrl = TextEditingController(
// //       text: widget.item.price.toStringAsFixed(0),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     _priceCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     if (_nameCtrl.text.trim().isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Required',
// //         message: 'Please enter an item name.',
// //       );
// //       return;
// //     }
// //     setState(() => _saving = true);
// //     try {
// //       final updated = widget.item.copyWith(
// //         itemName: _nameCtrl.text.trim(),
// //         price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
// //       );
// //       await ApiService.updatePackageItem(updated, widget.packageId);
// //       widget.onSaved();
// //       if (mounted) Navigator.pop(context);
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to update item.',
// //         );
// //     } finally {
// //       if (mounted) setState(() => _saving = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Padding(
// //       // SafeArea handles home indicator; viewInsets.bottom handles keyboard
// //       padding: EdgeInsets.only(
// //         bottom: MediaQuery.of(context).viewInsets.bottom,
// //       ),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _Handle(),
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 34,
// //                   height: 34,
// //                   decoration: BoxDecoration(
// //                     color: _kPLt,
// //                     borderRadius: BorderRadius.circular(9),
// //                   ),
// //                   child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 const Text(
// //                   'Edit Item',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w800,
// //                     color: _kT1,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
// //             const SizedBox(height: 10),
// //             _Field(
// //               _priceCtrl,
// //               'Price (₹)',
// //               Icons.currency_rupee_rounded,
// //               type: TextInputType.number,
// //             ),
// //             const SizedBox(height: 20),
// //             _SaveRow(
// //               () => Navigator.pop(context),
// //               _saving ? null : _save,
// //               'Save Item',
// //               _saving,
// //             ),
// //           ],
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // // ── Add Package Sheet ──────────────────────────────────────────────────────────
// // class _AddPackageSheet extends StatefulWidget {
// //   final VoidCallback onSaved;
// //   const _AddPackageSheet({required this.onSaved});
// //   @override
// //   State<_AddPackageSheet> createState() => __AddPackageSheetState();
// // }
// //
// // class __AddPackageSheetState extends State<_AddPackageSheet> {
// //   final _nameCtrl = TextEditingController();
// //   String _type = 'Veg';
// //   final List<Map<String, TextEditingController>> _items = [];
// //   bool _saving = false;
// //   @override
// //   void initState() {
// //     super.initState();
// //     _addItem();
// //   }
// //
// //   void _addItem() {
// //     _items.add({
// //       'name': TextEditingController(),
// //       'price': TextEditingController(),
// //     });
// //     setState(() {});
// //   }
// //
// //   void _removeItem(int i) {
// //     _items[i]['name']!.dispose();
// //     _items[i]['price']!.dispose();
// //     _items.removeAt(i);
// //     setState(() {});
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     for (final item in _items) {
// //       item['name']!.dispose();
// //       item['price']!.dispose();
// //     }
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     if (_nameCtrl.text.trim().isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Required',
// //         message: 'Please enter a package name.',
// //       );
// //       return;
// //     }
// //     final valid = _items
// //         .where(
// //           (i) =>
// //               i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
// //         )
// //         .map(
// //           (i) => PackageItem(
// //             id: 0,
// //             itemName: i['name']!.text.trim(),
// //             price: double.tryParse(i['price']!.text) ?? 0,
// //           ),
// //         )
// //         .toList();
// //     if (valid.isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'Items Required',
// //         message: 'Please add at least one valid item.',
// //       );
// //       return;
// //     }
// //     setState(() => _saving = true);
// //     try {
// //       final pkg = MenuPackage(
// //         id: 0,
// //         packageName: _nameCtrl.text.trim(),
// //         packageType: _type,
// //         totalPrice: valid.fold(0, (s, i) => s + i.price),
// //         items: valid,
// //       );
// //       await ApiService.addPackage(pkg: pkg);
// //       widget.onSaved();
// //       if (mounted) Navigator.pop(context);
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to add package.',
// //         );
// //     } finally {
// //       if (mounted) setState(() => _saving = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Padding(
// //       padding: EdgeInsets.only(
// //         bottom: MediaQuery.of(context).viewInsets.bottom,
// //       ),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               _Handle(),
// //               Row(
// //                 children: [
// //                   Container(
// //                     width: 34,
// //                     height: 34,
// //                     decoration: BoxDecoration(
// //                       color: _kPLt,
// //                       borderRadius: BorderRadius.circular(9),
// //                     ),
// //                     child: const Icon(
// //                       Icons.inventory_2_rounded,
// //                       color: _kP,
// //                       size: 17,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'Add New Package',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w800,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
// //               const SizedBox(height: 10),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Package Type',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                       color: _kT2,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// //                     decoration: BoxDecoration(
// //                       color: _kBg,
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: _kBrd),
// //                     ),
// //                     child: DropdownButtonHideUnderline(
// //                       child: DropdownButton<String>(
// //                         value: _type,
// //                         isExpanded: true,
// //                         icon: const Icon(
// //                           Icons.keyboard_arrow_down_rounded,
// //                           color: _kP,
// //                           size: 18,
// //                         ),
// //                         style: const TextStyle(fontSize: 13, color: _kT1),
// //                         onChanged: (v) => setState(() => _type = v ?? 'Veg'),
// //                         items: const [
// //                           DropdownMenuItem(value: 'Veg', child: Text('Veg')),
// //                           DropdownMenuItem(
// //                             value: 'Non_veg',
// //                             child: Text('Non-Veg'),
// //                           ),
// //                           DropdownMenuItem(
// //                             value: 'Drinks',
// //                             child: Text('Drinks'),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 14),
// //               Row(
// //                 children: [
// //                   const Text(
// //                     'Items',
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: _kT1,
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   GestureDetector(
// //                     onTap: _addItem,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 5,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _kPLt,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: const Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Icon(Icons.add_rounded, color: _kP, size: 13),
// //                           SizedBox(width: 4),
// //                           Text(
// //                             'Add Item',
// //                             style: TextStyle(
// //                               fontSize: 11,
// //                               fontWeight: FontWeight.w700,
// //                               color: _kP,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               ..._items.asMap().entries.map(
// //                 (e) => Padding(
// //                   padding: const EdgeInsets.only(bottom: 8),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: _TF(e.value['name']!, 'Item name'),
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Expanded(
// //                         flex: 2,
// //                         child: _TF(
// //                           e.value['price']!,
// //                           '₹ Price',
// //                           TextInputType.number,
// //                         ),
// //                       ),
// //                       if (_items.length > 1) ...[
// //                         const SizedBox(width: 6),
// //                         GestureDetector(
// //                           onTap: () => _removeItem(e.key),
// //                           child: Container(
// //                             padding: const EdgeInsets.all(7),
// //                             decoration: BoxDecoration(
// //                               color: _kDLt,
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: const Icon(
// //                               Icons.close_rounded,
// //                               size: 14,
// //                               color: _kDng,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 18),
// //               _SaveRow(
// //                 () => Navigator.pop(context),
// //                 _saving ? null : _save,
// //                 'Save Package',
// //                 _saving,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // // ── Shared bottom sheet helpers ────────────────────────────────────────────────
// // class _Handle extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Container(
// //       width: 36,
// //       height: 4,
// //       margin: const EdgeInsets.only(bottom: 14),
// //       decoration: BoxDecoration(
// //         color: _kBrd,
// //         borderRadius: BorderRadius.circular(2),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _Field extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final String hint;
// //   final IconData icon;
// //   final TextInputType type;
// //   const _Field(
// //     this.ctrl,
// //     this.hint,
// //     this.icon, {
// //     this.type = TextInputType.text,
// //   });
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: _kBg,
// //       borderRadius: BorderRadius.circular(10),
// //       border: Border.all(color: _kBrd),
// //     ),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: type,
// //       style: const TextStyle(fontSize: 13, color: _kT1),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //         prefixIcon: Icon(icon, color: _kP, size: 17),
// //         border: InputBorder.none,
// //         contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _TF extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final String hint;
// //   final TextInputType type;
// //   const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: _kBg,
// //       borderRadius: BorderRadius.circular(9),
// //       border: Border.all(color: _kBrd),
// //     ),
// //     child: TextField(
// //       controller: ctrl,
// //       keyboardType: type,
// //       style: const TextStyle(fontSize: 13, color: _kT1),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
// //         border: InputBorder.none,
// //         contentPadding: const EdgeInsets.symmetric(
// //           horizontal: 10,
// //           vertical: 10,
// //         ),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _SaveRow extends StatelessWidget {
// //   final VoidCallback onCancel;
// //   final VoidCallback? onSave;
// //   final String label;
// //   final bool saving;
// //   const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);
// //   @override
// //   Widget build(BuildContext context) => Row(
// //     children: [
// //       Expanded(
// //         child: GestureDetector(
// //           onTap: onCancel,
// //           child: Container(
// //             height: 44,
// //             decoration: BoxDecoration(
// //               color: _kBg,
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: _kBrd),
// //             ),
// //             child: const Center(
// //               child: Text(
// //                 'Cancel',
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: _kT2,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       const SizedBox(width: 10),
// //       Expanded(
// //         child: GestureDetector(
// //           onTap: onSave,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 180),
// //             height: 44,
// //             decoration: BoxDecoration(
// //               gradient: onSave != null ? _kGrd : null,
// //               color: onSave == null ? _kBrd : null,
// //               borderRadius: BorderRadius.circular(10),
// //               boxShadow: onSave != null
// //                   ? [
// //                       BoxShadow(
// //                         color: _kP.withOpacity(0.3),
// //                         blurRadius: 8,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ]
// //                   : null,
// //             ),
// //             child: Center(
// //               child: saving
// //                   ? const SizedBox(
// //                       width: 18,
// //                       height: 18,
// //                       child: CircularProgressIndicator(
// //                         color: _kW,
// //                         strokeWidth: 2,
// //                       ),
// //                     )
// //                   : Text(
// //                       label,
// //                       style: const TextStyle(
// //                         color: _kW,
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../widgets/common_widgets.dart';
//
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFF97316);
// const _kPDk = Color(0xFFC2510F);
// const _kPLt = Color(0xFFFFF0E6);
// const _kSuc = Color(0xFF10B981);
// const _kSLt = Color(0xFFD1FAE5);
// const _kSDk = Color(0xFF059669);
// const _kDng = Color(0xFFEF4444);
// const _kDLt = Color(0xFFFEE2E2);
// const _kInf = Color(0xFF3B82F6);
// const _kILt = Color(0xFFDBEAFE);
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
// class PackagesTab extends StatefulWidget {
//   const PackagesTab({super.key});
//   @override
//   State<PackagesTab> createState() => PackagesTabState();
// }
//
// class PackagesTabState extends State<PackagesTab> {
//   List<MenuPackage> _data = [];
//   List<MenuPackage> _filtered = [];
//   bool _loading = true;
//   String? _error;
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//   String? _selectedType;
//   String? _selectedPackage;
//   final Set<int> _expanded = {};
//
//   void openAddCategory() {
//     _showAddPackageSheet();
//   }
//
//   void enableBulkMode() {}
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchData() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final result = await MenuService.fetchPackages();
//       if (mounted) {
//         setState(() {
//           _data = result;
//           _loading = false;
//         });
//         _applyFilter();
//       }
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//     }
//   }
//
//   void _applyFilter() {
//     var f = [..._data];
//     if (_selectedType != null)
//       f = f.where((p) => p.packageType == _selectedType).toList();
//     if (_selectedPackage != null)
//       f = f.where((p) => p.packageName == _selectedPackage).toList();
//     if (_searchQuery.isNotEmpty) {
//       final q = _searchQuery.toLowerCase();
//       f = f
//           .map((p) {
//             final pm = p.packageName.toLowerCase().contains(q);
//             final items = p.items
//                 .where(
//                   (i) =>
//                       i.itemName.toLowerCase().contains(q) ||
//                       (i.description?.toLowerCase().contains(q) ?? false),
//                 )
//                 .toList();
//             if (pm || items.isNotEmpty)
//               return MenuPackage(
//                 id: p.id,
//                 packageName: p.packageName,
//                 packageType: p.packageType,
//                 image: p.image,
//                 totalPrice: p.totalPrice,
//                 items: pm ? p.items : items,
//               );
//             return null;
//           })
//           .whereType<MenuPackage>()
//           .toList();
//     }
//     setState(() => _filtered = f);
//   }
//
//   Future<void> _deletePackage(MenuPackage pkg) async {
//     final ok = await showConfirmDialog(
//       context,
//       title: 'Delete Package',
//       message: 'Delete "${pkg.packageName}"? This cannot be undone.',
//     );
//     if (!ok) return;
//     try {
//       await MenuService.deletePackage(pkg.id);
//       await _fetchData();
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to delete package.',
//         );
//     }
//   }
//
//   Future<void> _deleteItem(PackageItem item, int packageId) async {
//     final ok = await showConfirmDialog(
//       context,
//       title: 'Delete Item',
//       message: 'Delete "${item.itemName}"?',
//     );
//     if (!ok) return;
//     try {
//       await MenuService.deletePackageItem(item.id, packageId);
//       await _fetchData();
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to delete item.',
//         );
//     }
//   }
//
//   void _showEditItemSheet(PackageItem item, int packageId) =>
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         useSafeArea: true,
//         backgroundColor: Colors.transparent,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) => _EditItemSheet(
//           item: item,
//           packageId: packageId,
//           onSaved: _fetchData,
//         ),
//       );
//
//   void _showAddPackageSheet() => showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     useSafeArea: true,
//     backgroundColor: Colors.transparent,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) => _AddPackageSheet(onSaved: _fetchData),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ── Filter bar ──────────────────────────────────────────────────────
//         Container(
//           color: _kW,
//           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//           child: Column(
//             children: [
//               Container(
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: _kBg,
//                   borderRadius: BorderRadius.circular(11),
//                   border: Border.all(color: _kBrd),
//                 ),
//                 child: TextField(
//                   controller: _searchCtrl,
//                   style: const TextStyle(fontSize: 13, color: _kT1),
//                   onChanged: (v) {
//                     _searchQuery = v;
//                     _applyFilter();
//                     setState(() {});
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search packages or items...',
//                     hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//                     prefixIcon: const Icon(
//                       Icons.search_rounded,
//                       color: _kMut,
//                       size: 18,
//                     ),
//                     suffixIcon: _searchCtrl.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(
//                               Icons.close_rounded,
//                               size: 16,
//                               color: _kMut,
//                             ),
//                             onPressed: () {
//                               _searchCtrl.clear();
//                               _searchQuery = '';
//                               _applyFilter();
//                               setState(() {});
//                             },
//                           )
//                         : null,
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 11),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     for (final e in [
//                       _TEntry(null, 'All', _kP, _kPLt),
//                       _TEntry('Veg', '🟢 Veg', _kSuc, _kSLt),
//                       _TEntry('Non_veg', '🔴 Non-Veg', _kDng, _kDLt),
//                       _TEntry('Drinks', '🔵 Drinks', _kInf, _kILt),
//                     ]) ...[
//                       _TypeChip(
//                         e: e,
//                         active: _selectedType == e.type,
//                         onTap: () {
//                           setState(() => _selectedType = e.type);
//                           _applyFilter();
//                         },
//                       ),
//                       const SizedBox(width: 6),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Divider(color: _kBrd, height: 1),
//             ],
//           ),
//         ),
//
//         const Divider(color: _kBrd, height: 1),
//         // ── Content ─────────────────────────────────────────────────────────
//         Expanded(
//           child: _loading
//               ? const Center(
//                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
//                 )
//               : _error != null
//               ? _ErrWidget(msg: _error!, onRetry: _fetchData)
//               : _filtered.isEmpty
//               ? _EmptyWidget()
//               : RefreshIndicator(
//                   color: _kP,
//                   onRefresh: _fetchData,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
//                     itemCount: _filtered.length,
//                     itemBuilder: (_, i) {
//                       final pkg = _filtered[i];
//                       return _PackageCard(
//                         package: pkg,
//                         isExpanded: _expanded.contains(pkg.id),
//                         onToggleExpand: () => setState(() {
//                           _expanded.contains(pkg.id)
//                               ? _expanded.remove(pkg.id)
//                               : _expanded.add(pkg.id);
//                         }),
//                         onDelete: () => _deletePackage(pkg),
//                         onEditItem: (item) => _showEditItemSheet(item, pkg.id),
//                         onDeleteItem: (item) => _deleteItem(item, pkg.id),
//                       );
//                     },
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }
//
// class _TEntry {
//   final String? type;
//   final String label;
//   final Color color, bg;
//   const _TEntry(this.type, this.label, this.color, this.bg);
// }
//
// class _TypeChip extends StatelessWidget {
//   final _TEntry e;
//   final bool active;
//   final VoidCallback onTap;
//   const _TypeChip({required this.e, required this.active, required this.onTap});
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: active ? e.bg : _kBg,
//         borderRadius: BorderRadius.circular(9),
//         border: Border.all(
//           color: active ? e.color.withOpacity(0.4) : _kBrd,
//           width: active ? 1.5 : 1,
//         ),
//       ),
//       child: Text(
//         e.label,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           color: active ? e.color : _kT2,
//         ),
//       ),
//     ),
//   );
// }
//
// class _ErrWidget extends StatelessWidget {
//   final String msg;
//   final VoidCallback onRetry;
//   const _ErrWidget({required this.msg, required this.onRetry});
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(28),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
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
//             'Failed to load packages',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: _kT1,
//             ),
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
//
// class _EmptyWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 68,
//           height: 68,
//           decoration: BoxDecoration(
//             gradient: _kGrd,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: _kP.withOpacity(0.3),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
//         ),
//         const SizedBox(height: 14),
//         const Text(
//           'No packages found',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             color: _kT1,
//           ),
//         ),
//         const SizedBox(height: 5),
//         const Text(
//           'Tap Add Package to create one',
//           style: TextStyle(fontSize: 12, color: _kT2),
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Package Card ───────────────────────────────────────────────────────────────
// class _PackageCard extends StatelessWidget {
//   final MenuPackage package;
//   final bool isExpanded;
//   final VoidCallback onToggleExpand, onDelete;
//   final Function(PackageItem) onEditItem, onDeleteItem;
//   const _PackageCard({
//     required this.package,
//     required this.isExpanded,
//     required this.onToggleExpand,
//     required this.onDelete,
//     required this.onEditItem,
//     required this.onDeleteItem,
//   });
//
//   Color get _tc {
//     switch (package.packageType) {
//       case 'Veg':
//         return _kSuc;
//       case 'Non_veg':
//         return _kDng;
//       default:
//         return _kInf;
//     }
//   }
//
//   Color get _tb {
//     switch (package.packageType) {
//       case 'Veg':
//         return _kSLt;
//       case 'Non_veg':
//         return _kDLt;
//       default:
//         return _kILt;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: const EdgeInsets.only(bottom: 10),
//     decoration: BoxDecoration(
//       color: _kW,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: isExpanded ? _tc.withOpacity(0.2) : _kBrd),
//       boxShadow: [
//         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
//       ],
//     ),
//     child: Column(
//       children: [
//         GestureDetector(
//           onTap: onToggleExpand,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                     width: 52,
//                     height: 52,
//                     color: _kBg,
//                     child: package.image != null && package.image!.isNotEmpty
//                         ? Image.network(
//                             package.image!,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => const Icon(
//                               Icons.inventory_2_rounded,
//                               color: _kMut,
//                               size: 22,
//                             ),
//                           )
//                         : const Icon(
//                             Icons.inventory_2_rounded,
//                             color: _kMut,
//                             size: 22,
//                           ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         package.packageName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 14,
//                           color: _kT1,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _tb,
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(color: _tc.withOpacity(0.2)),
//                             ),
//                             child: Text(
//                               package.packageType == 'Non_veg'
//                                   ? 'Non-Veg'
//                                   : package.packageType,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: _tc,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '${package.items.length} items',
//                             style: const TextStyle(fontSize: 11, color: _kT2),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '₹${package.computedTotal.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w900,
//                         color: _kP,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         GestureDetector(
//                           onTap: onDelete,
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               color: _kDLt,
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                             child: const Icon(
//                               Icons.delete_outline_rounded,
//                               size: 15,
//                               color: _kDng,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         AnimatedRotation(
//                           turns: isExpanded ? 0.5 : 0,
//                           duration: const Duration(milliseconds: 200),
//                           child: Icon(
//                             Icons.keyboard_arrow_down_rounded,
//                             color: isExpanded ? _kP : _kMut,
//                             size: 20,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (isExpanded) ...[
//           Divider(
//             color: _kBrd.withOpacity(0.6),
//             height: 1,
//             indent: 12,
//             endIndent: 12,
//           ),
//           if (package.items.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Center(
//                 child: Text(
//                   'No items',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _kMut,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),
//             )
//           else
//             ...package.items.asMap().entries.map(
//               (e) => _ItemRow(
//                 item: e.value,
//                 index: e.key,
//                 onEdit: () => onEditItem(e.value),
//                 onDelete: () => onDeleteItem(e.value),
//                 isLast: e.key == package.items.length - 1,
//               ),
//             ),
//         ],
//       ],
//     ),
//   );
// }
//
// // ── Item Row ───────────────────────────────────────────────────────────────────
// class _ItemRow extends StatelessWidget {
//   final PackageItem item;
//   final int index;
//   final VoidCallback onEdit, onDelete;
//   final bool isLast;
//   const _ItemRow({
//     required this.item,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//     this.isLast = false,
//   });
//   @override
//   Widget build(BuildContext context) => Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
//         child: Row(
//           children: [
//             Container(
//               width: 2,
//               height: 36,
//               margin: const EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: _kP.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.itemName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13,
//                       color: _kT1,
//                     ),
//                   ),
//                   if (item.description != null && item.description!.isNotEmpty)
//                     Text(
//                       item.description!,
//                       style: const TextStyle(fontSize: 11, color: _kT2),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                 ],
//               ),
//             ),
//             Text(
//               '₹${item.price.toStringAsFixed(0)}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: _kP,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(width: 10),
//             GestureDetector(
//               onTap: onEdit,
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: _kILt,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
//               ),
//             ),
//             const SizedBox(width: 6),
//             GestureDetector(
//               onTap: onDelete,
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: _kDLt,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(
//                   Icons.delete_outline_rounded,
//                   size: 14,
//                   color: _kDng,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       if (!isLast)
//         Divider(
//           color: _kBrd.withOpacity(0.5),
//           height: 1,
//           indent: 16,
//           endIndent: 12,
//         ),
//     ],
//   );
// }
//
// // ── Edit Item Sheet ────────────────────────────────────────────────────────────
// class _EditItemSheet extends StatefulWidget {
//   final PackageItem item;
//   final int packageId;
//   final VoidCallback onSaved;
//   const _EditItemSheet({
//     required this.item,
//     required this.packageId,
//     required this.onSaved,
//   });
//   @override
//   State<_EditItemSheet> createState() => __EditItemSheetState();
// }
//
// class __EditItemSheetState extends State<_EditItemSheet> {
//   late final TextEditingController _nameCtrl, _priceCtrl;
//   bool _saving = false;
//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.item.itemName);
//     _priceCtrl = TextEditingController(
//       text: widget.item.price.toStringAsFixed(0),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _priceCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (_nameCtrl.text.trim().isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter an item name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final updated = widget.item.copyWith(
//         itemName: _nameCtrl.text.trim(),
//         price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
//       );
//       await MenuService.updatePackageItem(updated, widget.packageId);
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to update item.',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => SafeArea(
//     child: Padding(
//       // SafeArea handles home indicator; viewInsets.bottom handles keyboard
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _Handle(),
//             Row(
//               children: [
//                 Container(
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: _kPLt,
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Edit Item',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: _kT1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
//             const SizedBox(height: 10),
//             _Field(
//               _priceCtrl,
//               'Price (₹)',
//               Icons.currency_rupee_rounded,
//               type: TextInputType.number,
//             ),
//             const SizedBox(height: 20),
//             _SaveRow(
//               () => Navigator.pop(context),
//               _saving ? null : _save,
//               'Save Item',
//               _saving,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Add Package Sheet ──────────────────────────────────────────────────────────
// class _AddPackageSheet extends StatefulWidget {
//   final VoidCallback onSaved;
//   const _AddPackageSheet({required this.onSaved});
//   @override
//   State<_AddPackageSheet> createState() => __AddPackageSheetState();
// }
//
// class __AddPackageSheetState extends State<_AddPackageSheet> {
//   final _nameCtrl = TextEditingController();
//   String _type = 'Veg';
//   final List<Map<String, TextEditingController>> _items = [];
//   bool _saving = false;
//   File? _imageFile;
//
//   @override
//   void initState() {
//     super.initState();
//     _addItem();
//   }
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 1024,
//       maxHeight: 1024,
//     );
//     if (picked != null && mounted)
//       setState(() => _imageFile = File(picked.path));
//   }
//
//   void _addItem() {
//     _items.add({
//       'name': TextEditingController(),
//       'price': TextEditingController(),
//     });
//     setState(() {});
//   }
//
//   void _removeItem(int i) {
//     _items[i]['name']!.dispose();
//     _items[i]['price']!.dispose();
//     _items.removeAt(i);
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     for (final item in _items) {
//       item['name']!.dispose();
//       item['price']!.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (_nameCtrl.text.trim().isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter a package name.',
//       );
//       return;
//     }
//     final valid = _items
//         .where(
//           (i) =>
//               i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
//         )
//         .map(
//           (i) => PackageItem(
//             id: 0,
//             itemName: i['name']!.text.trim(),
//             price: double.tryParse(i['price']!.text) ?? 0,
//           ),
//         )
//         .toList();
//     if (valid.isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Items Required',
//         message: 'Please add at least one valid item.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final pkg = MenuPackage(
//         id: 0,
//         packageName: _nameCtrl.text.trim(),
//         packageType: _type,
//         totalPrice: valid.fold(0, (s, i) => s + i.price),
//         items: valid,
//       );
//       List<int>? imageBytes;
//       String imageFileName = 'package.jpg';
//       if (_imageFile != null) {
//         imageBytes = await _imageFile!.readAsBytes();
//         imageFileName = _imageFile!.path.split('/').last;
//       }
//       await MenuService.addPackage(
//         pkg: pkg,
//         imageBytes: imageBytes,
//         imageFileName: imageFileName,
//       );
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (_) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to add package.',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => SafeArea(
//     child: Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _Handle(),
//               Row(
//                 children: [
//                   Container(
//                     width: 34,
//                     height: 34,
//                     decoration: BoxDecoration(
//                       color: _kPLt,
//                       borderRadius: BorderRadius.circular(9),
//                     ),
//                     child: const Icon(
//                       Icons.inventory_2_rounded,
//                       color: _kP,
//                       size: 17,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Add New Package',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: _kT1,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
//               const SizedBox(height: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Package Type',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: _kBg,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _kBrd),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _type,
//                         isExpanded: true,
//                         icon: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: _kP,
//                           size: 18,
//                         ),
//                         style: const TextStyle(fontSize: 13, color: _kT1),
//                         onChanged: (v) => setState(() => _type = v ?? 'Veg'),
//                         items: const [
//                           DropdownMenuItem(value: 'Veg', child: Text('Veg')),
//                           DropdownMenuItem(
//                             value: 'Non_veg',
//                             child: Text('Non-Veg'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Drinks',
//                             child: Text('Drinks'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               // ── Package Image ────────────────────────────────────────────
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Package Image (optional)',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       height: 110,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: _kBg,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _imageFile != null ? _kP : _kBrd,
//                           width: _imageFile != null ? 1.5 : 1,
//                         ),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(11),
//                         child: _imageFile != null
//                             ? Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Image.file(_imageFile!, fit: BoxFit.cover),
//                                   Positioned(
//                                     bottom: 0,
//                                     left: 0,
//                                     right: 0,
//                                     child: Container(
//                                       color: Colors.black54,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 5,
//                                       ),
//                                       child: const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.camera_alt_rounded,
//                                             color: _kW,
//                                             size: 13,
//                                           ),
//                                           SizedBox(width: 5),
//                                           Text(
//                                             'Tap to change',
//                                             style: TextStyle(
//                                               color: _kW,
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: const [
//                                   Icon(
//                                     Icons.add_photo_alternate_outlined,
//                                     color: _kMut,
//                                     size: 32,
//                                   ),
//                                   SizedBox(height: 6),
//                                   Text(
//                                     'Tap to upload image',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: _kMut,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Text(
//                                     'JPG, PNG • Max 5MB',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: _kBrd,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//               Row(
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: _kT1,
//                     ),
//                   ),
//                   const Spacer(),
//                   GestureDetector(
//                     onTap: _addItem,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _kPLt,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.add_rounded, color: _kP, size: 13),
//                           SizedBox(width: 4),
//                           Text(
//                             'Add Item',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: _kP,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               ..._items.asMap().entries.map(
//                 (e) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: _TF(e.value['name']!, 'Item name'),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         flex: 2,
//                         child: _TF(
//                           e.value['price']!,
//                           '₹ Price',
//                           TextInputType.number,
//                         ),
//                       ),
//                       if (_items.length > 1) ...[
//                         const SizedBox(width: 6),
//                         GestureDetector(
//                           onTap: () => _removeItem(e.key),
//                           child: Container(
//                             padding: const EdgeInsets.all(7),
//                             decoration: BoxDecoration(
//                               color: _kDLt,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.close_rounded,
//                               size: 14,
//                               color: _kDng,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 18),
//               _SaveRow(
//                 () => Navigator.pop(context),
//                 _saving ? null : _save,
//                 'Save Package',
//                 _saving,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Shared bottom sheet helpers ────────────────────────────────────────────────
// class _Handle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Container(
//       width: 36,
//       height: 4,
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: _kBrd,
//         borderRadius: BorderRadius.circular(2),
//       ),
//     ),
//   );
// }
//
// class _Field extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final IconData icon;
//   final TextInputType type;
//   const _Field(
//     this.ctrl,
//     this.hint,
//     this.icon, {
//     this.type = TextInputType.text,
//   });
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: _kBg,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: _kBrd),
//     ),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: type,
//       style: const TextStyle(fontSize: 13, color: _kT1),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//         prefixIcon: Icon(icon, color: _kP, size: 17),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
//       ),
//     ),
//   );
// }
//
// class _TF extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final TextInputType type;
//   const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: _kBg,
//       borderRadius: BorderRadius.circular(9),
//       border: Border.all(color: _kBrd),
//     ),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: type,
//       style: const TextStyle(fontSize: 13, color: _kT1),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 10,
//           vertical: 10,
//         ),
//       ),
//     ),
//   );
// }
//
// class _SaveRow extends StatelessWidget {
//   final VoidCallback onCancel;
//   final VoidCallback? onSave;
//   final String label;
//   final bool saving;
//   const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Expanded(
//         child: GestureDetector(
//           onTap: onCancel,
//           child: Container(
//             height: 44,
//             decoration: BoxDecoration(
//               color: _kBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _kBrd),
//             ),
//             child: const Center(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: _kT2,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(width: 10),
//       Expanded(
//         child: GestureDetector(
//           onTap: onSave,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             height: 44,
//             decoration: BoxDecoration(
//               gradient: onSave != null ? _kGrd : null,
//               color: onSave == null ? _kBrd : null,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: onSave != null
//                   ? [
//                       BoxShadow(
//                         color: _kP.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Center(
//               child: saving
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         color: _kW,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       label,
//                       style: const TextStyle(
//                         color: _kW,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

// ─── tokens ───────────────────────────────────────────────────────────────────
const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFF97316);
const _kPDk = Color(0xFFC2510F);
const _kPLt = Color(0xFFFFF0E6);
const _kSuc = Color(0xFF10B981);
const _kSLt = Color(0xFFD1FAE5);
const _kSDk = Color(0xFF059669);
const _kDng = Color(0xFFEF4444);
const _kDLt = Color(0xFFFEE2E2);
const _kInf = Color(0xFF3B82F6);
const _kILt = Color(0xFFDBEAFE);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kMut = Color(0xFFB0B3C1);
const _kShd = Color(0x0A000000);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PackagesTab extends StatefulWidget {
  const PackagesTab({super.key});
  @override
  State<PackagesTab> createState() => PackagesTabState();
}

class PackagesTabState extends State<PackagesTab> {
  List<MenuPackage> _data = [];
  List<MenuPackage> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedType; // null = All
  final Set<int> _expanded = {};

  // ── Overlay filter state ──────────────────────────────────────────────────
  bool _filtersExpanded = false;
  final LayerLink _filterLayerLink = LayerLink();
  OverlayEntry? _filterOverlay;

  void _showFilterOverlay() {
    _filterOverlay = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeFilterOverlay,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _filterLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(-160, 48),
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: _FilterDropdown(
                    selectedType: _selectedType,
                    onSelect: (type) {
                      setState(() => _selectedType = type);
                      _applyFilter();
                      _removeFilterOverlay();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_filterOverlay!);
    setState(() => _filtersExpanded = true);
  }

  void _removeFilterOverlay({bool updateState = true}) {
    _filterOverlay?.remove();
    _filterOverlay = null;
    if (updateState && mounted) setState(() => _filtersExpanded = false);
  }

  void openAddCategory() => _showAddPackageSheet();
  void enableBulkMode() {}

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _removeFilterOverlay(updateState: false);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MenuService.fetchPackages();
      if (mounted) {
        setState(() {
          _data = result;
          _loading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  void _applyFilter() {
    var f = [..._data];
    if (_selectedType != null)
      f = f.where((p) => p.packageType == _selectedType).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f
          .map((p) {
        final pm = p.packageName.toLowerCase().contains(q);
        final items = p.items
            .where(
              (i) =>
          i.itemName.toLowerCase().contains(q) ||
              (i.description?.toLowerCase().contains(q) ?? false),
        )
            .toList();
        if (pm || items.isNotEmpty)
          return MenuPackage(
            id: p.id,
            packageName: p.packageName,
            packageType: p.packageType,
            image: p.image,
            totalPrice: p.totalPrice,
            items: pm ? p.items : items,
          );
        return null;
      })
          .whereType<MenuPackage>()
          .toList();
    }
    setState(() => _filtered = f);
  }

  Future<void> _deletePackage(MenuPackage pkg) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Package',
      message: 'Delete "${pkg.packageName}"? This cannot be undone.',
    );
    if (!ok) return;
    try {
      await MenuService.deletePackage(pkg.id);
      await _fetchData();
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to delete package.',
        );
    }
  }

  Future<void> _deleteItem(PackageItem item, int packageId) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message: 'Delete "${item.itemName}"?',
    );
    if (!ok) return;
    try {
      await MenuService.deletePackageItem(item.id, packageId);
      await _fetchData();
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to delete item.',
        );
    }
  }

  void _showEditItemSheet(PackageItem item, int packageId) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _EditItemSheet(
          item: item,
          packageId: packageId,
          onSaved: _fetchData,
        ),
      );

  void _showAddPackageSheet() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddPackageSheet(onSaved: _fetchData),
  );

  // String? get _activeFilterLabel {
  //   switch (_selectedType) {
  //     case 'Veg':
  //       return '🟢 Veg';
  //     case 'Non_veg':
  //       return '🔴 Non-Veg';
  //     case 'Drinks':
  //       return '🔵 Drinks';
  //     default:
  //       return null;
  //   }
  // }

  Color get _activeFilterColor {
    switch (_selectedType) {
      case 'Veg':
        return _kSuc;
      case 'Non_veg':
        return _kDng;
      case 'Drinks':
        return _kInf;
      default:
        return _kP;
    }
  }

  Color get _activeFilterBg {
    switch (_selectedType) {
      case 'Veg':
        return _kSLt;
      case 'Non_veg':
        return _kDLt;
      case 'Drinks':
        return _kILt;
      default:
        return _kPLt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool filterActive = _filtersExpanded || _selectedType != null;
    return Column(
      children: [
        // ── Filter bar ──────────────────────────────────────────────────────
        Container(
          color: _kW,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Column(
            children: [
              // Search row + filter icon button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: _kBrd),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 13, color: _kT1),
                        onChanged: (v) {
                          _searchQuery = v;
                          _applyFilter();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search packages or items...',
                          hintStyle: const TextStyle(
                            color: _kMut,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _kMut,
                            size: 18,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _kMut,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              _searchQuery = '';
                              _applyFilter();
                              setState(() {});
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Overlay filter button ──────────────────────────────
                  CompositedTransformTarget(
                    link: _filterLayerLink,
                    child: GestureDetector(
                      onTap: () => _filtersExpanded
                          ? _removeFilterOverlay()
                          : _showFilterOverlay(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: filterActive ? _kPLt : _kBg,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: filterActive ? _kP : _kBrd,
                            width: filterActive ? 1.5 : 1,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: filterActive ? _kP : _kT2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Active filter chip
              if (_selectedType != null) ...[
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     _FChip(
                //       label: _activeFilterLabel!,
                //       active: true,
                //       activeColor: _activeFilterColor,
                //       activeBg: _activeFilterBg,
                //       onTap: () {
                //         setState(() => _selectedType = null);
                //         _applyFilter();
                //       },
                //       onClear: () {
                //         setState(() => _selectedType = null);
                //         _applyFilter();
                //       },
                //     ),
                //   ],
                // ),
              ],

              const SizedBox(height: 8),
              const Divider(color: _kBrd, height: 1),
            ],
          ),
        ),

        const Divider(color: _kBrd, height: 1),

        // ── Content ─────────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
          )
              : _error != null
              ? _ErrWidget(msg: _error!, onRetry: _fetchData)
              : _filtered.isEmpty
              ? _EmptyWidget()
              : RefreshIndicator(
            color: _kP,
            onRefresh: _fetchData,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final pkg = _filtered[i];
                return _PackageCard(
                  package: pkg,
                  isExpanded: _expanded.contains(pkg.id),
                  onToggleExpand: () => setState(() {
                    _expanded.contains(pkg.id)
                        ? _expanded.remove(pkg.id)
                        : _expanded.add(pkg.id);
                  }),
                  onDelete: () => _deletePackage(pkg),
                  onEditItem: (item) => _showEditItemSheet(item, pkg.id),
                  onDeleteItem: (item) => _deleteItem(item, pkg.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Filter Dropdown (overlay) ─────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onSelect;

  const _FilterDropdown({required this.selectedType, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _kW,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBrd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DropItem(
            icon: Icons.apps_rounded,
            label: 'All',
            isActive: selectedType == null,
            activeColor: _kP,
            activeBg: _kPLt,
            onTap: () => onSelect(null),
          ),
          const SizedBox(height: 3),
          _DropItem(
            dotColor: _kSuc,
            label: 'Veg',
            isActive: selectedType == 'Veg',
            activeColor: _kSuc,
            activeBg: _kSLt,
            onTap: () => onSelect(selectedType == 'Veg' ? null : 'Veg'),
          ),
          const SizedBox(height: 3),
          _DropItem(
            dotColor: _kDng,
            label: 'Non-Veg',
            isActive: selectedType == 'Non_veg',
            activeColor: _kDng,
            activeBg: _kDLt,
            onTap: () => onSelect(selectedType == 'Non_veg' ? null : 'Non_veg'),
          ),
          const SizedBox(height: 3),
          _DropItem(
            dotColor: _kInf,
            label: 'Drinks',
            isActive: selectedType == 'Drinks',
            activeColor: _kInf,
            activeBg: _kILt,
            onTap: () => onSelect(selectedType == 'Drinks' ? null : 'Drinks'),
          ),
        ],
      ),
    );
  }
}

class _DropItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor, activeBg;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? dotColor;

  const _DropItem({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
    this.icon,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            if (dotColor != null)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(icon, size: 15, color: isActive ? activeColor : _kT2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : _kT1,
                ),
              ),
            ),
            if (isActive)
              Icon(Icons.check_rounded, size: 14, color: activeColor),
          ],
        ),
      ),
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────
class _FChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? activeColor, activeBg;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
    this.activeBg,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? _kP;
    final bg = activeBg ?? _kPLt;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? bg : _kBg,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? color.withOpacity(0.4) : _kBrd,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? color : _kT2,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 11, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Error / Empty states ─────────────────────────────────────────────────────
class _ErrWidget extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrWidget({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            'Failed to load packages',
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

class _EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: _kGrd,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kP.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.inventory_2_rounded, color: _kW, size: 30),
        ),
        const SizedBox(height: 14),
        const Text(
          'No packages found',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kT1,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Tap Add Package to create one',
          style: TextStyle(fontSize: 12, color: _kT2),
        ),
      ],
    ),
  );
}

// ── Package Card ───────────────────────────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final MenuPackage package;
  final bool isExpanded;
  final VoidCallback onToggleExpand, onDelete;
  final Function(PackageItem) onEditItem, onDeleteItem;

  const _PackageCard({
    required this.package,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onDelete,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  Color get _tc {
    switch (package.packageType) {
      case 'Veg':
        return _kSuc;
      case 'Non_veg':
        return _kDng;
      default:
        return _kInf;
    }
  }

  Color get _tb {
    switch (package.packageType) {
      case 'Veg':
        return _kSLt;
      case 'Non_veg':
        return _kDLt;
      default:
        return _kILt;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: _kW,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isExpanded ? _tc.withOpacity(0.25) : _kBrd,
        width: isExpanded ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isExpanded ? _tc.withOpacity(0.08) : _kShd,
          blurRadius: isExpanded ? 12 : 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggleExpand,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
              decoration: BoxDecoration(
                color: isExpanded ? _tb.withOpacity(0.35) : _kW,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: _kBg,
                      child: package.image != null && package.image!.isNotEmpty
                          ? Image.network(
                        package.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.inventory_2_rounded,
                          color: _kMut,
                          size: 22,
                        ),
                      )
                          : const Icon(
                        Icons.inventory_2_rounded,
                        color: _kMut,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.packageName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: _kT1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _tb,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _tc.withOpacity(0.2)),
                              ),
                              child: Text(
                                package.packageType == 'Non_veg'
                                    ? 'Non-Veg'
                                    : package.packageType,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _tc,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${package.items.length} item${package.items.length == 1 ? '' : 's'}',
                              style: const TextStyle(fontSize: 11, color: _kT2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${package.computedTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: _tc,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _kDLt,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 15,
                                color: _kDng,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isExpanded ? _tc : _kMut,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable items
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                  color: _kBrd.withOpacity(0.7),
                  height: 1,
                  indent: 12,
                  endIndent: 12,
                ),
                if (package.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No items in this package',
                        style: TextStyle(
                          fontSize: 12,
                          color: _kMut,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...package.items.asMap().entries.map(
                        (e) => _ItemRow(
                      item: e.value,
                      index: e.key,
                      isLast: e.key == package.items.length - 1,
                      onEdit: () => onEditItem(e.value),
                      onDelete: () => onDeleteItem(e.value),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Item Row ───────────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final PackageItem item;
  final int index;
  final VoidCallback onEdit, onDelete;
  final bool isLast;

  const _ItemRow({
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Container(
              width: 2,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _kP.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kT1,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      style: const TextStyle(fontSize: 11, color: _kT2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kPLt,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '₹${item.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _kP,
                  fontSize: 12,
                ),
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kILt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.edit_outlined, size: 14, color: _kInf),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kDLt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 14,
                  color: _kDng,
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Divider(
          color: _kBrd.withOpacity(0.5),
          height: 1,
          indent: 16,
          endIndent: 12,
        ),
    ],
  );
}

// ── Edit Item Sheet ────────────────────────────────────────────────────────────
class _EditItemSheet extends StatefulWidget {
  final PackageItem item;
  final int packageId;
  final VoidCallback onSaved;
  const _EditItemSheet({
    required this.item,
    required this.packageId,
    required this.onSaved,
  });
  @override
  State<_EditItemSheet> createState() => __EditItemSheetState();
}

class __EditItemSheetState extends State<_EditItemSheet> {
  late final TextEditingController _nameCtrl, _priceCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.itemName);
    _priceCtrl = TextEditingController(
      text: widget.item.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      showAppDialog(
        context,
        title: 'Required',
        message: 'Please enter an item name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = widget.item.copyWith(
        itemName: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? widget.item.price,
      );
      await MenuService.updatePackageItem(updated, widget.packageId);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update item.',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kPLt,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.edit_rounded, color: _kP, size: 17),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Edit Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kT1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(_nameCtrl, 'Item Name', Icons.fastfood_rounded),
            const SizedBox(height: 10),
            _Field(
              _priceCtrl,
              'Price (₹)',
              Icons.currency_rupee_rounded,
              type: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _SaveRow(
                  () => Navigator.pop(context),
              _saving ? null : _save,
              'Save Item',
              _saving,
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Add Package Sheet ──────────────────────────────────────────────────────────
class _AddPackageSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddPackageSheet({required this.onSaved});
  @override
  State<_AddPackageSheet> createState() => __AddPackageSheetState();
}

class __AddPackageSheetState extends State<_AddPackageSheet> {
  final _nameCtrl = TextEditingController();
  String _type = 'Veg';
  final List<Map<String, TextEditingController>> _items = [];
  bool _saving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked != null && mounted)
      setState(() => _imageFile = File(picked.path));
  }

  void _addItem() {
    _items.add({
      'name': TextEditingController(),
      'price': TextEditingController(),
    });
    setState(() {});
  }

  void _removeItem(int i) {
    _items[i]['name']!.dispose();
    _items[i]['price']!.dispose();
    _items.removeAt(i);
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final item in _items) {
      item['name']!.dispose();
      item['price']!.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      showAppDialog(
        context,
        title: 'Required',
        message: 'Please enter a package name.',
      );
      return;
    }
    final valid = _items
        .where(
          (i) =>
      i['name']!.text.trim().isNotEmpty && i['price']!.text.isNotEmpty,
    )
        .map(
          (i) => PackageItem(
        id: 0,
        itemName: i['name']!.text.trim(),
        price: double.tryParse(i['price']!.text) ?? 0,
      ),
    )
        .toList();
    if (valid.isEmpty) {
      showAppDialog(
        context,
        title: 'Items Required',
        message: 'Please add at least one valid item.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final pkg = MenuPackage(
        id: 0,
        packageName: _nameCtrl.text.trim(),
        packageType: _type,
        totalPrice: valid.fold(0, (s, i) => s + i.price),
        items: valid,
      );
      // CHANGED: Pass imageFile directly
      await MenuService.addPackage(
        pkg: pkg,
        imageFile: _imageFile, // Changed from imageBytes
        // imageFileName removed
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to add package.',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Handle(),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _kPLt,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: _kP,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Package',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _kT1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Field(_nameCtrl, 'Package Name *', Icons.restaurant_rounded),
              const SizedBox(height: 10),
              // Type dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Package Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kT2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kBrd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _type,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _kP,
                          size: 18,
                        ),
                        style: const TextStyle(fontSize: 13, color: _kT1),
                        onChanged: (v) => setState(() => _type = v ?? 'Veg'),
                        items: const [
                          DropdownMenuItem(value: 'Veg', child: Text('Veg')),
                          DropdownMenuItem(
                            value: 'Non_veg',
                            child: Text('Non-Veg'),
                          ),
                          DropdownMenuItem(
                            value: 'Drinks',
                            child: Text('Drinks'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Image picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Package Image (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kT2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _imageFile != null ? _kP : _kBrd,
                          width: _imageFile != null ? 1.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _imageFile != null
                            ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_imageFile!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black54,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: _kW,
                                      size: 13,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Tap to change',
                                      style: TextStyle(
                                        color: _kW,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                            : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: _kMut,
                              size: 32,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap to upload image',
                              style: TextStyle(
                                fontSize: 12,
                                color: _kMut,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'JPG, PNG • Max 5MB',
                              style: TextStyle(
                                fontSize: 10,
                                color: _kBrd,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Items header
              Row(
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kT1,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _addItem,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _kPLt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: _kP, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Add Item',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kP,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _TF(e.value['name']!, 'Item name'),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: _TF(
                          e.value['price']!,
                          '₹ Price',
                          TextInputType.number,
                        ),
                      ),
                      if (_items.length > 1) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeItem(e.key),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: _kDLt,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _kDng,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SaveRow(
                    () => Navigator.pop(context),
                _saving ? null : _save,
                'Save Package',
                _saving,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Shared bottom sheet helpers ────────────────────────────────────────────────
class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kBrd,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType type;
  const _Field(
      this.ctrl,
      this.hint,
      this.icon, {
        this.type = TextInputType.text,
      });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _kBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBrd),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontSize: 13, color: _kT1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kMut, fontSize: 13),
        prefixIcon: Icon(icon, color: _kP, size: 17),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      ),
    ),
  );
}

class _TF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType type;
  const _TF(this.ctrl, this.hint, [this.type = TextInputType.text]);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _kBg,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: _kBrd),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontSize: 13, color: _kT1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kMut, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    ),
  );
}

class _SaveRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final String label;
  final bool saving;
  const _SaveRow(this.onCancel, this.onSave, this.label, this.saving);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: onCancel,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBrd),
            ),
            child: const Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kT2,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: onSave,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            decoration: BoxDecoration(
              gradient: onSave != null ? _kGrd : null,
              color: onSave == null ? _kBrd : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: onSave != null
                  ? [
                BoxShadow(
                  color: _kP.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: _kW,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: _kW,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}