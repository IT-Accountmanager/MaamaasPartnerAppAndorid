import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/BannerScreen/screens/Theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// ─── ABOUT US ─────────────────────────────────────────────────────────────────
class AboutUsSection extends StatefulWidget {
  const AboutUsSection({super.key});

  @override
  State<AboutUsSection> createState() => _AboutUsSectionState();
}

class _AboutUsSectionState extends State<AboutUsSection> {
  AboutUsModel? _data;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  final _textCtrl = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final d = await AboutUsApi.get();
      if (d != null && mounted) {
        setState(() => _data = d);
        _textCtrl.text = d.text;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final bytes = _imageFile != null ? await _imageFile!.readAsBytes() : null;
      if (_data?.aboutUsId == null) {
        await AboutUsApi.create(_textCtrl.text.trim(), bytes);
      } else {
        await AboutUsApi.update(
          _data!.aboutUsId!,
          _textCtrl.text.trim(),
          bytes,
          _data!.image,
        );
      }
      await _fetch();
      setState(() => _editing = false);
      if (mounted) showSuccess(context, 'About Us updated!');
    } catch (e) {
      if (mounted) showError(context, 'Failed to save.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _SectionSkeleton(height: 200);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: fpCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: kPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'About Our Company',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                if (!_editing)
                  GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final f = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (f != null) {
                            setState(() => _imageFile = File(f.path));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: fpBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: fpBorder),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate,
                            color: kPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _saving ? null : _save,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kSuccess,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        )
                      : FpNetImage(
                          url: _data!.image,
                          width: double.infinity,
                          height: 160,
                          radius: BorderRadius.circular(12),
                          placeholder: Container(
                            height: 160,
                            color: fpBg,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: fpBorder,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                if (!_editing)
                  Text(
                    _data?.text.isEmpty ?? true
                        ? 'No description yet. Tap Edit to add.'
                        : _data!.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: fpText2,
                      height: 1.7,
                    ),
                  )
                else
                  TextField(
                    controller: _textCtrl,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Write about your company...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: fpBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: kPrimary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MISSION VISION ───────────────────────────────────────────────────────────
class MissionVisionSection extends StatefulWidget {
  const MissionVisionSection({super.key});

  @override
  State<MissionVisionSection> createState() => _MissionVisionSectionState();
}

class _MissionVisionSectionState extends State<MissionVisionSection> {
  MissionVisionModel? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final d = await MissionVisionApi.get();
      if (d != null && mounted) setState(() => _data = d);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _openEdit(String type) {
    if (_data == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditMVSheet(
        data: _data!,
        type: type,
        onSaved: () {
          _fetch();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SectionSkeleton(height: 300);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FpSectionHeader(title: 'Mission & Vision'),
          Row(
            children: [
              Expanded(
                child: _MVCard(
                  title: 'Our Mission',
                  text: _data?.mission ?? '',
                  imageUrl: _data?.missionImage,
                  onEdit: () => _openEdit('mission'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MVCard(
                  title: 'Our Vision',
                  text: _data?.vision ?? '',
                  imageUrl: _data?.visionImage,
                  onEdit: () => _openEdit('vision'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MVCard extends StatelessWidget {
  final String title;
  final String text;
  final String? imageUrl;
  final VoidCallback onEdit;

  const _MVCard({
    required this.title,
    required this.text,
    this.imageUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fpCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: FpNetImage(
                  url: imageUrl,
                  width: double.infinity,
                  height: 130,
                  placeholder: Container(
                    height: 130,
                    color: kPrimaryLight,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: kPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: kPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: fpText1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text.isEmpty ? 'Not set yet.' : text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: fpText2,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditMVSheet extends StatefulWidget {
  final MissionVisionModel data;
  final String type;
  final VoidCallback onSaved;

  const _EditMVSheet({
    required this.data,
    required this.type,
    required this.onSaved,
  });

  @override
  State<_EditMVSheet> createState() => __EditMVSheetState();
}

class __EditMVSheetState extends State<_EditMVSheet> {
  late final TextEditingController _ctrl;
  File? _imgFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.type == 'mission' ? widget.data.mission : widget.data.vision,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final bytes = _imgFile != null ? await _imgFile!.readAsBytes() : null;
      await MissionVisionApi.update(
        id: widget.data.aboutUsId!,
        mission: widget.type == 'mission'
            ? _ctrl.text.trim()
            : widget.data.mission,
        vision: widget.type == 'vision'
            ? _ctrl.text.trim()
            : widget.data.vision,
        missionImgBytes: widget.type == 'mission' ? bytes : null,
        visionImgBytes: widget.type == 'vision' ? bytes : null,
      );
      widget.onSaved();
      if (mounted) showSuccess(context, 'Updated!');
    } catch (_) {
      if (mounted) showError(context, 'Failed to update.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.type == 'mission' ? 'Mission' : 'Vision';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          Text(
            'Edit $label',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          // Image preview + picker
          GestureDetector(
            onTap: () async {
              final f = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (f != null) setState(() => _imgFile = File(f.path));
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: fpBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _imgFile != null
                    ? Image.file(
                        _imgFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Stack(
                        children: [
                          FpNetImage(
                            url: widget.type == 'mission'
                                ? widget.data.missionImage
                                : widget.data.visionImage,
                            width: double.infinity,
                            height: 120,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Change Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FormTile(label: 'Description', controller: _ctrl, maxLines: 4),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Update',
                  loading: _saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── GALLERY ──────────────────────────────────────────────────────────────────
class GallerySection extends StatefulWidget {
  const GallerySection({super.key});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  GalleryModel? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final d = await GalleryApi.get();
      if (d != null && mounted) setState(() => _data = d);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickAndUpload(int index) async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f == null || _data?.aboutUsId == null) return;
    try {
      final bytes = await File(f.path).readAsBytes();
      await GalleryApi.updateImage(
        _data!.aboutUsId!,
        'image${index + 1}',
        bytes,
      );
      await _fetch();
      if (mounted) showSuccess(context, 'Image updated!');
    } catch (_) {
      if (mounted) showError(context, 'Failed to update image.');
    }
  }

  Future<void> _addNew() async {
    if (_data == null) return;
    final count = _data!.images.length;
    if (count >= 4) {
      showError(context, 'Maximum 4 images allowed.');
      return;
    }
    await _pickAndUpload(count);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SectionSkeleton(height: 220);

    final images = _data?.images ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FpSectionHeader(
            title: 'Gallery',
            action: GestureDetector(
              onTap: _addNew,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Add Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (images.isEmpty)
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: fpBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fpBorder),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: fpBorder,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No images yet. Tap Add Image.',
                      style: TextStyle(color: fpText2, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: images.length,
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[i],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: fpBg,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: fpBorder,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _pickAndUpload(i),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── LEADERSHIP (TEAM) ────────────────────────────────────────────────────────
class LeadershipSection extends StatefulWidget {
  const LeadershipSection({super.key});

  @override
  State<LeadershipSection> createState() => _LeadershipSectionState();
}

class _LeadershipSectionState extends State<LeadershipSection> {
  List<TeamMember> _team = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final t = await TeamApi.getAll();
      if (mounted) setState(() => _team = t);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamMemberSheet(
        onSaved: () {
          _fetch();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openEditSheet(TeamMember m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamMemberSheet(
        member: m,
        onSaved: () {
          _fetch();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _delete(int teamId) async {
    final ok = await confirmDialog(
      context,
      'Delete Member',
      'Remove this team member?',
    );
    if (!ok) return;
    try {
      await TeamApi.delete(teamId);
      await _fetch();
      if (mounted) showSuccess(context, 'Member removed.');
    } catch (_) {
      if (mounted) showError(context, 'Failed to delete.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SectionSkeleton(height: 260);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FpSectionHeader(
            title: 'Meet Our Team',
            action: GestureDetector(
              onTap: _openAddSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_team.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: fpBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fpBorder),
              ),
              child: const Center(
                child: Text(
                  'No team members yet.',
                  style: TextStyle(color: fpText2),
                ),
              ),
            )
          else
            SizedBox(
              height: 240,
              child: CarouselSlider.builder(
                itemCount: _team.length,
                options: CarouselOptions(
                  height: 240,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.72,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                itemBuilder: (_, i, __) => _TeamCard(
                  member: _team[i],
                  onEdit: () => _openEditSheet(_team[i]),
                  onDelete: () => _delete(_team[i].teamId),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeamCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Image
            FpNetImage(
              url: member.image,
              width: double.infinity,
              height: 240,
              placeholder: Container(
                color: kPrimaryLight,
                child: const Center(
                  child: Icon(Icons.person, color: kPrimary, size: 48),
                ),
              ),
            ),
            // Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
            ),
            // Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            member.designation,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kDanger.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 14,
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

class _TeamMemberSheet extends StatefulWidget {
  final TeamMember? member;
  final VoidCallback onSaved;

  const _TeamMemberSheet({this.member, required this.onSaved});

  @override
  State<_TeamMemberSheet> createState() => __TeamMemberSheetState();
}

class __TeamMemberSheetState extends State<_TeamMemberSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _desigCtrl;
  late final TextEditingController _descCtrl;
  File? _imgFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.member?.name ?? '');
    _desigCtrl = TextEditingController(text: widget.member?.designation ?? '');
    _descCtrl = TextEditingController(text: widget.member?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _desigCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      showError(context, 'Name is required.');
      return;
    }
    setState(() => _saving = true);
    try {
      final bytes = _imgFile != null ? await _imgFile!.readAsBytes() : null;
      if (widget.member == null) {
        await TeamApi.add(
          name: _nameCtrl.text.trim(),
          designation: _desigCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageBytes: bytes,
        );
      } else {
        await TeamApi.update(
          teamId: widget.member!.teamId,
          name: _nameCtrl.text.trim(),
          designation: _desigCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageBytes: bytes,
        );
      }
      widget.onSaved();
      if (mounted) showSuccess(context, 'Saved!');
    } catch (_) {
      if (mounted) showError(context, 'Failed to save member.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(
              widget.member == null ? 'Add Team Member' : 'Edit Team Member',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            // Image picker
            GestureDetector(
              onTap: () async {
                final f = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (f != null) setState(() => _imgFile = File(f.path));
              },
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: kPrimaryLight,
                      backgroundImage: _imgFile != null
                          ? FileImage(_imgFile!) as ImageProvider
                          : (widget.member?.image != null
                                ? NetworkImage(widget.member!.image!)
                                : null),
                      child:
                          (_imgFile == null &&
                              (widget.member?.image == null ||
                                  widget.member!.image!.isEmpty))
                          ? const Icon(Icons.person, color: kPrimary, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FormTile(label: 'Name', controller: _nameCtrl, required: true),
            const SizedBox(height: 12),
            FormTile(label: 'Designation', controller: _desigCtrl),
            const SizedBox(height: 12),
            FormTile(label: 'Description', controller: _descCtrl, maxLines: 3),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: widget.member == null ? 'Add Member' : 'Update',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SKELETON LOADER ──────────────────────────────────────────────────────────
class _SectionSkeleton extends StatelessWidget {
  final double height;
  const _SectionSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: CircularProgressIndicator(color: kPrimary)),
    );
  }
}
