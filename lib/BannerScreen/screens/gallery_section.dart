import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/BannerScreen/screens/Theme.dart';
import '../models/food_profile_models.dart';
import '../services/food_profile_service.dart';

class GallerySection extends StatefulWidget {
  final AboutUsData? aboutUs;
  final VoidCallback onRefresh;
  const GallerySection({
    super.key,
    required this.aboutUs,
    required this.onRefresh,
  });
  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  bool _uploading = false;

  List<GalleryItem> get _items => widget.aboutUs?.images ?? [];
  int? get _aboutUsId => widget.aboutUs?.aboutUsId;

  Future<void> _addImage() async {
    if (_aboutUsId == null) {
      fpSnack(context, 'Add About Us content first', error: true);
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    final ok = await FoodProfileService.addGalleryImage(
      _aboutUsId!,
      File(picked.path),
    );
    setState(() => _uploading = false);
    if (mounted) {
      fpSnack(context, ok ? 'Image added!' : 'Upload failed', error: !ok);
      if (ok) widget.onRefresh();
    }
  }

  Future<void> _delete(GalleryItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Image?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: fpRed)),
          ),
        ],
      ),
    );
    if (ok != true || _aboutUsId == null) return;

    setState(() => _uploading = true);
    final r = await FoodProfileService.deleteGalleryImage(item.id); // ← just item.id, nothing else
    setState(() => _uploading = false);

    if (mounted) {
      fpSnack(context, r ? 'Deleted!' : 'Failed', error: !r);
      if (r) widget.onRefresh();
    }
  }

  void _preview(GalleryItem item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.mediaUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FpSectionHeader(
        title: 'Gallery',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: fpAccent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            GestureDetector(
              onTap: _uploading ? null : _addImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: fpAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      if (_items.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: fpCardDecoration(),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: fpAccentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: fpAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Images Yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: fpText1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add images to showcase your restaurant',
                  style: TextStyle(color: fpText2, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FpBtn(
                  label: 'Add First Image',
                  onTap: _uploading ? null : _addImage,
                  icon: Icons.add_photo_alternate_outlined,
                ),
              ],
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              return GestureDetector(
                onTap: () => _preview(item),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: fpBg,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: fpText3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Delete button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _delete(item),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    // Preview overlay hint
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 4),
    ],
  );
}
