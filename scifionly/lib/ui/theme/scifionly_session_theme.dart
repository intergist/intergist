import 'dart:ui';

import 'package:flutter/material.dart';

/// Session-screen layout and timing tokens exposed as a [ThemeExtension].
///
/// These values control the dimensions and animation durations of the live
/// riffing / recording session UI so that each theme variant can tune the
/// experience independently.
@immutable
class SciFiSessionTheme extends ThemeExtension<SciFiSessionTheme> {
  const SciFiSessionTheme({
    required this.participationRingThickness,
    required this.sessionCueMaxWidth,
    required this.transcriptPanelHeight,
    required this.syncChipHeight,
    required this.cueGlowBlur,
    required this.warningPulseDuration,
    required this.cueFadeDuration,
  });

  /// Stroke width for the participant-activity ring indicator.
  final double participationRingThickness;

  /// Maximum width constraint for a cue card bubble.
  final double sessionCueMaxWidth;

  /// Fixed height of the live-transcript bottom panel.
  final double transcriptPanelHeight;

  /// Height of sync-status chips in the session toolbar.
  final double syncChipHeight;

  /// Blur radius for the glow effect behind the active cue.
  final double cueGlowBlur;

  /// Duration of the warning-pulse animation on sync degradation.
  final Duration warningPulseDuration;

  /// Duration of the fade-in / fade-out for cue transitions.
  final Duration cueFadeDuration;

  // ── ThemeExtension overrides ────────────────────────────────────────

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
      warningPulseDuration:
          warningPulseDuration ?? this.warningPulseDuration,
      cueFadeDuration: cueFadeDuration ?? this.cueFadeDuration,
    );
  }

  @override
  SciFiSessionTheme lerp(SciFiSessionTheme? other, double t) {
    if (other is! SciFiSessionTheme) return this;
    return SciFiSessionTheme(
      participationRingThickness: lerpDouble(
        participationRingThickness,
        other.participationRingThickness,
        t,
      )!,
      sessionCueMaxWidth: lerpDouble(
        sessionCueMaxWidth,
        other.sessionCueMaxWidth,
        t,
      )!,
      transcriptPanelHeight: lerpDouble(
        transcriptPanelHeight,
        other.transcriptPanelHeight,
        t,
      )!,
      syncChipHeight: lerpDouble(
        syncChipHeight,
        other.syncChipHeight,
        t,
      )!,
      cueGlowBlur: lerpDouble(
        cueGlowBlur,
        other.cueGlowBlur,
        t,
      )!,
      // Durations are not lerpable — snap to the target at t >= 0.5.
      warningPulseDuration: t < 0.5
          ? warningPulseDuration
          : other.warningPulseDuration,
      cueFadeDuration:
          t < 0.5 ? cueFadeDuration : other.cueFadeDuration,
    );
  }
}
