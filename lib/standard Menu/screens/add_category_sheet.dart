//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import '../models/models.dart';
// import '../widgets/common_widgets.dart';
//
// const _kW = Color(0xFFFFFFFF);
// const _kBg = Color(0xFFF7F8FC);
// const _kBrd = Color(0xFFEEEFF5);
// const _kP = Color(0xFFB15DC6);
// const _kPDk = Color(0xFF8B3FA0);
// const _kPLt = Color(0xFFF5E8FA);
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
// // ── Shared helpers ─────────────────────────────────────────────────────────────
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
//
// class _ImageBox extends StatelessWidget {
//   final File? file;
//   final String? networkUrl;
//   final VoidCallback onPick;
//   final String label;
//   const _ImageBox({
//     required this.onPick,
//     required this.label,
//     this.file,
//     this.networkUrl,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final hasImg =
//         file != null || (networkUrl != null && networkUrl!.isNotEmpty);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: _kT2,
//           ),
//         ),
//         const SizedBox(height: 6),
//         GestureDetector(
//           onTap: onPick,
//           child: Container(
//             height: 110,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: _kBg,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: hasImg ? _kP : _kBrd,
//                 width: hasImg ? 1.5 : 1,
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(11),
//               child: file != null
//                   ? _overlay(
//                       Image.file(
//                         file!,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: 110,
//                       ),
//                     )
//                   : (networkUrl != null && networkUrl!.isNotEmpty)
//                   ? _overlay(
//                       Image.network(
//                         networkUrl!,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: 110,
//                         errorBuilder: (_, __, ___) => _placeholder(),
//                       ),
//                     )
//                   : _placeholder(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _overlay(Widget img) => Stack(
//     fit: StackFit.expand,
//     children: [
//       img,
//       Positioned(
//         bottom: 0,
//         left: 0,
//         right: 0,
//         child: Container(
//           color: Colors.black54,
//           padding: const EdgeInsets.symmetric(vertical: 5),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.camera_alt_rounded, color: _kW, size: 13),
//               SizedBox(width: 5),
//               Text(
//                 'Tap to change',
//                 style: TextStyle(
//                   color: _kW,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
//   Widget _placeholder() => Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: const [
//       Icon(Icons.add_photo_alternate_outlined, color: _kMut, size: 32),
//       SizedBox(height: 6),
//       Text(
//         'Tap to upload image',
//         style: TextStyle(
//           fontSize: 12,
//           color: _kMut,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       SizedBox(height: 2),
//       Text('JPG, PNG • Max 5MB', style: TextStyle(fontSize: 10, color: _kBrd)),
//     ],
//   );
// }
//
// class _NameField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String hint;
//   const _NameField(this.ctrl, this.hint);
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Name',
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: _kT2,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Container(
//         decoration: BoxDecoration(
//           color: _kBg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _kBrd),
//         ),
//         child: TextField(
//           controller: ctrl,
//           style: const TextStyle(fontSize: 14, color: _kT1),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: _kMut, fontSize: 13),
//             prefixIcon: const Icon(
//               Icons.label_outline_rounded,
//               color: _kP,
//               size: 17,
//             ),
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// // ─── ADD CATEGORY SHEET ────────────────────────────────────────────────────────
// class AddCategorySheet extends StatefulWidget {
//   final VoidCallback onSaved;
//   const AddCategorySheet({super.key, required this.onSaved});
//   @override
//   State<AddCategorySheet> createState() => _AddCategorySheetState();
// }
//
// class _AddCategorySheetState extends State<AddCategorySheet> {
//   final _nameCtrl = TextEditingController();
//   File? _imageFile;
//   bool _saving = false;
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
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
//         message: 'Please enter a category name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       // CHANGED: Pass imageFile directly instead of bytes
//       await MenuService.addCategory(
//         name: name,
//         imageFile: _imageFile,  // Changed from imageBytes
//         // imageFileName removed since not needed
//       );
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to add category:\n${e.toString()}',
//         );
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       // SafeArea prevents content going under home indicator
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: _kW,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _Handle(),
//               Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: _kPLt,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.category_rounded,
//                       color: _kP,
//                       size: 18,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Add New Category',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             color: _kT1,
//                           ),
//                         ),
//                         Text(
//                           'Create a menu category',
//                           style: TextStyle(fontSize: 11, color: _kT2),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 18),
//               _NameField(_nameCtrl, 'e.g. Starters, Main Course'),
//               const SizedBox(height: 14),
//               _ImageBox(
//                 label: 'Category Image (optional)',
//                 file: _imageFile,
//                 onPick: _pickImage,
//               ),
//               const SizedBox(height: 20),
//               _SaveRow(
//                 () => Navigator.pop(context),
//                 _saving ? null : _save,
//                 'Save Category',
//                 _saving,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── EDIT CATEGORY SHEET ──────────────────────────────────────────────────────
// class EditCategorySheet extends StatefulWidget {
//   final MenuCategory category;
//   final VoidCallback onSaved;
//   const EditCategorySheet({
//     super.key,
//     required this.category,
//     required this.onSaved,
//   });
//   @override
//   State<EditCategorySheet> createState() => _EditCategorySheetState();
// }
//
// class _EditCategorySheetState extends State<EditCategorySheet> {
//   late final TextEditingController _nameCtrl;
//   File? _imageFile;
//   bool _saving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.category.category);
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
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
//         message: 'Please enter a category name.',
//       );
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       // CHANGED: Pass imageFile directly instead of bytes
//       await MenuService.editCategory(
//         dishId: widget.category.dishId,
//         name: name,
//         imageFile: _imageFile,  // Changed from imageBytes
//         // imageFileName removed
//       );
//       widget.onSaved();
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted)
//         showAppDialog(
//           context,
//           title: 'Error',
//           message: 'Failed to update category:\n${e.toString()}',
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
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _Handle(),
//               Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: _kPLt,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.edit_rounded, color: _kP, size: 18),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Edit Category',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             color: _kT1,
//                           ),
//                         ),
//                         Text(
//                           'Update category details',
//                           style: TextStyle(fontSize: 11, color: _kT2),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 18),
//               _NameField(_nameCtrl, 'Category name'),
//               const SizedBox(height: 14),
//               _ImageBox(
//                 label: 'Category Image',
//                 file: _imageFile,
//                 networkUrl: widget.category.image,
//                 onPick: _pickImage,
//               ),
//               const SizedBox(height: 20),
//               _SaveRow(
//                 () => Navigator.pop(context),
//                 _saving ? null : _save,
//                 'Update Category',
//                 _saving,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
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

// ── Shared helpers ─────────────────────────────────────────────────────────────
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

class _ImageBox extends StatelessWidget {
  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;
  final String label;
  const _ImageBox({
    required this.onPick,
    required this.label,
    this.file,
    this.networkUrl,
  });
  @override
  Widget build(BuildContext context) {
    final hasImg =
        file != null || (networkUrl != null && networkUrl!.isNotEmpty);
    return Column(
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
        GestureDetector(
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
        ),
      ],
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
  Widget _placeholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
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

class _NameField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  const _NameField(this.ctrl, this.hint);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: _kT1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kMut, fontSize: 13),
            prefixIcon: const Icon(
              Icons.label_outline_rounded,
              color: _kP,
              size: 17,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          ),
        ),
      ),
    ],
  );
}

// ─── ADD CATEGORY SHEET ────────────────────────────────────────────────────────
class AddCategorySheet extends StatefulWidget {
  final VoidCallback onSaved;
  const AddCategorySheet({super.key, required this.onSaved});
  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  File? _imageFile;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
        message: 'Please enter a category name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // CHANGED: Pass imageFile directly instead of bytes
      await MenuService.addCategory(
        name: name,
        imageFile: _imageFile, // Changed from imageBytes
        // imageFileName removed since not needed
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to add category:\n${e.toString()}',
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // SafeArea prevents content going under home indicator
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kPLt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: _kP,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kT1,
                          ),
                        ),
                        Text(
                          'Create a menu category',
                          style: TextStyle(fontSize: 11, color: _kT2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _NameField(_nameCtrl, 'e.g. Starters, Main Course'),
              const SizedBox(height: 14),
              _ImageBox(
                label: 'Category Image (optional)',
                file: _imageFile,
                onPick: _pickImage,
              ),
              const SizedBox(height: 20),
              _SaveRow(
                () => Navigator.pop(context),
                _saving ? null : _save,
                'Save Category',
                _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── EDIT CATEGORY SHEET ──────────────────────────────────────────────────────
class EditCategorySheet extends StatefulWidget {
  final MenuCategory category;
  final VoidCallback onSaved;
  const EditCategorySheet({
    super.key,
    required this.category,
    required this.onSaved,
  });
  @override
  State<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<EditCategorySheet> {
  late final TextEditingController _nameCtrl;
  File? _imageFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category.category);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
        message: 'Please enter a category name.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // CHANGED: Pass imageFile directly instead of bytes
      await MenuService.editCategory(
        dishId: widget.category.dishId,
        name: name,
        imageFile: _imageFile, // Changed from imageBytes
        // imageFileName removed
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        showAppDialog(
          context,
          title: 'Error',
          message: 'Failed to update category:\n${e.toString()}',
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Handle(),
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
                          'Edit Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kT1,
                          ),
                        ),
                        Text(
                          'Update category details',
                          style: TextStyle(fontSize: 11, color: _kT2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _NameField(_nameCtrl, 'Category name'),
              const SizedBox(height: 14),
              _ImageBox(
                label: 'Category Image',
                file: _imageFile,
                networkUrl: widget.category.image,
                onPick: _pickImage,
              ),
              const SizedBox(height: 20),
              _SaveRow(
                () => Navigator.pop(context),
                _saving ? null : _save,
                'Update Category',
                _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
