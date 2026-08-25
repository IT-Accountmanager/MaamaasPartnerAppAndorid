import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});
  @override State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _nameCtrl    = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _cityCtrl    = TextEditingController();

  // Email check (existing user)
  final _loginEmailCtrl = TextEditingController();

  bool _loading = false;
  bool _loginLoading = false;
  bool _showLoginPanel = false;
  String? _error;

  // Validation errors
  Map<String, String?> _errors = {};

  @override
  void dispose() {
    _nameCtrl.dispose(); _companyCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _cityCtrl.dispose(); _loginEmailCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final errs = <String, String?>{};
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final city  = _cityCtrl.text.trim();

    if (name.length < 2) errs['name'] = 'Name must be at least 2 characters';
    else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) errs['name'] = 'Name should contain only letters';

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|in|org|net)$').hasMatch(email))
      errs['email'] = 'Enter valid email (example@gmail.com)';

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) errs['phone'] = 'Enter valid 10-digit phone number';

    if (city.length < 2) errs['city'] = 'Enter valid city';

    setState(() => _errors = errs);
    return errs.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.submitEnquiry(
        name:        _nameCtrl.text.trim(),
        email:       _emailCtrl.text.trim(),
        phone:       _phoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
        city:        _cityCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
      );
      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkEmail() async {
    final email = _loginEmailCtrl.text.trim();
    if (email.isEmpty) { mlSnack(context, 'Enter email', error: true); return; }
    setState(() { _loginLoading = true; _error = null; });
    try {
      await AuthService.checkEmail(email);
      if (mounted) {
        mlSnack(context, 'Email verified! Redirecting...');
        // Navigate to subscription / dashboard:
        // Navigator.pushReplacementNamed(context, '/subscriptionpage');
      }
    } catch (e) {
      mlSnack(context, e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Demo Booked! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Text("We'll get back to you shortly to schedule your demo.", style: TextStyle(color: Color(0xFF64748B), fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () { Navigator.pop(context); Navigator.pop(context); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(color: mlAccent, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: mlBg,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: mlBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: mlBorder)), child: const Icon(Icons.arrow_back_ios_rounded, size: 15, color: mlText1)),
      ),
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Book a Demo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: mlText1, letterSpacing: -0.3)),
        Text('Get started with Maamaas', style: TextStyle(fontSize: 11, color: mlText2)),
      ]),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Tab switch ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: mlBorder, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            _tab('Book Demo', !_showLoginPanel, () => setState(() => _showLoginPanel = false)),
            _tab('Already a User', _showLoginPanel, () => setState(() => _showLoginPanel = true)),
          ]),
        ),
        const SizedBox(height: 20),

        if (!_showLoginPanel) ...[
          // ── ENQUIRY FORM ─────────────────────────────────────────────────
          _heroCard(),
          const SizedBox(height: 20),
          _field(_nameCtrl,    'Full Name *',       Icons.person_outline_rounded,  TextInputType.name,          error: _errors['name']),
          const SizedBox(height: 12),
          _field(_companyCtrl, 'Company Name',      Icons.business_outlined,       TextInputType.text),
          const SizedBox(height: 12),
          _field(_emailCtrl,   'Email Address *',   Icons.email_outlined,          TextInputType.emailAddress,  error: _errors['email']),
          const SizedBox(height: 12),
          _field(_phoneCtrl,   'Phone Number *',    Icons.phone_outlined,          TextInputType.phone,         error: _errors['phone']),
          const SizedBox(height: 12),
          _field(_cityCtrl,    'City *',            Icons.location_city_outlined,  TextInputType.text,          error: _errors['city']),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBox(_error!),
          ],
          const SizedBox(height: 20),
          _submitBtn('Explore →', _loading, _submit),
        ] else ...[
          // ── EMAIL CHECK FORM ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: mlBorder), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Welcome Back 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mlText1)),
              const SizedBox(height: 4),
              const Text('Login with your registered email', style: TextStyle(fontSize: 12, color: mlText2)),
              const SizedBox(height: 16),
              _field(_loginEmailCtrl, 'Enter your Email', Icons.email_outlined, TextInputType.emailAddress),
              const SizedBox(height: 16),
              _submitBtn('Check & Continue →', _loginLoading, _checkEmail),
            ]),
          ),
        ],
      ]),
    ),
  );

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)] : null,
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? mlAccent : mlText2))),
      ),
    ),
  );

  Widget _heroCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [mlAccent, Color(0xFFD45A2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Start Your Journey 🚀', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Fill the form to get a free demo of Maamaas Partner platform.', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4)),
      ])),
      const SizedBox(width: 12),
      const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 40),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, TextInputType kt, {String? error}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: error != null ? const Color(0xFFDC2626) : mlBorder),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(icon, size: 18, color: error != null ? const Color(0xFFDC2626) : mlText3),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: ctrl,
            keyboardType: kt,
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: mlText3, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
            style: const TextStyle(fontSize: 13, color: mlText1),
            onChanged: (_) { if (_errors.isNotEmpty) setState(() => _errors.remove(hint.split(' ')[0].toLowerCase())); },
          )),
        ]),
      ),
      if (error != null) Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
        child: Text(error, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
      ),
    ],
  );

  Widget _submitBtn(String label, bool loading, VoidCallback onTap) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [mlAccent, Color(0xFFD45A2A)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: mlAccent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: loading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          : Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
    ),
  );

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
    ]),
  );
}
