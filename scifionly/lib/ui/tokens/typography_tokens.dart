import 'package:flutter/material.dart';

/// Type-scale tokens for the SciFiOnly design system.
///
/// Sans-serif styles use **Inter**; monospace styles use **JetBrains Mono**.
/// Font families are referenced by string name so that Google Fonts (or a
/// bundled font) can resolve them at the app level.
abstract final class AppTypography {
  // ── Font family names ─────────────────────────────────────────────────

  static const String _sansFontFamily = 'Inter';
  static const String _monoFontFamily = 'JetBrains Mono';

  // ── Display ───────────────────────────────────────────────────────────

  static TextStyle get displayXL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 40,
        height: 44 / 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle get displayL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 32,
        height: 36 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  // ── Headline ──────────────────────────────────────────────────────────

  static TextStyle get headlineL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineM => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
      );

  // ── Title ─────────────────────────────────────────────────────────────

  static TextStyle get titleL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleM => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // ── Body ──────────────────────────────────────────────────────────────

  static TextStyle get bodyL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyM => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  // ── Label ─────────────────────────────────────────────────────────────

  static TextStyle get labelL => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get labelM => const TextStyle(
        fontFamily: _sansFontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // ── Mono ──────────────────────────────────────────────────────────────

  static TextStyle get monoL => const TextStyle(
        fontFamily: _monoFontFamily,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoM => const TextStyle(
        fontFamily: _monoFontFamily,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoS => const TextStyle(
        fontFamily: _monoFontFamily,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );
}
