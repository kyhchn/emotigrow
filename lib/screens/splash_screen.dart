import 'dart:async';

import 'package:cakmoji_flutter/screens/homepage_generated.dart';
import 'package:cakmoji_flutter/screens/login_generated.dart';
import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../services/supabase_service.dart';

/// A splash screen designed to be driven by a single image.
///
/// ### Replacing the image
/// Simply drop your own image over `assets/images/splash.png` (or change
/// [AppConfig.splashImageAsset]) and rebuild. The screen will fade in the new
/// image over a solid brand-color background and then hand off to the first
/// real screen of your app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  bool get _isSignedIn => SupabaseService.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    // Give the splash image a moment to breathe, then route onwards.
    _timer = Timer(AppConfig.splashDuration, _goNext);
  }

  void _goNext() async {
    if (!mounted) return;

    // Delay the transition for fixed time
    await Future.delayed(const Duration(seconds: 5));

    final Widget destination = _isSignedIn
        ? HomepageGenerated()
        : const LoginGenerated();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: brandColor,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The splash image. Falls back gracefully if the asset is missing.
            Image.asset(
              AppConfig.splashImageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => _buildFallback(brandColor),
            ),
            // Subtle loading indicator aligned to the bottom.
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(Color color) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Icon(
        Icons.emoji_emotions,
        size: 96,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
