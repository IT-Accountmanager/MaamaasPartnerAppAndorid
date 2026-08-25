// //
// // import 'package:flutter/material.dart';
// // import '../models/employee.dart';
// // import '../services/api_service.dart';
// // import '../widgets/theme.dart';
// //
// // // ─── Design tokens ─────────────────────────────────────────────────────────────
// // const _kW = Color(0xFFFFFFFF);
// // const _kBg = Color(0xFFF7F8FC);
// // const _kBrd = Color(0xFFEEEFF5);
// // const _kP = Color(0xFFB15DC6);
// // const _kPDk = Color(0xFF8B3FA0);
// // const _kPLt = Color(0xFFF5E8FA);
// // const _kSuc = Color(0xFF10B981);
// // const _kDng = Color(0xFFEF4444);
// // const _kT1 = Color(0xFF111827);
// // const _kT2 = Color(0xFF6B7280);
// // const _kMut = Color(0xFFB0B3C1);
// // const _kGrd = LinearGradient(
// //   colors: [_kP, _kPDk],
// //   begin: Alignment.topLeft,
// //   end: Alignment.bottomRight,
// // );
// //
// // class AddEmployeeSheet extends StatefulWidget {
// //   final VoidCallback onSaved;
// //   const AddEmployeeSheet({super.key, required this.onSaved});
// //   @override
// //   State<AddEmployeeSheet> createState() => _AddEmployeeSheetState();
// // }
// //
// // class _AddEmployeeSheetState extends State<AddEmployeeSheet> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _nameCtrl = TextEditingController();
// //   final _phoneCtrl = TextEditingController();
// //   final _emailCtrl = TextEditingController();
// //   final _locCtrl = TextEditingController();
// //   String _role = '';
// //   bool _saving = false;
// //
// //   @override
// //   void dispose() {
// //     _nameCtrl.dispose();
// //     _phoneCtrl.dispose();
// //     _emailCtrl.dispose();
// //     _locCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _save() async {
// //     if (!_formKey.currentState!.validate()) return;
// //     if (_role.isEmpty) {
// //       showWarn(context, 'Please select a role');
// //       return;
// //     }
// //     setState(() => _saving = true);
// //     try {
// //       await EmployeeApi.add(
// //         name: _nameCtrl.text.trim(),
// //         phone: _phoneCtrl.text.trim(),
// //         email: _emailCtrl.text.trim(),
// //         role: _role,
// //         location: _locCtrl.text.trim(),
// //       );
// //       if (mounted) {
// //         showSuccess(context, 'Employee added successfully!');
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
// //     // SafeArea wraps the sheet so the home indicator is respected.
// //     // viewInsets.bottom shifts content up when the keyboard appears.
// //     return SafeArea(
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           color: _kW,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             // ── Gradient header ────────────────────────────────────────────
// //             Container(
// //               padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
// //               decoration: const BoxDecoration(
// //                 gradient: _kGrd,
// //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 34,
// //                     height: 34,
// //                     decoration: BoxDecoration(
// //                       color: _kW.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(9),
// //                     ),
// //                     child: const Icon(
// //                       Icons.person_add_rounded,
// //                       color: _kW,
// //                       size: 18,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Add New Employee',
// //                           style: TextStyle(
// //                             color: _kW,
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.w800,
// //                           ),
// //                         ),
// //                         Text(
// //                           'Fill in the employee details below',
// //                           style: TextStyle(color: _kW, fontSize: 11),
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
// //             // ── Form ───────────────────────────────────────────────────────
// //             Flexible(
// //               child: SingleChildScrollView(
// //                 padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
// //                 child: Form(
// //                   key: _formKey,
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Full Name
// //                       _FL('Full Name *'),
// //                       _FF(
// //                         ctrl: _nameCtrl,
// //                         hint: 'Enter full name',
// //                         icon: Icons.person_outline_rounded,
// //                         validator: (v) => (v == null || v.trim().isEmpty)
// //                             ? 'Name is required'
// //                             : null,
// //                       ),
// //                       const SizedBox(height: 12),
// //
// //                       // Phone + Email row
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 _FL('Phone *'),
// //                                 _FF(
// //                                   ctrl: _phoneCtrl,
// //                                   hint: '10-digit mobile',
// //                                   icon: Icons.phone_outlined,
// //                                   type: TextInputType.phone,
// //                                   validator: (v) {
// //                                     if (v == null || v.trim().isEmpty)
// //                                       return 'Required';
// //                                     if (v.trim().length < 10)
// //                                       return 'Min 10 digits';
// //                                     return null;
// //                                   },
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           const SizedBox(width: 10),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 _FL('Email *'),
// //                                 _FF(
// //                                   ctrl: _emailCtrl,
// //                                   hint: 'email@example.com',
// //                                   icon: Icons.email_outlined,
// //                                   type: TextInputType.emailAddress,
// //                                   validator: (v) =>
// //                                       (v == null || v.trim().isEmpty)
// //                                       ? 'Required'
// //                                       : null,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 12),
// //
// //                       // Role dropdown
// //                       _FL('Employee Role *'),
// //                       AnimatedContainer(
// //                         duration: const Duration(milliseconds: 180),
// //                         decoration: BoxDecoration(
// //                           color: _kBg,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(
// //                             color: _role.isEmpty ? _kBrd : _kP.withOpacity(0.5),
// //                             width: _role.isEmpty ? 1 : 1.5,
// //                           ),
// //                         ),
// //                         child: DropdownButtonHideUnderline(
// //                           child: DropdownButton<String>(
// //                             value: _role.isEmpty ? null : _role,
// //                             isExpanded: true,
// //                             hint: const Padding(
// //                               padding: EdgeInsets.symmetric(horizontal: 12),
// //                               child: Text(
// //                                 'Select a role',
// //                                 style: TextStyle(color: _kMut, fontSize: 13),
// //                               ),
// //                             ),
// //                             icon: const Padding(
// //                               padding: EdgeInsets.only(right: 10),
// //                               child: Icon(
// //                                 Icons.keyboard_arrow_down_rounded,
// //                                 color: _kMut,
// //                               ),
// //                             ),
// //                             items: kEmployeeRoles
// //                                 .map(
// //                                   (r) => DropdownMenuItem(
// //                                     value: r.value,
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.symmetric(
// //                                         horizontal: 12,
// //                                       ),
// //                                       child: Text(
// //                                         r.label,
// //                                         style: const TextStyle(fontSize: 13),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 )
// //                                 .toList(),
// //                             onChanged: (v) => setState(() => _role = v ?? ''),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //
// //                       // Location
// //                       _FL('Location'),
// //                       _FF(
// //                         ctrl: _locCtrl,
// //                         hint: 'City / Area',
// //                         icon: Icons.location_on_outlined,
// //                       ),
// //                       const SizedBox(height: 22),
// //
// //                       // Buttons
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: GestureDetector(
// //                               onTap: () => Navigator.pop(context),
// //                               child: Container(
// //                                 height: 44,
// //                                 decoration: BoxDecoration(
// //                                   color: _kBg,
// //                                   borderRadius: BorderRadius.circular(10),
// //                                   border: Border.all(color: _kBrd),
// //                                 ),
// //                                 child: const Center(
// //                                   child: Text(
// //                                     'Cancel',
// //                                     style: TextStyle(
// //                                       fontSize: 13,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: _kT2,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 10),
// //                           Expanded(
// //                             child: GestureDetector(
// //                               onTap: _saving ? null : _save,
// //                               child: AnimatedContainer(
// //                                 duration: const Duration(milliseconds: 180),
// //                                 height: 44,
// //                                 decoration: BoxDecoration(
// //                                   gradient: _saving ? null : _kGrd,
// //                                   color: _saving ? _kBrd : null,
// //                                   borderRadius: BorderRadius.circular(10),
// //                                   boxShadow: _saving
// //                                       ? null
// //                                       : [
// //                                           BoxShadow(
// //                                             color: _kP.withOpacity(0.3),
// //                                             blurRadius: 8,
// //                                             offset: const Offset(0, 3),
// //                                           ),
// //                                         ],
// //                                 ),
// //                                 child: Center(
// //                                   child: _saving
// //                                       ? const SizedBox(
// //                                           width: 18,
// //                                           height: 18,
// //                                           child: CircularProgressIndicator(
// //                                             color: _kW,
// //                                             strokeWidth: 2,
// //                                           ),
// //                                         )
// //                                       : const Row(
// //                                           mainAxisSize: MainAxisSize.min,
// //                                           children: [
// //                                             Icon(
// //                                               Icons.save_rounded,
// //                                               color: _kW,
// //                                               size: 15,
// //                                             ),
// //                                             SizedBox(width: 6),
// //                                             Text(
// //                                               'Save Employee',
// //                                               style: TextStyle(
// //                                                 fontSize: 13,
// //                                                 fontWeight: FontWeight.w700,
// //                                                 color: _kW,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
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
// // // ── Shared form helpers ────────────────────────────────────────────────────────
// // class _FL extends StatelessWidget {
// //   final String text;
// //   const _FL(this.text);
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
// //
// // class _FF extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final String hint;
// //   final IconData icon;
// //   final TextInputType? type;
// //   final String? Function(String?)? validator;
// //   const _FF({
// //     required this.ctrl,
// //     required this.hint,
// //     required this.icon,
// //     this.type,
// //     this.validator,
// //   });
// //   @override
// //   Widget build(BuildContext context) => TextFormField(
// //     controller: ctrl,
// //     keyboardType: type,
// //     validator: validator,
// //     style: const TextStyle(fontSize: 13, color: _kT1),
// //     decoration: InputDecoration(
// //       hintText: hint,
// //       hintStyle: const TextStyle(fontSize: 13, color: _kMut),
// //       prefixIcon: Icon(icon, size: 17, color: _kP.withOpacity(0.7)),
// //       filled: true,
// //       fillColor: _kBg,
// //       border: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: const BorderSide(color: _kBrd),
// //       ),
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: const BorderSide(color: _kBrd),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: const BorderSide(color: _kP, width: 1.5),
// //       ),
// //       errorBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: const BorderSide(color: _kDng),
// //       ),
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
// //     ),
// //   );
// // }
// import 'package:flutter/material.dart';
// import '../models/employee.dart';
// import '../services/api_service.dart';
// import '../widgets/theme.dart';
//
// // ─── Design tokens ─────────────────────────────────────────────────────────────
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFE66D33);
// const _kPDk = Color(0xFFCC5A20);
// const _kPLt = Color(0xFFFFF0E8);
// const _kSuc = Color(0xFF10B981);
// const _kDng = Color(0xFFEF4444);
// const _kT1 = Color(0xFF111827);
// const _kT2 = Color(0xFF6B7280);
// const _kMut = Color(0xFFB0B3C1);
// const _kGrd = LinearGradient(
//   colors: [_kP, _kPDk],
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
//
// class AddEmployeeSheet extends StatefulWidget {
//   final VoidCallback onSaved;
//   const AddEmployeeSheet({super.key, required this.onSaved});
//   @override
//   State<AddEmployeeSheet> createState() => _AddEmployeeSheetState();
// }
//
// class _AddEmployeeSheetState extends State<AddEmployeeSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _locCtrl = TextEditingController();
//   String _role = '';
//   bool _saving = false;
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     _locCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_role.isEmpty) {
//       showWarn(context, 'Please select a role');
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       await EmployeeApi.add(
//         name: _nameCtrl.text.trim(),
//         phone: _phoneCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         role: _role,
//         location: _locCtrl.text.trim(),
//       );
//       if (mounted) {
//         showSuccess(context, 'Employee added successfully!');
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
//     // SafeArea wraps the sheet so the home indicator is respected.
//     // viewInsets.bottom shifts content up when the keyboard appears.
//     return SafeArea(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: _kW,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Gradient header ────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//               decoration: const BoxDecoration(
//                 gradient: _kGrd,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 34,
//                     height: 34,
//                     decoration: BoxDecoration(
//                       color: _kW.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(9),
//                     ),
//                     child: const Icon(
//                       Icons.person_add_rounded,
//                       color: _kW,
//                       size: 18,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Add New Employee',
//                           style: TextStyle(
//                             color: _kW,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                         Text(
//                           'Fill in the employee details below',
//                           style: TextStyle(color: _kW, fontSize: 11),
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
//             // ── Form ───────────────────────────────────────────────────────
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Full Name
//                       _FL('Full Name *'),
//                       _FF(
//                         ctrl: _nameCtrl,
//                         hint: 'Enter full name',
//                         icon: Icons.person_outline_rounded,
//                         validator: (v) => (v == null || v.trim().isEmpty)
//                             ? 'Name is required'
//                             : null,
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Phone + Email row
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _FL('Phone *'),
//                                 _FF(
//                                   ctrl: _phoneCtrl,
//                                   hint: '10-digit mobile',
//                                   icon: Icons.phone_outlined,
//                                   type: TextInputType.phone,
//                                   validator: (v) {
//                                     if (v == null || v.trim().isEmpty)
//                                       return 'Required';
//                                     if (v.trim().length < 10)
//                                       return 'Min 10 digits';
//                                     return null;
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _FL('Email *'),
//                                 _FF(
//                                   ctrl: _emailCtrl,
//                                   hint: 'email@example.com',
//                                   icon: Icons.email_outlined,
//                                   type: TextInputType.emailAddress,
//                                   validator: (v) =>
//                                       (v == null || v.trim().isEmpty)
//                                       ? 'Required'
//                                       : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Role dropdown
//                       _FL('Employee Role *'),
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         decoration: BoxDecoration(
//                           color: _kBg,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: _role.isEmpty ? _kBrd : _kP.withOpacity(0.5),
//                             width: _role.isEmpty ? 1 : 1.5,
//                           ),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _role.isEmpty ? null : _role,
//                             isExpanded: true,
//                             hint: const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 12),
//                               child: Text(
//                                 'Select a role',
//                                 style: TextStyle(color: _kMut, fontSize: 13),
//                               ),
//                             ),
//                             icon: const Padding(
//                               padding: EdgeInsets.only(right: 10),
//                               child: Icon(
//                                 Icons.keyboard_arrow_down_rounded,
//                                 color: _kMut,
//                               ),
//                             ),
//                             items: kEmployeeRoles
//                                 .map(
//                                   (r) => DropdownMenuItem(
//                                     value: r.value,
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                       ),
//                                       child: Text(
//                                         r.label,
//                                         style: const TextStyle(fontSize: 13),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (v) => setState(() => _role = v ?? ''),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Location
//                       _FL('Location'),
//                       _FF(
//                         ctrl: _locCtrl,
//                         hint: 'City / Area',
//                         icon: Icons.location_on_outlined,
//                       ),
//                       const SizedBox(height: 22),
//
//                       // Buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Container(
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   color: _kBg,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(color: _kBrd),
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     'Cancel',
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                       color: _kT2,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: _saving ? null : _save,
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 180),
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   gradient: _saving ? null : _kGrd,
//                                   color: _saving ? _kBrd : null,
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: _saving
//                                       ? null
//                                       : [
//                                           BoxShadow(
//                                             color: _kP.withOpacity(0.3),
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 3),
//                                           ),
//                                         ],
//                                 ),
//                                 child: Center(
//                                   child: _saving
//                                       ? const SizedBox(
//                                           width: 18,
//                                           height: 18,
//                                           child: CircularProgressIndicator(
//                                             color: _kW,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : const Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.save_rounded,
//                                               color: _kW,
//                                               size: 15,
//                                             ),
//                                             SizedBox(width: 6),
//                                             Text(
//                                               'Save Employee',
//                                               style: TextStyle(
//                                                 fontSize: 13,
//                                                 fontWeight: FontWeight.w700,
//                                                 color: _kW,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
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
// // ── Shared form helpers ────────────────────────────────────────────────────────
// class _FL extends StatelessWidget {
//   final String text;
//   const _FL(this.text);
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
//
// class _FF extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   final IconData icon;
//   final TextInputType? type;
//   final String? Function(String?)? validator;
//   const _FF({
//     required this.ctrl,
//     required this.hint,
//     required this.icon,
//     this.type,
//     this.validator,
//   });
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     controller: ctrl,
//     keyboardType: type,
//     validator: validator,
//     style: const TextStyle(fontSize: 13, color: _kT1),
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(fontSize: 13, color: _kMut),
//       prefixIcon: Icon(icon, size: 17, color: _kP.withOpacity(0.7)),
//       filled: true,
//       fillColor: _kBg,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kBrd),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kBrd),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kP, width: 1.5),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kDng),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────
const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFE66D33);
const _kPDk = Color(0xFFCC5A20);
const _kPLt = Color(0xFFFFF0E8);
const _kSuc = Color(0xFF10B981);
const _kDng = Color(0xFFEF4444);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kMut = Color(0xFFB0B3C1);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AddEmployeeSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const AddEmployeeSheet({super.key, required this.onSaved});
  @override
  State<AddEmployeeSheet> createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends State<AddEmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  String _role = '';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role.isEmpty) {
      showWarn(context, 'Please select a role');
      return;
    }
    setState(() => _saving = true);
    try {
      await EmployeeApi.add(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        role: _role,
        location: _locCtrl.text.trim(),
      );
      if (mounted) {
        showSuccess(context, 'Employee added successfully!');
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
    // SafeArea wraps the sheet so the home indicator is respected.
    // viewInsets.bottom shifts content up when the keyboard appears.
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gradient header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: const BoxDecoration(
                gradient: _kGrd,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _kW.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: _kW,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Employee',
                          style: TextStyle(
                            color: _kW,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Fill in the employee details below',
                          style: TextStyle(color: _kW, fontSize: 11),
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

            // ── Form ───────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 18, 20, keyboard + 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _FL('Full Name *'),
                      _FF(
                        ctrl: _nameCtrl,
                        hint: 'Enter full name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Phone + Email row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FL('Phone *'),
                                _FF(
                                  ctrl: _phoneCtrl,
                                  hint: '10-digit mobile',
                                  icon: Icons.phone_outlined,
                                  type: TextInputType.phone,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    if (v.trim().length < 10)
                                      return 'Min 10 digits';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FL('Email *'),
                                _FF(
                                  ctrl: _emailCtrl,
                                  hint: 'email@example.com',
                                  icon: Icons.email_outlined,
                                  type: TextInputType.emailAddress,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Role dropdown
                      _FL('Employee Role *'),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _role.isEmpty ? _kBrd : _kP.withOpacity(0.5),
                            width: _role.isEmpty ? 1 : 1.5,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _role.isEmpty ? null : _role,
                            isExpanded: true,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Select a role',
                                style: TextStyle(color: _kMut, fontSize: 13),
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
                            onChanged: (v) => setState(() => _role = v ?? ''),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location
                      _FL('Location'),
                      _FF(
                        ctrl: _locCtrl,
                        hint: 'City / Area',
                        icon: Icons.location_on_outlined,
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
                                              'Save Employee',
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared form helpers ────────────────────────────────────────────────────────
class _FL extends StatelessWidget {
  final String text;
  const _FL(this.text);
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

class _FF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType? type;
  final String? Function(String?)? validator;
  const _FF({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.type,
    this.validator,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: type,
    validator: validator,
    style: const TextStyle(fontSize: 13, color: _kT1),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _kMut),
      prefixIcon: Icon(icon, size: 17, color: _kP.withOpacity(0.7)),
      filled: true,
      fillColor: _kBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBrd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBrd),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kP, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kDng),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    ),
  );
}
