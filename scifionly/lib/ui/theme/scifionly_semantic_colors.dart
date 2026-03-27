import 'package:flutter/material.dart';

/// Semantic color tokens exposed as a [ThemeExtension].
///
/// These map domain concepts (sync state, recording, cues, diagnostics,
/// project status) to concrete colors so that widgets never reference
/// the raw palette directly for semantic meaning.
@immutable
class SciFiSemanticColors extends ThemeExtension<SciFiSemanticColors> {
  const SciFiSemanticColors({
    required this.syncLocked,
    required this.syncLockedBg,
    required this.syncDegraded,
    required this.syncDegradedBg,
    required this.syncLost,
    required this.syncLostBg,
    required this.windowClosed,
    required this.windowWarning,
    required this.windowOpen,
    required this.recordingLive,
    required this.recordingDepletion,
    required this.cueSpoken,
    required this.cueDisplayOnly,
    required this.userRiff,
    required this.diagnosticsGood,
    required this.diagnosticsNeutral,
    required this.diagnosticsBad,
    required this.projectReady,
    required this.projectDraft,
    required this.projectMissingAsset,
    required this.panelAccent,
  });

  // ── Sync status ─────────────────────────────────────────────────────

  final Color syncLocked;
  final Color syncLockedBg;
  final Color syncDegraded;
  final Color syncDegradedBg;
  final Color syncLost;
  final Color syncLostBg;

  // ── Timing window ───────────────────────────────────────────────────

  final Color windowClosed;
  final Color windowWarning;
  final Color windowOpen;

  // ── Recording ───────────────────────────────────────────────────────

  final Color recordingLive;
  final Color recordingDepletion;

  // ── Cue types ───────────────────────────────────────────────────────

  final Color cueSpoken;
  final Color cueDisplayOnly;
  final Color userRiff;

  // ── Diagnostics ─────────────────────────────────────────────────────

  final Color diagnosticsGood;
  final Color diagnosticsNeutral;
  final Color diagnosticsBad;

  // ── Project status ──────────────────────────────────────────────────

  final Color projectReady;
  final Color projectDraft;
  final Color projectMissingAsset;

  // ── Panel ───────────────────────────────────────────────────────────

  final Color panelAccent;

  // ── ThemeExtension overrides ────────────────────────────────────────

  @override
  SciFiSemanticColors copyWith({
    Color? syncLocked,
    Color? syncLockedBg,
    Color? syncDegraded,
    Color? syncDegradedBg,
    Color? syncLost,
    Color? syncLostBg,
    Color? windowClosed,
    Color? windowWarning,
    Color? windowOpen,
    Color? recordingLive,
    Color? recordingDepletion,
    Color? cueSpoken,
    Color? cueDisplayOnly,
    Color? userRiff,
    Color? diagnosticsGood,
    Color? diagnosticsNeutral,
    Color? diagnosticsBad,
    Color? projectReady,
    Color? projectDraft,
    Color? projectMissingAsset,
    Color? panelAccent,
  }) {
    return SciFiSemanticColors(
      syncLocked: syncLocked ?? this.syncLocked,
      syncLockedBg: syncLockedBg ?? this.syncLockedBg,
      syncDegraded: syncDegraded ?? this.syncDegraded,
      syncDegradedBg: syncDegradedBg ?? this.syncDegradedBg,
      syncLost: syncLost ?? this.syncLost,
      syncLostBg: syncLostBg ?? this.syncLostBg,
      windowClosed: windowClosed ?? this.windowClosed,
      windowWarning: windowWarning ?? this.windowWarning,
      windowOpen: windowOpen ?? this.windowOpen,
      recordingLive: recordingLive ?? this.recordingLive,
      recordingDepletion: recordingDepletion ?? this.recordingDepletion,
      cueSpoken: cueSpoken ?? this.cueSpoken,
      cueDisplayOnly: cueDisplayOnly ?? this.cueDisplayOnly,
      userRiff: userRiff ?? this.userRiff,
      diagnosticsGood: diagnosticsGood ?? this.diagnosticsGood,
      diagnosticsNeutral: diagnosticsNeutral ?? this.diagnosticsNeutral,
      diagnosticsBad: diagnosticsBad ?? this.diagnosticsBad,
      projectReady: projectReady ?? this.projectReady,
      projectDraft: projectDraft ?? this.projectDraft,
      projectMissingAsset: projectMissingAsset ?? this.projectMissingAsset,
      panelAccent: panelAccent ?? this.panelAccent,
    );
  }

  @override
  SciFiSemanticColors lerp(SciFiSemanticColors? other, double t) {
    if (other is! SciFiSemanticColors) return this;
    return SciFiSemanticColors(
      syncLocked: Color.lerp(syncLocked, other.syncLocked, t)!,
      syncLockedBg: Color.lerp(syncLockedBg, other.syncLockedBg, t)!,
      syncDegraded: Color.lerp(syncDegraded, other.syncDegraded, t)!,
      syncDegradedBg: Color.lerp(syncDegradedBg, other.syncDegradedBg, t)!,
      syncLost: Color.lerp(syncLost, other.syncLost, t)!,
      syncLostBg: Color.lerp(syncLostBg, other.syncLostBg, t)!,
      windowClosed: Color.lerp(windowClosed, other.windowClosed, t)!,
      windowWarning: Color.lerp(windowWarning, other.windowWarning, t)!,
      windowOpen: Color.lerp(windowOpen, other.windowOpen, t)!,
      recordingLive: Color.lerp(recordingLive, other.recordingLive, t)!,
      recordingDepletion:
          Color.lerp(recordingDepletion, other.recordingDepletion, t)!,
      cueSpoken: Color.lerp(cueSpoken, other.cueSpoken, t)!,
      cueDisplayOnly: Color.lerp(cueDisplayOnly, other.cueDisplayOnly, t)!,
      userRiff: Color.lerp(userRiff, other.userRiff, t)!,
      diagnosticsGood:
          Color.lerp(diagnosticsGood, other.diagnosticsGood, t)!,
      diagnosticsNeutral:
          Color.lerp(diagnosticsNeutral, other.diagnosticsNeutral, t)!,
      diagnosticsBad: Color.lerp(diagnosticsBad, other.diagnosticsBad, t)!,
      projectReady: Color.lerp(projectReady, other.projectReady, t)!,
      projectDraft: Color.lerp(projectDraft, other.projectDraft, t)!,
      projectMissingAsset:
          Color.lerp(projectMissingAsset, other.projectMissingAsset, t)!,
      panelAccent: Color.lerp(panelAccent, other.panelAccent, t)!,
    );
  }
}
