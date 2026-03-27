import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import 'app_color_schemes.dart';
import 'app_text_theme.dart';
import 'scifionly_effects_theme.dart';
import 'scifionly_semantic_colors.dart';
import 'scifionly_session_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme mode enum
// ─────────────────────────────────────────────────────────────────────────────

/// The three visual theme modes available in SciFiOnly.
enum AppThemeMode {
  /// Default "command bridge" look — cyan / lime / violet.
  nebulaCommand,

  /// Retro phosphor-green terminal aesthetic.
  cathodeArcade,

  /// Cinematic deep-space look — icy blue / violet / gold.
  voidTheater,
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: get ThemeData from mode
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the fully configured [ThemeData] for the given [AppThemeMode].
ThemeData themeDataFor(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.nebulaCommand:
      return buildNebulaCommandTheme();
    case AppThemeMode.cathodeArcade:
      return buildCathodeArcadeTheme();
    case AppThemeMode.voidTheater:
      return buildVoidTheaterTheme();
  }
}

/// Alias for [themeDataFor] used by providers and tests.
ThemeData getThemeData(AppThemeMode mode) => themeDataFor(mode);

// ─────────────────────────────────────────────────────────────────────────────
// Nebula Command theme
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the **Nebula Command** theme — the default "command bridge" look.
ThemeData buildNebulaCommandTheme() {
  const colorScheme = AppColorSchemes.nebulaCommandScheme;
  final textTheme = buildAppTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    extensions: const <ThemeExtension<dynamic>>[
      // Semantic colors
      SciFiSemanticColors(
        syncLocked: AppColors.lime500,
        syncLockedBg: Color(0xFF1A2E0F),
        syncDegraded: AppColors.amber500,
        syncDegradedBg: Color(0xFF2E2410),
        syncLost: AppColors.red500,
        syncLostBg: Color(0xFF2E1012),
        windowClosed: AppColors.steel500,
        windowWarning: AppColors.amber500,
        windowOpen: AppColors.lime500,
        recordingLive: AppColors.red500,
        recordingDepletion: AppColors.amber400,
        cueSpoken: AppColors.cyan500,
        cueDisplayOnly: AppColors.steel300,
        userRiff: AppColors.lime400,
        diagnosticsGood: AppColors.lime500,
        diagnosticsNeutral: AppColors.steel300,
        diagnosticsBad: AppColors.red500,
        projectReady: AppColors.lime500,
        projectDraft: AppColors.amber500,
        projectMissingAsset: AppColors.red400,
        panelAccent: AppColors.cyan500,
      ),
      // Session metrics
      SciFiSessionTheme(
        participationRingThickness: 3.0,
        sessionCueMaxWidth: 420,
        transcriptPanelHeight: 200,
        syncChipHeight: 28,
        cueGlowBlur: 16,
        warningPulseDuration: Duration(milliseconds: 800),
        cueFadeDuration: Duration(milliseconds: 300),
      ),
      // Effects
      SciFiEffectsTheme(
        enableGlow: true,
        enableGridOverlay: true,
        enableScanLine: true,
        enablePulseAnimations: true,
        panelOutlineOpacity: 0.25,
        glowOpacity: 0.6,
        gridOpacity: 0.04,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Cathode Arcade theme
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the **Cathode Arcade** theme — retro phosphor-green terminal.
ThemeData buildCathodeArcadeTheme() {
  const colorScheme = AppColorSchemes.cathodeArcadeScheme;
  final textTheme = buildAppTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    extensions: const <ThemeExtension<dynamic>>[
      // Semantic colors — phosphor greens replace most accent usages.
      SciFiSemanticColors(
        syncLocked: Color(0xFF33FF66),
        syncLockedBg: Color(0xFF0A2E14),
        syncDegraded: AppColors.amber500,
        syncDegradedBg: Color(0xFF2E2410),
        syncLost: AppColors.red500,
        syncLostBg: Color(0xFF2E1012),
        windowClosed: Color(0xFF4D6B4D),
        windowWarning: AppColors.amber500,
        windowOpen: Color(0xFF33FF66),
        recordingLive: AppColors.red500,
        recordingDepletion: AppColors.amber400,
        cueSpoken: Color(0xFF33FF66),
        cueDisplayOnly: Color(0xFF8CB38C),
        userRiff: AppColors.teal500,
        diagnosticsGood: Color(0xFF33FF66),
        diagnosticsNeutral: Color(0xFF8CB38C),
        diagnosticsBad: AppColors.red500,
        projectReady: Color(0xFF33FF66),
        projectDraft: AppColors.amber500,
        projectMissingAsset: AppColors.red400,
        panelAccent: Color(0xFF33FF66),
      ),
      // Session metrics — slightly wider cue cards for retro feel.
      SciFiSessionTheme(
        participationRingThickness: 2.5,
        sessionCueMaxWidth: 440,
        transcriptPanelHeight: 180,
        syncChipHeight: 26,
        cueGlowBlur: 20,
        warningPulseDuration: Duration(milliseconds: 900),
        cueFadeDuration: Duration(milliseconds: 250),
      ),
      // Effects — heavy glow, prominent scan line.
      SciFiEffectsTheme(
        enableGlow: true,
        enableGridOverlay: false,
        enableScanLine: true,
        enablePulseAnimations: true,
        panelOutlineOpacity: 0.35,
        glowOpacity: 0.75,
        gridOpacity: 0.0,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Void Theater theme
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the **Void Theater** theme — cinematic deep-space aesthetic.
ThemeData buildVoidTheaterTheme() {
  const colorScheme = AppColorSchemes.voidTheaterScheme;
  final textTheme = buildAppTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    extensions: const <ThemeExtension<dynamic>>[
      // Semantic colors — cool blues and soft violets.
      SciFiSemanticColors(
        syncLocked: Color(0xFF7EC8E3),
        syncLockedBg: Color(0xFF0F2A36),
        syncDegraded: Color(0xFFFFD700),
        syncDegradedBg: Color(0xFF2E2A0A),
        syncLost: AppColors.red500,
        syncLostBg: Color(0xFF2E1012),
        windowClosed: Color(0xFF4D5570),
        windowWarning: Color(0xFFFFD700),
        windowOpen: Color(0xFF7EC8E3),
        recordingLive: AppColors.red500,
        recordingDepletion: Color(0xFFFFD700),
        cueSpoken: Color(0xFF7EC8E3),
        cueDisplayOnly: Color(0xFF9098B0),
        userRiff: Color(0xFFA78BFA),
        diagnosticsGood: Color(0xFF7EC8E3),
        diagnosticsNeutral: Color(0xFF9098B0),
        diagnosticsBad: AppColors.red500,
        projectReady: Color(0xFF7EC8E3),
        projectDraft: Color(0xFFFFD700),
        projectMissingAsset: AppColors.red400,
        panelAccent: Color(0xFFA78BFA),
      ),
      // Session metrics — cinematic proportions.
      SciFiSessionTheme(
        participationRingThickness: 2.0,
        sessionCueMaxWidth: 400,
        transcriptPanelHeight: 220,
        syncChipHeight: 30,
        cueGlowBlur: 12,
        warningPulseDuration: Duration(milliseconds: 1000),
        cueFadeDuration: Duration(milliseconds: 400),
      ),
      // Effects — softer, cinematic glow; no scan line.
      SciFiEffectsTheme(
        enableGlow: true,
        enableGridOverlay: false,
        enableScanLine: false,
        enablePulseAnimations: true,
        panelOutlineOpacity: 0.15,
        glowOpacity: 0.45,
        gridOpacity: 0.0,
      ),
    ],
  );
}
