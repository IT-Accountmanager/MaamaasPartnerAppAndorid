import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/BannerScreen/screens/Theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CompanyBannerSection extends StatefulWidget {
  const CompanyBannerSection({super.key});

  @override
  State<CompanyBannerSection> createState() => _CompanyBannerSectionState();
}

class _CompanyBannerSectionState extends State<CompanyBannerSection> {
  BannerModel _banner = BannerModel();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final b = await BannerApi.get();
      if (b != null && mounted) setState(() => _banner = b);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditBannerSheet(
        banner: _banner,
        onSaved: () {
          _fetch();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 280,
        color: fpBg,
        child:
            const Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return Stack(
      children: [
        // ── Background banner ──────────────────────────────────────────────
        SizedBox(
          height: 280,
          width: double.infinity,
          child: _banner.companyBanner != null
              ? Image.network(_banner.companyBanner!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: kPrimaryDark))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryDark, kPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
        ),
        // ── Dark overlay ──────────────────────────────────────────────────
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
        ),
        // ── Content ───────────────────────────────────────────────────────
        SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row — logo + company name + edit button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _banner.companyLogo != null
                            ? Image.network(_banner.companyLogo!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: kPrimary,
                                    size: 32))
                            : const Icon(Icons.restaurant_menu_rounded,
                                color: kPrimary, size: 32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _banner.companyName.isEmpty
                                ? "Your Company"
                                : _banner.companyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(1, 1))
                              ],
                            ),
                          ),
                          if (_banner.establishedYear.isNotEmpty)
                            Text(
                              'Since ${_banner.establishedYear}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: kPrimary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: const Text('Edit Info',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Open badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle,
                          color: kSuccess, size: 8),
                      SizedBox(width: 6),
                      Text('Open • 9 AM – 10 PM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Social icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIcon(
                        icon: FontAwesomeIcons.instagram,
                        url: _banner.instagramLink,
                        onTap: _launchUrl),
                    _SocialIcon(
                        icon: FontAwesomeIcons.youtube,
                        url: _banner.youtubeLink,
                        onTap: _launchUrl),
                    _SocialIcon(
                        icon: FontAwesomeIcons.linkedin,
                        url: _banner.linkedinLink,
                        onTap: _launchUrl),
                    _SocialIcon(
                        icon: FontAwesomeIcons.facebook,
                        url: _banner.facebookLink,
                        onTap: _launchUrl),
                    _SocialIcon(
                        icon: FontAwesomeIcons.xTwitter,
                        url: _banner.twitterLink,
                        onTap: _launchUrl),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String? url;
  final Function(String?) onTap;

  const _SocialIcon(
      {required this.icon, this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = url != null && url!.isNotEmpty;
    return GestureDetector(
      onTap: active ? () => onTap(url) : null,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(active ? 0.2 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white
                  .withOpacity(active ? 0.4 : 0.15)),
        ),
        child: Center(
          child: FaIcon(icon,
              color: Colors.white
                  .withOpacity(active ? 1.0 : 0.35),
              size: 16),
        ),
      ),
    );
  }
}

// ─── Edit Banner Bottom Sheet ─────────────────────────────────────────────────
class _EditBannerSheet extends StatefulWidget {
  final BannerModel banner;
  final VoidCallback onSaved;

  const _EditBannerSheet({required this.banner, required this.onSaved});

  @override
  State<_EditBannerSheet> createState() => __EditBannerSheetState();
}

class __EditBannerSheetState extends State<_EditBannerSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _igCtrl;
  late final TextEditingController _ytCtrl;
  late final TextEditingController _liCtrl;
  late final TextEditingController _fbCtrl;
  late final TextEditingController _twCtrl;

  File? _bannerFile;
  File? _logoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.banner;
    _nameCtrl = TextEditingController(text: b.companyName);
    _yearCtrl = TextEditingController(text: b.establishedYear);
    _igCtrl = TextEditingController(text: b.instagramLink ?? '');
    _ytCtrl = TextEditingController(text: b.youtubeLink ?? '');
    _liCtrl = TextEditingController(text: b.linkedinLink ?? '');
    _fbCtrl = TextEditingController(text: b.facebookLink ?? '');
    _twCtrl = TextEditingController(text: b.twitterLink ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _yearCtrl, _igCtrl, _ytCtrl, _liCtrl, _fbCtrl, _twCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(bool isBanner) async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) {
      setState(() {
        if (isBanner) _bannerFile = File(f.path);
        else _logoFile = File(f.path);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = widget.banner.copyWith(
        companyName: _nameCtrl.text.trim(),
        establishedYear: _yearCtrl.text.trim(),
        instagramLink: _igCtrl.text.trim(),
        youtubeLink: _ytCtrl.text.trim(),
        linkedinLink: _liCtrl.text.trim(),
        facebookLink: _fbCtrl.text.trim(),
        twitterLink: _twCtrl.text.trim(),
      );
      await BannerApi.save(
        updated,
        bannerBytes: _bannerFile != null
            ? await _bannerFile!.readAsBytes()
            : null,
        logoBytes:
            _logoFile != null ? await _logoFile!.readAsBytes() : null,
      );
      widget.onSaved();
      if (mounted) showSuccess(context, 'Banner updated successfully!');
    } catch (e) {
      if (mounted) showError(context, 'Failed to save banner.');
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
        left: 20, right: 20, top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Edit Company Info',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 20),

            // Image pickers
            Row(children: [
              Expanded(
                child: _ImagePickerTile(
                  label: 'Banner Image',
                  file: _bannerFile,
                  networkUrl: widget.banner.companyBanner,
                  onPick: () => _pickImage(true),
                  height: 80,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImagePickerTile(
                  label: 'Company Logo',
                  file: _logoFile,
                  networkUrl: widget.banner.companyLogo,
                  onPick: () => _pickImage(false),
                  height: 80,
                ),
              ),
            ]),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                  child: FormTile(
                      label: 'Company Name',
                      controller: _nameCtrl,
                      required: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: FormTile(
                      label: 'Since Year',
                      controller: _yearCtrl,
                      keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 14),

            FpSectionHeader(title: 'Social Links'),
            Row(children: [
              Expanded(
                  child: FormTile(
                      label: 'Instagram',
                      controller: _igCtrl,
                      hint: 'https://instagram.com/...')),
              const SizedBox(width: 12),
              Expanded(
                  child: FormTile(
                      label: 'YouTube',
                      controller: _ytCtrl,
                      hint: 'https://youtube.com/...')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: FormTile(
                      label: 'LinkedIn',
                      controller: _liCtrl,
                      hint: 'https://linkedin.com/...')),
              const SizedBox(width: 12),
              Expanded(
                  child: FormTile(
                      label: 'Facebook',
                      controller: _fbCtrl,
                      hint: 'https://facebook.com/...')),
            ]),
            const SizedBox(height: 10),
            FormTile(
                label: 'Twitter / X',
                controller: _twCtrl,
                hint: 'https://twitter.com/...'),
            const SizedBox(height: 24),

            Row(children: [
              Expanded(
                  child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(
                  child: PrimaryButton(
                      label: 'Save Changes',
                      loading: _saving,
                      onPressed: _save)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;
  final double height;

  const _ImagePickerTile({
    required this.label,
    this.file,
    this.networkUrl,
    required this.onPick,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fpText1)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: fpBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: fpBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file != null
                  ? Image.file(file!, fit: BoxFit.cover,
                      width: double.infinity)
                  : (networkUrl != null && networkUrl!.isNotEmpty)
                      ? Image.network(networkUrl!, fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _pickPlaceholder())
                      : _pickPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pickPlaceholder() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: fpText2, size: 24),
            SizedBox(height: 4),
            Text('Tap to upload',
                style: TextStyle(fontSize: 11, color: fpText2)),
          ],
        ),
      );
}
