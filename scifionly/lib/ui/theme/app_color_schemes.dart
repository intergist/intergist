import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

/// Pre-built [ColorScheme] instances for each SciFiOnly theme variant.
///
/// All three schemes use [Brightness.dark] — the app is dark-mode only by
/// design.
abstract final class AppColorSchemes {
  // ── Nebula Command ──────────────────────────────────────────────────
  //
  // The default "command bridge" look: cyan primary, lime secondary,
  // violet tertiary, graphite surfaces, red error.

  static const ColorScheme nebulaCommandScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary
    primary: AppColors.cyan500,
    onPrimary: AppColors.graphite900,
    primaryContainer: Color(0xFF0D3E4D),
    onPrimaryContainer: AppColors.cyan300,
    // Secondary
    secondary: AppColors.lime500,
    onSecondary: AppColors.graphite900,
    secondaryContainer: Color(0xFF2A3D12),
    onSecondaryContainer: AppColors.lime400,
    // Tertiary
    tertiary: AppColors.violet500,
    onTertiary: AppColors.white,
    tertiaryContainer: Color(0xFF2E2A59),
    onTertiaryContainer: Color(0xFFCBC5FF),
    // Error
    error: AppColors.red500,
    onError: AppColors.graphite900,
    errorContainer: Color(0xFF4D1517),
    onErrorContainer: AppColors.red400,
    // Surface
    surface: AppColors.graphite900,
    onSurface: AppColors.white,
    surfaceContainerHighest: AppColors.graphite700,
    onSurfaceVariant: AppColors.steel300,
    // Outline
    outline: AppColors.steel500,
    outlineVariant: AppColors.graphite700,
    // Misc
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.steel100,
    onInverseSurface: AppColors.graphite900,
    inversePrimary: Color(0xFF006E85),
  );

  // ── Cathode Arcade ──────────────────────────────────────────────────
  //
  // Retro phosphor-green terminal aesthetic with warm amber warnings.

  static const ColorScheme cathodeArcadeScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary – phosphor green
    primary: Color(0xFF33FF66),
    onPrimary: Color(0xFF003314),
    primaryContainer: Color(0xFF0A4D1F),
    onPrimaryContainer: Color(0xFF99FFAA),
    // Secondary – retro teal
    secondary: AppColors.teal500,
    onSecondary: AppColors.graphite900,
    secondaryContainer: Color(0xFF0D3D39),
    onSecondaryContainer: Color(0xFF99F0E8),
    // Tertiary – warm amber
    tertiary: AppColors.amber500,
    onTertiary: AppColors.graphite900,
    tertiaryContainer: Color(0xFF4D3612),
    onTertiaryContainer: AppColors.amber400,
    // Error
    error: AppColors.red500,
    onError: AppColors.graphite900,
    errorContainer: Color(0xFF4D1517),
    onErrorContainer: AppColors.red400,
    // Surface
    surface: Color(0xFF080E08),
    onSurface: Color(0xFFD4FFD4),
    surfaceContainerHighest: Color(0xFF1A2E1A),
    onSurfaceVariant: Color(0xFF8CB38C),
    // Outline
    outline: Color(0xFF4D6B4D),
    outlineVariant: Color(0xFF1A2E1A),
    // Misc
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: Color(0xFFC7DDC7),
    onInverseSurface: Color(0xFF0A140A),
    inversePrimary: Color(0xFF006E2E),
  );

  // ── Void Theater ────────────────────────────────────────────────────
  //
  // Cinematic deep-space look: icy blue primary, soft violet secondary,
  // gold warning accents.

  static const ColorScheme voidTheaterScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary – icy blue
    primary: Color(0xFF7EC8E3),
    onPrimary: Color(0xFF0A2A36),
    primaryContainer: Color(0xFF133A4D),
    onPrimaryContainer: Color(0xFFBEE4F2),
    // Secondary – soft violet
    secondary: Color(0xFFA78BFA),
    onSecondary: Color(0xFF1E1147),
    secondaryContainer: Color(0xFF2E1F6B),
    onSecondaryContainer: Color(0xFFD4C5FD),
    // Tertiary – gold warning
    tertiary: Color(0xFFFFD700),
    onTertiary: AppColors.graphite900,
    tertiaryContainer: Color(0xFF4D3F00),
    onTertiaryContainer: Color(0xFFFFEB80),
    // Error
    error: AppColors.red500,
    onError: AppColors.graphite900,
    errorContainer: Color(0xFF4D1517),
    onErrorContainer: AppColors.red400,
    // Surface
    surface: Color(0xFF060810),
    onSurface: Color(0xFFE0E4F0),
    surfaceContainerHighest: Color(0xFF1A1E30),
    onSurfaceVariant: Color(0xFF9098B0),
    // Outline
    outline: Color(0xFF4D5570),
    outlineVariant: Color(0xFF1A1E30),
    // Misc
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: Color(0xFFD4D8E8),
    onInverseSurface: Color(0xFF0A0E18),
    inversePrimary: Color(0xFF2E7A94),
  );
}
