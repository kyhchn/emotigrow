import 'dart:async';

import 'package:cakmoji_flutter/screens/ai_diagnosis/ai_diagnosis_screen.dart';
import 'package:flutter/material.dart';

class AiDiagnosisTransition extends StatefulWidget {
  const AiDiagnosisTransition({super.key});
  static const Duration holdDuration = Duration(seconds: 1);

  @override
  State<AiDiagnosisTransition> createState() => _AiDiagnosisTransitionState();
}

class _AiDiagnosisTransitionState extends State<AiDiagnosisTransition>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  /// Smooth entrance for the logo.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Stay on the transition for a full second before swiping away.
    _timer = Timer(AiDiagnosisTransition.holdDuration, _goToAiDiagnosis);
  }

  void _goToAiDiagnosis() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const AiDiagnosisScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          // Swipe-in from the right, combined with a soft fade.
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _entrance,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _entrance,
                  curve: Curves.easeOutBack,
                ),
                child: Image.asset(
                  'assets/images/shield.png',
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lightbulb_outline,
                    size: 90,
                    color: Color(0xFF097004),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097004)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Menyiapkan AI Diagnosis…',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
