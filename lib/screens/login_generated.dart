import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../services/supabase_service.dart';
import '../widgets/app_field_label.dart';
import '../widgets/app_role_button.dart';
import '../widgets/app_section_divider.dart';
import '../widgets/app_segmented_toggle.dart';
import '../widgets/app_text_field.dart';

/// Login / Register screen (Figma → code) wired to Supabase auth + database.
///
/// - **Masuk** tab: email + password.
/// - **Daftar** tab: name + email + password.
/// - The **Petani** / **Pengguna** buttons trigger the action — they log in or
///   register with the matching account `type` (`petani` | `pelanggan`).
class LoginGenerated extends StatelessWidget {
  const LoginGenerated({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.background),
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
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24, bottom: 34),
              child: _LogoMark(),
            ),
          ),
          // Tagline.
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 24),
              child: Text(
                'Tanam Cerdas, Panen Berkualitas!',
                style: TextStyle(
                  color: AppColors.textHero,
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

/// Small rounded logo.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: Image.asset(
        'assets/images/emotigrow.png',
        width: MediaQuery.of(context).size.width * 0.3,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form: tab toggle, fields, and the Petani/Pengguna auth triggers
// ---------------------------------------------------------------------------
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  int _tab = 0; // 0 = Masuk, 1 = Daftar
  String?
  _loadingRole; // role currently authenticating ('petani' | 'pelanggan')
  String? _error;

  bool get _isRegister => _tab == 1;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Runs a login or register with [role] as the account type.
  Future<void> _authenticate(String role) async {
    FocusScope.of(context).unfocus();
    if (!_isValid()) return;

    setState(() {
      _loadingRole = role;
      _error = null;
    });

    try {
      bool ready = true;
      if (_isRegister) {
        ready = await SupabaseService.instance.signUp(
          email: _email.text.trim(),
          password: _password.text,
          name: _name.text.trim(),
          userType: role,
        );
      } else {
        await SupabaseService.instance.signInWithEmail(
          email: _email.text.trim(),
          password: _password.text,
        );
      }

      if (!mounted) return;
      if (!ready) {
        setState(() {
          _error = 'Check your email to confirm your account, then sign in.';
        });
        return;
      }

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loadingRole = null);
    }
  }

  bool _isValid() {
    final email = _email.text.trim();
    final password = _password.text;
    String? message;
    if (_isRegister && _name.text.trim().isEmpty) {
      message = 'Please enter your name.';
    } else if (!email.contains('@') || !email.contains('.')) {
      message = 'Enter a valid email address.';
    } else if (password.length < 8) {
      message = 'Password must be at least 8 characters.';
    }
    if (message == null) return true;
    setState(() => _error = message);
    return false;
  }

  String _friendlyError(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('already registered') || s.contains('already exists')) {
      return 'This email is already registered.';
    }
    if (s.contains('invalid login credentials') || s.contains('invalidlogin')) {
      return 'Email or password is incorrect.';
    }
    return error.toString();
  }

  Widget _prefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(icon, color: AppColors.textMuted, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedToggle(
            options: const ['Masuk', 'Daftar'],
            index: _tab,
            onChanged: (i) => setState(() {
              _tab = i;
              _error = null;
            }),
          ),
          const SizedBox(height: 24),
          if (_isRegister) ...[
            AppFieldLabel('Nama'),
            const SizedBox(height: 6),
            AppTextField(
              controller: _name,
              hintText: 'Nama lengkap',
              prefixIcon: _prefixIcon(Icons.person_outline),
            ),
            const SizedBox(height: 24),
          ],
          AppFieldLabel('Email atau Nomor HP'),
          const SizedBox(height: 6),
          AppTextField(
            controller: _email,
            hintText: 'nama@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: _prefixIcon(Icons.mail_outline),
          ),
          const SizedBox(height: 24),
          AppFieldLabel('Kata Sandi'),
          const SizedBox(height: 6),
          AppTextField(
            controller: _password,
            hintText: 'Minimal 8 karakter',
            obscureText: _obscure,
            prefixIcon: _prefixIcon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          AppSectionDivider(_isRegister ? 'Daftar sebagai' : 'Masuk sebagai'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppRoleButton(
                  label: 'Pengguna',
                  loading: _loadingRole == 'pelanggan',
                  onPressed: _loadingRole == null
                      ? () => _authenticate('pelanggan')
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isRegister
                ? 'Akun akan disimpan dan Anda langsung masuk.'
                : 'Sudah punya akun? Masuk untuk melanjutkan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
