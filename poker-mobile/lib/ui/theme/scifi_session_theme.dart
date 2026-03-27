// Poker Sharp — SciFi Session Theme Extension

import 'package:flutter/material.dart';

import '../tokens/motion_tokens.dart';

class SciFiSessionTheme extends ThemeExtension<SciFiSessionTheme> {
  final double participationRingThickness;
  final double sessionCueMaxWidth;
  final double transcriptPanelHeight;
  final double syncChipHeight;
  final double cueGlowBlur;
  final Duration warningPulseDuration;
  final Duration cueFadeDuration;

  const SciFiSessionTheme({
    required this.participationRingThickness,
    required this.sessionCueMaxWidth,
    required this.transcriptPanelHeight,
    required this.syncChipHeight,
    required this.cueGlowBlur,
    required this.warningPulseDuration,
    required this.cueFadeDuration,
  });

  @override
  SciFiSessionTheme copyWith({
    double? participationRingThickness,
    double? sessionCueMaxWidth,
    double? transcriptPanelHeight,
    double? syncChipHeight,
    double? cueGlowBlur,
    Duration? warningPulseDuration,
    Duration? cueFadeDuration,
  }) {
    return SciFiSessionTheme(
      participationRingThickness:
          participationRingThickness ?? this.participationRingThickness,
      sessionCueMaxWidth: sessionCueMaxWidth ?? this.sessionCueMaxWidth,
      transcriptPanelHeight:
          transcriptPanelHeight ?? this.transcriptPanelHeight,
      syncChipHeight: syncChipHeight ?? this.syncChipHeight,
      cueGlowBlur: cueGlowBlur ?? this.cueGlowBlur,
      warningPulseDuration: warningPulseDuration ?? this.warningPulseDuration,
      cueFadeDuration: cueFadeDuration ?? this.cueFadeDuration,
    );
  }

  @override
  SciFiSessionTheme lerp(ThemeExtension<SciFiSessionTheme>? other, double t) {
    if (other is! SciFiSessionTheme) return this;
    return SciFiSessionTheme(
      participationRingThickness: lerpDouble(
          participationRingThickness, other.participationRingThickness, t)!,
      sessionCueMaxWidth:
          lerpDouble(sessionCueMaxWidth, other.sessionCueMaxWidth, t)!,
      transcriptPanelHeight:
          lerpDouble(transcriptPanelHeight, other.transcriptPanelHeight, t)!,
      syncChipHeight: lerpDouble(syncChipHeight, other.syncChipHeight, t)!,
      cueGlowBlur: lerpDouble(cueGlowBlur, other.cueGlowBlur, t)!,
      warningPulseDuration: warningPulseDuration,
      cueFadeDuration: cueFadeDuration,
    );
  }

  static double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

const sciFiSessionTheme = SciFiSessionTheme(
  participationRingThickness: 12,
  sessionCueMaxWidth: 420,
  transcriptPanelHeight: 80,
  syncChipHeight: 28,
  cueGlowBlur: 16,
  warningPulseDuration: AppMotion.slow,
  cueFadeDuration: AppMotion.normal,
);
