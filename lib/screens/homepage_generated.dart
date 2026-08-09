import 'package:cakmoji_flutter/screens/home/kebunku_page.dart';
import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_iot_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import '../services/supabase_service.dart';
import '../widgets/app_bottom_nav.dart';

/// WhatsApp logo from `assets/icons/whatsapp.svg` as a tintable Flutter icon.
///
/// ```dart
/// whatsappIcon(size: 24, color: Color(0xFF25D366))
/// ```
Widget whatsappIcon({double size = 28, Color color = Colors.white}) {
  return SvgPicture.asset(
    'assets/icons/whatsapp.svg',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    semanticsLabel: 'WhatsApp',
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );
}

/// WhatsApp number used for support / consultation.
/// Digits only (no `+`, no spaces). Replace with your own number.
const String kWhatsAppSupportNumber = '6289528344530';

/// Pre-filled message when opening the support chat.
const String kWhatsAppSupportMessage = 'Halo Cakmoji, saya ingin bertanya.';

/// Opens a WhatsApp chat with [number], pre-filling [message].
///
/// Returns `true` when the external WhatsApp app/browser was launched.
Future<bool> openWhatsApp({
  String number = kWhatsAppSupportNumber,
  String message = kWhatsAppSupportMessage,
}) {
  final uri = Uri(
    scheme: 'https',
    host: 'wa.me',
    path: number,
    queryParameters: message.isEmpty ? null : {'text': message},
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Safe wrapper around [openWhatsApp] — shows a SnackBar when WhatsApp can't
/// be opened instead of throwing.
Future<void> launchWhatsApp(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  const fallback = SnackBar(content: Text('Tidak dapat membuka WhatsApp.'));
  try {
    final launched = await openWhatsApp();
    if (!launched) messenger.showSnackBar(fallback);
  } catch (_) {
    messenger.showSnackBar(fallback);
  }
}

/// Homepage (Figma → code) rebuilt with responsive Flutter widgets.
///
/// - **Width-aware**: sections resize with the available width; grids collapse
///   to fewer columns on narrow phones; content is capped & centered on
///   tablets/desktops.
/// - **Height-aware**: the whole page scrolls, so it fits any screen height.
/// - Greets the signed-in user using their Supabase profile `name`
///   (falls back to a static greeting when offline / not initialized).
class HomepageGenerated extends StatefulWidget {
  const HomepageGenerated({super.key});

  @override
  State<HomepageGenerated> createState() => _HomepageGeneratedState();
}

class _HomepageGeneratedState extends State<HomepageGenerated> {
  int _navIndex = 0;
  String _userName = 'Muhammad Nadhif';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await SupabaseService.instance.fetchProfile();
      final name = (profile?['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty && mounted) {
        setState(() => _userName = name);
      }
    } catch (_) {
      // Supabase not initialized / offline — keep the fallback greeting.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/icons/book.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      body: _navIndex == 0
          ? Column(
              children: [
                _AppHeader(userName: _userName),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: const _HomeContent(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _AppHeader(userName: _userName),
                Expanded(child: KebunkuPage()),
              ],
            ),
      bottomNavigationBar: AppBottomNav(
        items: [
          BottomNavItem(icon: Icons.home_outlined, label: 'Beranda'),
          BottomNavItem(
            customIcon: SvgPicture.asset('assets/icons/plant.svg'),
            label: 'Kebunku',
          ),
          BottomNavItem(icon: Icons.storefront_outlined, label: 'Marketplace'),
          BottomNavItem(icon: Icons.person_outline, label: 'Profil'),
        ],
        selectedIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        centerButton: const _NavScanButton(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/homepage_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Image.asset(
                  'assets/images/cakmoji.png',
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () => launchWhatsApp(context),
                        child: whatsappIcon(size: 28, color: Colors.white),
                      ),
                    ),
                    _BellIcon(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BellIcon extends StatelessWidget {
  const _BellIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: Colors.white, size: 28),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFC01212),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Scrollable content
// ---------------------------------------------------------------------------
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _StatusGrid(),
        SizedBox(height: 16),
        _IotCard(),
        SizedBox(height: 24),
        _FeatureRow(),
        SizedBox(height: 24),
        _SectionHeader(),
        SizedBox(height: 12),
        _CategoriesGrid(),
        SizedBox(height: 24),
        // _PromoBanner(),
      ],
    );
  }
}

// -- Status cards (Sehat / Waspada / Darurat) -------------------------------
class _StatusGrid extends StatelessWidget {
  const _StatusGrid();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width < 300 ? 1 : 3;
    return GridView.count(
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: crossCount == 1 ? 2.8 : 0.92,
      children: const [
        _StatusCard(
          title: 'Sehat',
          count: 2,
          accent: Color(0xFF22C55E),
          icon: Icons.health_and_safety_outlined,
          imagePath: 'assets/images/cakmoji_happy.png',
        ),
        _StatusCard(
          title: 'Waspada',
          count: 0,
          accent: Color(0xFFFFCC00),
          icon: Icons.warning_amber_rounded,
          imagePath: 'assets/images/cakmoji_flat.png',
        ),
        _StatusCard(
          title: 'Darurat',
          count: 0,
          accent: Color(0xFFEF4444),
          icon: Icons.emergency_outlined,
          imagePath: 'assets/images/cakmoji_sad.png',
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.count,
    required this.accent,
    required this.icon,
    required this.imagePath,
  });

  final String title;
  final int count;
  final Color accent;
  final IconData icon;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [accent, Colors.white],
          stops: const [0.0, 0.20],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accent, size: 26),
                Image.asset(imagePath, width: 26, height: 26),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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

// -- IoT / scan CTA card -----------------------------------------------------
class _IotCard extends StatelessWidget {
  const _IotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white,
            Color(0xFFF5FFF5),
            Color(0xFFB8F5BA),
            Color(0xFF65E169),
          ],
          stops: [0.0, 0.45, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Kontrol IoT',
                  style: TextStyle(
                    color: Color(0xFF111812),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cek status tanaman berbasis data',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Powered by IoT and AI',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                _ScanButton(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/kontrol_iot_banner_top.png',
                width: MediaQuery.sizeOf(context).width * 0.25,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              Image.asset(
                'assets/images/kontrol_iot_banner_bot.png',
                width: MediaQuery.sizeOf(context).width * 0.25,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (_, animation, __) => const KontrolIotTransition(),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF0DF233),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4C0DF233),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Mulai Scan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// -- Feature row: AI Diagnosis + Konsultasi Ahli -----------------------------
class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).width < 350 ? 168 : 138,
            child: _FeatureCard(
              iconWidget: Image.asset(
                'assets/images/notif.png',
                width: 22,
                height: 22,
              ),
              icon: Icons.analytics_outlined,
              isLeftAligned: true,
              iconColor: AppColors.primary,
              gradient: const [Color(0xFFE9F9E4), Color(0xFFF6FCF3)],
              title: 'AI Diagnosis',
              subtitle: 'Cek laporan infeksi pada tanaman',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).width < 350 ? 168 : 138,
            child: _FeatureCard(
              iconWidget: Image.asset(
                'assets/images/consult.png',
                width: 22,
                height: 22,
              ),
              icon: Icons.support_agent,
              isLeftAligned: false,
              iconColor: const Color(0xFF0891B2),
              gradient: const [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
              title: 'Konsultasi Ahli',
              subtitle: 'Sesi konsultasi bersama agronom',
              onTap: () => launchWhatsApp(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.title,
    required this.subtitle,
    this.iconWidget,
    this.onTap,
    this.isLeftAligned = true,
  });

  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final bool isLeftAligned;

  /// Optional custom leading widget (e.g. the WhatsApp logo); when provided it
  /// replaces the [icon] / [iconColor] pair.
  final Widget? iconWidget;

  /// Optional action when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: gradient,
          // ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isLeftAligned
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget ?? Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111812),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isLeftAligned ? TextAlign.start : TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Section header (Kategori terbaik / Lihat semua) -------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Kategori terbaik',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF1C1C20),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Lihat semua',
            style: TextStyle(
              color: Color(0xFFC2C2C2),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// -- Categories grid ---------------------------------------------------------
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width < 350 ? 2 : 4;
    return GridView.count(
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      childAspectRatio: crossCount == 4 ? 0.98 : 1.2,
      children: const [
        _CategoryItem(
          label: 'Flex Your Plant',
          assetName: 'assets/images/flex_your_plant.png',
        ),
        _CategoryItem(
          label: 'Daftar Kebun',
          assetName: 'assets/images/daftar_kebun.png',
        ),
        _CategoryItem(
          label: 'Dashboard Tanaman',
          assetName: 'assets/images/dashboard_tanaman.png',
        ),
        _CategoryItem(
          label: 'Kontrol Notifikasi',
          assetName: 'assets/images/kontrol_notif.png',
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.assetName, required this.label});

  final String label;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          assetName,
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1C1C20),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

// -- Raised center nav button -------------------------------------------------
class _NavScanButton extends StatelessWidget {
  const _NavScanButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF195A56),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF5F8F6), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4C000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/cakmoji_navbar.png',
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
