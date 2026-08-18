import 'package:cakmoji_flutter/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/supabase_service.dart';

/// Profile tab: shows the signed-in user's info (name, email, account type)
/// pulled from Supabase, and exposes the logout action.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Pengguna Emotigrow';
  String _email = '';
  String _type = 'pelanggan'; // from profiles.type: 'petani' | 'pelanggan'
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // The Supabase client may be uninitialized in tests/offline builds, so
    // every service access is guarded.
    final authEmail = _safeAuthEmail();
    try {
      final profile = await SupabaseService.instance.fetchProfile();
      if (!mounted) return;

      setState(() {
        final name = (profile?['name'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) _name = name;

        final email = (profile?['email'] as String?)?.trim() ?? authEmail ?? '';
        if (email.isNotEmpty) _email = email;

        final type = (profile?['type'] as String?)?.trim().toLowerCase();
        if (type != null && type.isNotEmpty) _type = type;
      });
    } catch (_) {
      // Offline / not initialized — fall back to the auth user's email.
      if (!mounted) return;
      setState(() {
        if (authEmail != null && authEmail.isNotEmpty) {
          _email = authEmail;
          final local = authEmail.split('@').first.trim();
          if (local.isNotEmpty) _name = local;
        }
      });
    }
  }

  /// Safe wrapper around [SupabaseService.currentUser] (returns `null` when
  /// the client is not yet initialized instead of throwing).
  String? _safeAuthEmail() {
    try {
      return SupabaseService.instance.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  /// Human-friendly label for the `profiles.type` column.
  String get _typeLabel => switch (_type) {
    'petani' => 'Petani',
    _ => 'Pengguna',
  };

  Future<void> _onLogoutPressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari Emotigrow?'),
        content: const Text('Anda akan kembali ke halaman masuk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);
    try {
      await SupabaseService.instance.signOut();
      if (!mounted) return;
      // Clear the whole stack so the back button never returns to the home tab.
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar. Silakan coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // height: MediaQuery.of(context).size.height * 0.3,
          padding: const EdgeInsets.only(bottom: 32),
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.primary),
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/icons/batik_new.svg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/ava_madura_sad.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: const Icon(
                              Icons.construction,
                              color: Colors.white,
                            ),
                          ),
          
                          // Bottom-right circle
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF13EC13),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                color: Colors.white,
                height: double.infinity,
                child: SvgPicture.asset(
                  'assets/icons/batik_background.svg',
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFCCFFCC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            color: Color(0xFF097004),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      profileMenuList(
                        'Edit Profil',
                        'assets/icons/profile_edit.svg',
                        null,
                        () {
                          // Handle Edit Profile tap
                        },
                      ),
                      profileMenuList(
                        'Pengaturan Aplikasi',
                        null,
                        Icons.settings,
                        () {
                          // Handle Edit Profile tap
                        },
                      ),
                      profileMenuList(
                        'Bantuan & FAQ',
                        null,
                        Icons.help_outline,
                        () {
                          // Handle Edit Profile tap
                        },
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _signingOut ? null : _onLogoutPressed,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        child: _signingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Versi Aplikasi 1.0.4 (Build 202)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container profileMenuList(
    String title,
    String? iconAssetPath,
    IconData? iconData,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: iconAssetPath != null
                  ? SvgPicture.asset(iconAssetPath, width: 24, height: 24)
                  : Icon(iconData, size: 24, color: AppColors.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
