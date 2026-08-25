// //
// // import 'package:flutter/material.dart';
// // import '../models/models.dart';
// // import '../services/api_service.dart';
// // import '../widgets/common_widgets.dart';
// // import 'add_category_sheet.dart';
// // import 'add_dish_sheet.dart';
// // import 'edit_category_sheet.dart';
// // import 'edit_dish_sheet.dart';
// //
// // // ─── tokens ───────────────────────────────────────────────────────────────────
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
// // const _kWrn = Color(0xFF16A34A);
// // const _kWLt = Color(0xFFDCFCE7);
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
// // // ─── Compact iOS-style On/Off toggle ─────────────────────────────────────────
// //
// // class _OnOffSwitch extends StatelessWidget {
// //   final bool value;
// //   final ValueChanged<bool> onChanged;
// //   const _OnOffSwitch({required this.value, required this.onChanged});
// //
// //   @override
// //   Widget build(BuildContext context) => Transform.scale(
// //     scale: 0.75,
// //     alignment: Alignment.centerRight,
// //     child: Switch(
// //       value: value,
// //       onChanged: onChanged,
// //       activeColor: Colors.white,
// //       activeTrackColor: _kSuc,
// //       inactiveThumbColor: Colors.white,
// //       inactiveTrackColor: _kDng,
// //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //       thumbColor: WidgetStateProperty.all(Colors.white),
// //       trackOutlineColor: WidgetStateProperty.resolveWith(
// //         (states) => states.contains(WidgetState.selected)
// //             ? _kSDk
// //             : const Color(0xFFD32F2F),
// //       ),
// //     ),
// //   );
// // }
// //
// // class MenuTab extends StatefulWidget {
// //   const MenuTab({super.key});
// //   @override
// //   State<MenuTab> createState() => MenuTabState();
// // }
// //
// // class MenuTabState extends State<MenuTab> {
// //   List<MenuCategory> _data = [];
// //   List<MenuCategory> _filtered = [];
// //   bool _loading = true;
// //
// //   String? _error;
// //   final _searchCtrl = TextEditingController();
// //   String _searchQuery = '';
// //   String? _selectedCategory;
// //   bool? _isVeg;
// //   final Set<int> _expanded = {};
// //   bool _bulkMode = false;
// //   final Set<int> _selectedDishIds = {};
// //   final _bulkQtyCtrl = TextEditingController();
// //
// //   // ── Overlay filter state ──────────────────────────────────────────────────
// //   bool _filtersExpanded = false;
// //   final LayerLink _filterLayerLink = LayerLink();
// //   OverlayEntry? _filterOverlay;
// //
// //   void _showFilterOverlay() {
// //     _filterOverlay = OverlayEntry(
// //       builder: (_) => GestureDetector(
// //         behavior: HitTestBehavior.translucent,
// //         onTap: _removeFilterOverlay,
// //         child: Stack(
// //           children: [
// //             CompositedTransformFollower(
// //               link: _filterLayerLink,
// //               showWhenUnlinked: false,
// //               offset: const Offset(-160, 48),
// //               child: GestureDetector(
// //                 onTap: () {}, // prevent dismiss on tap inside
// //                 child: Material(
// //                   color: Colors.transparent,
// //                   child: _FilterDropdown(
// //                     selectedCategory: _selectedCategory,
// //                     isVeg: _isVeg,
// //                     onCategoryTap: () {
// //                       _removeFilterOverlay();
// //                       _showCategoryFilter();
// //                     },
// //                     onCategoryClear: () {
// //                       setState(() => _selectedCategory = null);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                     onVegTap: () {
// //                       setState(() => _isVeg = _isVeg == true ? null : true);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                     onNonVegTap: () {
// //                       setState(() => _isVeg = _isVeg == false ? null : false);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //     Overlay.of(context).insert(_filterOverlay!);
// //     setState(() => _filtersExpanded = true);
// //   }
// //
// //   void _removeFilterOverlay() {
// //     _filterOverlay?.remove();
// //     _filterOverlay = null;
// //     if (mounted) setState(() => _filtersExpanded = false);
// //   }
// //
// //   // ── Public methods called from parent ────────────────────────────────────
// //   void filterByCategory(String category) {
// //     setState(() {
// //       if (category == 'all') {
// //         _selectedCategory = null;
// //         _isVeg = null;
// //       } else if (category == 'veg') {
// //         _selectedCategory = null;
// //         _isVeg = true;
// //       } else if (category == 'non-veg') {
// //         _selectedCategory = null;
// //         _isVeg = false;
// //       }
// //       _applyFilter();
// //     });
// //   }
// //
// //   void openAddCategory() {
// //     _openSheet(AddCategorySheet(onSaved: _fetchData));
// //   }
// //
// //   void enableBulkMode() {
// //     setState(() => _bulkMode = true);
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
// //     _filterOverlay?.remove();
// //     _filterOverlay = null;
// //     _searchCtrl.dispose();
// //     _bulkQtyCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _fetchData() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final result = await MenuService.fetchMenu();
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
// //     if (_selectedCategory != null)
// //       f = f.where((c) => c.category == _selectedCategory).toList();
// //     if (_isVeg != null) {
// //       f = f
// //           .map(
// //             (c) => c.copyWith(
// //               subcategories: c.subcategories
// //                   .where((s) => _isVeg! ? s.tag == 'Veg' : s.tag == 'Non_Veg')
// //                   .toList(),
// //             ),
// //           )
// //           .where((c) => c.subcategories.isNotEmpty)
// //           .toList();
// //     }
// //     if (_searchQuery.isNotEmpty) {
// //       final q = _searchQuery.toLowerCase();
// //       f = f
// //           .map((c) {
// //             final cm = c.category.toLowerCase().contains(q);
// //             final subs = c.subcategories
// //                 .where(
// //                   (s) =>
// //                       s.subName.toLowerCase().contains(q) ||
// //                       s.description.toLowerCase().contains(q),
// //                 )
// //                 .toList();
// //             if (cm || subs.isNotEmpty)
// //               return c.copyWith(subcategories: cm ? c.subcategories : subs);
// //             return null;
// //           })
// //           .whereType<MenuCategory>()
// //           .toList();
// //     }
// //     setState(() => _filtered = f);
// //   }
// //
// //   Future<void> _toggleStatus(MenuCategory cat, int? subIndex) async {
// //     final dishId = subIndex == null
// //         ? cat.dishId
// //         : cat.subcategories[subIndex].dishId;
// //     final current = subIndex == null
// //         ? cat.menuStatus
// //         : cat.subcategories[subIndex].menuStatus;
// //     try {
// //       await MenuService.toggleMenuStatus(
// //         dishId,
// //         current == 'Enable' ? 'Disable' : 'Enable',
// //       );
// //       await _fetchData();
// //     } catch (e) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to update status.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteCategory(MenuCategory cat) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Category',
// //       message: 'Delete "${cat.category}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deleteCategory(cat.dishId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete category.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteSubDish(SubDish sub) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Dish',
// //       message: 'Delete "${sub.subName}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deleteSubDish(sub.dishId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete dish.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _bulkUpdate() async {
// //     if (_selectedDishIds.isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'No Selection',
// //         message: 'Please select at least one dish.',
// //       );
// //       return;
// //     }
// //     final qty = int.tryParse(_bulkQtyCtrl.text);
// //     if (qty == null) {
// //       showAppDialog(
// //         context,
// //         title: 'Invalid Input',
// //         message: 'Please enter a valid quantity.',
// //       );
// //       return;
// //     }
// //     int success = 0;
// //     for (final id in _selectedDishIds) {
// //       try {
// //         for (final cat in _data) {
// //           for (final sub in cat.subcategories) {
// //             if (sub.dishId == id) {
// //               await MenuService.editSubDish(sub.copyWith(stockQuantity: qty));
// //               success++;
// //             }
// //           }
// //         }
// //       } catch (_) {}
// //     }
// //     if (mounted) {
// //       showAppDialog(
// //         context,
// //         title: 'Done',
// //         message: 'Updated $success items.',
// //         isSuccess: true,
// //       );
// //       setState(() {
// //         _bulkMode = false;
// //         _selectedDishIds.clear();
// //         _bulkQtyCtrl.clear();
// //       });
// //       await _fetchData();
// //     }
// //   }
// //
// //   void _showCategoryFilter() {
// //     final cats = _data.map((c) => c.category).toSet().toList();
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       useSafeArea: true,
// //       backgroundColor: Colors.transparent,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) => _CategoryFilterSheet(
// //         categories: cats,
// //         selected: _selectedCategory,
// //         onSelect: (c) {
// //           setState(() => _selectedCategory = c);
// //           _applyFilter();
// //           Navigator.pop(context);
// //         },
// //       ),
// //     );
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
// //     return Column(
// //       children: [
// //         // ── Filter bar ──────────────────────────────────────────────────────
// //         Container(
// //           color: _kW,
// //           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
// //           child: Column(
// //             children: [
// //               // Search row with filter button
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       height: 42,
// //                       decoration: BoxDecoration(
// //                         color: _kBg,
// //                         borderRadius: BorderRadius.circular(11),
// //                         border: Border.all(color: _kBrd),
// //                       ),
// //                       child: TextField(
// //                         controller: _searchCtrl,
// //                         style: const TextStyle(fontSize: 13, color: _kT1),
// //                         onChanged: (v) {
// //                           _searchQuery = v;
// //                           _applyFilter();
// //                           setState(() {});
// //                         },
// //                         decoration: InputDecoration(
// //                           hintText: 'Search dishes or categories...',
// //                           hintStyle: const TextStyle(
// //                             color: _kMut,
// //                             fontSize: 13,
// //                           ),
// //                           prefixIcon: const Icon(
// //                             Icons.search_rounded,
// //                             color: _kMut,
// //                             size: 18,
// //                           ),
// //                           suffixIcon: _searchCtrl.text.isNotEmpty
// //                               ? IconButton(
// //                                   icon: const Icon(
// //                                     Icons.close_rounded,
// //                                     size: 16,
// //                                     color: _kMut,
// //                                   ),
// //                                   onPressed: () {
// //                                     _searchCtrl.clear();
// //                                     _searchQuery = '';
// //                                     _applyFilter();
// //                                     setState(() {});
// //                                   },
// //                                 )
// //                               : null,
// //                           border: InputBorder.none,
// //                           contentPadding: const EdgeInsets.symmetric(
// //                             vertical: 11,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   // ── Overlay filter button ────────────────────────────────
// //                   CompositedTransformTarget(
// //                     link: _filterLayerLink,
// //                     child: GestureDetector(
// //                       onTap: () => _filtersExpanded
// //                           ? _removeFilterOverlay()
// //                           : _showFilterOverlay(),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         width: 42,
// //                         height: 42,
// //                         decoration: BoxDecoration(
// //                           color: _filtersExpanded ? _kPLt : _kBg,
// //                           borderRadius: BorderRadius.circular(11),
// //                           border: Border.all(
// //                             color: _filtersExpanded ? _kP : _kBrd,
// //                             width: _filtersExpanded ? 1.5 : 1,
// //                           ),
// //                         ),
// //                         child: Icon(
// //                           Icons.tune_rounded,
// //                           size: 18,
// //                           color: _filtersExpanded ? _kP : _kT2,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               // Active filter chips (shown when filters are active)
// //               if (_selectedCategory != null || _isVeg != null) ...[
// //                 const SizedBox(height: 8),
// //                 SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Row(
// //                     children: [
// //                       if (_selectedCategory != null)
// //                         _FChip(
// //                           label: _selectedCategory!,
// //                           active: true,
// //                           icon: Icons.folder_rounded,
// //                           onTap: _showCategoryFilter,
// //                           onClear: () {
// //                             setState(() => _selectedCategory = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       if (_selectedCategory != null && _isVeg != null)
// //                         const SizedBox(width: 6),
// //                       if (_isVeg == true)
// //                         _FChip(
// //                           label: '🟢 Veg',
// //                           active: true,
// //                           activeColor: _kSuc,
// //                           activeBg: _kSLt,
// //                           onTap: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                           onClear: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       if (_isVeg == false)
// //                         _FChip(
// //                           label: '🔴 Non-Veg',
// //                           active: true,
// //                           activeColor: _kDng,
// //                           activeBg: _kDLt,
// //                           onTap: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                           onClear: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       const SizedBox(width: 6),
// //                       _FChip(
// //                         label: 'Clear all',
// //                         active: false,
// //                         icon: Icons.close_rounded,
// //                         onTap: () {
// //                           setState(() {
// //                             _selectedCategory = null;
// //                             _isVeg = null;
// //                           });
// //                           _applyFilter();
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //               // Bulk controls
// //               if (_bulkMode) ...[
// //                 const SizedBox(height: 8),
// //                 Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: BoxDecoration(
// //                     color: _kWLt,
// //                     borderRadius: BorderRadius.circular(10),
// //                     border: Border.all(color: _kWrn.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             color: _kW,
// //                             borderRadius: BorderRadius.circular(8),
// //                             border: Border.all(color: _kBrd),
// //                           ),
// //                           child: TextField(
// //                             controller: _bulkQtyCtrl,
// //                             keyboardType: TextInputType.number,
// //                             style: const TextStyle(fontSize: 13, color: _kT1),
// //                             decoration: const InputDecoration(
// //                               hintText: 'Set stock quantity',
// //                               hintStyle: TextStyle(color: _kMut, fontSize: 13),
// //                               prefixIcon: Icon(
// //                                 Icons.inventory_2_rounded,
// //                                 color: _kWrn,
// //                                 size: 16,
// //                               ),
// //                               border: InputBorder.none,
// //                               contentPadding: EdgeInsets.symmetric(
// //                                 vertical: 10,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       _PillBtn(
// //                         'Update (${_selectedDishIds.length})',
// //                         _kSuc,
// //                         _kSLt,
// //                         _bulkUpdate,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       _PillBtn(
// //                         'Cancel',
// //                         _kT2,
// //                         _kBg,
// //                         () => setState(() {
// //                           _bulkMode = false;
// //                           _selectedDishIds.clear();
// //                           _bulkQtyCtrl.clear();
// //                         }),
// //                         outlined: true,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //               const SizedBox(height: 8),
// //               const Divider(color: _kBrd, height: 1),
// //             ],
// //           ),
// //         ),
// //
// //         const Divider(color: _kBrd, height: 1),
// //
// //         // ── Content ─────────────────────────────────────────────────────────
// //         Expanded(
// //           child: _loading
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
// //                 )
// //               : _error != null
// //               ? _ErrState(msg: _error!, onRetry: _fetchData)
// //               : _filtered.isEmpty
// //               ? _EmptyState()
// //               : RefreshIndicator(
// //                   color: _kP,
// //                   onRefresh: _fetchData,
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
// //                     itemCount: _filtered.length,
// //                     itemBuilder: (_, i) => _CategoryCard(
// //                       category: _filtered[i],
// //                       isExpanded: _expanded.contains(_filtered[i].dishId),
// //                       bulkMode: _bulkMode,
// //                       selectedIds: _selectedDishIds,
// //                       onToggleExpand: () => setState(() {
// //                         _expanded.contains(_filtered[i].dishId)
// //                             ? _expanded.remove(_filtered[i].dishId)
// //                             : _expanded.add(_filtered[i].dishId);
// //                       }),
// //                       onToggleStatus: (si) => _toggleStatus(_filtered[i], si),
// //                       onEdit: () => _openSheet(
// //                         EditCategorySheet(
// //                           category: _filtered[i],
// //                           onSaved: _fetchData,
// //                         ),
// //                       ),
// //                       onDelete: () => _deleteCategory(_filtered[i]),
// //                       onAddDish: () => _openSheet(
// //                         AddDishSheet(
// //                           categoryId: _filtered[i].dishId,
// //                           categoryName: _filtered[i].category,
// //                           onSaved: _fetchData,
// //                         ),
// //                       ),
// //                       onEditDish: (sub, _) => _openSheet(
// //                         EditDishSheet(sub: sub, onSaved: _fetchData),
// //                       ),
// //                       onDeleteDish: (sub) => _deleteSubDish(sub),
// //                       onSelectChanged: (id, val) => setState(
// //                         () => val
// //                             ? _selectedDishIds.add(id)
// //                             : _selectedDishIds.remove(id),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // ── Filter Dropdown (overlay) ─────────────────────────────────────────────────
// // class _FilterDropdown extends StatelessWidget {
// //   final String? selectedCategory;
// //   final bool? isVeg;
// //   final VoidCallback onCategoryTap, onVegTap, onNonVegTap;
// //   final VoidCallback? onCategoryClear;
// //
// //   const _FilterDropdown({
// //     required this.selectedCategory,
// //     required this.isVeg,
// //     required this.onCategoryTap,
// //     required this.onVegTap,
// //     required this.onNonVegTap,
// //     this.onCategoryClear,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 200,
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: _kW,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: _kBrd),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.10),
// //             blurRadius: 16,
// //             offset: const Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _DropItem(
// //             icon: Icons.grid_view_rounded,
// //             label: selectedCategory ?? 'Categories',
// //             isActive: selectedCategory != null,
// //             activeColor: _kP,
// //             activeBg: _kPLt,
// //             onTap: onCategoryTap,
// //             onClear: selectedCategory != null ? onCategoryClear : null,
// //           ),
// //           const SizedBox(height: 3),
// //           _DropItem(
// //             dotColor: _kSuc,
// //             label: 'Veg',
// //             isActive: isVeg == true,
// //             activeColor: _kSuc,
// //             activeBg: _kSLt,
// //             onTap: onVegTap,
// //           ),
// //           const SizedBox(height: 3),
// //           _DropItem(
// //             dotColor: _kDng,
// //             label: 'Non-Veg',
// //             isActive: isVeg == false,
// //             activeColor: _kDng,
// //             activeBg: _kDLt,
// //             onTap: onNonVegTap,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _DropItem extends StatelessWidget {
// //   final String label;
// //   final bool isActive;
// //   final Color activeColor, activeBg;
// //   final VoidCallback onTap;
// //   final VoidCallback? onClear;
// //   final IconData? icon;
// //   final Color? dotColor;
// //
// //   const _DropItem({
// //     required this.label,
// //     required this.isActive,
// //     required this.activeColor,
// //     required this.activeBg,
// //     required this.onTap,
// //     this.onClear,
// //     this.icon,
// //     this.dotColor,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //         decoration: BoxDecoration(
// //           color: isActive ? activeBg : Colors.transparent,
// //           borderRadius: BorderRadius.circular(9),
// //         ),
// //         child: Row(
// //           children: [
// //             if (dotColor != null)
// //               Container(
// //                 width: 9,
// //                 height: 9,
// //                 decoration: BoxDecoration(
// //                   color: dotColor,
// //                   shape: BoxShape.circle,
// //                 ),
// //               )
// //             else
// //               Icon(icon, size: 15, color: isActive ? activeColor : _kT2),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: isActive ? activeColor : _kT1,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //             if (isActive && onClear != null)
// //               GestureDetector(
// //                 onTap: onClear,
// //                 child: Icon(Icons.close_rounded, size: 13, color: activeColor),
// //               )
// //             else if (isActive)
// //               Icon(Icons.check_rounded, size: 14, color: activeColor),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Reusable chip / btn ────────────────────────────────────────────────────────
// // class _FChip extends StatelessWidget {
// //   final String label;
// //   final bool active;
// //   final Color? activeColor, activeBg;
// //   final IconData? icon;
// //   final VoidCallback onTap;
// //   final VoidCallback? onClear;
// //   const _FChip({
// //     required this.label,
// //     required this.active,
// //     required this.onTap,
// //     this.activeColor,
// //     this.activeBg,
// //     this.icon,
// //     this.onClear,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = activeColor ?? _kP;
// //     final bg = activeBg ?? _kPLt;
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //         decoration: BoxDecoration(
// //           color: active ? bg : _kBg,
// //           borderRadius: BorderRadius.circular(9),
// //           border: Border.all(
// //             color: active ? color.withOpacity(0.4) : _kBrd,
// //             width: active ? 1.5 : 1,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             if (icon != null) ...[
// //               Icon(icon, size: 12, color: active ? color : _kT2),
// //               const SizedBox(width: 4),
// //             ],
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 11,
// //                 fontWeight: FontWeight.w700,
// //                 color: active ? color : _kT2,
// //               ),
// //             ),
// //             if (onClear != null) ...[
// //               const SizedBox(width: 4),
// //               GestureDetector(
// //                 onTap: onClear,
// //                 child: Icon(Icons.close_rounded, size: 11, color: color),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _PillBtn extends StatelessWidget {
// //   final String label;
// //   final Color color, bg;
// //   final VoidCallback onTap;
// //   final IconData? icon;
// //   final bool outlined;
// //   const _PillBtn(
// //     this.label,
// //     this.color,
// //     this.bg,
// //     this.onTap, {
// //     this.icon,
// //     this.outlined = false,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
// //       decoration: BoxDecoration(
// //         color: outlined ? _kW : bg,
// //         borderRadius: BorderRadius.circular(9),
// //         border: Border.all(color: outlined ? _kBrd : color.withOpacity(0.25)),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           if (icon != null) ...[
// //             Icon(icon, size: 14, color: color),
// //             const SizedBox(width: 5),
// //           ],
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 12,
// //               fontWeight: FontWeight.w700,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // class _ErrState extends StatelessWidget {
// //   final String msg;
// //   final VoidCallback onRetry;
// //   const _ErrState({required this.msg, required this.onRetry});
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
// //             'Failed to load menu',
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
// //
// // class _EmptyState extends StatelessWidget {
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
// //           child: const Icon(Icons.inbox_outlined, color: _kW, size: 30),
// //         ),
// //         const SizedBox(height: 14),
// //         const Text(
// //           'No items found',
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.w700,
// //             color: _kT1,
// //           ),
// //         ),
// //         const SizedBox(height: 5),
// //         const Text(
// //           'Try adjusting your filters',
// //           style: TextStyle(fontSize: 12, color: _kT2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Category Card ──────────────────────────────────────────────────────────────
// // class _CategoryCard extends StatelessWidget {
// //   final MenuCategory category;
// //   final bool isExpanded, bulkMode;
// //   final Set<int> selectedIds;
// //   final VoidCallback onToggleExpand;
// //   final Function(int?) onToggleStatus;
// //   final VoidCallback onEdit, onDelete, onAddDish;
// //   final Function(SubDish, int) onEditDish;
// //   final Function(SubDish) onDeleteDish;
// //   final Function(int, bool) onSelectChanged;
// //
// //   const _CategoryCard({
// //     required this.category,
// //     required this.isExpanded,
// //     required this.bulkMode,
// //     required this.selectedIds,
// //     required this.onToggleExpand,
// //     required this.onToggleStatus,
// //     required this.onEdit,
// //     required this.onDelete,
// //     required this.onAddDish,
// //     required this.onEditDish,
// //     required this.onDeleteDish,
// //     required this.onSelectChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: isExpanded ? _kP.withOpacity(0.25) : _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     ),
// //     child: Column(
// //       children: [
// //         // Header
// //         GestureDetector(
// //           onTap: onToggleExpand,
// //           child: Container(
// //             padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
// //             decoration: BoxDecoration(
// //               color: isExpanded ? _kPLt.withOpacity(0.4) : _kW,
// //               borderRadius: isExpanded
// //                   ? const BorderRadius.vertical(top: Radius.circular(16))
// //                   : BorderRadius.circular(16),
// //             ),
// //             child: Row(
// //               children: [
// //                 if (bulkMode) ...[
// //                   Checkbox(
// //                     value: category.subcategories.every(
// //                       (s) => selectedIds.contains(s.dishId),
// //                     ),
// //                     onChanged: (v) {
// //                       for (final s in category.subcategories)
// //                         onSelectChanged(s.dishId, v ?? false);
// //                     },
// //                     activeColor: _kP,
// //                     visualDensity: VisualDensity.compact,
// //                   ),
// //                   const SizedBox(width: 4),
// //                 ],
// //                 DishImage(url: category.image, size: 44),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         category.category,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 14,
// //                           color: _kT1,
// //                         ),
// //                       ),
// //                       Text(
// //                         '${category.subcategories.length} dishes',
// //                         style: const TextStyle(fontSize: 11, color: _kT2),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // ── Category On/Off toggle ────────────────────────────────
// //                 _OnOffSwitch(
// //                   value: category.menuStatus == 'Enable',
// //                   onChanged: (_) => onToggleStatus(null),
// //                 ),
// //
// //                 // Action popup
// //                 PopupMenuButton<String>(
// //                   icon: const Icon(
// //                     Icons.more_vert_rounded,
// //                     size: 18,
// //                     color: _kT2,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   onSelected: (v) {
// //                     if (v == 'add') onAddDish();
// //                     if (v == 'edit') onEdit();
// //                     if (v == 'delete') onDelete();
// //                   },
// //                   itemBuilder: (_) => [
// //                     _pItem(
// //                       'add',
// //                       Icons.add_circle_outline_rounded,
// //                       'Add Dish',
// //                       _kSuc,
// //                     ),
// //                     _pItem('edit', Icons.edit_outlined, 'Edit Category', _kInf),
// //                     _pItem(
// //                       'delete',
// //                       Icons.delete_outline_rounded,
// //                       'Delete',
// //                       _kDng,
// //                       danger: true,
// //                     ),
// //                   ],
// //                 ),
// //                 AnimatedRotation(
// //                   turns: isExpanded ? 0.5 : 0,
// //                   duration: const Duration(milliseconds: 200),
// //                   child: Icon(
// //                     Icons.keyboard_arrow_down_rounded,
// //                     color: isExpanded ? _kP : _kMut,
// //                     size: 20,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         // Dishes
// //         if (isExpanded) ...[
// //           Divider(
// //             color: _kBrd.withOpacity(0.7),
// //             height: 1,
// //             indent: 12,
// //             endIndent: 12,
// //           ),
// //           if (category.subcategories.isEmpty)
// //             Padding(
// //               padding: const EdgeInsets.all(14),
// //               child: Center(
// //                 child: Text(
// //                   'No dishes — tap ··· to add one',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _kMut,
// //                     fontStyle: FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...category.subcategories.asMap().entries.map(
// //               (e) => _DishRow(
// //                 sub: e.value,
// //                 index: e.key,
// //                 bulkMode: bulkMode,
// //                 isSelected: selectedIds.contains(e.value.dishId),
// //                 isLast: e.key == category.subcategories.length - 1,
// //                 onToggleStatus: () => onToggleStatus(e.key),
// //                 onEdit: () => onEditDish(e.value, e.key),
// //                 onDelete: () => onDeleteDish(e.value),
// //                 onSelectChanged: (v) => onSelectChanged(e.value.dishId, v),
// //               ),
// //             ),
// //         ],
// //       ],
// //     ),
// //   );
// //
// //   PopupMenuItem<String> _pItem(
// //     String val,
// //     IconData icon,
// //     String label,
// //     Color color, {
// //     bool danger = false,
// //   }) => PopupMenuItem(
// //     value: val,
// //     child: Row(
// //       children: [
// //         Container(
// //           width: 28,
// //           height: 28,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(7),
// //           ),
// //           child: Icon(icon, size: 14, color: color),
// //         ),
// //         const SizedBox(width: 10),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 13,
// //             fontWeight: FontWeight.w600,
// //             color: danger ? _kDng : _kT1,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Dish Row ───────────────────────────────────────────────────────────────────
// // class _DishRow extends StatelessWidget {
// //   final SubDish sub;
// //   final int index;
// //   final bool bulkMode, isSelected, isLast;
// //   final VoidCallback onToggleStatus, onEdit, onDelete;
// //   final Function(bool) onSelectChanged;
// //
// //   const _DishRow({
// //     required this.sub,
// //     required this.index,
// //     required this.bulkMode,
// //     required this.isSelected,
// //     required this.isLast,
// //     required this.onToggleStatus,
// //     required this.onEdit,
// //     required this.onDelete,
// //     required this.onSelectChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Column(
// //     children: [
// //       Padding(
// //         padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (bulkMode) ...[
// //               Checkbox(
// //                 value: isSelected,
// //                 onChanged: (v) => onSelectChanged(v ?? false),
// //                 activeColor: _kP,
// //                 visualDensity: VisualDensity.compact,
// //               ),
// //               const SizedBox(width: 2),
// //             ],
// //             Container(
// //               width: 2,
// //               height: 50,
// //               margin: const EdgeInsets.only(left: 4, right: 8),
// //               decoration: BoxDecoration(
// //                 color: _kP.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             DishImage(url: sub.image, size: 48),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         width: 8,
// //                         height: 8,
// //                         decoration: BoxDecoration(
// //                           color: sub.tag == 'Veg' ? _kSuc : _kDng,
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 5),
// //                       Expanded(
// //                         child: Text(
// //                           sub.subName,
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.w700,
// //                             fontSize: 13,
// //                             color: _kT1,
// //                           ),
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Wrap(
// //                     spacing: 5,
// //                     runSpacing: 4,
// //                     children: [
// //                       _IC(
// //                         Icons.currency_rupee_rounded,
// //                         '₹${sub.price.toStringAsFixed(0)}',
// //                         _kP,
// //                         _kPLt,
// //                       ),
// //                       _IC(
// //                         Icons.percent_rounded,
// //                         'GST ${sub.gst.toStringAsFixed(0)}%',
// //                         _kInf,
// //                         _kILt,
// //                       ),
// //                       _IC(
// //                         Icons.inventory_2_rounded,
// //                         'Stock ${sub.stockQuantity}',
// //                         sub.stockQuantity > 0 ? _kSuc : _kDng,
// //                         sub.stockQuantity > 0 ? _kSLt : _kDLt,
// //                       ),
// //                       if (sub.packingCharges > 0)
// //                         _IC(
// //                           Icons.local_shipping_outlined,
// //                           '₹${sub.packingCharges.toStringAsFixed(0)} pkg',
// //                           _kWrn,
// //                           _kWLt,
// //                         ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.restaurant_menu_rounded,
// //                         size: 11,
// //                         color: _kMut,
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         sub.chefType.replaceFirst('Chef_', ''),
// //                         style: const TextStyle(fontSize: 10, color: _kT2),
// //                       ),
// //                       const Spacer(),
// //                       // ── Dish On/Off toggle ──────────────────────────────
// //                       _OnOffSwitch(
// //                         value: sub.menuStatus == 'Enable',
// //                         onChanged: (_) => onToggleStatus(),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 _IB(Icons.edit_outlined, _kInf, onEdit),
// //                 const SizedBox(height: 4),
// //                 _IB(Icons.delete_outline_rounded, _kDng, onDelete),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //       if (!isLast)
// //         Divider(
// //           color: _kBrd.withOpacity(0.5),
// //           height: 1,
// //           indent: 12,
// //           endIndent: 12,
// //         ),
// //     ],
// //   );
// // }
// //
// // class _IC extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final Color color, bg;
// //   const _IC(this.icon, this.label, this.color, this.bg);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //     decoration: BoxDecoration(
// //       color: bg,
// //       borderRadius: BorderRadius.circular(6),
// //     ),
// //     child: Row(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(icon, size: 10, color: color),
// //         const SizedBox(width: 3),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 10,
// //             color: color,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // class _IB extends StatelessWidget {
// //   final IconData icon;
// //   final Color color;
// //   final VoidCallback onTap;
// //   const _IB(this.icon, this.color, this.onTap);
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(7),
// //       ),
// //       child: Icon(icon, size: 15, color: color),
// //     ),
// //   );
// // }
// //
// // // ── Category Filter Sheet ─────────────────────────────────────────────────────
// // class _CategoryFilterSheet extends StatelessWidget {
// //   final List<String> categories;
// //   final String? selected;
// //   final Function(String?) onSelect;
// //   const _CategoryFilterSheet({
// //     required this.categories,
// //     this.selected,
// //     required this.onSelect,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Container(
// //       decoration: const BoxDecoration(
// //         color: _kW,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: 36,
// //             height: 4,
// //             decoration: BoxDecoration(
// //               color: _kBrd,
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'Filter by Category',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w800,
// //               color: _kT1,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           _row(null, 'All Categories', Icons.apps_rounded, selected),
// //           ...categories.map((c) => _row(c, c, Icons.folder_rounded, selected)),
// //           const SizedBox(height: 6),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _row(String? val, String label, IconData icon, String? selected) {
// //     final sel = selected == val;
// //     return GestureDetector(
// //       onTap: () => onSelect(val),
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 6),
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
// //         decoration: BoxDecoration(
// //           color: sel ? _kPLt : _kBg,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: sel ? _kP.withOpacity(0.3) : _kBrd),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, size: 16, color: sel ? _kP : _kT2),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: sel ? _kP : _kT1,
// //                 ),
// //               ),
// //             ),
// //             if (sel) const Icon(Icons.check_rounded, color: _kP, size: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import '../models/models.dart';
// // import '../services/api_service.dart';
// // import '../widgets/common_widgets.dart';
// // import 'add_category_sheet.dart';
// // import 'add_dish_sheet.dart';
// // import 'edit_category_sheet.dart';
// // import 'edit_dish_sheet.dart';
// //
// // // ─── tokens ───────────────────────────────────────────────────────────────────
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
// // const _kWrn = Color(0xFF16A34A);
// // const _kWLt = Color(0xFFDCFCE7);
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
// // // ─── Compact iOS-style On/Off toggle ─────────────────────────────────────────
// //
// // class _OnOffSwitch extends StatelessWidget {
// //   final bool value;
// //   final ValueChanged<bool> onChanged;
// //   const _OnOffSwitch({required this.value, required this.onChanged});
// //
// //   @override
// //   Widget build(BuildContext context) => Transform.scale(
// //     scale: 0.75,
// //     alignment: Alignment.centerRight,
// //     child: Switch(
// //       value: value,
// //       onChanged: onChanged,
// //       activeColor: Colors.white,
// //       activeTrackColor: _kSuc,
// //       inactiveThumbColor: Colors.white,
// //       inactiveTrackColor: _kDng,
// //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //       thumbColor: WidgetStateProperty.all(Colors.white),
// //       trackOutlineColor: WidgetStateProperty.resolveWith(
// //         (states) => states.contains(WidgetState.selected)
// //             ? _kSDk
// //             : const Color(0xFFD32F2F),
// //       ),
// //     ),
// //   );
// // }
// //
// // class MenuTab extends StatefulWidget {
// //   const MenuTab({super.key});
// //   @override
// //   State<MenuTab> createState() => MenuTabState();
// // }
// //
// // class MenuTabState extends State<MenuTab> {
// //   List<MenuCategory> _data = [];
// //   List<MenuCategory> _filtered = [];
// //   bool _loading = true;
// //
// //   String? _error;
// //   final _searchCtrl = TextEditingController();
// //   String _searchQuery = '';
// //   String? _selectedCategory;
// //   bool? _isVeg;
// //   final Set<int> _expanded = {};
// //   bool _bulkMode = false;
// //   final Set<int> _selectedDishIds = {};
// //   final _bulkQtyCtrl = TextEditingController();
// //
// //   // ── Overlay filter state ──────────────────────────────────────────────────
// //   bool _filtersExpanded = false;
// //   final LayerLink _filterLayerLink = LayerLink();
// //   OverlayEntry? _filterOverlay;
// //
// //   void _showFilterOverlay() {
// //     _filterOverlay = OverlayEntry(
// //       builder: (_) => GestureDetector(
// //         behavior: HitTestBehavior.translucent,
// //         onTap: _removeFilterOverlay,
// //         child: Stack(
// //           children: [
// //             CompositedTransformFollower(
// //               link: _filterLayerLink,
// //               showWhenUnlinked: false,
// //               offset: const Offset(-160, 48),
// //               child: GestureDetector(
// //                 onTap: () {}, // prevent dismiss on tap inside
// //                 child: Material(
// //                   color: Colors.transparent,
// //                   child: _FilterDropdown(
// //                     selectedCategory: _selectedCategory,
// //                     isVeg: _isVeg,
// //                     onCategoryTap: () {
// //                       _removeFilterOverlay();
// //                       _showCategoryFilter();
// //                     },
// //                     onCategoryClear: () {
// //                       setState(() => _selectedCategory = null);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                     onVegTap: () {
// //                       setState(() => _isVeg = _isVeg == true ? null : true);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                     onNonVegTap: () {
// //                       setState(() => _isVeg = _isVeg == false ? null : false);
// //                       _applyFilter();
// //                       _removeFilterOverlay();
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //     Overlay.of(context).insert(_filterOverlay!);
// //     setState(() => _filtersExpanded = true);
// //   }
// //
// //   void _removeFilterOverlay() {
// //     _filterOverlay?.remove();
// //     _filterOverlay = null;
// //     if (mounted) setState(() => _filtersExpanded = false);
// //   }
// //
// //   // ── Public methods called from parent ────────────────────────────────────
// //   void filterByCategory(String category) {
// //     setState(() {
// //       if (category == 'all') {
// //         _selectedCategory = null;
// //         _isVeg = null;
// //       } else if (category == 'veg') {
// //         _selectedCategory = null;
// //         _isVeg = true;
// //       } else if (category == 'non-veg') {
// //         _selectedCategory = null;
// //         _isVeg = false;
// //       }
// //       _applyFilter();
// //     });
// //   }
// //
// //   void openAddCategory() {
// //     _openSheet(AddCategorySheet(onSaved: _fetchData));
// //   }
// //
// //   void enableBulkMode() {
// //     setState(() => _bulkMode = true);
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
// //     _filterOverlay?.remove();
// //     _filterOverlay = null;
// //     _searchCtrl.dispose();
// //     _bulkQtyCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _fetchData() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final result = await MenuService.fetchMenu();
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
// //     if (_selectedCategory != null)
// //       f = f.where((c) => c.category == _selectedCategory).toList();
// //     if (_isVeg != null) {
// //       f = f
// //           .map(
// //             (c) => c.copyWith(
// //               subcategories: c.subcategories
// //                   .where((s) => _isVeg! ? s.tag == 'Veg' : s.tag == 'Non_Veg')
// //                   .toList(),
// //             ),
// //           )
// //           .where((c) => c.subcategories.isNotEmpty)
// //           .toList();
// //     }
// //     if (_searchQuery.isNotEmpty) {
// //       final q = _searchQuery.toLowerCase();
// //       f = f
// //           .map((c) {
// //             final cm = c.category.toLowerCase().contains(q);
// //             final subs = c.subcategories
// //                 .where(
// //                   (s) =>
// //                       s.subName.toLowerCase().contains(q) ||
// //                       s.description.toLowerCase().contains(q) ||
// //                       (s.code?.toLowerCase().contains(q) ??
// //                           false), // ← NEW: search by code
// //                 )
// //                 .toList();
// //             if (cm || subs.isNotEmpty)
// //               return c.copyWith(subcategories: cm ? c.subcategories : subs);
// //             return null;
// //           })
// //           .whereType<MenuCategory>()
// //           .toList();
// //     }
// //     setState(() => _filtered = f);
// //   }
// //
// //   Future<void> _toggleStatus(MenuCategory cat, int? subIndex) async {
// //     final dishId = subIndex == null
// //         ? cat.dishId
// //         : cat.subcategories[subIndex].dishId;
// //     final current = subIndex == null
// //         ? cat.menuStatus
// //         : cat.subcategories[subIndex].menuStatus;
// //     try {
// //       await MenuService.toggleMenuStatus(
// //         dishId,
// //         current == 'Enable' ? 'Disable' : 'Enable',
// //       );
// //       await _fetchData();
// //     } catch (e) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to update status.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteCategory(MenuCategory cat) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Category',
// //       message: 'Delete "${cat.category}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deleteCategory(cat.dishId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete category.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _deleteSubDish(SubDish sub) async {
// //     final ok = await showConfirmDialog(
// //       context,
// //       title: 'Delete Dish',
// //       message: 'Delete "${sub.subName}"? This cannot be undone.',
// //     );
// //     if (!ok) return;
// //     try {
// //       await MenuService.deleteSubDish(sub.dishId);
// //       await _fetchData();
// //     } catch (_) {
// //       if (mounted)
// //         showAppDialog(
// //           context,
// //           title: 'Error',
// //           message: 'Failed to delete dish.',
// //         );
// //     }
// //   }
// //
// //   Future<void> _bulkUpdate() async {
// //     if (_selectedDishIds.isEmpty) {
// //       showAppDialog(
// //         context,
// //         title: 'No Selection',
// //         message: 'Please select at least one dish.',
// //       );
// //       return;
// //     }
// //     final qty = int.tryParse(_bulkQtyCtrl.text);
// //     if (qty == null) {
// //       showAppDialog(
// //         context,
// //         title: 'Invalid Input',
// //         message: 'Please enter a valid quantity.',
// //       );
// //       return;
// //     }
// //     int success = 0;
// //     for (final id in _selectedDishIds) {
// //       try {
// //         for (final cat in _data) {
// //           for (final sub in cat.subcategories) {
// //             if (sub.dishId == id) {
// //               await MenuService.editSubDish(sub.copyWith(stockQuantity: qty));
// //               success++;
// //             }
// //           }
// //         }
// //       } catch (_) {}
// //     }
// //     if (mounted) {
// //       showAppDialog(
// //         context,
// //         title: 'Done',
// //         message: 'Updated $success items.',
// //         isSuccess: true,
// //       );
// //       setState(() {
// //         _bulkMode = false;
// //         _selectedDishIds.clear();
// //         _bulkQtyCtrl.clear();
// //       });
// //       await _fetchData();
// //     }
// //   }
// //
// //   void _showCategoryFilter() {
// //     final cats = _data.map((c) => c.category).toSet().toList();
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       useSafeArea: true,
// //       backgroundColor: Colors.transparent,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) => _CategoryFilterSheet(
// //         categories: cats,
// //         selected: _selectedCategory,
// //         onSelect: (c) {
// //           setState(() => _selectedCategory = c);
// //           _applyFilter();
// //           Navigator.pop(context);
// //         },
// //       ),
// //     );
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
// //     return Column(
// //       children: [
// //         // ── Filter bar ──────────────────────────────────────────────────────
// //         Container(
// //           color: _kW,
// //           padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
// //           child: Column(
// //             children: [
// //               // Search row with filter button
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       height: 42,
// //                       decoration: BoxDecoration(
// //                         color: _kBg,
// //                         borderRadius: BorderRadius.circular(11),
// //                         border: Border.all(color: _kBrd),
// //                       ),
// //                       child: TextField(
// //                         controller: _searchCtrl,
// //                         style: const TextStyle(fontSize: 13, color: _kT1),
// //                         onChanged: (v) {
// //                           _searchQuery = v;
// //                           _applyFilter();
// //                           setState(() {});
// //                         },
// //                         decoration: InputDecoration(
// //                           hintText:
// //                               'Search by name, code or category...', // ← updated hint
// //                           hintStyle: const TextStyle(
// //                             color: _kMut,
// //                             fontSize: 13,
// //                           ),
// //                           prefixIcon: const Icon(
// //                             Icons.search_rounded,
// //                             color: _kMut,
// //                             size: 18,
// //                           ),
// //                           suffixIcon: _searchCtrl.text.isNotEmpty
// //                               ? IconButton(
// //                                   icon: const Icon(
// //                                     Icons.close_rounded,
// //                                     size: 16,
// //                                     color: _kMut,
// //                                   ),
// //                                   onPressed: () {
// //                                     _searchCtrl.clear();
// //                                     _searchQuery = '';
// //                                     _applyFilter();
// //                                     setState(() {});
// //                                   },
// //                                 )
// //                               : null,
// //                           border: InputBorder.none,
// //                           contentPadding: const EdgeInsets.symmetric(
// //                             vertical: 11,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   // ── Overlay filter button ────────────────────────────────
// //                   CompositedTransformTarget(
// //                     link: _filterLayerLink,
// //                     child: GestureDetector(
// //                       onTap: () => _filtersExpanded
// //                           ? _removeFilterOverlay()
// //                           : _showFilterOverlay(),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         width: 42,
// //                         height: 42,
// //                         decoration: BoxDecoration(
// //                           color: _filtersExpanded ? _kPLt : _kBg,
// //                           borderRadius: BorderRadius.circular(11),
// //                           border: Border.all(
// //                             color: _filtersExpanded ? _kP : _kBrd,
// //                             width: _filtersExpanded ? 1.5 : 1,
// //                           ),
// //                         ),
// //                         child: Icon(
// //                           Icons.tune_rounded,
// //                           size: 18,
// //                           color: _filtersExpanded ? _kP : _kT2,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               // Active filter chips
// //               if (_selectedCategory != null || _isVeg != null) ...[
// //                 const SizedBox(height: 8),
// //                 SingleChildScrollView(
// //                   scrollDirection: Axis.horizontal,
// //                   child: Row(
// //                     children: [
// //                       if (_selectedCategory != null)
// //                         _FChip(
// //                           label: _selectedCategory!,
// //                           active: true,
// //                           icon: Icons.folder_rounded,
// //                           onTap: _showCategoryFilter,
// //                           onClear: () {
// //                             setState(() => _selectedCategory = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       if (_selectedCategory != null && _isVeg != null)
// //                         const SizedBox(width: 6),
// //                       if (_isVeg == true)
// //                         _FChip(
// //                           label: '🟢 Veg',
// //                           active: true,
// //                           activeColor: _kSuc,
// //                           activeBg: _kSLt,
// //                           onTap: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                           onClear: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       if (_isVeg == false)
// //                         _FChip(
// //                           label: '🔴 Non-Veg',
// //                           active: true,
// //                           activeColor: _kDng,
// //                           activeBg: _kDLt,
// //                           onTap: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                           onClear: () {
// //                             setState(() => _isVeg = null);
// //                             _applyFilter();
// //                           },
// //                         ),
// //                       const SizedBox(width: 6),
// //                       _FChip(
// //                         label: 'Clear all',
// //                         active: false,
// //                         icon: Icons.close_rounded,
// //                         onTap: () {
// //                           setState(() {
// //                             _selectedCategory = null;
// //                             _isVeg = null;
// //                           });
// //                           _applyFilter();
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //               // Bulk controls
// //               if (_bulkMode) ...[
// //                 const SizedBox(height: 8),
// //                 Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: BoxDecoration(
// //                     color: _kWLt,
// //                     borderRadius: BorderRadius.circular(10),
// //                     border: Border.all(color: _kWrn.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             color: _kW,
// //                             borderRadius: BorderRadius.circular(8),
// //                             border: Border.all(color: _kBrd),
// //                           ),
// //                           child: TextField(
// //                             controller: _bulkQtyCtrl,
// //                             keyboardType: TextInputType.number,
// //                             style: const TextStyle(fontSize: 13, color: _kT1),
// //                             decoration: const InputDecoration(
// //                               hintText: 'Set stock quantity',
// //                               hintStyle: TextStyle(color: _kMut, fontSize: 13),
// //                               prefixIcon: Icon(
// //                                 Icons.inventory_2_rounded,
// //                                 color: _kWrn,
// //                                 size: 16,
// //                               ),
// //                               border: InputBorder.none,
// //                               contentPadding: EdgeInsets.symmetric(
// //                                 vertical: 10,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       _PillBtn(
// //                         'Update (${_selectedDishIds.length})',
// //                         _kSuc,
// //                         _kSLt,
// //                         _bulkUpdate,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       _PillBtn(
// //                         'Cancel',
// //                         _kT2,
// //                         _kBg,
// //                         () => setState(() {
// //                           _bulkMode = false;
// //                           _selectedDishIds.clear();
// //                           _bulkQtyCtrl.clear();
// //                         }),
// //                         outlined: true,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //               const SizedBox(height: 8),
// //               const Divider(color: _kBrd, height: 1),
// //             ],
// //           ),
// //         ),
// //
// //         const Divider(color: _kBrd, height: 1),
// //
// //         // ── Content ─────────────────────────────────────────────────────────
// //         Expanded(
// //           child: _loading
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
// //                 )
// //               : _error != null
// //               ? _ErrState(msg: _error!, onRetry: _fetchData)
// //               : _filtered.isEmpty
// //               ? _EmptyState()
// //               : RefreshIndicator(
// //                   color: _kP,
// //                   onRefresh: _fetchData,
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
// //                     itemCount: _filtered.length,
// //                     itemBuilder: (_, i) => _CategoryCard(
// //                       category: _filtered[i],
// //                       isExpanded: _expanded.contains(_filtered[i].dishId),
// //                       bulkMode: _bulkMode,
// //                       selectedIds: _selectedDishIds,
// //                       onToggleExpand: () => setState(() {
// //                         _expanded.contains(_filtered[i].dishId)
// //                             ? _expanded.remove(_filtered[i].dishId)
// //                             : _expanded.add(_filtered[i].dishId);
// //                       }),
// //                       onToggleStatus: (si) => _toggleStatus(_filtered[i], si),
// //                       onEdit: () => _openSheet(
// //                         EditCategorySheet(
// //                           category: _filtered[i],
// //                           onSaved: _fetchData,
// //                         ),
// //                       ),
// //                       onDelete: () => _deleteCategory(_filtered[i]),
// //                       onAddDish: () => _openSheet(
// //                         AddDishSheet(
// //                           categoryId: _filtered[i].dishId,
// //                           categoryName: _filtered[i].category,
// //                           onSaved: _fetchData,
// //                         ),
// //                       ),
// //                       onEditDish: (sub, _) => _openSheet(
// //                         EditDishSheet(sub: sub, onSaved: _fetchData),
// //                       ),
// //                       onDeleteDish: (sub) => _deleteSubDish(sub),
// //                       onSelectChanged: (id, val) => setState(
// //                         () => val
// //                             ? _selectedDishIds.add(id)
// //                             : _selectedDishIds.remove(id),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // ── Filter Dropdown (overlay) ─────────────────────────────────────────────────
// // class _FilterDropdown extends StatelessWidget {
// //   final String? selectedCategory;
// //   final bool? isVeg;
// //   final VoidCallback onCategoryTap, onVegTap, onNonVegTap;
// //   final VoidCallback? onCategoryClear;
// //
// //   const _FilterDropdown({
// //     required this.selectedCategory,
// //     required this.isVeg,
// //     required this.onCategoryTap,
// //     required this.onVegTap,
// //     required this.onNonVegTap,
// //     this.onCategoryClear,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 200,
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: _kW,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: _kBrd),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.10),
// //             blurRadius: 16,
// //             offset: const Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _DropItem(
// //             icon: Icons.grid_view_rounded,
// //             label: selectedCategory ?? 'Categories',
// //             isActive: selectedCategory != null,
// //             activeColor: _kP,
// //             activeBg: _kPLt,
// //             onTap: onCategoryTap,
// //             onClear: selectedCategory != null ? onCategoryClear : null,
// //           ),
// //           const SizedBox(height: 3),
// //           _DropItem(
// //             dotColor: _kSuc,
// //             label: 'Veg',
// //             isActive: isVeg == true,
// //             activeColor: _kSuc,
// //             activeBg: _kSLt,
// //             onTap: onVegTap,
// //           ),
// //           const SizedBox(height: 3),
// //           _DropItem(
// //             dotColor: _kDng,
// //             label: 'Non-Veg',
// //             isActive: isVeg == false,
// //             activeColor: _kDng,
// //             activeBg: _kDLt,
// //             onTap: onNonVegTap,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _DropItem extends StatelessWidget {
// //   final String label;
// //   final bool isActive;
// //   final Color activeColor, activeBg;
// //   final VoidCallback onTap;
// //   final VoidCallback? onClear;
// //   final IconData? icon;
// //   final Color? dotColor;
// //
// //   const _DropItem({
// //     required this.label,
// //     required this.isActive,
// //     required this.activeColor,
// //     required this.activeBg,
// //     required this.onTap,
// //     this.onClear,
// //     this.icon,
// //     this.dotColor,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //         decoration: BoxDecoration(
// //           color: isActive ? activeBg : Colors.transparent,
// //           borderRadius: BorderRadius.circular(9),
// //         ),
// //         child: Row(
// //           children: [
// //             if (dotColor != null)
// //               Container(
// //                 width: 9,
// //                 height: 9,
// //                 decoration: BoxDecoration(
// //                   color: dotColor,
// //                   shape: BoxShape.circle,
// //                 ),
// //               )
// //             else
// //               Icon(icon, size: 15, color: isActive ? activeColor : _kT2),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: isActive ? activeColor : _kT1,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //             if (isActive && onClear != null)
// //               GestureDetector(
// //                 onTap: onClear,
// //                 child: Icon(Icons.close_rounded, size: 13, color: activeColor),
// //               )
// //             else if (isActive)
// //               Icon(Icons.check_rounded, size: 14, color: activeColor),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Reusable chip / btn ────────────────────────────────────────────────────────
// // class _FChip extends StatelessWidget {
// //   final String label;
// //   final bool active;
// //   final Color? activeColor, activeBg;
// //   final IconData? icon;
// //   final VoidCallback onTap;
// //   final VoidCallback? onClear;
// //   const _FChip({
// //     required this.label,
// //     required this.active,
// //     required this.onTap,
// //     this.activeColor,
// //     this.activeBg,
// //     this.icon,
// //     this.onClear,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = activeColor ?? _kP;
// //     final bg = activeBg ?? _kPLt;
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //         decoration: BoxDecoration(
// //           color: active ? bg : _kBg,
// //           borderRadius: BorderRadius.circular(9),
// //           border: Border.all(
// //             color: active ? color.withOpacity(0.4) : _kBrd,
// //             width: active ? 1.5 : 1,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             if (icon != null) ...[
// //               Icon(icon, size: 12, color: active ? color : _kT2),
// //               const SizedBox(width: 4),
// //             ],
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 11,
// //                 fontWeight: FontWeight.w700,
// //                 color: active ? color : _kT2,
// //               ),
// //             ),
// //             if (onClear != null) ...[
// //               const SizedBox(width: 4),
// //               GestureDetector(
// //                 onTap: onClear,
// //                 child: Icon(Icons.close_rounded, size: 11, color: color),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _PillBtn extends StatelessWidget {
// //   final String label;
// //   final Color color, bg;
// //   final VoidCallback onTap;
// //   final IconData? icon;
// //   final bool outlined;
// //   const _PillBtn(
// //     this.label,
// //     this.color,
// //     this.bg,
// //     this.onTap, {
// //     this.icon,
// //     this.outlined = false,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
// //       decoration: BoxDecoration(
// //         color: outlined ? _kW : bg,
// //         borderRadius: BorderRadius.circular(9),
// //         border: Border.all(color: outlined ? _kBrd : color.withOpacity(0.25)),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           if (icon != null) ...[
// //             Icon(icon, size: 14, color: color),
// //             const SizedBox(width: 5),
// //           ],
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 12,
// //               fontWeight: FontWeight.w700,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // class _ErrState extends StatelessWidget {
// //   final String msg;
// //   final VoidCallback onRetry;
// //   const _ErrState({required this.msg, required this.onRetry});
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
// //             'Failed to load menu',
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
// //
// // class _EmptyState extends StatelessWidget {
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
// //           child: const Icon(Icons.inbox_outlined, color: _kW, size: 30),
// //         ),
// //         const SizedBox(height: 14),
// //         const Text(
// //           'No items found',
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.w700,
// //             color: _kT1,
// //           ),
// //         ),
// //         const SizedBox(height: 5),
// //         const Text(
// //           'Try adjusting your filters',
// //           style: TextStyle(fontSize: 12, color: _kT2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Category Card ──────────────────────────────────────────────────────────────
// // class _CategoryCard extends StatelessWidget {
// //   final MenuCategory category;
// //   final bool isExpanded, bulkMode;
// //   final Set<int> selectedIds;
// //   final VoidCallback onToggleExpand;
// //   final Function(int?) onToggleStatus;
// //   final VoidCallback onEdit, onDelete, onAddDish;
// //   final Function(SubDish, int) onEditDish;
// //   final Function(SubDish) onDeleteDish;
// //   final Function(int, bool) onSelectChanged;
// //
// //   const _CategoryCard({
// //     required this.category,
// //     required this.isExpanded,
// //     required this.bulkMode,
// //     required this.selectedIds,
// //     required this.onToggleExpand,
// //     required this.onToggleStatus,
// //     required this.onEdit,
// //     required this.onDelete,
// //     required this.onAddDish,
// //     required this.onEditDish,
// //     required this.onDeleteDish,
// //     required this.onSelectChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kW,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: isExpanded ? _kP.withOpacity(0.25) : _kBrd),
// //       boxShadow: [
// //         BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     ),
// //     child: Column(
// //       children: [
// //         // Header
// //         GestureDetector(
// //           onTap: onToggleExpand,
// //           child: Container(
// //             padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
// //             decoration: BoxDecoration(
// //               color: isExpanded ? _kPLt.withOpacity(0.4) : _kW,
// //               borderRadius: isExpanded
// //                   ? const BorderRadius.vertical(top: Radius.circular(16))
// //                   : BorderRadius.circular(16),
// //             ),
// //             child: Row(
// //               children: [
// //                 if (bulkMode) ...[
// //                   Checkbox(
// //                     value: category.subcategories.every(
// //                       (s) => selectedIds.contains(s.dishId),
// //                     ),
// //                     onChanged: (v) {
// //                       for (final s in category.subcategories)
// //                         onSelectChanged(s.dishId, v ?? false);
// //                     },
// //                     activeColor: _kP,
// //                     visualDensity: VisualDensity.compact,
// //                   ),
// //                   const SizedBox(width: 4),
// //                 ],
// //                 DishImage(url: category.image, size: 44),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         category.category,
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 14,
// //                           color: _kT1,
// //                         ),
// //                       ),
// //                       Text(
// //                         '${category.subcategories.length} dishes',
// //                         style: const TextStyle(fontSize: 11, color: _kT2),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 _OnOffSwitch(
// //                   value: category.menuStatus == 'Enable',
// //                   onChanged: (_) => onToggleStatus(null),
// //                 ),
// //                 PopupMenuButton<String>(
// //                   icon: const Icon(
// //                     Icons.more_vert_rounded,
// //                     size: 18,
// //                     color: _kT2,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   onSelected: (v) {
// //                     if (v == 'add') onAddDish();
// //                     if (v == 'edit') onEdit();
// //                     if (v == 'delete') onDelete();
// //                   },
// //                   itemBuilder: (_) => [
// //                     _pItem(
// //                       'add',
// //                       Icons.add_circle_outline_rounded,
// //                       'Add Dish',
// //                       _kSuc,
// //                     ),
// //                     _pItem('edit', Icons.edit_outlined, 'Edit Category', _kInf),
// //                     _pItem(
// //                       'delete',
// //                       Icons.delete_outline_rounded,
// //                       'Delete',
// //                       _kDng,
// //                       danger: true,
// //                     ),
// //                   ],
// //                 ),
// //                 AnimatedRotation(
// //                   turns: isExpanded ? 0.5 : 0,
// //                   duration: const Duration(milliseconds: 200),
// //                   child: Icon(
// //                     Icons.keyboard_arrow_down_rounded,
// //                     color: isExpanded ? _kP : _kMut,
// //                     size: 20,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         // Dishes
// //         if (isExpanded) ...[
// //           Divider(
// //             color: _kBrd.withOpacity(0.7),
// //             height: 1,
// //             indent: 12,
// //             endIndent: 12,
// //           ),
// //           if (category.subcategories.isEmpty)
// //             Padding(
// //               padding: const EdgeInsets.all(14),
// //               child: Center(
// //                 child: Text(
// //                   'No dishes — tap ··· to add one',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _kMut,
// //                     fontStyle: FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             ...category.subcategories.asMap().entries.map(
// //               (e) => _DishRow(
// //                 sub: e.value,
// //                 index: e.key,
// //                 bulkMode: bulkMode,
// //                 isSelected: selectedIds.contains(e.value.dishId),
// //                 isLast: e.key == category.subcategories.length - 1,
// //                 onToggleStatus: () => onToggleStatus(e.key),
// //                 onEdit: () => onEditDish(e.value, e.key),
// //                 onDelete: () => onDeleteDish(e.value),
// //                 onSelectChanged: (v) => onSelectChanged(e.value.dishId, v),
// //               ),
// //             ),
// //         ],
// //       ],
// //     ),
// //   );
// //
// //   PopupMenuItem<String> _pItem(
// //     String val,
// //     IconData icon,
// //     String label,
// //     Color color, {
// //     bool danger = false,
// //   }) => PopupMenuItem(
// //     value: val,
// //     child: Row(
// //       children: [
// //         Container(
// //           width: 28,
// //           height: 28,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(7),
// //           ),
// //           child: Icon(icon, size: 14, color: color),
// //         ),
// //         const SizedBox(width: 10),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 13,
// //             fontWeight: FontWeight.w600,
// //             color: danger ? _kDng : _kT1,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ── Dish Row ───────────────────────────────────────────────────────────────────
// // class _DishRow extends StatelessWidget {
// //   final SubDish sub;
// //   final int index;
// //   final bool bulkMode, isSelected, isLast;
// //   final VoidCallback onToggleStatus, onEdit, onDelete;
// //   final Function(bool) onSelectChanged;
// //
// //   const _DishRow({
// //     required this.sub,
// //     required this.index,
// //     required this.bulkMode,
// //     required this.isSelected,
// //     required this.isLast,
// //     required this.onToggleStatus,
// //     required this.onEdit,
// //     required this.onDelete,
// //     required this.onSelectChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Column(
// //     children: [
// //       Padding(
// //         padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (bulkMode) ...[
// //               Checkbox(
// //                 value: isSelected,
// //                 onChanged: (v) => onSelectChanged(v ?? false),
// //                 activeColor: _kP,
// //                 visualDensity: VisualDensity.compact,
// //               ),
// //               const SizedBox(width: 2),
// //             ],
// //             Container(
// //               width: 2,
// //               height: 50,
// //               margin: const EdgeInsets.only(left: 4, right: 8),
// //               decoration: BoxDecoration(
// //                 color: _kP.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             DishImage(url: sub.image, size: 48),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         width: 8,
// //                         height: 8,
// //                         decoration: BoxDecoration(
// //                           color: sub.tag == 'Veg' ? _kSuc : _kDng,
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 5),
// //                       Expanded(
// //                         child: Text(
// //                           sub.subName,
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.w700,
// //                             fontSize: 13,
// //                             color: _kT1,
// //                           ),
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Wrap(
// //                     spacing: 5,
// //                     runSpacing: 4,
// //                     children: [
// //                       _IC(
// //                         Icons.currency_rupee_rounded,
// //                         '₹${sub.price.toStringAsFixed(0)}',
// //                         _kP,
// //                         _kPLt,
// //                       ),
// //                       _IC(
// //                         Icons.percent_rounded,
// //                         'GST ${sub.gst.toStringAsFixed(0)}%',
// //                         _kInf,
// //                         _kILt,
// //                       ),
// //                       _IC(
// //                         Icons.inventory_2_rounded,
// //                         'Stock ${sub.stockQuantity}',
// //                         sub.stockQuantity > 0 ? _kSuc : _kDng,
// //                         sub.stockQuantity > 0 ? _kSLt : _kDLt,
// //                       ),
// //                       if (sub.packingCharges > 0)
// //                         _IC(
// //                           Icons.local_shipping_outlined,
// //                           '₹${sub.packingCharges.toStringAsFixed(0)} pkg',
// //                           _kWrn,
// //                           _kWLt,
// //                         ),
// //                       // ── NEW: show code chip if non-null ──────────────────
// //                       if (sub.code != null && sub.code!.isNotEmpty)
// //                         _IC(Icons.qr_code_rounded, '#${sub.code}', _kMut, _kBg),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.restaurant_menu_rounded,
// //                         size: 11,
// //                         color: _kMut,
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         sub.chefType.replaceFirst('Chef_', ''),
// //                         style: const TextStyle(fontSize: 10, color: _kT2),
// //                       ),
// //                       const Spacer(),
// //                       _OnOffSwitch(
// //                         value: sub.menuStatus == 'Enable',
// //                         onChanged: (_) => onToggleStatus(),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 _IB(Icons.edit_outlined, _kInf, onEdit),
// //                 const SizedBox(height: 4),
// //                 _IB(Icons.delete_outline_rounded, _kDng, onDelete),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //       if (!isLast)
// //         Divider(
// //           color: _kBrd.withOpacity(0.5),
// //           height: 1,
// //           indent: 12,
// //           endIndent: 12,
// //         ),
// //     ],
// //   );
// // }
// //
// // class _IC extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final Color color, bg;
// //   const _IC(this.icon, this.label, this.color, this.bg);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //     decoration: BoxDecoration(
// //       color: bg,
// //       borderRadius: BorderRadius.circular(6),
// //     ),
// //     child: Row(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(icon, size: 10, color: color),
// //         const SizedBox(width: 3),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 10,
// //             color: color,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // class _IB extends StatelessWidget {
// //   final IconData icon;
// //   final Color color;
// //   final VoidCallback onTap;
// //   const _IB(this.icon, this.color, this.onTap);
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       padding: const EdgeInsets.all(6),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(7),
// //       ),
// //       child: Icon(icon, size: 15, color: color),
// //     ),
// //   );
// // }
// //
// // // ── Category Filter Sheet ─────────────────────────────────────────────────────
// // class _CategoryFilterSheet extends StatelessWidget {
// //   final List<String> categories;
// //   final String? selected;
// //   final Function(String?) onSelect;
// //   const _CategoryFilterSheet({
// //     required this.categories,
// //     this.selected,
// //     required this.onSelect,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => SafeArea(
// //     child: Container(
// //       decoration: const BoxDecoration(
// //         color: _kW,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: 36,
// //             height: 4,
// //             decoration: BoxDecoration(
// //               color: _kBrd,
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'Filter by Category',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w800,
// //               color: _kT1,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           _row(null, 'All Categories', Icons.apps_rounded, selected),
// //           ...categories.map((c) => _row(c, c, Icons.folder_rounded, selected)),
// //           const SizedBox(height: 6),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _row(String? val, String label, IconData icon, String? selected) {
// //     final sel = selected == val;
// //     return GestureDetector(
// //       onTap: () => onSelect(val),
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 6),
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
// //         decoration: BoxDecoration(
// //           color: sel ? _kPLt : _kBg,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: sel ? _kP.withOpacity(0.3) : _kBrd),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, size: 16, color: sel ? _kP : _kT2),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: sel ? _kP : _kT1,
// //                 ),
// //               ),
// //             ),
// //             if (sel) const Icon(Icons.check_rounded, color: _kP, size: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import 'add_category_sheet.dart';
import 'add_dish_sheet.dart';
import 'edit_category_sheet.dart';
import 'edit_dish_sheet.dart';

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
const _kWrn = Color(0xFF16A34A);
const _kWLt = Color(0xFFDCFCE7);
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

// ─── Compact iOS-style On/Off toggle ─────────────────────────────────────────
class _OnOffSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OnOffSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Transform.scale(
    scale: 0.75,

    alignment: Alignment.centerRight,
    child: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: _kSuc,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: _kDng,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? _kSDk
            : const Color(0xFFD32F2F),
      ),
    ),
  );
}

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});
  @override
  State<MenuTab> createState() => MenuTabState();
}

class MenuTabState extends State<MenuTab> {
  List<MenuCategory> _data = [];
  List<MenuCategory> _filtered = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _isVeg;

  // expanded state: category dishId -> set of expanded subCategory dishIds
  final Set<int> _expandedCats = {};
  final Set<int> _expandedSubCats = {};

  bool _bulkMode = false;
  final Set<int> _selectedDishIds = {};
  final _bulkQtyCtrl = TextEditingController();

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
                    selectedCategory: _selectedCategory,
                    isVeg: _isVeg,
                    onCategoryTap: () {
                      _removeFilterOverlay();
                      _showCategoryFilter();
                    },
                    onCategoryClear: () {
                      setState(() => _selectedCategory = null);
                      _applyFilter();
                      _removeFilterOverlay();
                    },
                    onVegTap: () {
                      setState(() => _isVeg = _isVeg == true ? null : true);
                      _applyFilter();
                      _removeFilterOverlay();
                    },
                    onNonVegTap: () {
                      setState(() => _isVeg = _isVeg == false ? null : false);
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

  void _removeFilterOverlay() {
    _filterOverlay?.remove();
    _filterOverlay = null;
    if (mounted) setState(() => _filtersExpanded = false);
  }

  // ── Public methods called from parent ────────────────────────────────────
  void filterByCategory(String category) {
    setState(() {
      if (category == 'all') {
        _selectedCategory = null;
        _isVeg = null;
      } else if (category == 'veg') {
        _selectedCategory = null;
        _isVeg = true;
      } else if (category == 'non-veg') {
        _selectedCategory = null;
        _isVeg = false;
      }
      _applyFilter();
    });
  }

  void openAddCategory() {
    _openSheet(AddCategorySheet(onSaved: _fetchData));
  }

  void enableBulkMode() {
    setState(() => _bulkMode = true);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _filterOverlay?.remove();
    _filterOverlay = null;
    _searchCtrl.dispose();
    _bulkQtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MenuService.fetchMenu();
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

    if (_selectedCategory != null) {
      f = f.where((c) => c.category == _selectedCategory).toList();
    }

    if (_isVeg != null) {
      f = f
          .map((c) {
            final filteredSubs = c.subcategories
                .map((sc) {
                  final filteredDishes = sc.dishes
                      .where(
                        (d) => _isVeg! ? d.tag == 'Veg' : d.tag == 'Non_Veg',
                      )
                      .toList();
                  return sc.copyWith(dishes: filteredDishes);
                })
                .where((sc) => sc.dishes.isNotEmpty)
                .toList();
            return c.copyWith(subcategories: filteredSubs);
          })
          .where((c) => c.subcategories.isNotEmpty)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f
          .map((c) {
            final catMatch = c.category.toLowerCase().contains(q);
            final filteredSubs = c.subcategories
                .map((sc) {
                  final scMatch = sc.name.toLowerCase().contains(q);
                  final filteredDishes = sc.dishes
                      .where(
                        (d) =>
                            d.subName.toLowerCase().contains(q) ||
                            d.description.toLowerCase().contains(q) ||
                            (d.code?.toLowerCase().contains(q) ?? false),
                      )
                      .toList();
                  if (scMatch || filteredDishes.isNotEmpty) {
                    return sc.copyWith(
                      dishes: scMatch ? sc.dishes : filteredDishes,
                    );
                  }
                  return null;
                })
                .whereType<SubCategory>()
                .toList();

            if (catMatch || filteredSubs.isNotEmpty) {
              return c.copyWith(
                subcategories: catMatch ? c.subcategories : filteredSubs,
              );
            }
            return null;
          })
          .whereType<MenuCategory>()
          .toList();
    }

    setState(() => _filtered = f);
  }

  Future<void> _toggleCategoryStatus(MenuCategory cat) async {
    try {
      await MenuService.toggleMenuStatus(
        cat.dishId,
        cat.menuStatus == 'Enable' ? 'Disable' : 'Enable',
      );
      await _fetchData();
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update status.',
        );
    }
  }

  Future<void> _toggleSubCategoryStatus(SubCategory sc) async {
    try {
      await MenuService.toggleMenuStatus(
        sc.dishId,
        sc.menuStatus == 'Enable' ? 'Disable' : 'Enable',
      );
      await _fetchData();
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update status.',
        );
    }
  }

  Future<void> _toggleDishStatus(SubDish dish) async {
    try {
      await MenuService.toggleMenuStatus(
        dish.dishId,
        dish.menuStatus == 'Enable' ? 'Disable' : 'Enable',
      );
      await _fetchData();
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update status.',
        );
    }
  }

  Future<void> _deleteCategory(MenuCategory cat) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Category',
      message: 'Delete "${cat.category}"? This cannot be undone.',
    );
    if (!ok) return;
    try {
      await MenuService.deleteCategory(cat.dishId);
      await _fetchData();
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to delete category.',
        );
    }
  }

  Future<void> _deleteSubCategory(SubCategory sc) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Sub-Category',
      message: 'Delete "${sc.name}"? All its dishes will also be removed.',
    );
    if (!ok) return;
    try {
      await MenuService.deleteCategory(sc.dishId);
      await _fetchData();
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to delete sub-category.',
        );
    }
  }

  Future<void> _deleteSubDish(SubDish sub) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Dish',
      message: 'Delete "${sub.subName}"? This cannot be undone.',
    );
    if (!ok) return;
    try {
      await MenuService.deleteSubDish(sub.dishId);
      await _fetchData();
    } catch (_) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to delete dish.',
        );
    }
  }

  Future<void> _bulkUpdate() async {
    if (_selectedDishIds.isEmpty) {
      showAppDialog(
        context,
        title: 'No Selection',
        message: 'Please select at least one dish.',
      );
      return;
    }
    final qty = int.tryParse(_bulkQtyCtrl.text);
    if (qty == null) {
      showAppDialog(
        context,
        title: 'Invalid Input',
        message: 'Please enter a valid quantity.',
      );
      return;
    }
    int success = 0;
    for (final id in _selectedDishIds) {
      try {
        for (final cat in _data) {
          for (final sc in cat.subcategories) {
            for (final dish in sc.dishes) {
              if (dish.dishId == id) {
                await MenuService.editSubDish(
                  dish.copyWith(stockQuantity: qty),
                );
                success++;
              }
            }
          }
        }
      } catch (_) {}
    }
    if (mounted) {
      showAppDialog(
        context,
        title: 'Done',
        message: 'Updated $success items.',
        isSuccess: true,
      );
      setState(() {
        _bulkMode = false;
        _selectedDishIds.clear();
        _bulkQtyCtrl.clear();
      });
      await _fetchData();
    }
  }

  void _showCategoryFilter() {
    final cats = _data.map((c) => c.category).toSet().toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryFilterSheet(
        categories: cats,
        selected: _selectedCategory,
        onSelect: (c) {
          setState(() => _selectedCategory = c);
          _applyFilter();
          Navigator.pop(context);
        },
      ),
    );
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
    return Column(
      children: [
        // ── Filter bar ──────────────────────────────────────────────────────
        Container(
          color: _kW,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Column(
            children: [
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
                          hintText: 'Search by name, code or category...',
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
                          color: _filtersExpanded ? _kPLt : _kBg,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: _filtersExpanded ? _kP : _kBrd,
                            width: _filtersExpanded ? 1.5 : 1,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _filtersExpanded ? _kP : _kT2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedCategory != null || _isVeg != null) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedCategory != null)
                        _FChip(
                          label: _selectedCategory!,
                          active: true,
                          icon: Icons.folder_rounded,
                          onTap: _showCategoryFilter,
                          onClear: () {
                            setState(() => _selectedCategory = null);
                            _applyFilter();
                          },
                        ),
                      if (_selectedCategory != null && _isVeg != null)
                        const SizedBox(width: 6),
                      if (_isVeg == true)
                        _FChip(
                          label: '🟢 Veg',
                          active: true,
                          activeColor: _kSuc,
                          activeBg: _kSLt,
                          onTap: () {
                            setState(() => _isVeg = null);
                            _applyFilter();
                          },
                          onClear: () {
                            setState(() => _isVeg = null);
                            _applyFilter();
                          },
                        ),
                      if (_isVeg == false)
                        _FChip(
                          label: '🔴 Non-Veg',
                          active: true,
                          activeColor: _kDng,
                          activeBg: _kDLt,
                          onTap: () {
                            setState(() => _isVeg = null);
                            _applyFilter();
                          },
                          onClear: () {
                            setState(() => _isVeg = null);
                            _applyFilter();
                          },
                        ),
                      const SizedBox(width: 6),
                      _FChip(
                        label: 'Clear all',
                        active: false,
                        icon: Icons.close_rounded,
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                            _isVeg = null;
                          });
                          _applyFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ],
              if (_bulkMode) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kWLt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kWrn.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _kW,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _kBrd),
                          ),
                          child: TextField(
                            controller: _bulkQtyCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13, color: _kT1),
                            decoration: const InputDecoration(
                              hintText: 'Set stock quantity',
                              hintStyle: TextStyle(color: _kMut, fontSize: 13),
                              prefixIcon: Icon(
                                Icons.inventory_2_rounded,
                                color: _kWrn,
                                size: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PillBtn(
                        'Update (${_selectedDishIds.length})',
                        _kSuc,
                        _kSLt,
                        _bulkUpdate,
                      ),
                      const SizedBox(width: 6),
                      _PillBtn(
                        'Cancel',
                        _kT2,
                        _kBg,
                        () => setState(() {
                          _bulkMode = false;
                          _selectedDishIds.clear();
                          _bulkQtyCtrl.clear();
                        }),
                        outlined: true,
                      ),
                    ],
                  ),
                ),
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
              ? _ErrState(msg: _error!, onRetry: _fetchData)
              : _filtered.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  color: _kP,
                  onRefresh: _fetchData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final cat = _filtered[i];
                      return _CategoryCard(
                        category: cat,
                        isExpanded: _expandedCats.contains(cat.dishId),
                        expandedSubCatIds: _expandedSubCats,
                        bulkMode: _bulkMode,
                        selectedIds: _selectedDishIds,
                        onToggleExpand: () => setState(() {
                          _expandedCats.contains(cat.dishId)
                              ? _expandedCats.remove(cat.dishId)
                              : _expandedCats.add(cat.dishId);
                        }),
                        onToggleSubCatExpand: (scId) => setState(() {
                          _expandedSubCats.contains(scId)
                              ? _expandedSubCats.remove(scId)
                              : _expandedSubCats.add(scId);
                        }),
                        onToggleCatStatus: () => _toggleCategoryStatus(cat),
                        onToggleSubCatStatus: (sc) =>
                            _toggleSubCategoryStatus(sc),
                        onToggleDishStatus: (d) => _toggleDishStatus(d),
                        onEditCat: () => _openSheet(
                          EditCategorySheet(category: cat, onSaved: _fetchData),
                        ),
                        onDeleteCat: () => _deleteCategory(cat),
                        onAddSubCat: () => _openSheet(
                          _AddSubCategorySheetProxy(
                            parentId: cat.dishId,
                            categoryId: cat.dishId,
                            parentName: cat.category,
                            onSaved: _fetchData,
                          ),
                        ),
                        onEditSubCat: (sc) => _openSheet(
                          _EditSubCategorySheetProxy(
                            sc: sc,
                            onSaved: _fetchData,
                          ),
                        ),
                        onDeleteSubCat: (sc) => _deleteSubCategory(sc),
                        onAddDish: (sc) => _openSheet(
                          // AddDishSheet(
                          //   rootCategoryId: cat.dishId,
                          //   categoryId: sc.dishId,
                          //   categoryName: sc.name,
                          //   onSaved: _fetchData,
                          // ),
                          AddDishSheet(
                            rootCategoryId: cat.dishId,
                            categoryId: sc.dishId,
                            categoryName: sc.name,
                            dishName: sc.name,
                            onSaved: _fetchData,
                          ),
                        ),
                        onEditDish: (dish) => _openSheet(
                          EditDishSheet(sub: dish, onSaved: _fetchData),
                        ),
                        onDeleteDish: (dish) => _deleteSubDish(dish),
                        onSelectChanged: (id, val) => setState(
                          () => val
                              ? _selectedDishIds.add(id)
                              : _selectedDishIds.remove(id),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Proxy sheet widgets ──────────────────────────────────────────────────────

class _AddSubCategorySheetProxy extends StatefulWidget {
  final int parentId;
  final String parentName;
  final VoidCallback onSaved;
  final int categoryId;
  const _AddSubCategorySheetProxy({
    required this.parentId,
    required this.categoryId,
    required this.parentName,
    required this.onSaved,
  });
  @override
  State<_AddSubCategorySheetProxy> createState() =>
      _AddSubCategorySheetProxyState();
}

class _AddSubCategorySheetProxyState extends State<_AddSubCategorySheetProxy> {
  final _ctrl = TextEditingController();
  File? _imageFile;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      showAppDialog(
        context,
        title: 'Required',
        message: 'Enter a sub-category name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await MenuService.addSubCategory(
        name: name,
        parentCategoryId: widget.parentId,
        categoryId: widget.categoryId,
        imageFile: _imageFile,
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(context, title: 'Error', message: e.toString());
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: _kBrd,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPLt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: _kP,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Sub-Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kT1,
                        ),
                      ),
                      Text(
                        'Under: ${widget.parentName}',
                        style: const TextStyle(fontSize: 11, color: _kT2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Name field
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kT2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBrd),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 14, color: _kT1),
                decoration: const InputDecoration(
                  hintText: 'e.g. Dosa, Idly, Meals',
                  hintStyle: TextStyle(color: _kMut, fontSize: 13),
                  prefixIcon: Icon(Icons.folder_rounded, color: _kP, size: 17),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Image picker
            const Text(
              'Sub-Category Image (optional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kT2,
              ),
            ),
            const SizedBox(height: 6),
            _SubCatImageBox(file: _imageFile, onPick: _pickImage),
            const SizedBox(height: 20),
            // Buttons
            _SheetButtonRow(
              onCancel: () => Navigator.pop(context),
              onSave: _saving ? null : _save,
              label: 'Save Sub-Category',
              saving: _saving,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditSubCategorySheetProxy extends StatefulWidget {
  final SubCategory sc;
  final VoidCallback onSaved;
  const _EditSubCategorySheetProxy({required this.sc, required this.onSaved});
  @override
  State<_EditSubCategorySheetProxy> createState() =>
      _EditSubCategorySheetProxyState();
}

class _EditSubCategorySheetProxyState
    extends State<_EditSubCategorySheetProxy> {
  late final TextEditingController _ctrl;
  File? _imageFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.sc.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      showAppDialog(context, title: 'Required', message: 'Enter a name.');
      return;
    }
    setState(() => _saving = true);
    try {
      await MenuService.editSubCategory(
        dishId: widget.sc.dishId,
        name: name,
        imageFile: _imageFile,
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(context, title: 'Error', message: e.toString());
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: _kBrd,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPLt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded, color: _kP, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Sub-Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kT1,
                        ),
                      ),
                      Text(
                        'Update sub-category details',
                        style: TextStyle(fontSize: 11, color: _kT2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Name field
            Container(
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBrd),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 14, color: _kT1),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.folder_rounded, color: _kP, size: 17),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Image picker — shows existing network image when no new file chosen
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sub-Category Image',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kT2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _SubCatImageBox(
              file: _imageFile,
              networkUrl: widget.sc.image,
              onPick: _pickImage,
            ),
            const SizedBox(height: 20),
            // Buttons
            _SheetButtonRow(
              onCancel: () => Navigator.pop(context),
              onSave: _saving ? null : _save,
              label: 'Update Sub-Category',
              saving: _saving,
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Shared image box for sub-category sheets ─────────────────────────────────
class _SubCatImageBox extends StatelessWidget {
  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;
  const _SubCatImageBox({required this.onPick, this.file, this.networkUrl});

  @override
  Widget build(BuildContext context) {
    final hasImg =
        file != null || (networkUrl != null && networkUrl!.isNotEmpty);
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImg ? _kP : _kBrd,
            width: hasImg ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: file != null
              ? _overlay(
                  Image.file(
                    file!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 110,
                  ),
                )
              : (networkUrl != null && networkUrl!.isNotEmpty)
              ? _overlay(
                  Image.network(
                    networkUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 110,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  ),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _overlay(Widget img) => Stack(
    fit: StackFit.expand,
    children: [
      img,
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, color: _kW, size: 13),
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
  );

  Widget _placeholder() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_photo_alternate_outlined, color: _kMut, size: 32),
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
      Text('JPG, PNG • Max 5MB', style: TextStyle(fontSize: 10, color: _kBrd)),
    ],
  );
}

// ─── Shared Cancel / Save button row for sub-category sheets ──────────────────
class _SheetButtonRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final String label;
  final bool saving;

  const _SheetButtonRow({
    required this.onCancel,
    required this.onSave,
    required this.label,
    required this.saving,
  });

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

class _CategoryCard extends StatelessWidget {
  final MenuCategory category;
  final bool isExpanded;
  final Set<int> expandedSubCatIds;
  final bool bulkMode;
  final Set<int> selectedIds;

  final VoidCallback onToggleExpand;
  final Function(int) onToggleSubCatExpand;
  final VoidCallback onToggleCatStatus;
  final Function(SubCategory) onToggleSubCatStatus;
  final Function(SubDish) onToggleDishStatus;
  final VoidCallback onEditCat;
  final VoidCallback onDeleteCat;
  final VoidCallback onAddSubCat;
  final Function(SubCategory) onEditSubCat;
  final Function(SubCategory) onDeleteSubCat;
  final Function(SubCategory) onAddDish;
  final Function(SubDish) onEditDish;
  final Function(SubDish) onDeleteDish;
  final Function(int, bool) onSelectChanged;

  const _CategoryCard({
    required this.category,
    required this.isExpanded,
    required this.expandedSubCatIds,
    required this.bulkMode,
    required this.selectedIds,
    required this.onToggleExpand,
    required this.onToggleSubCatExpand,
    required this.onToggleCatStatus,
    required this.onToggleSubCatStatus,
    required this.onToggleDishStatus,
    required this.onEditCat,
    required this.onDeleteCat,
    required this.onAddSubCat,
    required this.onEditSubCat,
    required this.onDeleteSubCat,
    required this.onAddDish,
    required this.onEditDish,
    required this.onDeleteDish,
    required this.onSelectChanged,
  });

  int get _totalDishes =>
      category.subcategories.fold(0, (s, sc) => s + sc.dishes.length);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: _kW,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isExpanded ? _kP.withOpacity(0.25) : _kBrd),
      boxShadow: [
        BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
      ],
    ),
    child: Column(
      children: [
        // ── Level-1 header ──────────────────────────────────────────
        GestureDetector(
          onTap: onToggleExpand,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
            decoration: BoxDecoration(
              color: isExpanded ? _kPLt.withOpacity(0.4) : _kW,
              borderRadius: isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (bulkMode) ...[
                  Checkbox(
                    value: category.subcategories
                        .expand((sc) => sc.dishes)
                        .every((d) => selectedIds.contains(d.dishId)),
                    onChanged: (v) {
                      for (final sc in category.subcategories)
                        for (final d in sc.dishes)
                          onSelectChanged(d.dishId, v ?? false);
                    },
                    activeColor: _kP,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                ],
                DishImage(url: category.image, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _kT1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${category.subcategories.length} sub-categories',
                              style: const TextStyle(fontSize: 11, color: _kT2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (category.approvalStatus != null) ...[
                            const SizedBox(width: 4),
                            _ApprovalBadge(
                              status: category.approvalStatus,
                              reason: category.rejectionReason,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                _OnOffSwitch(
                  value: category.menuStatus == 'Enable',
                  onChanged: (_) => onToggleCatStatus(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: _kT2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (v) {
                    if (v == 'add') onAddSubCat();
                    if (v == 'edit') onEditCat();
                    if (v == 'delete') onDeleteCat();
                  },
                  itemBuilder: (_) => [
                    _pItem(
                      'add',
                      Icons.create_new_folder_rounded,
                      'Add Sub-Category',
                      _kSuc,
                    ),
                    _pItem('edit', Icons.edit_outlined, 'Edit Category', _kInf),
                    _pItem(
                      'delete',
                      Icons.delete_outline_rounded,
                      'Delete',
                      _kDng,
                      danger: true,
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? _kP : _kMut,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Level-2 sub-categories ──────────────────────────────────
        if (isExpanded) ...[
          Divider(
            color: _kBrd.withOpacity(0.7),
            height: 1,
            indent: 12,
            endIndent: 12,
          ),
          if (category.subcategories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: Text(
                  'No sub-categories — tap ··· to add one',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kMut,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...category.subcategories.asMap().entries.map(
              (e) => _SubCategoryTile(
                sc: e.value,
                isLast: e.key == category.subcategories.length - 1,
                isExpanded: expandedSubCatIds.contains(e.value.dishId),
                bulkMode: bulkMode,
                selectedIds: selectedIds,
                onToggleExpand: () => onToggleSubCatExpand(e.value.dishId),
                onToggleStatus: () => onToggleSubCatStatus(e.value),
                onEdit: () => onEditSubCat(e.value),
                onDelete: () => onDeleteSubCat(e.value),
                onAddDish: () => onAddDish(e.value),
                onEditDish: onEditDish,
                onDeleteDish: onDeleteDish,
                onToggleDishStatus: onToggleDishStatus,
                onSelectChanged: onSelectChanged,
              ),
            ),
        ],
      ],
    ),
  );

  PopupMenuItem<String> _pItem(
    String val,
    IconData icon,
    String label,
    Color color, {
    bool danger = false,
  }) => PopupMenuItem(
    value: val,
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: danger ? _kDng : _kT1,
          ),
        ),
      ],
    ),
  );
}

class _SubCategoryTile extends StatelessWidget {
  final SubCategory sc;
  final bool isLast;
  final bool isExpanded;
  final bool bulkMode;
  final Set<int> selectedIds;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddDish;
  final Function(SubDish) onEditDish;
  final Function(SubDish) onDeleteDish;
  final Function(SubDish) onToggleDishStatus;
  final Function(int, bool) onSelectChanged;

  const _SubCategoryTile({
    required this.sc,
    required this.isLast,
    required this.isExpanded,
    required this.bulkMode,
    required this.selectedIds,
    required this.onToggleExpand,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onAddDish,
    required this.onEditDish,
    required this.onDeleteDish,
    required this.onToggleDishStatus,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Sub-category header row
      GestureDetector(
        onTap: onToggleExpand,
        child: Container(
          color: isExpanded ? _kPLt.withOpacity(0.2) : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
          child: Row(
            children: [
              if (bulkMode) ...[
                Checkbox(
                  value: sc.dishes.every((d) => selectedIds.contains(d.dishId)),
                  onChanged: (v) {
                    for (final d in sc.dishes)
                      onSelectChanged(d.dishId, v ?? false);
                  },
                  activeColor: _kP,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 2),
              ],
              // Indent marker
              Container(
                width: 3,
                height: 36,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _kP.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              DishImage(url: sc.image, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kT1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${sc.dishes.length} dishes',
                            style: const TextStyle(fontSize: 10, color: _kT2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (sc.approvalStatus != null) ...[
                          const SizedBox(width: 4),
                          _ApprovalBadge(
                            status: sc.approvalStatus,
                            reason: sc.rejectionReason,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),
              _OnOffSwitch(
                value: sc.menuStatus == 'Enable',
                onChanged: (_) => onToggleStatus(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 16,
                  color: _kT2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (v) {
                  if (v == 'add') onAddDish();
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  _pItem(
                    'add',
                    Icons.add_circle_outline_rounded,
                    'Add Dish',
                    _kSuc,
                  ),
                  _pItem(
                    'edit',
                    Icons.edit_outlined,
                    'Edit Sub-Category',
                    _kInf,
                  ),
                  _pItem(
                    'delete',
                    Icons.delete_outline_rounded,
                    'Delete',
                    _kDng,
                    danger: true,
                  ),
                ],
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? _kP : _kMut,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),

      // Level-3 dishes
      if (isExpanded) ...[
        if (sc.dishes.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 12, 10),
            child: Text(
              'No dishes — tap ··· to add one',
              style: TextStyle(
                fontSize: 11,
                color: _kMut,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...sc.dishes.asMap().entries.map(
            (e) => _DishRow(
              sub: e.value,
              index: e.key,
              bulkMode: bulkMode,
              isSelected: selectedIds.contains(e.value.dishId),
              isLast: e.key == sc.dishes.length - 1,
              onToggleStatus: () => onToggleDishStatus(e.value),
              onEdit: () => onEditDish(e.value),
              onDelete: () => onDeleteDish(e.value),
              onSelectChanged: (v) => onSelectChanged(e.value.dishId, v),
            ),
          ),
      ],

      if (!isLast)
        Divider(
          color: _kBrd.withOpacity(0.5),
          height: 1,
          indent: 12,
          endIndent: 12,
        ),
    ],
  );

  PopupMenuItem<String> _pItem(
    String val,
    IconData icon,
    String label,
    Color color, {
    bool danger = false,
  }) => PopupMenuItem(
    value: val,
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: danger ? _kDng : _kT1,
          ),
        ),
      ],
    ),
  );
}

class _DishRow extends StatelessWidget {
  final SubDish sub;
  final int index;
  final bool bulkMode, isSelected, isLast;
  final VoidCallback onToggleStatus, onEdit, onDelete;
  final Function(bool) onSelectChanged;

  const _DishRow({
    required this.sub,
    required this.index,
    required this.bulkMode,
    required this.isSelected,
    required this.isLast,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bulkMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (v) => onSelectChanged(v ?? false),
                activeColor: _kP,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 2),
            ],
            // Deeper indent marker
            Container(
              width: 2,
              height: 50,
              margin: const EdgeInsets.only(left: 6, right: 10),
              decoration: BoxDecoration(
                color: _kP.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            DishImage(url: sub.image, size: 46),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: sub.tag == 'Veg' ? _kSuc : _kDng,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          sub.subName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _kT1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      _IC(
                        Icons.currency_rupee_rounded,
                        '${sub.effectivePrice.toStringAsFixed(0)}',
                        _kP,
                        _kPLt,
                      ),
                      _IC(
                        Icons.local_shipping_outlined,
                        '₹${sub.deliveryPrice.toStringAsFixed(0)}',
                        _kInf,
                        _kILt,
                      ),
                      _IC(
                        Icons.percent_rounded,
                        'GST ${sub.gst.toStringAsFixed(0)}%',
                        _kInf,
                        _kILt,
                      ),
                      _IC(
                        Icons.inventory_2_rounded,
                        'Stock ${sub.stockQuantity}',
                        sub.stockQuantity > 0 ? _kSuc : _kDng,
                        sub.stockQuantity > 0 ? _kSLt : _kDLt,
                      ),
                      if (sub.packingCharges > 0)
                        _IC(
                          Icons.local_shipping_outlined,
                          '₹${sub.packingCharges.toStringAsFixed(0)} pkg',
                          _kWrn,
                          _kWLt,
                        ),
                      if (sub.code != null && sub.code!.isNotEmpty)
                        _IC(Icons.qr_code_rounded, '#${sub.code}', _kMut, _kBg),
                      _ApprovalBadge(
                        status: sub.approvalStatus,
                        reason: sub.rejectionReason,
                      ), // 👈 NEW
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 11,
                        color: _kMut,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sub.chefType.replaceFirst('Chef_', ''),
                        style: const TextStyle(fontSize: 10, color: _kT2),
                      ),
                      const Spacer(),
                      _OnOffSwitch(
                        value: sub.menuStatus == 'Enable',
                        onChanged: (_) => onToggleStatus(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IB(Icons.edit_outlined, _kInf, onEdit),
                const SizedBox(height: 4),
                _IB(Icons.delete_outline_rounded, _kDng, onDelete),
              ],
            ),
          ],
        ),
      ),
      if (!isLast)
        Divider(
          color: _kBrd.withOpacity(0.4),
          height: 1,
          indent: 28,
          endIndent: 12,
        ),
    ],
  );
}

// ─── Small "0" badge shown at category/sub-category level ─────────────────────
class _ZeroChip extends StatelessWidget {
  final String label;
  const _ZeroChip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: _kBg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _kBrd),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: _kMut,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _IC extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _IC(this.icon, this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _IB extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IB(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 15, color: color),
    ),
  );
}

class _PillBtn extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outlined;
  const _PillBtn(
    this.label,
    this.color,
    this.bg,
    this.onTap, {
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: outlined ? _kW : bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: outlined ? _kBrd : color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrState extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrState({required this.msg, required this.onRetry});
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
            'Failed to load menu',
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

class _EmptyState extends StatelessWidget {
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
          child: const Icon(Icons.inbox_outlined, color: _kW, size: 30),
        ),
        const SizedBox(height: 14),
        const Text(
          'No items found',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kT1,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Try adjusting your filters',
          style: TextStyle(fontSize: 12, color: _kT2),
        ),
      ],
    ),
  );
}

// ── Filter Dropdown (overlay) ─────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String? selectedCategory;
  final bool? isVeg;
  final VoidCallback onCategoryTap, onVegTap, onNonVegTap;
  final VoidCallback? onCategoryClear;

  const _FilterDropdown({
    required this.selectedCategory,
    required this.isVeg,
    required this.onCategoryTap,
    required this.onVegTap,
    required this.onNonVegTap,
    this.onCategoryClear,
  });

  @override
  Widget build(BuildContext context) => Container(
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
          icon: Icons.grid_view_rounded,
          label: selectedCategory ?? 'Categories',
          isActive: selectedCategory != null,
          activeColor: _kP,
          activeBg: _kPLt,
          onTap: onCategoryTap,
          onClear: selectedCategory != null ? onCategoryClear : null,
        ),
        const SizedBox(height: 3),
        _DropItem(
          dotColor: _kSuc,
          label: 'Veg',
          isActive: isVeg == true,
          activeColor: _kSuc,
          activeBg: _kSLt,
          onTap: onVegTap,
        ),
        const SizedBox(height: 3),
        _DropItem(
          dotColor: _kDng,
          label: 'Non-Veg',
          isActive: isVeg == false,
          activeColor: _kDng,
          activeBg: _kDLt,
          onTap: onNonVegTap,
        ),
      ],
    ),
  );
}

class _DropItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor, activeBg;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final IconData? icon;
  final Color? dotColor;

  const _DropItem({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
    this.onClear,
    this.icon,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isActive && onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 13, color: activeColor),
            )
          else if (isActive)
            Icon(Icons.check_rounded, size: 14, color: activeColor),
        ],
      ),
    ),
  );
}

class _FChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? activeColor, activeBg;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _FChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
    this.activeBg,
    this.icon,
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
            if (icon != null) ...[
              Icon(icon, size: 12, color: active ? color : _kT2),
              const SizedBox(width: 4),
            ],
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

class _CategoryFilterSheet extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final Function(String?) onSelect;
  const _CategoryFilterSheet({
    required this.categories,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        color: _kW,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _kBrd,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Filter by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kT1,
            ),
          ),
          const SizedBox(height: 12),
          _row(null, 'All Categories', Icons.apps_rounded, selected),
          ...categories.map((c) => _row(c, c, Icons.folder_rounded, selected)),
          const SizedBox(height: 6),
        ],
      ),
    ),
  );

  Widget _row(String? val, String label, IconData icon, String? selected) {
    final sel = selected == val;
    return GestureDetector(
      onTap: () => onSelect(val),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: sel ? _kPLt : _kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? _kP.withOpacity(0.3) : _kBrd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: sel ? _kP : _kT2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? _kP : _kT1,
                ),
              ),
            ),
            if (sel) const Icon(Icons.check_rounded, color: _kP, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ApprovalBadge extends StatelessWidget {
  final String? status;
  final String? reason;
  const _ApprovalBadge({required this.status, this.reason});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();
    final isApproved = status == 'APPROVED';
    final isRejected = status == 'REJECTED';
    final color = isApproved ? _kSuc : (isRejected ? _kDng : _kWrn);
    final bg = isApproved ? _kSLt : (isRejected ? _kDLt : _kWLt);
    final icon = isApproved
        ? Icons.check_circle_rounded
        : (isRejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            status!,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (isRejected && reason != null && reason!.isNotEmpty) {
      return Tooltip(message: reason!, child: badge);
    }
    return badge;
  }
}
