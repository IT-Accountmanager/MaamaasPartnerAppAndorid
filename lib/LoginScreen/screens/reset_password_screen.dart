import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';

/// Opened when the user taps the reset link from their email.
/// The deep-link should pass the token as a constructor arg.
/// Usage: ResetPasswordScreen(token: 'abc123...')
class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  const ResetPasswordScreen({super.key, this.token});
  @override State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPass      = false;
  bool _showConfirm   = false;
  bool _passBlurred   = false;
  bool _confirmBlurred = false;
  bool _loading       = false;

  String? _error;
  bool _success = false;

  @override
  void dispose() { _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  bool get _passwordsMatch => _passCtrl.text == _confirmCtrl.text;
  bool get _isValid => _passCtrl.text.length >= 6 && _passwordsMatch && (widget.token?.isNotEmpty ?? false);

  Future<void> _submit() async {
    if (!_isValid) return;
    if (widget.token == null || widget.token!.trim().isEmpty) {
      setState(() => _error = 'Invalid or missing reset link.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.resetPasswordWithToken(token: widget.token!, newPassword: _passCtrl.text);
      if (mounted) setState(() { _success = true; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // No token
    if (widget.token == null || widget.token!.isEmpty) {
      return _noTokenScreen();
    }

    return Scaffold(
      backgroundColor: mlBg,
      body: SafeArea(child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(children: [
            const SizedBox(height: 40),
            // Logo / brand
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: mlAccentL, shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_rounded, color: mlAccent, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: mlText1, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Enter your new password below', style: TextStyle(fontSize: 13, color: mlText2)),
            const SizedBox(height: 32),

            // ── New Password ─────────────────────────────────────────────────
            _label('New Password *'),
            const SizedBox(height: 6),
            _passwordField(
              ctrl: _passCtrl,
              hint: 'Enter new password',
              show: _showPass,
              onToggle: () => setState(() => _showPass = !_showPass),
              onBlur: () => setState(() => _passBlurred = true),
              hasError: _passBlurred && _passCtrl.text.length < 6,
            ),
            if (_passBlurred && _passCtrl.text.length < 6)
              _fieldError('Password must be at least 6 characters'),
            const SizedBox(height: 16),

            // ── Confirm Password ─────────────────────────────────────────────
            _label('Confirm Password *'),
            const SizedBox(height: 6),
            _passwordField(
              ctrl: _confirmCtrl,
              hint: 'Confirm new password',
              show: _showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              onBlur: () => setState(() => _confirmBlurred = true),
              hasError: _confirmBlurred && _confirmCtrl.text.isNotEmpty && !_passwordsMatch,
              isSuccess: _confirmBlurred && _confirmCtrl.text.isNotEmpty && _passwordsMatch,
            ),
            if (_confirmBlurred && _confirmCtrl.text.isNotEmpty && !_passwordsMatch)
              _fieldError('Passwords do not match'),

            if (_error != null) ...[
              const SizedBox(height: 16),
              _errorBox(_error!),
            ],
            const SizedBox(height: 24),

            // ── Submit button ────────────────────────────────────────────────
            GestureDetector(
              onTap: (_isValid && !_loading) ? _submit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: (_isValid && !_loading)
                      ? const LinearGradient(colors: [mlAccent, Color(0xFFD45A2A)])
                      : null,
                  color: (!_isValid || _loading) ? mlBorder : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: (_isValid && !_loading)
                      ? [BoxShadow(color: mlAccent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                      : null,
                ),
                child: _loading
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                    : Center(child: Text(
                        _isValid ? 'Reset Password' : 'Enter password (6+ chars)',
                        style: TextStyle(color: _isValid ? Colors.white : mlText3, fontWeight: FontWeight.w800, fontSize: 15),
                      )),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('← Back to Login', style: TextStyle(color: Color(0xFF667EEA), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // Success overlay
        if (_success) _successOverlay(),
      ])),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    required VoidCallback onBlur,
    bool hasError = false,
    bool isSuccess = false,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: hasError ? const Color(0xFFDC2626) : isSuccess ? const Color(0xFF10B981) : mlBorder),
    ),
    child: Row(children: [
      const SizedBox(width: 14),
      const Icon(Icons.lock_outline_rounded, size: 18, color: mlText3),
      const SizedBox(width: 8),
      Expanded(child: Focus(
        onFocusChange: (hasFocus) { if (!hasFocus) onBlur(); },
        child: TextField(
          controller: ctrl,
          obscureText: !show,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: mlText3, fontSize: 13),
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(fontSize: 13, color: mlText1),
        ),
      )),
      if (isSuccess) const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)),
      GestureDetector(
        onTap: onToggle,
        child: Padding(padding: const EdgeInsets.only(right: 14), child: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: mlText3)),
      ),
    ]),
  );

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: mlText1));

  Widget _fieldError(String msg) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Text(msg, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
  );

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
    ]),
  );

  Widget _successOverlay() => Container(
    color: Colors.black54,
    child: Center(child: Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 36),
        ),
        const SizedBox(height: 16),
        const Text('Password Reset! ✅', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mlText1)),
        const SizedBox(height: 8),
        const Text('Your password has been reset successfully.', style: TextStyle(color: mlText2, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: mlAccent, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('Back to Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    )),
  );

  Widget _noTokenScreen() => Scaffold(
    backgroundColor: mlBg,
    body: SafeArea(child: Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
          child: const Center(child: Text('!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)))),
        ),
        const SizedBox(height: 16),
        const Text('Invalid Reset Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mlText1)),
        const SizedBox(height: 8),
        const Text('The reset link you clicked is invalid or has expired.', style: TextStyle(color: mlText2, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: mlAccent, borderRadius: BorderRadius.circular(12)),
            child: const Text('Back to Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ))),
  );
}
