//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import '../models/models.dart';
// import '../widgets/common_widgets.dart';
//
// // ── Color tokens ──────────────────────────────────────────────────────────────
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFF97316);
// const _kPDk = Color(0xFFC2510F);
// const _kPLt = Color(0xFFFFF0E6);
// const _kSuc = Color(0xFF10B981);
// const _kSLt = Color(0xFFD1FAE5);
// const _kDng = Color(0xFFEF4444);
// const _kInf = Color(0xFF3B82F6);
// const _kILt = Color(0xFFDBEAFE);
// const _kWrn = Color(0xFF16A34A);
// const _kWLt = Color(0xFFDCFCE7);
// const _kT1 = Color(0xFF111827);
// const _kT2 = Color(0xFF6B7280);
// const _kMut = Color(0xFFB0B3C1);
// const _kGrd = LinearGradient(
//   colors: [_kP, _kPDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// const _kMetricOptions = [
//   MapEntry('KG', 'KG'),
//   MapEntry('LITRE', 'Litre'),
//   MapEntry('PIECE', 'Piece'),
//   MapEntry('PACKET', 'Packet'),
// ];
//
// double _numOrZero(String text) => double.tryParse(text.trim()) ?? 0;
// int _intOrZero(String text) => int.tryParse(text.trim()) ?? 0;
//
// const _kGstOptions = ['0', '5', '18'];
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Small reusable widgets
// // ─────────────────────────────────────────────────────────────────────────────
//
// class _Handle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Center(
//     child: Container(
//       width: 40,
//       height: 4,
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: _kBrd,
//         borderRadius: BorderRadius.circular(2),
//       ),
//     ),
//   );
// }
//
// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Text(
//       text,
//       style: const TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w800,
//         color: _kT1,
//       ),
//     ),
//   );
// }
//
// class _LField extends StatelessWidget {
//   final String label;
//   final TextEditingController ctrl;
//   final String hint;
//   final TextInputType? type;
//   final int maxLines;
//   final bool required;
//   final Widget? trailing;
//   final Widget? prefix;
//
//   const _LField(
//     this.label,
//     this.ctrl, {
//     this.hint = '',
//     this.type,
//     this.maxLines = 1,
//     this.required = false,
//     this.trailing,
//     this.prefix,
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: _kT2,
//             ),
//           ),
//           if (required)
//             const Text(
//               ' *',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: _kDng,
//               ),
//             ),
//           if (trailing != null) ...[const Spacer(), trailing!],
//         ],
//       ),
//       const SizedBox(height: 6),
//       Container(
//         decoration: BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBrd),
//         ),
//         child: TextField(
//           controller: ctrl,
//           keyboardType: type,
//           maxLines: maxLines,
//           style: const TextStyle(fontSize: 13, color: _kT1),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: _kMut, fontSize: 12),
//             border: InputBorder.none,
//             prefixIcon: prefix,
//             prefixIconConstraints: const BoxConstraints(
//               minWidth: 40,
//               minHeight: 40,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 12,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// class _DField extends StatelessWidget {
//   final String label;
//   final String value;
//   final List<MapEntry<String, String>> options;
//   final ValueChanged<String?> onChanged;
//
//   const _DField({
//     required this.label,
//     required this.value,
//     required this.options,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: _kT2,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBrd),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: value,
//             isExpanded: true,
//             icon: const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: _kT2,
//               size: 18,
//             ),
//             style: const TextStyle(fontSize: 13, color: _kT1),
//             onChanged: onChanged,
//             items: options
//                 .map(
//                   (e) => DropdownMenuItem(
//                     value: e.key,
//                     child: Text(e.value, style: const TextStyle(fontSize: 13)),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// class _GstDropdown extends StatelessWidget {
//   final String label;
//   final String value;
//   final ValueChanged<String?> onChanged;
//
//   const _GstDropdown({
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: _kT2,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBrd),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: _kGstOptions.contains(value) ? value : '5',
//             isExpanded: true,
//             icon: const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: _kT2,
//               size: 18,
//             ),
//             style: const TextStyle(fontSize: 13, color: _kT1),
//             onChanged: onChanged,
//             items: _kGstOptions
//                 .map(
//                   (v) => DropdownMenuItem(
//                     value: v,
//                     child: Text('$v%', style: const TextStyle(fontSize: 13)),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// class _TaxTypeRow extends StatelessWidget {
//   final bool inclusive;
//   final ValueChanged<bool> onChanged;
//   final bool required;
//   const _TaxTypeRow({
//     required this.inclusive,
//     required this.onChanged,
//     this.required = false,
//   });
//
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Text(
//         'Tax Type',
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: _kT2,
//         ),
//       ),
//       if (required)
//         const Text(
//           ' *',
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: _kDng,
//           ),
//         ),
//       const SizedBox(width: 16),
//       _radio('Exclusive', !inclusive, () => onChanged(false)),
//       const SizedBox(width: 20),
//       _radio('Inclusive', inclusive, () => onChanged(true)),
//     ],
//   );
//
//   Widget _radio(String label, bool selected, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 18,
//               height: 18,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: selected ? _kP : _kMut,
//                   width: selected ? 5 : 1.5,
//                 ),
//                 color: _kW,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: selected ? _kT1 : _kT2,
//               ),
//             ),
//           ],
//         ),
//       );
// }
//
// /// Three-column price breakdown card
// class _BreakdownCard extends StatelessWidget {
//   final String leftLabel;
//   final double price;
//   final double gstPercent;
//   final bool inclusive;
//   final String emptyHint;
//
//   const _BreakdownCard({
//     required this.leftLabel,
//     required this.price,
//     required this.gstPercent,
//     required this.inclusive,
//     this.emptyHint = 'Enter price to see breakdown',
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Empty state
//     if (price == 0) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
//         decoration: BoxDecoration(
//           color: _kBg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _kBrd),
//         ),
//         child: Text(
//           emptyHint,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 12, color: _kMut),
//         ),
//       );
//     }
//
//     double basePrice, gstAmount, finalPrice;
//     if (inclusive) {
//       final div = 1 + (gstPercent / 100);
//       basePrice = div == 0 ? price : price / div;
//       gstAmount = price - basePrice;
//       finalPrice = price;
//     } else {
//       basePrice = price;
//       gstAmount = price * gstPercent / 100;
//       finalPrice = price + gstAmount;
//     }
//     final gLabel = gstPercent == gstPercent.roundToDouble()
//         ? gstPercent.toStringAsFixed(0)
//         : gstPercent.toStringAsFixed(1);
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       decoration: BoxDecoration(
//         color: _kBg,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBrd),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _col(
//               leftLabel.toUpperCase(),
//               '₹${basePrice.toStringAsFixed(2)}',
//               _kT2,
//               _kT1,
//               bold: false,
//             ),
//           ),
//           Container(width: 1, height: 36, color: _kBrd),
//           Expanded(
//             child: _col(
//               'GST ($gLabel%)',
//               '+ ₹${gstAmount.toStringAsFixed(2)}',
//               _kT2,
//               _kP, // orange for GST
//               bold: false,
//             ),
//           ),
//           Container(width: 1, height: 36, color: _kBrd),
//           Expanded(
//             child: _col(
//               'FINAL PRICE',
//               '₹${finalPrice.toStringAsFixed(2)}',
//               _kT2,
//               _kT1,
//               bold: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _col(
//     String label,
//     String value,
//     Color labelColor,
//     Color valueColor, {
//     required bool bold,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Text(
//         label,
//         style: TextStyle(fontSize: 10, color: labelColor, letterSpacing: 0.3),
//         textAlign: TextAlign.center,
//       ),
//       const SizedBox(height: 4),
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: bold ? 15 : 14,
//           fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
//           color: valueColor,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     ],
//   );
// }
//
// class _PriceSection extends StatelessWidget {
//   final String priceLabel;
//   final TextEditingController priceCtrl;
//   final bool priceRequired;
//   final String gstValue;
//   final ValueChanged<String?> onGstChanged;
//   final bool inclusive;
//   final ValueChanged<bool> onInclusiveChanged;
//   final String breakdownLeftLabel;
//   final bool taxRequired;
//   final String breakdownEmptyHint;
//
//   const _PriceSection({
//     required this.priceLabel,
//     required this.priceCtrl,
//     this.priceRequired = false,
//     required this.gstValue,
//     required this.onGstChanged,
//     required this.inclusive,
//     required this.onInclusiveChanged,
//     required this.breakdownLeftLabel,
//     this.taxRequired = false,
//     this.breakdownEmptyHint = 'Enter price to see breakdown',
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: _LField(
//               priceLabel,
//               priceCtrl,
//               hint: '0.00',
//               type: const TextInputType.numberWithOptions(decimal: true),
//               required: priceRequired,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _GstDropdown(
//               label: 'GST %',
//               value: gstValue,
//               onChanged: onGstChanged,
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 10),
//       _TaxTypeRow(
//         inclusive: inclusive,
//         onChanged: onInclusiveChanged,
//         required: taxRequired,
//       ),
//       const SizedBox(height: 10),
//       _BreakdownCard(
//         leftLabel: breakdownLeftLabel,
//         price: _numOrZero(priceCtrl.text),
//         gstPercent: _numOrZero(gstValue),
//         inclusive: inclusive,
//         emptyHint: breakdownEmptyHint,
//       ),
//     ],
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Bottom action row  –  dark-gray Cancel, orange Save
// // ─────────────────────────────────────────────────────────────────────────────
// class _BottomRow extends StatelessWidget {
//   final VoidCallback onCancel;
//   final VoidCallback? onSave;
//   final String label;
//   final bool saving;
//
//   const _BottomRow(this.onCancel, this.onSave, this.label, this.saving);
//
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       // Cancel — dark charcoal
//       Expanded(
//         child: GestureDetector(
//           onTap: onCancel,
//           child: Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFF374151),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Center(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: _kW,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(width: 12),
//       // Save — orange gradient
//       Expanded(
//         child: GestureDetector(
//           onTap: onSave,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             height: 50,
//             decoration: BoxDecoration(
//               gradient: onSave != null ? _kGrd : null,
//               color: onSave == null ? _kBrd : null,
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: onSave != null
//                   ? [
//                       BoxShadow(
//                         color: _kP.withOpacity(0.35),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Center(
//               child: saving
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: _kW,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       label,
//                       style: const TextStyle(
//                         color: _kW,
//                         fontSize: 14,
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
//
// // ─────────────────────────────────────────────────────────────────────────────
// // ADDON EDITOR
// // ─────────────────────────────────────────────────────────────────────────────
//
// class _AddonRow {
//   final TextEditingController nameCtrl;
//   final TextEditingController priceCtrl;
//   bool available;
//   final int? addonId;
//
//   _AddonRow({
//     String name = '',
//     String price = '',
//     this.available = true,
//     this.addonId,
//   }) : nameCtrl = TextEditingController(text: name),
//        priceCtrl = TextEditingController(text: price);
//
//   void dispose() {
//     nameCtrl.dispose();
//     priceCtrl.dispose();
//   }
//
//   Addon toAddon() => Addon(
//     addonId: addonId ?? 0,
//     addonName: nameCtrl.text.trim(),
//     addonPrice: _numOrZero(priceCtrl.text),
//     available: available,
//   );
// }
//
// class _AddonEditor extends StatelessWidget {
//   final List<_AddonRow> addons;
//   final VoidCallback onAdd;
//   final ValueChanged<int> onRemove;
//   final VoidCallback onChanged;
//
//   const _AddonEditor({
//     required this.addons,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // ── Section header ──
//       Row(
//         children: [
//           const Text(
//             'Add On',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//               color: _kT1,
//             ),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: onAdd,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _kP,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.add_rounded, size: 14, color: _kW),
//                   SizedBox(width: 4),
//                   Text(
//                     'Add',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: _kW,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 10),
//
//       // ── Column headers (only if rows exist) ──
//       if (addons.isNotEmpty) ...[
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 2),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: Text(
//                   'Name',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: _kT2,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 flex: 2,
//                 child: Text(
//                   'Price (₹)',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: _kT2,
//                   ),
//                 ),
//               ),
//               // Placeholder space for switch + delete
//               const SizedBox(width: 80),
//             ],
//           ),
//         ),
//         const SizedBox(height: 6),
//       ],
//
//       // ── Addon rows ──
//       if (addons.isEmpty)
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             color: _kBg,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: _kBrd),
//           ),
//           child: const Text(
//             'No addons added',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 12, color: _kT2),
//           ),
//         )
//       else
//         ...List.generate(addons.length, (i) {
//           final row = addons[i];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Name field
//                 Expanded(
//                   flex: 3,
//                   child: _miniField(row.nameCtrl, 'e.g. Extra Cheese'),
//                 ),
//                 const SizedBox(width: 8),
//                 // Price field
//                 Expanded(
//                   flex: 2,
//                   child: _miniField(row.priceCtrl, '0.00', isNum: true),
//                 ),
//                 const SizedBox(width: 6),
//                 // Available toggle
//                 Transform.scale(
//                   scale: 0.8,
//                   child: Switch(
//                     value: row.available,
//                     activeColor: _kP,
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     onChanged: (v) {
//                       row.available = v;
//                       onChanged();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 // Delete button
//                 GestureDetector(
//                   onTap: () => onRemove(i),
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: _kW,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: _kBrd),
//                     ),
//                     child: const Icon(
//                       Icons.close_rounded,
//                       size: 14,
//                       color: _kDng,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//     ],
//   );
//
//   Widget _miniField(
//     TextEditingController ctrl,
//     String hint, {
//     bool isNum = false,
//   }) => Container(
//     decoration: BoxDecoration(
//       color: _kW,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: _kBrd),
//     ),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: isNum
//           ? const TextInputType.numberWithOptions(decimal: true)
//           : TextInputType.text,
//       style: const TextStyle(fontSize: 13, color: _kT1),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kMut, fontSize: 12),
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
// // ─────────────────────────────────────────────────────────────────────────────
// // Dish image picker  –  dashed-border upload area + source buttons
// // ─────────────────────────────────────────────────────────────────────────────
// class _DishImagePicker extends StatelessWidget {
//   final File? file;
//   final String? networkUrl;
//   final VoidCallback onPick;
//
//   const _DishImagePicker({required this.onPick, this.file, this.networkUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     final hasImg =
//         file != null || (networkUrl != null && networkUrl!.isNotEmpty);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Upload area ──
//         GestureDetector(
//           onTap: onPick,
//           child: CustomPaint(
//             painter: _DashedBorderPainter(
//               color: hasImg ? _kP : const Color(0xFFCBCDD8),
//             ),
//             child: Container(
//               height: 150,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: _kBg,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: file != null
//                     ? Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Image.file(file!, fit: BoxFit.cover),
//                           _changeOverlay(),
//                         ],
//                       )
//                     : (networkUrl != null && networkUrl!.isNotEmpty)
//                     ? Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Image.network(
//                             networkUrl!,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => _uploadPlaceholder(),
//                           ),
//                           _changeOverlay(),
//                         ],
//                       )
//                     : _uploadPlaceholder(),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//
//         // ── Source buttons ──
//         // Row(
//         //   children: [
//         //     _SourceButton('From Device', onPick),
//         //     const SizedBox(width: 8),
//         //     _SourceButton('From Platform', () {}),
//         //     const SizedBox(width: 8),
//         //     _SourceButton('AI Generated', () {}),
//         //   ],
//         // ),
//       ],
//     );
//   }
//
//   Widget _uploadPlaceholder() => Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Container(
//         width: 52,
//         height: 52,
//         decoration: BoxDecoration(
//           color: _kPLt,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Icon(Icons.image_outlined, color: _kP, size: 28),
//       ),
//       const SizedBox(height: 10),
//       const Text(
//         'Click or drag to upload',
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: _kInf,
//         ),
//       ),
//       const SizedBox(height: 2),
//       const Text(
//         'JPG, PNG • Max 5MB',
//         style: TextStyle(fontSize: 11, color: _kT2),
//       ),
//     ],
//   );
//
//   Widget _changeOverlay() => Positioned(
//     bottom: 0,
//     left: 0,
//     right: 0,
//     child: Container(
//       color: Colors.black54,
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.upload_rounded, color: _kW, size: 13),
//           SizedBox(width: 5),
//           Text(
//             'Change Image',
//             style: TextStyle(
//               color: _kW,
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// /// A small outlined source-selection button below the image picker.
// class _SourceButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _SourceButton(this.label, this.onTap);
//
//   @override
//   Widget build(BuildContext context) => Expanded(
//     child: GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 9),
//         decoration: BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBrd),
//         ),
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: _kT1,
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// /// CustomPainter that draws a dashed rounded-rectangle border.
// class _DashedBorderPainter extends CustomPainter {
//   final Color color;
//   final double strokeWidth;
//   final double dashWidth;
//   final double dashSpace;
//   final double radius;
//
//   const _DashedBorderPainter({
//     required this.color,
//     this.strokeWidth = 1.5,
//     this.dashWidth = 6,
//     this.dashSpace = 4,
//     this.radius = 10,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke;
//
//     final path = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(
//             strokeWidth / 2,
//             strokeWidth / 2,
//             size.width - strokeWidth,
//             size.height - strokeWidth,
//           ),
//           Radius.circular(radius),
//         ),
//       );
//
//     final pathMetrics = path.computeMetrics();
//     for (final metric in pathMetrics) {
//       double distance = 0;
//       while (distance < metric.length) {
//         final extractPath = metric.extractPath(distance, distance + dashWidth);
//         canvas.drawPath(extractPath, paint);
//         distance += dashWidth + dashSpace;
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // ADD DISH SHEET
// // ─────────────────────────────────────────────────────────────────────────────
// class AddDishSheet extends StatefulWidget {
//   final int categoryId;
//   final int rootCategoryId;
//   final String categoryName;
//   final String dishName;
//   final VoidCallback onSaved;
//
//   const AddDishSheet({
//     super.key,
//     required this.categoryId,
//     required this.categoryName,
//     required this.dishName,
//     required this.rootCategoryId,
//     required this.onSaved,
//   });
//
//   @override
//   State<AddDishSheet> createState() => _AddDishSheetState();
// }
//
// class _AddDishSheetState extends State<AddDishSheet> {
//   final _nameCtrl = TextEditingController();
//   final _codeCtrl = TextEditingController();
//   final _priceCtrl = TextEditingController();
//   final _deliveryCtrl = TextEditingController(text: '0');
//   final _packingCtrl = TextEditingController(text: '0');
//   final _stockCtrl = TextEditingController(text: '0');
//   final _descCtrl = TextEditingController();
//   final _servesCtrl = TextEditingController(text: '1');
//   final _metricQtyCtrl = TextEditingController(text: '0');
//
//   bool _resetQuantity = false;
//
//   String _menuGst = '5';
//   String _deliveryGst = '5';
//   String _packingGst = '5';
//   String _metrics = 'KG';
//
//   bool _menuInclusive = false;
//   bool _deliveryInclusive = false;
//   bool _packingInclusive = false;
//
//   String _tag = 'Veg';
//   String _chefType = 'Chef_All';
//
//   final List<_AddonRow> _addons = [];
//
//   File? _imageFile;
//   bool _saving = false;
//
//   static const _descMax = 250;
//
//   static const _chefOptions = [
//     MapEntry('Chef_All', 'All Chefs'),
//     MapEntry('Chef_North', 'North Indian'),
//     MapEntry('Chef_South', 'South Indian'),
//     MapEntry('Chef_Chinese', 'Chinese'),
//     MapEntry('Chef_Continental', 'Continental'),
//     MapEntry('Tea_stall', 'Tea Stall'),
//     MapEntry('Snacks', 'Snacks'),
//     MapEntry('Bakery', 'Bakery'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _priceCtrl.addListener(() => setState(() {}));
//     _deliveryCtrl.addListener(() => setState(() {}));
//     _packingCtrl.addListener(() => setState(() {}));
//     _descCtrl.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _codeCtrl.dispose();
//     _priceCtrl.dispose();
//     _deliveryCtrl.dispose();
//     _packingCtrl.dispose();
//     _stockCtrl.dispose();
//     _descCtrl.dispose();
//     _servesCtrl.dispose();
//     _metricQtyCtrl.dispose();
//     for (final a in _addons) {
//       a.dispose();
//     }
//     super.dispose();
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
//   Future<void> _save() async {
//     final name = _nameCtrl.text.trim();
//     if (name.isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter a dish name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final sub = SubDish(
//         dishId: 0,
//         subName: name,
//         price: _numOrZero(_priceCtrl.text),
//         gst: _numOrZero(_menuGst),
//         includeGst: _menuInclusive,
//         packingCharges: _numOrZero(_packingCtrl.text),
//         packingGst: _numOrZero(_packingGst),
//         deliveryPrice: _numOrZero(_deliveryCtrl.text),
//         deliveryGst: _numOrZero(_deliveryGst),
//         stockQuantity: _intOrZero(_stockCtrl.text),
//         description: _descCtrl.text.trim(),
//         tag: _tag,
//         chefType: _chefType,
//         code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
//         addons: _addons
//             .where((a) => a.nameCtrl.text.trim().isNotEmpty)
//             .map((a) => a.toAddon())
//             .toList(),
//         resetQuantity: _resetQuantity,
//
//         metrics: _metrics,
//         metricQuantity: _intOrZero(_metricQtyCtrl.text),
//       );
//       await MenuService.addSubDish(
//         sub: sub,
//         parentId: widget.categoryId,
//         categoryId: widget.rootCategoryId,
//         imageFile: _imageFile,
//       );
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to add dish:\n${e.toString()}',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: _kW,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: DraggableScrollableSheet(
//             expand: false,
//             initialChildSize: 0.94,
//             minChildSize: 0.5,
//             maxChildSize: 0.97,
//             builder: (ctx, scrollCtrl) => SingleChildScrollView(
//               controller: scrollCtrl,
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _Handle(),
//
//                   // ── Header ──
//                   Row(
//                     children: [
//                       const Text(
//                         'Add New Dish Item',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: _kT1,
//                         ),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: _kBg,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: _kBrd),
//                           ),
//                           child: const Icon(
//                             Icons.close_rounded,
//                             size: 16,
//                             color: _kT2,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Category / Sub-Category context ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(child: _contextBox('Category', widget.dishName)),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _contextBox('Sub Category', widget.categoryName),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Dish Name * | Stock Quantity ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _LField(
//                           'Dish Name',
//                           _nameCtrl,
//                           hint: 'Enter dish name',
//                           required: true,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _LField(
//                           'Stock Quantity',
//                           _stockCtrl,
//                           hint: '0',
//                           type: TextInputType.number,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const SizedBox(height: 10),
//
//                   // ── Metric | Metric Quantity ──  (NEW)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _DField(
//                           label: 'Metric',
//                           value: _metrics,
//                           options: _kMetricOptions,
//                           onChanged: (v) =>
//                               setState(() => _metrics = v ?? 'KG'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _LField(
//                           'Metric Quantity',
//                           _metricQtyCtrl,
//                           hint: '0',
//                           type: TextInputType.number,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   // ── Reset Quantity checkbox ──
//                   InkWell(
//                     onTap: () =>
//                         setState(() => _resetQuantity = !_resetQuantity),
//                     borderRadius: BorderRadius.circular(8),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: Checkbox(
//                               value: _resetQuantity,
//                               activeColor: _kP,
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               visualDensity: VisualDensity.compact,
//                               onChanged: (v) =>
//                                   setState(() => _resetQuantity = v ?? false),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Reset Quantity Daily',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: _kT1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Menu Price ──
//                   _PriceSection(
//                     priceLabel: 'Menu Price (₹)',
//                     priceCtrl: _priceCtrl,
//                     priceRequired: true,
//                     gstValue: _menuGst,
//                     onGstChanged: (v) => setState(() => _menuGst = v ?? '5'),
//                     inclusive: _menuInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _menuInclusive = v),
//                     breakdownLeftLabel: 'Menu Price',
//                     taxRequired: true,
//                     breakdownEmptyHint: 'Enter price to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   _SectionLabel('Delivery Price'),
//                   _PriceSection(
//                     priceLabel: 'Delivery Price (₹)',
//                     priceCtrl: _deliveryCtrl,
//                     gstValue: _deliveryGst,
//                     onGstChanged: (v) =>
//                         setState(() => _deliveryGst = v ?? '5'),
//                     inclusive: _deliveryInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _deliveryInclusive = v),
//                     breakdownLeftLabel: 'Delivery Price',
//                     breakdownEmptyHint: 'Enter delivery price to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Packaging Charges ──
//                   _SectionLabel('Packaging Charges'),
//                   _PriceSection(
//                     priceLabel: 'Packing Charges (₹)',
//                     priceCtrl: _packingCtrl,
//                     gstValue: _packingGst,
//                     onGstChanged: (v) => setState(() => _packingGst = v ?? '5'),
//                     inclusive: _packingInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _packingInclusive = v),
//                     breakdownLeftLabel: 'Packaging Charges',
//                     breakdownEmptyHint:
//                         'Enter packaging charges to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Dish Type | Chef Type ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _DField(
//                           label: 'Dish Type',
//                           value: _tag,
//                           options: const [
//                             MapEntry('Veg', 'Veg'),
//                             MapEntry('Non_Veg', 'Non-Veg'),
//                           ],
//                           onChanged: (v) => setState(() => _tag = v ?? 'Veg'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _DField(
//                           label: 'Chef Type',
//                           value: _chefType,
//                           options: _chefOptions,
//                           onChanged: (v) =>
//                               setState(() => _chefType = v ?? 'Chef_All'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Description ──
//                   _LField(
//                     'Description',
//                     _descCtrl,
//                     hint: 'Enter dish description...',
//                     maxLines: 3,
//                     trailing: Text(
//                       '${_descCtrl.text.length}/$_descMax',
//                       style: const TextStyle(fontSize: 11, color: _kT2),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Dish Image ──
//                   const Text(
//                     'Dish Image',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   _DishImagePicker(file: _imageFile, onPick: _pickImage),
//                   const SizedBox(height: 20),
//
//                   // ── Add On ──
//                   _AddonEditor(
//                     addons: _addons,
//                     onAdd: () => setState(() => _addons.add(_AddonRow())),
//                     onRemove: (i) => setState(() {
//                       _addons[i].dispose();
//                       _addons.removeAt(i);
//                     }),
//                     onChanged: () => setState(() {}),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // ── Action buttons ──
//                   _BottomRow(
//                     () => Navigator.pop(context),
//                     _saving ? null : _save,
//                     'Save Dish Item',
//                     _saving,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _contextBox(String label, String value) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: _kT2,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         decoration: BoxDecoration(
//           color: _kBg,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBrd),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 value,
//                 style: const TextStyle(fontSize: 13, color: _kT1),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 18,
//               color: _kMut,
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // EDIT DISH SHEET
// // ─────────────────────────────────────────────────────────────────────────────
// class EditDishSheet extends StatefulWidget {
//   final SubDish sub;
//   final VoidCallback onSaved;
//   const EditDishSheet({super.key, required this.sub, required this.onSaved});
//
//   @override
//   State<EditDishSheet> createState() => _EditDishSheetState();
// }
//
// class _EditDishSheetState extends State<EditDishSheet> {
//   late final TextEditingController _nameCtrl,
//       _codeCtrl,
//       _priceCtrl,
//       _deliveryCtrl,
//       _packingCtrl,
//       _stockCtrl,
//       _descCtrl,
//       _servesCtrl,
//       _metricQtyCtrl;
//
//   late String _menuGst, _deliveryGst, _packingGst;
//   late bool _menuInclusive, _deliveryInclusive, _packingInclusive;
//   late String _tag, _chefType;
//   late String _metrics;
//
//   late final List<_AddonRow> _addons;
//
//   File? _imageFile;
//   bool _saving = false;
//   late bool _resetQuantity;
//
//   static const _descMax = 250;
//
//   static const _chefOptions = [
//     MapEntry('Chef_All', 'All Chefs'),
//     MapEntry('Chef_North', 'North Indian'),
//     MapEntry('Chef_South', 'South Indian'),
//     MapEntry('Chef_Chinese', 'Chinese'),
//     MapEntry('Chef_Continental', 'Continental'),
//     MapEntry('Tea_stall', 'Tea Stall'),
//     MapEntry('Snacks', 'Snacks'),
//     MapEntry('Bakery', 'Bakery'),
//   ];
//
//   String _snapGst(double v) {
//     final s = v.toStringAsFixed(0);
//     return _kGstOptions.contains(s) ? s : '5';
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _resetQuantity = widget.sub.resetQuantity;
//     _nameCtrl = TextEditingController(text: widget.sub.subName);
//     _codeCtrl = TextEditingController(text: widget.sub.code ?? '');
//     _priceCtrl = TextEditingController(
//       text: widget.sub.effectivePrice.toStringAsFixed(2),
//     );
//     _deliveryCtrl = TextEditingController(
//       text: widget.sub.deliveryPrice.toStringAsFixed(2),
//     );
//     _packingCtrl = TextEditingController(
//       text: widget.sub.packingCharges.toStringAsFixed(2),
//     );
//     _stockCtrl = TextEditingController(
//       text: widget.sub.stockQuantity.toString(),
//     );
//     _descCtrl = TextEditingController(text: widget.sub.description);
//     _servesCtrl = TextEditingController(text: '1');
//     _metricQtyCtrl = TextEditingController(
//       text: widget.sub.metricQuantity.toString(),
//     );
//
//     _menuGst = _snapGst(widget.sub.gst);
//     _deliveryGst = _snapGst(widget.sub.gst);
//     _packingGst = _snapGst(widget.sub.gst);
//
//     _menuInclusive = widget.sub.includeGst;
//     _deliveryInclusive = false;
//     _packingInclusive = false;
//     _metrics = widget.sub.metrics;
//
//     _tag = widget.sub.tag;
//     _chefType = widget.sub.chefType;
//
//     _addons = widget.sub.addons
//         .map(
//           (a) => _AddonRow(
//             name: a.addonName,
//             price: a.addonPrice.toStringAsFixed(2),
//             available: a.available,
//             addonId: a.addonId,
//           ),
//         )
//         .toList();
//
//     _priceCtrl.addListener(() => setState(() {}));
//     _deliveryCtrl.addListener(() => setState(() {}));
//     _packingCtrl.addListener(() => setState(() {}));
//     _descCtrl.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _codeCtrl.dispose();
//     _priceCtrl.dispose();
//     _deliveryCtrl.dispose();
//     _packingCtrl.dispose();
//     _stockCtrl.dispose();
//     _descCtrl.dispose();
//     _servesCtrl.dispose();
//     _metricQtyCtrl.dispose();
//     for (final a in _addons) {
//       a.dispose();
//     }
//     super.dispose();
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
//   Future<void> _save() async {
//     final name = _nameCtrl.text.trim();
//     if (name.isEmpty) {
//       showAppDialog(
//         context,
//         title: 'Required',
//         message: 'Please enter a dish name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       final updated = widget.sub.copyWith(
//         subName: name,
//         price: _numOrZero(_priceCtrl.text),
//         gst: _numOrZero(_menuGst),
//         includeGst: _menuInclusive,
//         packingCharges: _numOrZero(_packingCtrl.text),
//         packingGst: _numOrZero(_packingGst),
//         deliveryPrice: _numOrZero(_deliveryCtrl.text),
//         deliveryGst: _numOrZero(_deliveryGst),
//         stockQuantity: _intOrZero(_stockCtrl.text),
//         description: _descCtrl.text.trim(),
//         tag: _tag,
//         chefType: _chefType,
//         code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
//         resetQuantity: _resetQuantity,
//         metrics: _metrics,
//         metricQuantity: _intOrZero(_metricQtyCtrl.text),
//         addons: _addons
//             .where((a) => a.nameCtrl.text.trim().isNotEmpty)
//             .map((a) => a.toAddon())
//             .toList(),
//       );
//
//       await MenuService.editSubDish(updated, imageFile: _imageFile);
//
//       for (final row in _addons) {
//         if (row.nameCtrl.text.trim().isEmpty) continue;
//         if (row.addonId == null || row.addonId == 0) {
//           await MenuService.addAddon(
//             addon: row.toAddon(),
//             dishId: widget.sub.dishId,
//           );
//         }
//       }
//
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to update dish:\n${e.toString()}',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: _kW,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: DraggableScrollableSheet(
//             expand: false,
//             initialChildSize: 0.94,
//             minChildSize: 0.5,
//             maxChildSize: 0.97,
//             builder: (ctx, scrollCtrl) => SingleChildScrollView(
//               controller: scrollCtrl,
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _Handle(),
//
//                   // ── Header ──
//                   Row(
//                     children: [
//                       const Text(
//                         'Edit Dish',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: _kT1,
//                         ),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: _kBg,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: _kBrd),
//                           ),
//                           child: const Icon(
//                             Icons.close_rounded,
//                             size: 16,
//                             color: _kT2,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Item Name * | Item Code ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _LField(
//                           'Item Name',
//                           _nameCtrl,
//                           hint: 'Dish name',
//                           required: true,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _LField(
//                           'Item Code',
//                           _codeCtrl,
//                           hint: 'e.g. 001',
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Menu Price ──
//                   _PriceSection(
//                     priceLabel: 'Menu Price (₹)',
//                     priceCtrl: _priceCtrl,
//                     priceRequired: true,
//                     gstValue: _menuGst,
//                     onGstChanged: (v) => setState(() => _menuGst = v ?? '5'),
//                     inclusive: _menuInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _menuInclusive = v),
//                     breakdownLeftLabel: 'Menu Price',
//                     taxRequired: true,
//                     breakdownEmptyHint: 'Enter price to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Delivery Price ──
//                   _SectionLabel('Delivery Price'),
//                   _PriceSection(
//                     priceLabel: 'Delivery Price (₹)',
//                     priceCtrl: _deliveryCtrl,
//                     gstValue: _deliveryGst,
//                     onGstChanged: (v) =>
//                         setState(() => _deliveryGst = v ?? '5'),
//                     inclusive: _deliveryInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _deliveryInclusive = v),
//                     breakdownLeftLabel: 'Delivery Price',
//                     breakdownEmptyHint: 'Enter price to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Packaging Charges ──
//                   _SectionLabel('Packaging Charges'),
//                   _PriceSection(
//                     priceLabel: 'Packaging Charges (₹)',
//                     priceCtrl: _packingCtrl,
//                     gstValue: _packingGst,
//                     onGstChanged: (v) => setState(() => _packingGst = v ?? '5'),
//                     inclusive: _packingInclusive,
//                     onInclusiveChanged: (v) =>
//                         setState(() => _packingInclusive = v),
//                     breakdownLeftLabel: 'Packaging Charges',
//                     breakdownEmptyHint:
//                         'Enter packaging charges to see breakdown',
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Stock Quantity | Serves ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _LField(
//                           'Stock Quantity',
//                           _stockCtrl,
//                           hint: '0',
//                           type: TextInputType.number,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _LField(
//                           'Serves (No. of Members)',
//                           _servesCtrl,
//                           hint: 'eg., 1',
//                           type: TextInputType.number,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   const SizedBox(height: 10),
//
//                   // ── Metric | Metric Quantity ──  (NEW)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _DField(
//                           label: 'Metric',
//                           value: _metrics,
//                           options: _kMetricOptions,
//                           onChanged: (v) =>
//                               setState(() => _metrics = v ?? 'KG'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _LField(
//                           'Metric Quantity',
//                           _metricQtyCtrl,
//                           hint: '0',
//                           type: TextInputType.number,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // ── Reset Quantity checkbox ──
//                   InkWell(
//                     onTap: () =>
//                         setState(() => _resetQuantity = !_resetQuantity),
//                     borderRadius: BorderRadius.circular(8),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: Checkbox(
//                               value: _resetQuantity,
//                               activeColor: _kP,
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               visualDensity: VisualDensity.compact,
//                               onChanged: (v) =>
//                                   setState(() => _resetQuantity = v ?? false),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Reset Quantity Daily',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: _kT1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Dish Type | Chef Type ──
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: _DField(
//                           label: 'Dish Type',
//                           value: _tag,
//                           options: const [
//                             MapEntry('Veg', 'Veg'),
//                             MapEntry('Non_Veg', 'Non-Veg'),
//                           ],
//                           onChanged: (v) => setState(() => _tag = v ?? 'Veg'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _DField(
//                           label: 'Chef Type',
//                           value: _chefType,
//                           options: _chefOptions,
//                           onChanged: (v) =>
//                               setState(() => _chefType = v ?? 'Chef_All'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Consumed / Balance stats ──
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: _kBg,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _kBrd),
//                     ),
//                     child: Row(
//                       children: [
//                         _StatChip(
//                           'Consumed',
//                           widget.sub.consumedQuantity.toString(),
//                           _kWrn,
//                           _kWLt,
//                         ),
//                         const SizedBox(width: 16),
//                         _StatChip(
//                           'Balance',
//                           widget.sub.balanceQuantity.toString(),
//                           _kInf,
//                           _kILt,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── Description ──
//                   _LField(
//                     'Description',
//                     _descCtrl,
//                     hint: 'Enter dish description...',
//                     maxLines: 3,
//                     trailing: Text(
//                       '${_descCtrl.text.length}/$_descMax',
//                       style: const TextStyle(fontSize: 11, color: _kT2),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Dish Image ──
//                   const Text(
//                     'Dish Image',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _kT2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   _DishImagePicker(
//                     file: _imageFile,
//                     networkUrl: widget.sub.image,
//                     onPick: _pickImage,
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ── Add On ──
//                   _AddonEditor(
//                     addons: _addons,
//                     onAdd: () => setState(() => _addons.add(_AddonRow())),
//                     onRemove: (i) async {
//                       final row = _addons[i];
//                       if (row.addonId != null && row.addonId != 0) {
//                         try {
//                           await MenuService.deleteAddon(row.addonId!);
//                         } catch (e) {
//                           if (mounted) {
//                             showAppDialog(
//                               context,
//                               title: 'Error',
//                               message:
//                                   'Failed to delete addon:\n${e.toString()}',
//                             );
//                           }
//                           return;
//                         }
//                       }
//                       setState(() {
//                         row.dispose();
//                         _addons.removeAt(i);
//                       });
//                     },
//                     onChanged: () => setState(() {}),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // ── Action buttons ──
//                   _BottomRow(
//                     () => Navigator.pop(context),
//                     _saving ? null : _save,
//                     'Update Dish',
//                     _saving,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Stat chip
// // ─────────────────────────────────────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final String label, value;
//   final Color color, bg;
//   const _StatChip(this.label, this.value, this.color, this.bg);
//
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontSize: 10, color: _kT2)),
//       const SizedBox(height: 2),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(7),
//         ),
//         child: Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w800,
//             color: color,
//           ),
//         ),
//       ),
//     ],
//   );
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFF97316);
const _kPDk = Color(0xFFC2510F);
const _kPLt = Color(0xFFFFF0E6);
const _kSuc = Color(0xFF10B981);
const _kSLt = Color(0xFFD1FAE5);
const _kDng = Color(0xFFEF4444);
const _kInf = Color(0xFF3B82F6);
const _kILt = Color(0xFFDBEAFE);
const _kWrn = Color(0xFF16A34A);
const _kWLt = Color(0xFFDCFCE7);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kMut = Color(0xFFB0B3C1);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _kMetricOptions = [
  MapEntry('KG', 'KG'),
  MapEntry('LITRE', 'Litre'),
  MapEntry('PIECE', 'Piece'),
  MapEntry('PACKET', 'Packet'),
];

double _numOrZero(String text) => double.tryParse(text.trim()) ?? 0;
int _intOrZero(String text) => int.tryParse(text.trim()) ?? 0;

const _kGstOptions = ['0', '5', '18'];

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _kBrd,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _kT1,
      ),
    ),
  );
}

class _LField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? type;
  final int maxLines;
  final bool required;
  final Widget? trailing;
  final Widget? prefix;

  const _LField(
    this.label,
    this.ctrl, {
    this.hint = '',
    this.type,
    this.maxLines = 1,
    this.required = false,
    this.trailing,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kT2,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kDng,
              ),
            ),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBrd),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: _kT1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kMut, fontSize: 12),
            border: InputBorder.none,
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    ],
  );
}

class _DField extends StatelessWidget {
  final String label;
  final String value;
  final List<MapEntry<String, String>> options;
  final ValueChanged<String?> onChanged;

  const _DField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kT2,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBrd),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _kT2,
              size: 18,
            ),
            style: const TextStyle(fontSize: 13, color: _kT1),
            onChanged: onChanged,
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ],
  );
}

class _GstDropdown extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  const _GstDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kT2,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBrd),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _kGstOptions.contains(value) ? value : '5',
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _kT2,
              size: 18,
            ),
            style: const TextStyle(fontSize: 13, color: _kT1),
            onChanged: onChanged,
            items: _kGstOptions
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text('$v%', style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ],
  );
}

class _TaxTypeRow extends StatelessWidget {
  final bool inclusive;
  final ValueChanged<bool> onChanged;
  final bool required;
  const _TaxTypeRow({
    required this.inclusive,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        'Tax Type',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kT2,
        ),
      ),
      if (required)
        const Text(
          ' *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kDng,
          ),
        ),
      const SizedBox(width: 16),
      _radio('Exclusive', !inclusive, () => onChanged(false)),
      const SizedBox(width: 20),
      _radio('Inclusive', inclusive, () => onChanged(true)),
    ],
  );

  Widget _radio(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _kP : _kMut,
                  width: selected ? 5 : 1.5,
                ),
                color: _kW,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? _kT1 : _kT2,
              ),
            ),
          ],
        ),
      );
}

/// Three-column price breakdown card
class _BreakdownCard extends StatelessWidget {
  final String leftLabel;
  final double price;
  final double gstPercent;
  final bool inclusive;
  final String emptyHint;

  const _BreakdownCard({
    required this.leftLabel,
    required this.price,
    required this.gstPercent,
    required this.inclusive,
    this.emptyHint = 'Enter price to see breakdown',
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (price == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBrd),
        ),
        child: Text(
          emptyHint,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: _kMut),
        ),
      );
    }

    double basePrice, gstAmount, finalPrice;
    if (inclusive) {
      final div = 1 + (gstPercent / 100);
      basePrice = div == 0 ? price : price / div;
      gstAmount = price - basePrice;
      finalPrice = price;
    } else {
      basePrice = price;
      gstAmount = price * gstPercent / 100;
      finalPrice = price + gstAmount;
    }
    final gLabel = gstPercent == gstPercent.roundToDouble()
        ? gstPercent.toStringAsFixed(0)
        : gstPercent.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBrd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _col(
              leftLabel.toUpperCase(),
              '₹${basePrice.toStringAsFixed(2)}',
              _kT2,
              _kT1,
              bold: false,
            ),
          ),
          Container(width: 1, height: 36, color: _kBrd),
          Expanded(
            child: _col(
              'GST ($gLabel%)',
              '+ ₹${gstAmount.toStringAsFixed(2)}',
              _kT2,
              _kP, // orange for GST
              bold: false,
            ),
          ),
          Container(width: 1, height: 36, color: _kBrd),
          Expanded(
            child: _col(
              'FINAL PRICE',
              '₹${finalPrice.toStringAsFixed(2)}',
              _kT2,
              _kT1,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _col(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    required bool bold,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 10, color: labelColor, letterSpacing: 0.3),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: bold ? 15 : 14,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          color: valueColor,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _PriceSection extends StatelessWidget {
  final String priceLabel;
  final TextEditingController priceCtrl;
  final bool priceRequired;
  final String gstValue;
  final ValueChanged<String?> onGstChanged;
  final bool inclusive;
  final ValueChanged<bool> onInclusiveChanged;
  final String breakdownLeftLabel;
  final bool taxRequired;
  final String breakdownEmptyHint;

  const _PriceSection({
    required this.priceLabel,
    required this.priceCtrl,
    this.priceRequired = false,
    required this.gstValue,
    required this.onGstChanged,
    required this.inclusive,
    required this.onInclusiveChanged,
    required this.breakdownLeftLabel,
    this.taxRequired = false,
    this.breakdownEmptyHint = 'Enter price to see breakdown',
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _LField(
              priceLabel,
              priceCtrl,
              hint: '0.00',
              type: const TextInputType.numberWithOptions(decimal: true),
              required: priceRequired,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GstDropdown(
              label: 'GST %',
              value: gstValue,
              onChanged: onGstChanged,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _TaxTypeRow(
        inclusive: inclusive,
        onChanged: onInclusiveChanged,
        required: taxRequired,
      ),
      const SizedBox(height: 10),
      _BreakdownCard(
        leftLabel: breakdownLeftLabel,
        price: _numOrZero(priceCtrl.text),
        gstPercent: _numOrZero(gstValue),
        inclusive: inclusive,
        emptyHint: breakdownEmptyHint,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom action row  –  dark-gray Cancel, orange Save
// ─────────────────────────────────────────────────────────────────────────────
class _BottomRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final String label;
  final bool saving;

  const _BottomRow(this.onCancel, this.onSave, this.label, this.saving);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      // Cancel — dark charcoal
      Expanded(
        child: GestureDetector(
          onTap: onCancel,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kW,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Save — orange gradient
      Expanded(
        child: GestureDetector(
          onTap: onSave,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 50,
            decoration: BoxDecoration(
              gradient: onSave != null ? _kGrd : null,
              color: onSave == null ? _kBrd : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: onSave != null
                  ? [
                      BoxShadow(
                        color: _kP.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _kW,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: _kW,
                        fontSize: 14,
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

// ─────────────────────────────────────────────────────────────────────────────
// ADDON EDITOR
// ─────────────────────────────────────────────────────────────────────────────

class _AddonRow {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  bool available;
  final int? addonId;

  _AddonRow({
    String name = '',
    String price = '',
    this.available = true,
    this.addonId,
  }) : nameCtrl = TextEditingController(text: name),
       priceCtrl = TextEditingController(text: price);

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }

  Addon toAddon() => Addon(
    addonId: addonId ?? 0,
    addonName: nameCtrl.text.trim(),
    addonPrice: _numOrZero(priceCtrl.text),
    available: available,
  );
}

class _AddonEditor extends StatelessWidget {
  final List<_AddonRow> addons;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  const _AddonEditor({
    required this.addons,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Section header ──
      Row(
        children: [
          const Text(
            'Add On',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kT1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kP,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14, color: _kW),
                  SizedBox(width: 4),
                  Text(
                    'Add',
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
      const SizedBox(height: 10),

      // ── Column headers (only if rows exist) ──
      if (addons.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Name',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kT2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  'Price (₹)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kT2,
                  ),
                ),
              ),
              // Placeholder space for switch + delete
              const SizedBox(width: 80),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],

      // ── Addon rows ──
      if (addons.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBrd),
          ),
          child: const Text(
            'No addons added',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _kT2),
          ),
        )
      else
        ...List.generate(addons.length, (i) {
          final row = addons[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name field
                Expanded(
                  flex: 3,
                  child: _miniField(row.nameCtrl, 'e.g. Extra Cheese'),
                ),
                const SizedBox(width: 8),
                // Price field
                Expanded(
                  flex: 2,
                  child: _miniField(row.priceCtrl, '0.00', isNum: true),
                ),
                const SizedBox(width: 6),
                // Available toggle
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: row.available,
                    activeColor: _kP,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (v) {
                      row.available = v;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                // Delete button
                GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _kW,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kBrd),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: _kDng,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
    ],
  );

  Widget _miniField(
    TextEditingController ctrl,
    String hint, {
    bool isNum = false,
  }) => Container(
    decoration: BoxDecoration(
      color: _kW,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _kBrd),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: isNum
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: _kT1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kMut, fontSize: 12),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dish image picker  –  dashed-border upload area + source buttons
// ─────────────────────────────────────────────────────────────────────────────
class _DishImagePicker extends StatelessWidget {
  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;

  const _DishImagePicker({required this.onPick, this.file, this.networkUrl});

  @override
  Widget build(BuildContext context) {
    final hasImg =
        file != null || (networkUrl != null && networkUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Upload area ──
        GestureDetector(
          onTap: onPick,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: hasImg ? _kP : const Color(0xFFCBCDD8),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: file != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(file!, fit: BoxFit.cover),
                          _changeOverlay(),
                        ],
                      )
                    : (networkUrl != null && networkUrl!.isNotEmpty)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            networkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _uploadPlaceholder(),
                          ),
                          _changeOverlay(),
                        ],
                      )
                    : _uploadPlaceholder(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Source buttons ──
        // Row(
        //   children: [
        //     _SourceButton('From Device', onPick),
        //     const SizedBox(width: 8),
        //     _SourceButton('From Platform', () {}),
        //     const SizedBox(width: 8),
        //     _SourceButton('AI Generated', () {}),
        //   ],
        // ),
      ],
    );
  }

  Widget _uploadPlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _kPLt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_outlined, color: _kP, size: 28),
      ),
      const SizedBox(height: 10),
      const Text(
        'Click or drag to upload',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _kInf,
        ),
      ),
      const SizedBox(height: 2),
      const Text(
        'JPG, PNG • Max 5MB',
        style: TextStyle(fontSize: 11, color: _kT2),
      ),
    ],
  );

  Widget _changeOverlay() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_rounded, color: _kW, size: 13),
          SizedBox(width: 5),
          Text(
            'Change Image',
            style: TextStyle(
              color: _kW,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

/// A small outlined source-selection button below the image picker.
class _SourceButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SourceButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBrd),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kT1,
          ),
        ),
      ),
    ),
  );
}

/// CustomPainter that draws a dashed rounded-rectangle border.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(radius),
        ),
      );

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD DISH SHEET
// ─────────────────────────────────────────────────────────────────────────────
class AddDishSheet extends StatefulWidget {
  final int categoryId;
  final int rootCategoryId;
  final String categoryName;
  final String dishName;
  final VoidCallback onSaved;

  const AddDishSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.dishName,
    required this.rootCategoryId,
    required this.onSaved,
  });

  @override
  State<AddDishSheet> createState() => _AddDishSheetState();
}

class _AddDishSheetState extends State<AddDishSheet> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController(text: '0');
  final _packingCtrl = TextEditingController(text: '0');
  final _stockCtrl = TextEditingController(text: '0');
  final _descCtrl = TextEditingController();
  final _servesCtrl = TextEditingController(text: '1');
  final _metricQtyCtrl = TextEditingController(text: '0');

  bool _resetQuantity = false;

  String _menuGst = '5';
  String _deliveryGst = '5';
  String _packingGst = '5';
  String _metrics = 'KG';

  bool _menuInclusive = false;
  bool _deliveryInclusive = false;
  bool _packingInclusive = false;

  String _tag = 'Veg';
  String _chefType = 'Chef_All';

  final List<_AddonRow> _addons = [];

  File? _imageFile;
  bool _saving = false;

  static const _descMax = 250;

  static const _chefOptions = [
    MapEntry('Chef_All', 'All Chefs'),
    MapEntry('Chef_North', 'North Indian'),
    MapEntry('Chef_South', 'South Indian'),
    MapEntry('Chef_Chinese', 'Chinese'),
    MapEntry('Chef_Continental', 'Continental'),
    MapEntry('Tea_stall', 'Tea Stall'),
    MapEntry('Snacks', 'Snacks'),
    MapEntry('Bakery', 'Bakery'),
  ];

  @override
  void initState() {
    super.initState();
    _priceCtrl.addListener(() => setState(() {}));
    _deliveryCtrl.addListener(() => setState(() {}));
    _packingCtrl.addListener(() => setState(() {}));
    _descCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _priceCtrl.dispose();
    _deliveryCtrl.dispose();
    _packingCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _servesCtrl.dispose();
    _metricQtyCtrl.dispose();
    for (final a in _addons) {
      a.dispose();
    }
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showAppDialog(
        context,
        title: 'Required',
        message: 'Please enter a dish name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final sub = SubDish(
        dishId: 0,
        subName: name,
        price: _numOrZero(_priceCtrl.text),
        gst: _numOrZero(_menuGst),
        includeGst: _menuInclusive,
        packingCharges: _numOrZero(_packingCtrl.text),
        packingGst: _numOrZero(_packingGst),
        deliveryPrice: _numOrZero(_deliveryCtrl.text),
        deliveryGst: _numOrZero(_deliveryGst),
        stockQuantity: _intOrZero(_stockCtrl.text),
        description: _descCtrl.text.trim(),
        tag: _tag,
        chefType: _chefType,
        code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
        addons: _addons
            .where((a) => a.nameCtrl.text.trim().isNotEmpty)
            .map((a) => a.toAddon())
            .toList(),
        resetQuantity: _resetQuantity,
        deliveryIncludeGst: _deliveryInclusive,

        metrics: _metrics,
        metricQuantity: _intOrZero(_metricQtyCtrl.text),
      );
      await MenuService.addSubDish(
        sub: sub,
        parentId: widget.categoryId,
        categoryId: widget.rootCategoryId,
        imageFile: _imageFile,
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to add dish:\n${e.toString()}',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: _kW,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.94,
            minChildSize: 0.5,
            maxChildSize: 0.97,
            builder: (ctx, scrollCtrl) => SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Handle(),

                  // ── Header ──
                  Row(
                    children: [
                      const Text(
                        'Add New Dish Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kT1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: _kBrd),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _kT2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Category / Sub-Category context ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _contextBox('Category', widget.dishName)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _contextBox('Sub Category', widget.categoryName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Dish Name * | Stock Quantity ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LField(
                          'Dish Name',
                          _nameCtrl,
                          hint: 'Enter dish name',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LField(
                          'Stock Quantity',
                          _stockCtrl,
                          hint: '0',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),

                  // ── Metric | Metric Quantity ──  (NEW)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DField(
                          label: 'Metric',
                          value: _metrics,
                          options: _kMetricOptions,
                          onChanged: (v) =>
                              setState(() => _metrics = v ?? 'KG'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LField(
                          'Metric Quantity',
                          _metricQtyCtrl,
                          hint: '0',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Reset Quantity checkbox ──
                  InkWell(
                    onTap: () =>
                        setState(() => _resetQuantity = !_resetQuantity),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _resetQuantity,
                              activeColor: _kP,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (v) =>
                                  setState(() => _resetQuantity = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Reset Quantity Daily',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kT1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Menu Price ──
                  _PriceSection(
                    priceLabel: 'Menu Price (₹)',
                    priceCtrl: _priceCtrl,
                    priceRequired: true,
                    gstValue: _menuGst,
                    onGstChanged: (v) => setState(() => _menuGst = v ?? '5'),
                    inclusive: _menuInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _menuInclusive = v),
                    breakdownLeftLabel: 'Menu Price',
                    taxRequired: true,
                    breakdownEmptyHint: 'Enter price to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('Delivery Price'),
                  _PriceSection(
                    priceLabel: 'Delivery Price (₹)',
                    priceCtrl: _deliveryCtrl,
                    gstValue: _deliveryGst,
                    onGstChanged: (v) =>
                        setState(() => _deliveryGst = v ?? '5'),
                    inclusive: _deliveryInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _deliveryInclusive = v),
                    breakdownLeftLabel: 'Delivery Price',
                    breakdownEmptyHint: 'Enter delivery price to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  // ── Packaging Charges ──
                  _SectionLabel('Packaging Charges'),
                  _PriceSection(
                    priceLabel: 'Packing Charges (₹)',
                    priceCtrl: _packingCtrl,
                    gstValue: _packingGst,
                    onGstChanged: (v) => setState(() => _packingGst = v ?? '5'),
                    inclusive: _packingInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _packingInclusive = v),
                    breakdownLeftLabel: 'Packaging Charges',
                    breakdownEmptyHint:
                        'Enter packaging charges to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  // ── Dish Type | Chef Type ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DField(
                          label: 'Dish Type',
                          value: _tag,
                          options: const [
                            MapEntry('Veg', 'Veg'),
                            MapEntry('Non_Veg', 'Non-Veg'),
                          ],
                          onChanged: (v) => setState(() => _tag = v ?? 'Veg'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DField(
                          label: 'Chef Type',
                          value: _chefType,
                          options: _chefOptions,
                          onChanged: (v) =>
                              setState(() => _chefType = v ?? 'Chef_All'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Description ──
                  _LField(
                    'Description',
                    _descCtrl,
                    hint: 'Enter dish description...',
                    maxLines: 3,
                    trailing: Text(
                      '${_descCtrl.text.length}/$_descMax',
                      style: const TextStyle(fontSize: 11, color: _kT2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Dish Image ──
                  const Text(
                    'Dish Image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kT2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _DishImagePicker(file: _imageFile, onPick: _pickImage),
                  const SizedBox(height: 20),

                  // ── Add On ──
                  _AddonEditor(
                    addons: _addons,
                    onAdd: () => setState(() => _addons.add(_AddonRow())),
                    onRemove: (i) => setState(() {
                      _addons[i].dispose();
                      _addons.removeAt(i);
                    }),
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // ── Action buttons ──
                  _BottomRow(
                    () => Navigator.pop(context),
                    _saving ? null : _save,
                    'Save Dish Item',
                    _saving,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contextBox(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kT2,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBrd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, color: _kT1),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: _kMut,
            ),
          ],
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT DISH SHEET
// ─────────────────────────────────────────────────────────────────────────────
class EditDishSheet extends StatefulWidget {
  final SubDish sub;
  final VoidCallback onSaved;
  const EditDishSheet({super.key, required this.sub, required this.onSaved});

  @override
  State<EditDishSheet> createState() => _EditDishSheetState();
}

class _EditDishSheetState extends State<EditDishSheet> {
  late final TextEditingController _nameCtrl,
      _codeCtrl,
      _priceCtrl,
      _deliveryCtrl,
      _packingCtrl,
      _stockCtrl,
      _descCtrl,
      _servesCtrl,
      _metricQtyCtrl;

  late String _menuGst, _deliveryGst, _packingGst;
  late bool _menuInclusive, _deliveryInclusive, _packingInclusive;
  late String _tag, _chefType;
  late String _metrics;

  late final List<_AddonRow> _addons;

  File? _imageFile;
  bool _saving = false;
  late bool _resetQuantity;

  static const _descMax = 250;

  static const _chefOptions = [
    MapEntry('Chef_All', 'All Chefs'),
    MapEntry('Chef_North', 'North Indian'),
    MapEntry('Chef_South', 'South Indian'),
    MapEntry('Chef_Chinese', 'Chinese'),
    MapEntry('Chef_Continental', 'Continental'),
    MapEntry('Tea_stall', 'Tea Stall'),
    MapEntry('Snacks', 'Snacks'),
    MapEntry('Bakery', 'Bakery'),
  ];

  String _snapGst(double v) {
    final s = v.toStringAsFixed(0);
    return _kGstOptions.contains(s) ? s : '5';
  }

  @override
  void initState() {
    super.initState();
    _resetQuantity = widget.sub.resetQuantity;
    _nameCtrl = TextEditingController(text: widget.sub.subName);
    _codeCtrl = TextEditingController(text: widget.sub.code ?? '');
    _priceCtrl = TextEditingController(
      text: widget.sub.effectivePrice.toStringAsFixed(2),
    );
    _deliveryCtrl = TextEditingController(
      text: widget.sub.deliveryPrice.toStringAsFixed(2),
    );
    _packingCtrl = TextEditingController(
      text: widget.sub.packingCharges.toStringAsFixed(2),
    );
    _stockCtrl = TextEditingController(
      text: widget.sub.stockQuantity.toString(),
    );
    _descCtrl = TextEditingController(text: widget.sub.description);
    _servesCtrl = TextEditingController(text: '1');
    _metricQtyCtrl = TextEditingController(
      text: widget.sub.metricQuantity.toString(),
    );

    _menuGst = _snapGst(widget.sub.gst);
    _deliveryGst = _snapGst(widget.sub.deliveryGst);
    _packingGst = _snapGst(widget.sub.packingGst);

    _menuInclusive = widget.sub.includeGst;
    _deliveryInclusive = widget.sub.deliveryIncludeGst;
    _packingInclusive = false;
    _metrics = widget.sub.metrics;

    _tag = widget.sub.tag;
    _chefType = widget.sub.chefType;

    _addons = widget.sub.addons
        .map(
          (a) => _AddonRow(
            name: a.addonName,
            price: a.addonPrice.toStringAsFixed(2),
            available: a.available,
            addonId: a.addonId,
          ),
        )
        .toList();

    _priceCtrl.addListener(() => setState(() {}));
    _deliveryCtrl.addListener(() => setState(() {}));
    _packingCtrl.addListener(() => setState(() {}));
    _descCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _priceCtrl.dispose();
    _deliveryCtrl.dispose();
    _packingCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _servesCtrl.dispose();
    _metricQtyCtrl.dispose();
    for (final a in _addons) {
      a.dispose();
    }
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showAppDialog(
        context,
        title: 'Required',
        message: 'Please enter a dish name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = widget.sub.copyWith(
        subName: name,
        price: _numOrZero(_priceCtrl.text),
        gst: _numOrZero(_menuGst),
        includeGst: _menuInclusive,
        packingCharges: _numOrZero(_packingCtrl.text),
        packingGst: _numOrZero(_packingGst),
        deliveryPrice: _numOrZero(_deliveryCtrl.text),
        deliveryGst: _numOrZero(_deliveryGst),
        stockQuantity: _intOrZero(_stockCtrl.text),
        description: _descCtrl.text.trim(),
        tag: _tag,
        chefType: _chefType,
        code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
        resetQuantity: _resetQuantity,
        deliveryIncludeGst: _deliveryInclusive,
        metrics: _metrics,
        metricQuantity: _intOrZero(_metricQtyCtrl.text),
        addons: _addons
            .where((a) => a.nameCtrl.text.trim().isNotEmpty)
            .map((a) => a.toAddon())
            .toList(),
      );

      await MenuService.editSubDish(updated, imageFile: _imageFile);

      for (final row in _addons) {
        if (row.nameCtrl.text.trim().isEmpty) continue;
        if (row.addonId == null || row.addonId == 0) {
          await MenuService.addAddon(
            addon: row.toAddon(),
            dishId: widget.sub.dishId,
          );
        }
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update dish:\n${e.toString()}',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: _kW,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.94,
            minChildSize: 0.5,
            maxChildSize: 0.97,
            builder: (ctx, scrollCtrl) => SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Handle(),

                  // ── Header ──
                  Row(
                    children: [
                      const Text(
                        'Edit Dish',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kT1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: _kBrd),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _kT2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Item Name * | Item Code ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LField(
                          'Item Name',
                          _nameCtrl,
                          hint: 'Dish name',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LField(
                          'Item Code',
                          _codeCtrl,
                          hint: 'e.g. 001',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Menu Price ──
                  _PriceSection(
                    priceLabel: 'Menu Price (₹)',
                    priceCtrl: _priceCtrl,
                    priceRequired: true,
                    gstValue: _menuGst,
                    onGstChanged: (v) => setState(() => _menuGst = v ?? '5'),
                    inclusive: _menuInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _menuInclusive = v),
                    breakdownLeftLabel: 'Menu Price',
                    taxRequired: true,
                    breakdownEmptyHint: 'Enter price to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  // ── Delivery Price ──
                  _SectionLabel('Delivery Price'),
                  _PriceSection(
                    priceLabel: 'Delivery Price (₹)',
                    priceCtrl: _deliveryCtrl,
                    gstValue: _deliveryGst,
                    onGstChanged: (v) =>
                        setState(() => _deliveryGst = v ?? '5'),
                    inclusive: _deliveryInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _deliveryInclusive = v),
                    breakdownLeftLabel: 'Delivery Price',
                    breakdownEmptyHint: 'Enter price to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  // ── Packaging Charges ──
                  _SectionLabel('Packaging Charges'),
                  _PriceSection(
                    priceLabel: 'Packaging Charges (₹)',
                    priceCtrl: _packingCtrl,
                    gstValue: _packingGst,
                    onGstChanged: (v) => setState(() => _packingGst = v ?? '5'),
                    inclusive: _packingInclusive,
                    onInclusiveChanged: (v) =>
                        setState(() => _packingInclusive = v),
                    breakdownLeftLabel: 'Packaging Charges',
                    breakdownEmptyHint:
                        'Enter packaging charges to see breakdown',
                  ),
                  const SizedBox(height: 20),

                  // ── Stock Quantity | Serves ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LField(
                          'Stock Quantity',
                          _stockCtrl,
                          hint: '0',
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LField(
                          'Serves (No. of Members)',
                          _servesCtrl,
                          hint: 'eg., 1',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 10),

                  // ── Metric | Metric Quantity ──  (NEW)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DField(
                          label: 'Metric',
                          value: _metrics,
                          options: _kMetricOptions,
                          onChanged: (v) =>
                              setState(() => _metrics = v ?? 'KG'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LField(
                          'Metric Quantity',
                          _metricQtyCtrl,
                          hint: '0',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  // ── Reset Quantity checkbox ──
                  InkWell(
                    onTap: () =>
                        setState(() => _resetQuantity = !_resetQuantity),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _resetQuantity,
                              activeColor: _kP,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (v) =>
                                  setState(() => _resetQuantity = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Reset Quantity Daily',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kT1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Dish Type | Chef Type ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DField(
                          label: 'Dish Type',
                          value: _tag,
                          options: const [
                            MapEntry('Veg', 'Veg'),
                            MapEntry('Non_Veg', 'Non-Veg'),
                          ],
                          onChanged: (v) => setState(() => _tag = v ?? 'Veg'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DField(
                          label: 'Chef Type',
                          value: _chefType,
                          options: _chefOptions,
                          onChanged: (v) =>
                              setState(() => _chefType = v ?? 'Chef_All'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Consumed / Balance stats ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kBrd),
                    ),
                    child: Row(
                      children: [
                        _StatChip(
                          'Consumed',
                          widget.sub.consumedQuantity.toString(),
                          _kWrn,
                          _kWLt,
                        ),
                        const SizedBox(width: 16),
                        _StatChip(
                          'Balance',
                          widget.sub.balanceQuantity.toString(),
                          _kInf,
                          _kILt,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Description ──
                  _LField(
                    'Description',
                    _descCtrl,
                    hint: 'Enter dish description...',
                    maxLines: 3,
                    trailing: Text(
                      '${_descCtrl.text.length}/$_descMax',
                      style: const TextStyle(fontSize: 11, color: _kT2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Dish Image ──
                  const Text(
                    'Dish Image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kT2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _DishImagePicker(
                    file: _imageFile,
                    networkUrl: widget.sub.image,
                    onPick: _pickImage,
                  ),
                  const SizedBox(height: 20),

                  // ── Add On ──
                  _AddonEditor(
                    addons: _addons,
                    onAdd: () => setState(() => _addons.add(_AddonRow())),
                    onRemove: (i) async {
                      final row = _addons[i];
                      if (row.addonId != null && row.addonId != 0) {
                        try {
                          await MenuService.deleteAddon(row.addonId!);
                        } catch (e) {
                          if (mounted) {
                            showAppDialog(
                              context,
                              title: 'Error',
                              message:
                                  'Failed to delete addon:\n${e.toString()}',
                            );
                          }
                          return;
                        }
                      }
                      setState(() {
                        row.dispose();
                        _addons.removeAt(i);
                      });
                    },
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // ── Action buttons ──
                  _BottomRow(
                    () => Navigator.pop(context),
                    _saving ? null : _save,
                    'Update Dish',
                    _saving,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat chip
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _StatChip(this.label, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: _kT2)),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    ],
  );
}
