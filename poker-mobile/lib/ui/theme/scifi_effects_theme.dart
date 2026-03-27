// Poker Sharp — SciFi Effects Theme Extension

import 'package:flutter/material.dart';

class SciFiEffectsTheme extends ThemeExtension<SciFiEffectsTheme> {
  final bool enableGlow;
  final bool enableGridOverlay;
  final bool enableScanLine;
  final bool enablePulseAnimations;
  final double panelOutlineOpacity;
  final double glowOpacity;
  final double gridOpacity;

  const SciFiEffectsTheme({
    required this.enableGlow,
    required this.enableGridOverlay,
    required this.enableScanLine,
    required this.enablePulseAnimations,
    required this.panelOutlineOpacity,
    required this.glowOpacity,
    required this.gridOpacity,
  });

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
  SciFiEffectsTheme lerp(ThemeExtension<SciFiEffectsTheme>? other, double t) {
    if (other is! SciFiEffectsTheme) return this;
    return SciFiEffectsTheme(
      enableGlow: t < 0.5 ? enableGlow : other.enableGlow,
      enableGridOverlay:
          t < 0.5 ? enableGridOverlay : other.enableGridOverlay,
      enableScanLine: t < 0.5 ? enableScanLine : other.enableScanLine,
      enablePulseAnimations:
          t < 0.5 ? enablePulseAnimations : other.enablePulseAnimations,
      panelOutlineOpacity: _lerpDouble(
          panelOutlineOpacity, other.panelOutlineOpacity, t)!,
      glowOpacity: _lerpDouble(glowOpacity, other.glowOpacity, t)!,
      gridOpacity: _lerpDouble(gridOpacity, other.gridOpacity, t)!,
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

const sciFiEffectsTheme = SciFiEffectsTheme(
  enableGlow: true,
  enableGridOverlay: false,
  enableScanLine: false,
  enablePulseAnimations: true,
  panelOutlineOpacity: 0.6,
  glowOpacity: 0.4,
  gridOpacity: 0.08,
);
