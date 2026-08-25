// //
// // import 'package:flutter/material.dart';
// // import '../models/employee.dart';
// // import '../services/api_service.dart';
// // import '../widgets/theme.dart';
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
// // const _kT1 = Color(0xFF111827);
// // const _kT2 = Color(0xFF6B7280);
// // const _kMut = Color(0xFFB0B3C1);
// // const _kGrd = LinearGradient(
// //   colors: [_kP, _kPDk],
// //   begin: Alignment.topLeft,
// //   end: Alignment.bottomRight,
// // );
// //
// // class EditEmployeeSheet extends StatefulWidget {
// //   final Employee employee;
// //   final VoidCallback onSaved;
// //   const EditEmployeeSheet({
// //     super.key,
// //     required this.employee,
// //     required this.onSaved,
// //   });
// //   @override
// //   State<EditEmployeeSheet> createState() => _EditEmployeeSheetState();
// // }
// //
// // class _EditEmployeeSheetState extends State<EditEmployeeSheet> {
// //   late bool _isActive;
// //   late String _role;
// //   late String _exitDate;
// //   final _remarksCtrl = TextEditingController();
// //   bool _saving = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _isActive = widget.employee.isActive;
// //     _role = widget.employee.role;
// //     _exitDate = widget.employee.exitDate;
// //     _remarksCtrl.text = widget.employee.remarks;
// //   }
// //
// //   @override
// //   void dispose() {
// //     _remarksCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     setState(() => _saving = true);
// //     try {
// //       await EmployeeApi.updateEmployee(
// //         widget.employee.vendorId,
// //         role: _role,
// //         enabled: _isActive,
// //         remarks: _remarksCtrl.text.trim(),
// //         exitDate: _exitDate,
// //       );
// //       if (mounted) {
// //         showSuccess(context, 'Employee updated successfully!');
// //         widget.onSaved();
// //       }
// //     } catch (e) {
// //       if (mounted)
// //         showError(context, e.toString().replaceAll('Exception: ', ''));
// //     } finally {
// //       if (mounted) setState(() => _saving = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final keyboard = MediaQuery.of(context).viewInsets.bottom;
// //     // SafeArea handles home indicator; viewInsets.bottom handles keyboard push-up
// //     return SafeArea(
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             // ── Gradient header with avatar ────────────────────────────────
// //             Container(
// //               padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
// //               decoration: const BoxDecoration(
// //                 gradient: _kGrd,
// //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 38,
// //                     height: 38,
// //                     decoration: BoxDecoration(
// //                       color: _kW.withOpacity(0.25),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Center(
// //                       child: Text(
// //                         widget.employee.name.isNotEmpty
// //                             ? widget.employee.name[0].toUpperCase()
// //                             : '?',
// //                         style: const TextStyle(
// //                           color: _kW,
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Edit — ${widget.employee.name}',
// //                           style: const TextStyle(
// //                             color: _kW,
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.w800,
// //                           ),
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                         Text(
// //                           widget.employee.id,
// //                           style: TextStyle(
// //                             color: _kW.withOpacity(0.8),
// //                             fontSize: 11,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   GestureDetector(
// //                     onTap: () => Navigator.pop(context),
// //                     child: Container(
// //                       padding: const EdgeInsets.all(5),
// //                       decoration: BoxDecoration(
// //                         color: _kW.withOpacity(0.15),
// //                         borderRadius: BorderRadius.circular(7),
// //                       ),
// //                       child: const Icon(
// //                         Icons.close_rounded,
// //                         color: _kW,
// //                         size: 17,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // ── Content ────────────────────────────────────────────────────
// //             Flexible(
// //               child: SingleChildScrollView(
// //                 padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Status toggle card
// //                     Container(
// //                       padding: const EdgeInsets.all(14),
// //                       decoration: BoxDecoration(
// //                         color: _isActive
// //                             ? _kSLt.withOpacity(0.4)
// //                             : _kDLt.withOpacity(0.4),
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: _isActive
// //                               ? _kSuc.withOpacity(0.3)
// //                               : _kDng.withOpacity(0.2),
// //                         ),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Container(
// //                             width: 38,
// //                             height: 38,
// //                             decoration: BoxDecoration(
// //                               color: _isActive ? _kSLt : _kDLt,
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             child: Icon(
// //                               _isActive
// //                                   ? Icons.check_circle_rounded
// //                                   : Icons.cancel_rounded,
// //                               color: _isActive ? _kSDk : _kDng,
// //                               size: 20,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 const Text(
// //                                   'Employee Status',
// //                                   style: TextStyle(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w700,
// //                                     color: _kT1,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 2),
// //                                 Text(
// //                                   _isActive
// //                                       ? 'Currently Active'
// //                                       : 'Currently Inactive',
// //                                   style: TextStyle(
// //                                     fontSize: 11,
// //                                     color: _isActive ? _kSDk : _kDng,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           Row(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               Text(
// //                                 _isActive ? 'Active' : 'Inactive',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   fontWeight: FontWeight.w700,
// //                                   color: _isActive ? _kSDk : _kDng,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 6),
// //                               Switch(
// //                                 value: _isActive,
// //                                 onChanged: (v) => setState(() => _isActive = v),
// //                                 activeColor: _kSuc,
// //                                 materialTapTargetSize:
// //                                     MaterialTapTargetSize.shrinkWrap,
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     const SizedBox(height: 14),
// //
// //                     // Role dropdown
// //                     const _SL('Employee Role'),
// //                     AnimatedContainer(
// //                       duration: const Duration(milliseconds: 180),
// //                       decoration: BoxDecoration(
// //                         color: _kBg,
// //                         borderRadius: BorderRadius.circular(10),
// //                         border: Border.all(color: _kBrd),
// //                       ),
// //                       child: DropdownButtonHideUnderline(
// //                         child: DropdownButton<String>(
// //                           value: _role.isNotEmpty ? _role : null,
// //                           isExpanded: true,
// //                           hint: Padding(
// //                             padding: const EdgeInsets.symmetric(horizontal: 12),
// //                             child: Text(
// //                               _role.isNotEmpty ? _role : 'Select role',
// //                               style: const TextStyle(
// //                                 fontSize: 13,
// //                                 color: _kMut,
// //                               ),
// //                             ),
// //                           ),
// //                           icon: const Padding(
// //                             padding: EdgeInsets.only(right: 10),
// //                             child: Icon(
// //                               Icons.keyboard_arrow_down_rounded,
// //                               color: _kMut,
// //                             ),
// //                           ),
// //                           items: kEmployeeRoles
// //                               .map(
// //                                 (r) => DropdownMenuItem(
// //                                   value: r.value,
// //                                   child: Padding(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 12,
// //                                     ),
// //                                     child: Text(
// //                                       r.label,
// //                                       style: const TextStyle(fontSize: 13),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               )
// //                               .toList(),
// //                           onChanged: (v) => setState(() => _role = v ?? _role),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 14),
// //
// //                     // Exit date picker
// //                     const _SL('Exit Date'),
// //                     GestureDetector(
// //                       onTap: () async {
// //                         DateTime initial = DateTime.now();
// //                         if (_exitDate.isNotEmpty) {
// //                           try {
// //                             initial = DateTime.parse(_exitDate);
// //                           } catch (_) {}
// //                         }
// //                         final picked = await showDatePicker(
// //                           context: context,
// //                           initialDate: initial,
// //                           firstDate: DateTime(2020),
// //                           lastDate: DateTime(2030),
// //                           builder: (c, child) => Theme(
// //                             data: ThemeData.light().copyWith(
// //                               colorScheme: const ColorScheme.light(
// //                                 primary: _kP,
// //                               ),
// //                             ),
// //                             child: child!,
// //                           ),
// //                         );
// //                         if (picked != null)
// //                           setState(
// //                             () => _exitDate = picked.toIso8601String().split(
// //                               'T',
// //                             )[0],
// //                           );
// //                       },
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 180),
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 14,
// //                           vertical: 12,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: _kBg,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(
// //                             color: _exitDate.isNotEmpty
// //                                 ? _kP.withOpacity(0.4)
// //                                 : _kBrd,
// //                             width: _exitDate.isNotEmpty ? 1.5 : 1,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Icon(
// //                               Icons.calendar_today_outlined,
// //                               size: 16,
// //                               color: _exitDate.isNotEmpty ? _kP : _kMut,
// //                             ),
// //                             const SizedBox(width: 10),
// //                             Expanded(
// //                               child: Text(
// //                                 _exitDate.isNotEmpty
// //                                     ? _exitDate
// //                                     : 'Select exit date (optional)',
// //                                 style: TextStyle(
// //                                   fontSize: 13,
// //                                   color: _exitDate.isNotEmpty ? _kT1 : _kMut,
// //                                 ),
// //                               ),
// //                             ),
// //                             if (_exitDate.isNotEmpty)
// //                               GestureDetector(
// //                                 onTap: () => setState(() => _exitDate = ''),
// //                                 child: Container(
// //                                   padding: const EdgeInsets.all(3),
// //                                   decoration: BoxDecoration(
// //                                     color: _kBrd,
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                   child: const Icon(
// //                                     Icons.close_rounded,
// //                                     size: 11,
// //                                     color: _kT2,
// //                                   ),
// //                                 ),
// //                               ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 14),
// //
// //                     // Remarks
// //                     const _SL('Remarks'),
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: _kBg,
// //                         borderRadius: BorderRadius.circular(10),
// //                         border: Border.all(color: _kBrd),
// //                       ),
// //                       child: TextField(
// //                         controller: _remarksCtrl,
// //                         maxLines: 3,
// //                         maxLength: 300,
// //                         style: const TextStyle(fontSize: 13, color: _kT1),
// //                         decoration: InputDecoration(
// //                           hintText: 'Enter remarks about the employee...',
// //                           hintStyle: const TextStyle(
// //                             fontSize: 12,
// //                             color: _kMut,
// //                           ),
// //                           filled: true,
// //                           fillColor: _kBg,
// //                           border: InputBorder.none,
// //                           contentPadding: const EdgeInsets.all(12),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 22),
// //
// //                     // Buttons
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: GestureDetector(
// //                             onTap: () => Navigator.pop(context),
// //                             child: Container(
// //                               height: 44,
// //                               decoration: BoxDecoration(
// //                                 color: _kBg,
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 border: Border.all(color: _kBrd),
// //                               ),
// //                               child: const Center(
// //                                 child: Text(
// //                                   'Cancel',
// //                                   style: TextStyle(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: _kT2,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 10),
// //                         Expanded(
// //                           child: GestureDetector(
// //                             onTap: _saving ? null : _save,
// //                             child: AnimatedContainer(
// //                               duration: const Duration(milliseconds: 180),
// //                               height: 44,
// //                               decoration: BoxDecoration(
// //                                 gradient: _saving ? null : _kGrd,
// //                                 color: _saving ? _kBrd : null,
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 boxShadow: _saving
// //                                     ? null
// //                                     : [
// //                                         BoxShadow(
// //                                           color: _kP.withOpacity(0.3),
// //                                           blurRadius: 8,
// //                                           offset: const Offset(0, 3),
// //                                         ),
// //                                       ],
// //                               ),
// //                               child: Center(
// //                                 child: _saving
// //                                     ? const SizedBox(
// //                                         width: 18,
// //                                         height: 18,
// //                                         child: CircularProgressIndicator(
// //                                           color: _kW,
// //                                           strokeWidth: 2,
// //                                         ),
// //                                       )
// //                                     : const Row(
// //                                         mainAxisSize: MainAxisSize.min,
// //                                         children: [
// //                                           Icon(
// //                                             Icons.save_rounded,
// //                                             color: _kW,
// //                                             size: 15,
// //                                           ),
// //                                           SizedBox(width: 6),
// //                                           Text(
// //                                             'Save Changes',
// //                                             style: TextStyle(
// //                                               fontSize: 13,
// //                                               fontWeight: FontWeight.w700,
// //                                               color: _kW,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _SL extends StatelessWidget {
// //   final String text;
// //   const _SL(this.text);
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: const EdgeInsets.only(bottom: 5),
// //     child: Text(
// //       text,
// //       style: const TextStyle(
// //         fontSize: 11,
// //         fontWeight: FontWeight.w700,
// //         color: _kT2,
// //       ),
// //     ),
// //   );
// // }
// import 'package:flutter/material.dart';
// import '../models/employee.dart';
// import '../services/api_service.dart';
// import '../widgets/theme.dart';
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
// const _kT1 = Color(0xFF111827);
// const _kT2 = Color(0xFF6B7280);
// const _kMut = Color(0xFFB0B3C1);
// const _kGrd = LinearGradient(
//   colors: [_kP, _kPDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class EditEmployeeSheet extends StatefulWidget {
//   final Employee employee;
//   final VoidCallback onSaved;
//   const EditEmployeeSheet({
//     super.key,
//     required this.employee,
//     required this.onSaved,
//   });
//   @override
//   State<EditEmployeeSheet> createState() => _EditEmployeeSheetState();
// }
//
// class _EditEmployeeSheetState extends State<EditEmployeeSheet> {
//   late bool _isActive;
//   late String _role;
//   late String _exitDate;
//   final _remarksCtrl = TextEditingController();
//   bool _saving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isActive = widget.employee.isActive;
//     _role = widget.employee.role;
//     _exitDate = widget.employee.exitDate;
//     _remarksCtrl.text = widget.employee.remarks;
//   }
//
//   @override
//   void dispose() {
//     _remarksCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     setState(() => _saving = true);
//     try {
//       await EmployeeApi.updateEmployee(
//         widget.employee.vendorId,
//         role: _role,
//         enabled: _isActive,
//         remarks: _remarksCtrl.text.trim(),
//         exitDate: _exitDate,
//       );
//       if (mounted) {
//         showSuccess(context, 'Employee updated successfully!');
//         widget.onSaved();
//       }
//     } catch (e) {
//       if (mounted)
//         showError(context, e.toString().replaceAll('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final keyboard = MediaQuery.of(context).viewInsets.bottom;
//     // SafeArea handles home indicator; viewInsets.bottom handles keyboard push-up
//     return SafeArea(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Gradient header with avatar ────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//               decoration: const BoxDecoration(
//                 gradient: _kGrd,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 38,
//                     height: 38,
//                     decoration: BoxDecoration(
//                       color: _kW.withOpacity(0.25),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         widget.employee.name.isNotEmpty
//                             ? widget.employee.name[0].toUpperCase()
//                             : '?',
//                         style: const TextStyle(
//                           color: _kW,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Edit — ${widget.employee.name}',
//                           style: const TextStyle(
//                             color: _kW,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w800,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           widget.employee.id,
//                           style: TextStyle(
//                             color: _kW.withOpacity(0.8),
//                             fontSize: 11,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: const EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         color: _kW.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                       child: const Icon(
//                         Icons.close_rounded,
//                         color: _kW,
//                         size: 17,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Content ────────────────────────────────────────────────────
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Status toggle card
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: _isActive
//                             ? _kSLt.withOpacity(0.4)
//                             : _kDLt.withOpacity(0.4),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _isActive
//                               ? _kSuc.withOpacity(0.3)
//                               : _kDng.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 38,
//                             height: 38,
//                             decoration: BoxDecoration(
//                               color: _isActive ? _kSLt : _kDLt,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(
//                               _isActive
//                                   ? Icons.check_circle_rounded
//                                   : Icons.cancel_rounded,
//                               color: _isActive ? _kSDk : _kDng,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Employee Status',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w700,
//                                     color: _kT1,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   _isActive
//                                       ? 'Currently Active'
//                                       : 'Currently Inactive',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: _isActive ? _kSDk : _kDng,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 _isActive ? 'Active' : 'Inactive',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700,
//                                   color: _isActive ? _kSDk : _kDng,
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Switch(
//                                 value: _isActive,
//                                 onChanged: (v) => setState(() => _isActive = v),
//                                 activeColor: _kSuc,
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//
//                     // Role dropdown
//                     const _SL('Employee Role'),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 180),
//                       decoration: BoxDecoration(
//                         color: _kBg,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _kBrd),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _role.isNotEmpty ? _role : null,
//                           isExpanded: true,
//                           hint: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             child: Text(
//                               _role.isNotEmpty ? _role : 'Select role',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: _kMut,
//                               ),
//                             ),
//                           ),
//                           icon: const Padding(
//                             padding: EdgeInsets.only(right: 10),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: _kMut,
//                             ),
//                           ),
//                           items: kEmployeeRoles
//                               .map(
//                                 (r) => DropdownMenuItem(
//                                   value: r.value,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     child: Text(
//                                       r.label,
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                               .toList(),
//                           onChanged: (v) => setState(() => _role = v ?? _role),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//
//                     // Exit date picker
//                     const _SL('Exit Date'),
//                     GestureDetector(
//                       onTap: () async {
//                         DateTime initial = DateTime.now();
//                         if (_exitDate.isNotEmpty) {
//                           try {
//                             initial = DateTime.parse(_exitDate);
//                           } catch (_) {}
//                         }
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: initial,
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2030),
//                           builder: (c, child) => Theme(
//                             data: ThemeData.light().copyWith(
//                               colorScheme: const ColorScheme.light(
//                                 primary: _kP,
//                               ),
//                             ),
//                             child: child!,
//                           ),
//                         );
//                         if (picked != null)
//                           setState(
//                             () => _exitDate = picked.toIso8601String().split(
//                               'T',
//                             )[0],
//                           );
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 12,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _kBg,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: _exitDate.isNotEmpty
//                                 ? _kP.withOpacity(0.4)
//                                 : _kBrd,
//                             width: _exitDate.isNotEmpty ? 1.5 : 1,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today_outlined,
//                               size: 16,
//                               color: _exitDate.isNotEmpty ? _kP : _kMut,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 _exitDate.isNotEmpty
//                                     ? _exitDate
//                                     : 'Select exit date (optional)',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: _exitDate.isNotEmpty ? _kT1 : _kMut,
//                                 ),
//                               ),
//                             ),
//                             if (_exitDate.isNotEmpty)
//                               GestureDetector(
//                                 onTap: () => setState(() => _exitDate = ''),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(3),
//                                   decoration: BoxDecoration(
//                                     color: _kBrd,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.close_rounded,
//                                     size: 11,
//                                     color: _kT2,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//
//                     // Remarks
//                     const _SL('Remarks'),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: _kBg,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _kBrd),
//                       ),
//                       child: TextField(
//                         controller: _remarksCtrl,
//                         maxLines: 3,
//                         maxLength: 300,
//                         style: const TextStyle(fontSize: 13, color: _kT1),
//                         decoration: InputDecoration(
//                           hintText: 'Enter remarks about the employee...',
//                           hintStyle: const TextStyle(
//                             fontSize: 12,
//                             color: _kMut,
//                           ),
//                           filled: true,
//                           fillColor: _kBg,
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.all(12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 22),
//
//                     // Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Container(
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: _kBg,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: _kBrd),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   'Cancel',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: _kT2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: _saving ? null : _save,
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 180),
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 gradient: _saving ? null : _kGrd,
//                                 color: _saving ? _kBrd : null,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: _saving
//                                     ? null
//                                     : [
//                                         BoxShadow(
//                                           color: _kP.withOpacity(0.3),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ],
//                               ),
//                               child: Center(
//                                 child: _saving
//                                     ? const SizedBox(
//                                         width: 18,
//                                         height: 18,
//                                         child: CircularProgressIndicator(
//                                           color: _kW,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : const Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(
//                                             Icons.save_rounded,
//                                             color: _kW,
//                                             size: 15,
//                                           ),
//                                           SizedBox(width: 6),
//                                           Text(
//                                             'Save Changes',
//                                             style: TextStyle(
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w700,
//                                               color: _kW,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SL extends StatelessWidget {
//   final String text;
//   const _SL(this.text);
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 5),
//     child: Text(
//       text,
//       style: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w700,
//         color: _kT2,
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

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
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kMut = Color(0xFFB0B3C1);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EditEmployeeSheet extends StatefulWidget {
  final Employee employee;
  final VoidCallback onSaved;
  const EditEmployeeSheet({
    super.key,
    required this.employee,
    required this.onSaved,
  });
  @override
  State<EditEmployeeSheet> createState() => _EditEmployeeSheetState();
}

class _EditEmployeeSheetState extends State<EditEmployeeSheet> {
  late bool _isActive;
  late String _role;
  late String _exitDate;
  final _remarksCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.employee.isActive;
    _role = widget.employee.role;
    _exitDate = widget.employee.exitDate;
    _remarksCtrl.text = widget.employee.remarks;
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await EmployeeApi.updateEmployee(
        widget.employee.vendorId,
        role: _role,
        enabled: _isActive,
        remarks: _remarksCtrl.text.trim(),
        exitDate: _exitDate,
      );
      if (mounted) {
        showSuccess(context, 'Employee updated successfully!');
        widget.onSaved();
      }
    } catch (e) {
      if (mounted)
        showError(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    // SafeArea handles home indicator; viewInsets.bottom handles keyboard push-up
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gradient header with avatar ────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: const BoxDecoration(
                gradient: _kGrd,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _kW.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.employee.name.isNotEmpty
                            ? widget.employee.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: _kW,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
                          'Edit — ${widget.employee.name}',
                          style: const TextStyle(
                            color: _kW,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.employee.id,
                          style: TextStyle(
                            color: _kW.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _kW.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _kW,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status toggle card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isActive
                            ? _kSLt.withOpacity(0.4)
                            : _kDLt.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isActive
                              ? _kSuc.withOpacity(0.3)
                              : _kDng.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _isActive ? _kSLt : _kDLt,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _isActive ? _kSDk : _kDng,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Employee Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _kT1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isActive
                                      ? 'Currently Active'
                                      : 'Currently Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _isActive ? _kSDk : _kDng,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _isActive ? _kSDk : _kDng,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Switch(
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                                activeColor: _kSuc,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Role dropdown
                    const _SL('Employee Role'),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBrd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _role.isNotEmpty ? _role : null,
                          isExpanded: true,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _role.isNotEmpty ? _role : 'Select role',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _kMut,
                              ),
                            ),
                          ),
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _kMut,
                            ),
                          ),
                          items: kEmployeeRoles
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r.value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      r.label,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _role = v ?? _role),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Exit date picker
                    const _SL('Exit Date'),
                    GestureDetector(
                      onTap: () async {
                        DateTime initial = DateTime.now();
                        if (_exitDate.isNotEmpty) {
                          try {
                            initial = DateTime.parse(_exitDate);
                          } catch (_) {}
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (c, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: _kP,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null)
                          setState(
                            () => _exitDate = picked.toIso8601String().split(
                              'T',
                            )[0],
                          );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _exitDate.isNotEmpty
                                ? _kP.withOpacity(0.4)
                                : _kBrd,
                            width: _exitDate.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: _exitDate.isNotEmpty ? _kP : _kMut,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _exitDate.isNotEmpty
                                    ? _exitDate
                                    : 'Select exit date (optional)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _exitDate.isNotEmpty ? _kT1 : _kMut,
                                ),
                              ),
                            ),
                            if (_exitDate.isNotEmpty)
                              GestureDetector(
                                onTap: () => setState(() => _exitDate = ''),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _kBrd,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 11,
                                    color: _kT2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Remarks
                    const _SL('Remarks'),
                    Container(
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBrd),
                      ),
                      child: TextField(
                        controller: _remarksCtrl,
                        maxLines: 3,
                        maxLength: 300,
                        style: const TextStyle(fontSize: 13, color: _kT1),
                        decoration: InputDecoration(
                          hintText: 'Enter remarks about the employee...',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: _kMut,
                          ),
                          filled: true,
                          fillColor: _kBg,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                            onTap: _saving ? null : _save,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: _saving ? null : _kGrd,
                                color: _saving ? _kBrd : null,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _saving
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: _kP.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: _kW,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.save_rounded,
                                            color: _kW,
                                            size: 15,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _kW,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _SL extends StatelessWidget {
  final String text;
  const _SL(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _kT2,
      ),
    ),
  );
}
