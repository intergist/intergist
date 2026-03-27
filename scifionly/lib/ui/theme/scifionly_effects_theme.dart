import 'dart:ui';

import 'package:flutter/material.dart';

/// Visual-effects toggles and intensity values exposed as a [ThemeExtension].
///
/// Each theme variant can independently control which decorative effects
/// are active and how prominent they are — from a full "command bridge" glow
/// aesthetic to a stripped-down accessibility mode.
@immutable
class SciFiEffectsTheme extends ThemeExtension<SciFiEffectsTheme> {
  const SciFiEffectsTheme({
    required this.enableGlow,
    required this.enableGridOverlay,
    required this.enableScanLine,
    required this.enablePulseAnimations,
    required this.panelOutlineOpacity,
    required this.glowOpacity,
    required this.gridOpacity,
  });

  // ── Feature flags ───────────────────────────────────────────────────

  /// Whether to render the ambient glow effect behind accent elements.
  final bool enableGlow;

  /// Whether to render a subtle background grid overlay.
  final bool enableGridOverlay;

  /// Whether to render the horizontal scan-line effect.
  final bool enableScanLine;

  /// Whether pulse animations (warning ring, live dot) are enabled.
  final bool enablePulseAnimations;

  // ── Intensity ───────────────────────────────────────────────────────

  /// Opacity of the thin panel-outline border (0.0–1.0).
  final double panelOutlineOpacity;

  /// Opacity of the glow blur layer (0.0–1.0).
  final double glowOpacity;

  /// Opacity of the background grid overlay (0.0–1.0).
  final double gridOpacity;

  // ── ThemeExtension overrides ────────────────────────────────────────

  @override
  SciFiEffectsTheme copyWith({
    bool? enableGlow,
    bool? enableGridOverlay,
    bool? enableScanLine,
    bool? enablePulseAnimations,
    double? panelOutlineOpacity,
    double? glowOpacity,
    double? gridOpacity,
  }) {
    return SciFiEffectsTheme(
      enableGlow: enableGlow ?? this.enableGlow,
      enableGridOverlay: enableGridOverlay ?? this.enableGridOverlay,
      enableScanLine: enableScanLine ?? this.enableScanLine,
      enablePulseAnimations:
          enablePulseAnimations ?? this.enablePulseAnimations,
      panelOutlineOpacity: panelOutlineOpacity ?? this.panelOutlineOpacity,
      glowOpacity: glowOpacity ?? this.glowOpacity,
      gridOpacity: gridOpacity ?? this.gridOpacity,
    );
  }

  @override
  SciFiEffectsTheme lerp(SciFiEffectsTheme? other, double t) {
    if (other is! SciFiEffectsTheme) return this;
    return SciFiEffectsTheme(
      // Booleans snap at the midpoint.
      enableGlow: t < 0.5 ? enableGlow : other.enableGlow,
      enableGridOverlay:
          t < 0.5 ? enableGridOverlay : other.enableGridOverlay,
      enableScanLine: t < 0.5 ? enableScanLine : other.enableScanLine,
      enablePulseAnimations:
          t < 0.5 ? enablePulseAnimations : other.enablePulseAnimations,
      // Doubles are linearly interpolated.
      panelOutlineOpacity: lerpDouble(
        panelOutlineOpacity,
        other.panelOutlineOpacity,
        t,
      )!,
      glowOpacity: lerpDouble(glowOpacity, other.glowOpacity, t)!,
      gridOpacity: lerpDouble(gridOpacity, other.gridOpacity, t)!,
    );
  }
}
