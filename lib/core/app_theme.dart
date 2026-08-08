import 'package:flutter/material.dart';

/// Centralised styling for the app.
///
/// The Inter font family is registered in `pubspec.yaml` (all 9 weights).
class AppFonts {
  AppFonts._();

  /// Family name as declared in `pubspec.yaml`.
  static const String family = 'Inter';
}

/// Named text-style variants built on Inter.
///
/// Use these instead of raw `TextStyle(...)` for consistent typography, e.g.
/// ```dart
/// Text('Hello', style: AppTextStyles.titleBold)
/// ```
class AppTextStyles {
  AppTextStyles._();

  // Thumbnail of the weights we registered.
  static const _thin = FontWeight.w100;
  static const _extraLight = FontWeight.w200;
  static const _light = FontWeight.w300;
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;
  static const _extraBold = FontWeight.w800;
  static const _black = FontWeight.w900;

  // -- Display ----------------------------------------------------------------

  static const TextStyle displayBlack = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 34,
    fontWeight: _black,
    height: 1.2,
  );

  static const TextStyle displayThin = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 32,
    fontWeight: _thin,
    height: 1.2,
  );

  static const TextStyle displayBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 30,
    fontWeight: _bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 28,
    fontWeight: _medium,
    height: 1.2,
  );

  // -- Headings ---------------------------------------------------------------

  static const TextStyle titleBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 24,
    fontWeight: _bold,
    height: 1.3,
  );

  static const TextStyle titleSemiBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 22,
    fontWeight: _semiBold,
    height: 1.3,
  );

  static const TextStyle titleExtraBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 22,
    fontWeight: _extraBold,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 20,
    fontWeight: _medium,
    height: 1.3,
  );

  // -- Body -------------------------------------------------------------------

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16,
    fontWeight: _regular,
    height: 1.5,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: _regular,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: _medium,
    height: 1.5,
  );

  static const TextStyle bodyExtraLight = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: _extraLight,
    height: 1.5,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: _semiBold,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: _bold,
    height: 1.5,
  );

  // -- Labels / captions ------------------------------------------------------

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 12,
    fontWeight: _medium,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSemiBold = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 12,
    fontWeight: _semiBold,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 11,
    fontWeight: _light,
    height: 1.4,
    letterSpacing: 0.2,
  );
}

/// Builds the app-wide [ThemeData], wiring Inter into every Material text style
/// so the font applies app-wide by default.
ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final base = ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: brightness,
    ),
    useMaterial3: true,
  );

  // Override the whole text theme to use Inter.
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: AppFonts.family,
      bodyColor: base.colorScheme.onSurface,
      displayColor: base.colorScheme.onSurface,
    ),
  );
}
