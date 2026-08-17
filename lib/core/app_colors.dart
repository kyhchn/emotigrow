import 'package:flutter/material.dart';

/// Design tokens extracted from the Emotigrow design (login screen, Figma).
///
/// Use these constants instead of hard-coded colors so the whole app follows
/// one palette.
class AppColors {
  AppColors._();

  // -- Brand ------------------------------------------------------------------

  /// Primary brand color (green) — CTAs, role buttons, active states.
  static const Color primary = Color(0xFF097004);

  /// Secondary / supporting tint of the brand green.
  static const Color secondary = Color(0xFF22C55E);

  /// Danger / destructive + form error text.
  static const Color error = Color(0xFFDC2626);

  // -- Surfaces ---------------------------------------------------------------

  /// Page / screen background.
  static const Color background = Color(0xFFF5F8F6);

  /// Cards, inputs, raised surfaces.
  static const Color surface = Colors.white;

  // -- Text -------------------------------------------------------------------

  /// Primary text (headings / high emphasis).
  static const Color textPrimary = Color(0xFF0F172A);

  /// Input labels.
  static const Color textLabel = Color(0xFF334155);

  /// Secondary / muted text.
  static const Color textMuted = Color(0xFF64748B);

  /// Placeholders / hints inside inputs.
  static const Color textHint = Color(0xFF94A3B8);

  /// Hero / tagline text on the login header.
  static const Color textHero = Color(0xFF475569);

  // -- Lines ------------------------------------------------------------------

  /// Borders, dividers, toggle track.
  static const Color border = Color(0xFFE2E8F0);

  /// Accent border used next to the primary buttons.
  static const Color borderAccent = Color(0xFFCBD5E1);

  // -- Bottom navigation ------------------------------------------------------

  /// Bottom navigation bar background (teal).
  static const Color navBar = Color(0xFF195955);

  /// Bottom navigation center button / nav highlight (bright green).
  static const Color navActive = Color(0xFF0DF233);
}
