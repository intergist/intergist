import 'dart:ui';

/// Core color palette for the SciFiOnly design system.
///
/// All values are ARGB hex literals taken directly from the design spec.
/// Use these tokens exclusively — never hard-code color values elsewhere.
abstract final class AppColors {
  // ── Neutrals ──────────────────────────────────────────────────────────

  static const Color black = Color(0xFF05070A);
  static const Color white = Color(0xFFF7FAFC);

  // Graphite – deepest background shades
  static const Color graphite900 = Color(0xFF0A0F14);
  static const Color graphite850 = Color(0xFF111821);
  static const Color graphite800 = Color(0xFF16202B);
  static const Color graphite700 = Color(0xFF203040);

  // Steel – mid-range text / border / muted UI
  static const Color steel500 = Color(0xFF536579);
  static const Color steel300 = Color(0xFF91A1B3);
  static const Color steel200 = Color(0xFFAAB8C6);
  static const Color steel100 = Color(0xFFC7D2DD);

  // ── Accent: Cyan ──────────────────────────────────────────────────────

  static const Color cyan500 = Color(0xFF35D9FF);
  static const Color cyan400 = Color(0xFF5FE4FF);
  static const Color cyan300 = Color(0xFF8CEEFF);

  // ── Accent: Lime ──────────────────────────────────────────────────────

  static const Color lime500 = Color(0xFFA7FF3C);
  static const Color lime400 = Color(0xFFBEFF67);

  // ── Accent: Amber ─────────────────────────────────────────────────────

  static const Color amber500 = Color(0xFFFFBF3C);
  static const Color amber400 = Color(0xFFFFD36B);

  // ── Accent: Red ───────────────────────────────────────────────────────

  static const Color red500 = Color(0xFFFF5A5F);
  static const Color red400 = Color(0xFFFF7C81);

  // ── Accent: Violet ────────────────────────────────────────────────────

  static const Color violet500 = Color(0xFF8A7DFF);

  // ── Accent: Teal ──────────────────────────────────────────────────────

  static const Color teal500 = Color(0xFF33D1C6);

  // ── Overlays ──────────────────────────────────────────────────────────

  /// 70 % black overlay (alpha 0xB3 ≈ 179/255).
  static const Color overlay70 = Color(0xB3000000);

  /// 50 % black overlay (alpha 0x80 = 128/255).
  static const Color overlay50 = Color(0x80000000);

  /// 30 % black overlay (alpha 0x4D ≈ 77/255).
  static const Color overlay30 = Color(0x4D000000);
}
