import 'package:flutter/material.dart';

/// Figma-to-code conversion of the login screen.
///
/// Rebuilt from the generated markup into clean, responsive Flutter widgets so
/// it renders without overflow / "RenderBox was not laid out" errors on any
/// screen size (incl. small phones and when the keyboard is open).
class LoginGenerated extends StatelessWidget {
  const LoginGenerated({super.key});

  static const Color _bg = Color(0xFFF5F8F6);
  static const Color _primary = Color(0xFF097004);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _label = Color(0xFF334155);
  static const Color _hint = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        // Scrolls so nothing overflows, even on small screens / with keyboard.
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [_Header(), _LoginForm()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: hero image + fade-to-background + logo + tagline
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          // Background image (falls back to a plain color if it can't load).
          Image.asset(
            'assets/images/login/login_header.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Colors.red,
            ),
          ),
          // Fade into the page background towards the bottom.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00F5F8F6), Color(0xFFF5F8F6)],
              ),
            ),
          ),
          // Logo image.
          Align(
            alignment: Alignment.bottomLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Image.asset(
                  'assets/images/cakmoji.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // Tagline.
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 24),
              child: Text(
                'Data Naik, Emoji Baik!',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form: tab toggle, email + password fields, divider, role buttons, submit
// ---------------------------------------------------------------------------
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  int _tab = 0; // 0 = Masuk, 1 = Daftar

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabToggle(),
          const SizedBox(height: 24),
          _fieldLabel('Email atau Nomor HP'),
          const SizedBox(height: 6),
          _buildEmailField(),
          const SizedBox(height: 24),
          _fieldLabel('Kata Sandi'),
          const SizedBox(height: 6),
          _buildPasswordField(),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: LoginGenerated._primary,
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDividerWithLabel('Masuk sebagai'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRoleButton('Petani')),
              const SizedBox(width: 12),
              Expanded(child: _buildRoleButton('Pengguna')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: LoginGenerated._primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _tab == 0 ? 'Masuk' : 'Daftar',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: LoginGenerated._label,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LoginGenerated._border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Masuk', 0, active: _tab == 0)),
          Expanded(child: _buildTabItem('Daftar', 1, active: _tab == 1)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, {required bool active}) {
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? LoginGenerated._ink : LoginGenerated._muted,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: LoginGenerated._hint, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: _fieldDecoration('nama@email.com').copyWith(
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.mail_outline,
            color: LoginGenerated._muted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _password,
      obscureText: _obscure,
      decoration: _fieldDecoration('Minimal 8 karakter').copyWith(
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.lock_outline,
            color: LoginGenerated._muted,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: LoginGenerated._muted,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }

  Widget _buildDividerWithLabel(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: LoginGenerated._border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: LoginGenerated._muted,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const Expanded(child: Divider(color: LoginGenerated._border)),
      ],
    );
  }

  Widget _buildRoleButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LoginGenerated._primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),
      ),
    );
  }
}
