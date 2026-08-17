import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Makes the web build "mobile only".
///
/// - Native (iOS/Android) builds always show [child].
/// - On the web the mobile UI is shown when the browser reports a phone
///   platform (iOS/Android user agent) **or** the viewport is mobile-sized.
/// - Everything else (desktop browsers on a wide screen) is blocked with a
///   "use a phone" screen instead of letting the mobile layout stretch.
class MobileOnlyGate extends StatelessWidget {
  const MobileOnlyGate({super.key, required this.child});

  final Widget child;

  /// Widest viewport (logical px) still treated as a "mobile screen".
  static const double mobileBreakpoint = 600;

  bool get _isPhoneBrowser =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    // Never gate the native app.
    if (!kIsWeb) return child;

    final isMobileSized = MediaQuery.sizeOf(context).width <= mobileBreakpoint;
    if (_isPhoneBrowser || isMobileSized) return child;

    return const _MobileOnlyPlaceholder();
  }
}

/// Blocked screen shown on desktop-sized web viewports.
class _MobileOnlyPlaceholder extends StatelessWidget {
  const _MobileOnlyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width.round();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.smartphone, size: 96, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Emotigrow hanya tersedia di perangkat seluler',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan buka Emotigrow melalui handphone, atau sempitkan '
                  'jendela browser Anda agar tampilan ponsel dapat dimuat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Lebar layar saat ini: $width px '
                  '(maks. ${MobileOnlyGate.mobileBreakpoint.round()} px)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
