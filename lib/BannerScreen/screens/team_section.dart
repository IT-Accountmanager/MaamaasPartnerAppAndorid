import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/BannerScreen/screens/Theme.dart';
import '../models/food_profile_models.dart';
import '../services/food_profile_service.dart';

class TeamSection extends StatefulWidget {
  final AboutUsData? aboutUs;
  const TeamSection({super.key, required this.aboutUs});
  @override
  State<TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<TeamSection> {
  List<TeamMember> _team = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await FoodProfileService.getTeamMembers();
    if (mounted)
      setState(() {
        _team = t;
        _loading = false;
      });
  }

  void _openSheet({TeamMember? member}) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TeamSheet(member: member, onSaved: _load),
  );

  Future<void> _delete(TeamMember m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Member?'),
        content: Text('Remove ${m.name}?'),
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
    if (ok != true) return;
    final r = await FoodProfileService.deleteTeamMember(m.teamId);
    if (mounted) {
      fpSnack(context, r ? 'Deleted!' : 'Failed', error: !r);
      if (r) _load();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FpSectionHeader(
        title: 'Our Team',
        trailing: GestureDetector(
          onTap: () => _openSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: fpAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 14),
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
      ),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: fpAccent, strokeWidth: 2),
          ),
        )
      else if (_team.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                    Icons.group_outlined,
                    color: fpAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Team Members',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: fpText1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add your team to showcase to customers',
                  style: TextStyle(color: fpText2, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FpBtn(
                  label: 'Add First Member',
                  onTap: () => _openSheet(),
                  icon: Icons.person_add_outlined,
                ),
              ],
            ),
          ),
        )
      else
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: _team.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final m = _team[i];
              final imgUrl = m.image.startsWith('http')
                  ? m.image
                  : m.image.isNotEmpty
                  ? 'http://staging.maamaas.com:8080/${m.image}'
                  : '';
              return SizedBox(
                width: 145,
                child: Container(
                  decoration: fpCardDecoration(radius: 16),
                  child: Stack(
                    children: [
                      // Full image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imgUrl.isNotEmpty
                            ? Image.network(
                                imgUrl,
                                width: 145,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarPlaceholder(m),
                              )
                            : _avatarPlaceholder(m),
                      ),
                      // Bottom gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                m.designation,
                                style: const TextStyle(
                                  color: fpAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Action buttons top right
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Column(
                          children: [
                            _ab(
                              Icons.edit_outlined,
                              const Color(0xFF4CAF50),
                              () => _openSheet(member: m),
                            ),
                            const SizedBox(height: 4),
                            _ab(Icons.delete_outlined, fpRed, () => _delete(m)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 4),
    ],
  );

  Widget _avatarPlaceholder(TeamMember m) => Container(
    width: 145,
    height: 220,
    color: fpAccentLight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: fpAccent,
          child: Text(
            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ab(IconData ic, Color c, VoidCallback t) => GestureDetector(
    onTap: t,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Icon(ic, color: c, size: 13),
    ),
  );
}

class _TeamSheet extends StatefulWidget {
  final TeamMember? member;
  final VoidCallback onSaved;
  const _TeamSheet({this.member, required this.onSaved});
  @override
  State<_TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<_TeamSheet> {
  final _name = TextEditingController();
  final _designation = TextEditingController();
  final _desc = TextEditingController();
  File? _imgFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    if (m != null) {
      _name.text = m.name;
      _designation.text = m.designation;
      _desc.text = m.description;
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _designation.text.trim().isEmpty) {
      fpSnack(context, 'Name and designation required', error: true);
      return;
    }
    setState(() => _saving = true);
    bool ok;
    if (widget.member == null) {
      ok = await FoodProfileService.addTeamMember(
        name: _name.text.trim(),
        designation: _designation.text.trim(),
        description: _desc.text.trim(),
        image: _imgFile,
      );
    } else {
      ok = await FoodProfileService.updateTeamMember(
        teamId: widget.member!.teamId,
        vendorId: widget.member!.vendorId,
        name: _name.text.trim(),
        designation: _designation.text.trim(),
        description: _desc.text.trim(),
        existingImage: widget.member!.image,
        image: _imgFile,
      );
    }
    setState(() => _saving = false);
    if (mounted) {
      if (ok) {
        fpSnack(context, widget.member == null ? 'Member added!' : 'Updated!');
        Navigator.pop(context);
        widget.onSaved();
      } else
        fpSnack(context, 'Failed', error: true);
    }
  }

  Widget _f(
    String label,
    TextEditingController c, {
    int lines = 1,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: c,
      maxLines: lines,
      style: const TextStyle(color: fpText1, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: fpText2, fontSize: 13),
        filled: true,
        fillColor: fpBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fpBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fpBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fpAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      decoration: const BoxDecoration(
        color: fpCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: fpBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  widget.member == null ? 'Add Team Member' : 'Edit Member',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: fpText1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: fpText2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Photo picker
            Center(
              child: GestureDetector(
                onTap: () async {
                  final p = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (p != null) setState(() => _imgFile = File(p.path));
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: fpAccentLight,
                      backgroundImage: _imgFile != null
                          ? FileImage(_imgFile!) as ImageProvider
                          : widget.member?.image.isNotEmpty == true
                          ? (NetworkImage(
                              widget.member!.image.startsWith('http')
                                  ? widget.member!.image
                                  : 'http://staging.maamaas.com:8080/${widget.member!.image}',
                            ))
                          : null,
                      child:
                          (_imgFile == null &&
                              (widget.member?.image.isEmpty != false))
                          ? const Icon(Icons.person, color: fpAccent, size: 36)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: fpAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: fpCard, width: 2),
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
            _f('Name *', _name, hint: 'Enter full name'),
            _f('Designation *', _designation, hint: 'e.g. Chef, Manager'),
            _f(
              'Description',
              _desc,
              lines: 3,
              hint: 'Tell us about this member...',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FpBtn(
                label: _saving
                    ? 'Saving...'
                    : (widget.member == null ? 'Add Member' : 'Update Member'),
                loading: _saving,
                onTap: _save,
                icon: Icons.person_add_outlined,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
