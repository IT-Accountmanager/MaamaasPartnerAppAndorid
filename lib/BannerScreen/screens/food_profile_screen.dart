import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/food_profile_models.dart';
import '../services/food_profile_service.dart';
import '../widgets/theme.dart';
import 'gallery_section.dart';
import 'team_section.dart';

class FoodProfileScreen0 extends StatefulWidget {
  const FoodProfileScreen0({super.key});
  @override
  State<FoodProfileScreen0> createState() => _FoodProfileScreenState();
}

class _FoodProfileScreenState extends State<FoodProfileScreen0> {
  BannerData? _banner;
  AboutUsData? _aboutUs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final b = await FoodProfileService.getBanner();
    final a = await FoodProfileService.getAboutUs();
    if (mounted)
      setState(() {
        _banner = b;
        _aboutUs = a;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fpBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: fpAccent,
                        strokeWidth: 2,
                      ),
                    )
                  : RefreshIndicator(
                      color: fpAccent,
                      onRefresh: _loadAll,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BannerSection(
                              banner: _banner,
                              onRefresh: _loadAll,
                            ),
                            _AboutUsSection(
                              aboutUs: _aboutUs,
                              onRefresh: _loadAll,
                            ),
                            _MissionVisionSection(
                              aboutUs: _aboutUs,
                              onRefresh: _loadAll,
                            ),
                            TeamSection(aboutUs: _aboutUs),
                            GallerySection(
                              aboutUs: _aboutUs,
                              onRefresh: _loadAll,
                            ),
                            const SizedBox(height: 40),
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

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: const BoxDecoration(
      color: fpCard,
      border: Border(bottom: BorderSide(color: fpBorder)),
    ),

  );
}

// BANNER SECTION
class _BannerSection extends StatelessWidget {
  final BannerData? banner;
  final VoidCallback onRefresh;
  const _BannerSection({required this.banner, required this.onRefresh});

  void _openEdit(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BannerEditSheet(banner: banner, onSaved: onRefresh),
  );

  @override
  Widget build(BuildContext context) {
    final bannerUrl = FoodProfileService.fullImageUrl(banner?.companyBanner);
    final logoUrl = FoodProfileService.fullImageUrl(banner?.companyLogo);
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: fpText1,
            image: bannerUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(bannerUrl),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Color(0x66000000),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: bannerUrl.isEmpty
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFFE66D33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                )
              : null,
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: fpCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: fpAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.restaurant,
                                  color: fpAccent,
                                  size: 32,
                                ),
                              )
                            : const Icon(
                                Icons.restaurant,
                                color: fpAccent,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner?.companyName.isNotEmpty == true
                                ? banner!.companyName
                                : 'Your Restaurant',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                          ),
                          if (banner?.establishedYear.isNotEmpty == true)
                            Text(
                              'Est. ${banner!.establishedYear}',
                              style: const TextStyle(
                                color: Color(0xFFFFD8B3),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openEdit(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: fpAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          banner != null ? 'Edit Info' : 'Add Info',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _sIcon(
                      Icons.camera_alt_outlined,
                      banner?.instagramLink ?? '',
                    ),
                    _sIcon(
                      Icons.play_circle_outline,
                      banner?.youtubeLink ?? '',
                    ),
                    _sIcon(Icons.work_outline, banner?.linkedinLink ?? ''),
                    _sIcon(Icons.facebook_outlined, banner?.facebookLink ?? ''),
                    _sIcon(Icons.alternate_email, banner?.twitterLink ?? ''),
                    _sIcon(
                      Icons.chat_bubble_outline,
                      banner?.whatsappLink ?? '',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sIcon(IconData icon, String url) => GestureDetector(
    onTap: url.isNotEmpty
        ? () async {
            final u = Uri.tryParse(url);
            if (u != null)
              await launchUrl(u, mode: LaunchMode.externalApplication);
          }
        : null,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: url.isNotEmpty ? fpAccent : Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: url.isNotEmpty ? fpAccent : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );
}

class _BannerEditSheet extends StatefulWidget {
  final BannerData? banner;
  final VoidCallback onSaved;
  const _BannerEditSheet({required this.banner, required this.onSaved});
  @override
  State<_BannerEditSheet> createState() => _BannerEditSheetState();
}

class _BannerEditSheetState extends State<_BannerEditSheet> {
  final _name = TextEditingController();
  final _since = TextEditingController();
  final _ig = TextEditingController();
  final _yt = TextEditingController();
  final _li = TextEditingController();
  final _fb = TextEditingController();
  final _tw = TextEditingController();
  final _wa = TextEditingController();
  File? _bannerFile, _logoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.banner;
    _name.text = b?.companyName ?? '';
    _since.text = b?.establishedYear ?? '';
    _ig.text = b?.instagramLink ?? '';
    _yt.text = b?.youtubeLink ?? '';
    _li.text = b?.linkedinLink ?? '';
    _fb.text = b?.facebookLink ?? '';
    _tw.text = b?.twitterLink ?? '';
    _wa.text = b?.whatsappLink ?? '';
  }

  Future<void> _pick(bool isBanner) async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (p != null)
      setState(
        () => isBanner ? _bannerFile = File(p.path) : _logoFile = File(p.path),
      );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      fpSnack(context, 'Enter company name', error: true);
      return;
    }
    setState(() => _saving = true);
    final ok = await FoodProfileService.saveBanner(
      data: BannerData(
        bannerId: widget.banner?.bannerId,
        companyName: _name.text.trim(),
        establishedYear: _since.text.trim(),
        instagramLink: _ig.text.trim(),
        youtubeLink: _yt.text.trim(),
        linkedinLink: _li.text.trim(),
        facebookLink: _fb.text.trim(),
        twitterLink: _tw.text.trim(),
        whatsappLink: _wa.text.trim(),
      ),
      bannerFile: _bannerFile,
      logoFile: _logoFile,
      isEdit: widget.banner != null,
    );
    setState(() => _saving = false);
    if (mounted) {
      if (ok) {
        fpSnack(context, 'Saved!');
        Navigator.pop(context);
        widget.onSaved();
      } else
        fpSnack(context, 'Failed', error: true);
    }
  }

  Widget _f(
    String label,
    TextEditingController c,
    IconData icon, {
    TextInputType? kb,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: kb,
      style: const TextStyle(color: fpText1, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: fpText2, fontSize: 13),
        prefixIcon: Icon(icon, color: fpText3, size: 18),
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

  Widget _imgPick(
    String lbl,
    File? file,
    bool isBanner, {
    double aspect = 2.2,
  }) => GestureDetector(
    onTap: () => _pick(isBanner),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lbl,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: fpText2,
          ),
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: aspect,
          child: Container(
            decoration: BoxDecoration(
              color: fpBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fpBorder, width: 1.5),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(file, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: fpAccent,
                        size: 28,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to add',
                        style: TextStyle(color: fpText3, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.92,
    maxChildSize: 0.95,
    minChildSize: 0.5,
    builder: (_, ctrl) => Container(
      decoration: const BoxDecoration(
        color: fpCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: fpBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Company Banner',
                  style: TextStyle(
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
          ),
          const Divider(height: 20, color: fpBorder),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _imgPick(
                        'Banner Image',
                        _bannerFile,
                        true,
                        aspect: 2.2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: _imgPick('Logo', _logoFile, false, aspect: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _f('Company Name', _name, Icons.store_outlined),
                _f(
                  'Established Year',
                  _since,
                  Icons.calendar_today_outlined,
                  kb: TextInputType.number,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Social Media Links',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: fpText1,
                  ),
                ),
                const SizedBox(height: 10),
                _f('Instagram', _ig, Icons.camera_alt_outlined),
                _f('YouTube', _yt, Icons.play_circle_outline),
                _f('LinkedIn', _li, Icons.work_outline),
                _f('Facebook', _fb, Icons.facebook_outlined),
                _f('Twitter / X', _tw, Icons.alternate_email),
                _f('WhatsApp', _wa, Icons.chat_bubble_outline),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FpBtn(
                    label: _saving ? 'Saving...' : 'Save Changes',
                    loading: _saving,
                    onTap: _save,
                    icon: Icons.save_outlined,
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


// ABOUT US SECTION
class _AboutUsSection extends StatefulWidget {
  final AboutUsData? aboutUs;
  final VoidCallback onRefresh;
  const _AboutUsSection({required this.aboutUs, required this.onRefresh});
  @override
  State<_AboutUsSection> createState() => _AboutUsSectionState();
}

class _AboutUsSectionState extends State<_AboutUsSection> {
  bool _edit = false, _saving = false;
  final _ctrl = TextEditingController();
  File? _imgFile;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.aboutUs?.aboutUs ?? '';
  }

  @override
  void didUpdateWidget(_AboutUsSection o) {
    super.didUpdateWidget(o);
    if (!_edit) _ctrl.text = widget.aboutUs?.aboutUs ?? '';
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) {
      fpSnack(context, 'Enter about us text', error: true);
      return;
    }
    setState(() => _saving = true);
    bool ok;
    if (widget.aboutUs?.aboutUsId == null)
      ok = await FoodProfileService.createAboutUs(_ctrl.text.trim(), _imgFile);
    else
      ok = await FoodProfileService.updateAboutUs(
        widget.aboutUs!.aboutUsId!,
        _ctrl.text.trim(),
        _imgFile,
      );
    setState(() => _saving = false);
    if (mounted) {
      if (ok) {
        fpSnack(context, 'Updated!');
        setState(() {
          _edit = false;
          _imgFile = null;
        });
        widget.onRefresh();
      } else
        fpSnack(context, 'Failed', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = FoodProfileService.fullImageUrl(widget.aboutUs?.image);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FpSectionHeader(
          title: 'About Our Company',
          trailing: _edit
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _edit = false;
                          _imgFile = null;
                          _ctrl.text = widget.aboutUs?.aboutUs ?? '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: fpBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: fpBorder),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: fpText2,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
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
                          color: fpAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => setState(() => _edit = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: fpAccentLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: fpAccent.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, color: fpAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: fpAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: fpCardDecoration(),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _edit
                      ? () async {
                          final p = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (p != null)
                            setState(() => _imgFile = File(p.path));
                        }
                      : null,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _imgFile != null
                            ? Image.file(
                                _imgFile!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : imgUrl.isNotEmpty
                            ? Image.network(
                                imgUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ph(),
                              )
                            : _ph(),
                      ),
                      if (_edit)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tap to change image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _edit
                      ? TextField(
                          controller: _ctrl,
                          maxLines: 6,
                          style: const TextStyle(
                            color: fpText1,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tell customers about your restaurant...',
                            hintStyle: const TextStyle(color: fpText3),
                            filled: true,
                            fillColor: fpBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: fpBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: fpAccent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          widget.aboutUs?.aboutUs.isNotEmpty == true
                              ? widget.aboutUs!.aboutUs
                              : 'Tap Edit to add your story...',
                          style: TextStyle(
                            color: widget.aboutUs?.aboutUs.isNotEmpty == true
                                ? fpText2
                                : fpText3,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ph() => Container(
    height: 180,
    width: double.infinity,
    color: fpBg,
    child: const Center(
      child: Icon(Icons.image_outlined, color: fpText3, size: 48),
    ),
  );
}


// MISSION & VISION SECTION

class _MissionVisionSection extends StatelessWidget {
  final AboutUsData? aboutUs;
  final VoidCallback onRefresh;
  const _MissionVisionSection({required this.aboutUs, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const FpSectionHeader(title: 'Mission & Vision'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _MVCard(
                title: 'Our Mission',
                text: aboutUs?.mission ?? '',
                imageUrl: FoodProfileService.fullImageUrl(
                  aboutUs?.missionImage,
                ),
                icon: Icons.flag_outlined,
                color: const Color(0xFF4CAF50),
                onEdit: () => _open(context, 'mission'),
                onReset: aboutUs?.aboutUsId != null
                    ? () => _reset(context, 'mission')
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MVCard(
                title: 'Our Vision',
                text: aboutUs?.vision ?? '',
                imageUrl: FoodProfileService.fullImageUrl(aboutUs?.visionImage),
                icon: Icons.visibility_outlined,
                color: const Color(0xFF2196F3),
                onEdit: () => _open(context, 'vision'),
                onReset: aboutUs?.aboutUsId != null
                    ? () => _reset(context, 'vision')
                    : null,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  void _open(BuildContext ctx, String type) {
    if (aboutUs?.aboutUsId == null) {
      fpSnack(ctx, 'Add About Us first', error: true);
      return;
    }
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MVSheet(
        type: type,
        aboutUsId: aboutUs!.aboutUsId!,
        currentText: type == 'mission'
            ? (aboutUs?.mission ?? '')
            : (aboutUs?.vision ?? ''),
        currentImageUrl: type == 'mission'
            ? FoodProfileService.fullImageUrl(aboutUs?.missionImage)
            : FoodProfileService.fullImageUrl(aboutUs?.visionImage),
        onSaved: onRefresh,
      ),
    );
  }

  Future<void> _reset(BuildContext ctx, String type) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset ${type == 'mission' ? 'Mission' : 'Vision'}?'),
        content: const Text('This will clear the content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: fpRed)),
          ),
        ],
      ),
    );
    if (ok != true || aboutUs?.aboutUsId == null) return;
    final r = await FoodProfileService.updateMissionVision(
      aboutUsId: aboutUs!.aboutUsId!,
      mission: type == 'mission' ? '' : null,
      vision: type == 'vision' ? '' : null,
    );
    if (ctx.mounted) {
      fpSnack(ctx, r ? 'Reset!' : 'Failed', error: !r);
      if (r) onRefresh();
    }
  }
}

class _MVCard extends StatelessWidget {
  final String title, text, imageUrl;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback? onReset;
  const _MVCard({
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.onEdit,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: fpCardDecoration(radius: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph(),
                    )
                  : _ph(),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Row(
                children: [
                  _ab(Icons.edit_outlined, const Color(0xFF4CAF50), onEdit),
                  if (onReset != null) ...[
                    const SizedBox(width: 4),
                    _ab(Icons.refresh_outlined, fpRed, onReset!),
                  ],
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                text.isNotEmpty ? text : 'Tap edit to add...',
                style: TextStyle(
                  color: text.isNotEmpty ? fpText2 : fpText3,
                  fontSize: 11,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _ph() => Container(
    height: 110,
    width: double.infinity,
    color: color.withOpacity(0.08),
    child: Center(child: Icon(icon, color: color.withOpacity(0.3), size: 32)),
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

class _MVSheet extends StatefulWidget {
  final String type, currentText, currentImageUrl;
  final int aboutUsId;
  final VoidCallback onSaved;
  const _MVSheet({
    required this.type,
    required this.aboutUsId,
    required this.currentText,
    required this.currentImageUrl,
    required this.onSaved,
  });
  @override
  State<_MVSheet> createState() => _MVSheetState();
}

class _MVSheetState extends State<_MVSheet> {
  late final TextEditingController _ctrl;
  File? _imgFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentText);
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) {
      fpSnack(context, 'Enter description', error: true);
      return;
    }
    setState(() => _saving = true);
    final ok = await FoodProfileService.updateMissionVision(
      aboutUsId: widget.aboutUsId,
      mission: widget.type == 'mission' ? _ctrl.text.trim() : null,
      vision: widget.type == 'vision' ? _ctrl.text.trim() : null,
      missionImage: widget.type == 'mission' ? _imgFile : null,
      visionImage: widget.type == 'vision' ? _imgFile : null,
    );
    setState(() => _saving = false);
    if (mounted) {
      if (ok) {
        fpSnack(context, 'Updated!');
        Navigator.pop(context);
        widget.onSaved();
      } else
        fpSnack(context, 'Failed', error: true);
    }
  }

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
                  'Edit ${widget.type == 'mission' ? 'Mission' : 'Vision'}',
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
            GestureDetector(
              onTap: () async {
                final p = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (p != null) setState(() => _imgFile = File(p.path));
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: fpBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: fpBorder, width: 1.5),
                ),
                child: _imgFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(_imgFile!, fit: BoxFit.cover),
                      )
                    : widget.currentImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          widget.currentImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _hint(),
                        ),
                      )
                    : _hint(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              maxLines: 5,
              style: const TextStyle(color: fpText1, fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Enter ${widget.type} description...',
                hintStyle: const TextStyle(color: fpText3),
                filled: true,
                fillColor: fpBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: fpBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: fpAccent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FpBtn(
                label: _saving ? 'Updating...' : 'Update',
                loading: _saving,
                onTap: _save,
                icon: Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _hint() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.add_photo_alternate_outlined, color: fpAccent, size: 32),
      SizedBox(height: 6),
      Text(
        'Tap to select image',
        style: TextStyle(color: fpText3, fontSize: 12),
      ),
    ],
  );
}
