// Poker Sharp — SciFi Semantic Colors ThemeExtension

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

class SciFiSemanticColors extends ThemeExtension<SciFiSemanticColors> {
  final Color syncLocked;
  final Color syncLockedBg;
  final Color syncDegraded;
  final Color syncDegradedBg;
  final Color syncLost;
  final Color syncLostBg;
  final Color windowClosed;
  final Color windowWarning;
  final Color windowOpen;
  final Color recordingLive;
  final Color recordingDepletion;
  final Color cueSpoken;
  final Color cueDisplayOnly;
  final Color userRiff;
  final Color diagnosticsGood;
  final Color diagnosticsNeutral;
  final Color diagnosticsBad;

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
  });

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
    );
  }

  @override
  SciFiSemanticColors lerp(ThemeExtension<SciFiSemanticColors>? other, double t) {
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
    );
  }
}

const sciFiSemanticColors = SciFiSemanticColors(
  syncLocked: AppColors.cyan500,
  syncLockedBg: Color(0xFF103746),
  syncDegraded: AppColors.amber500,
  syncDegradedBg: Color(0xFF3B2A0A),
  syncLost: AppColors.red500,
  syncLostBg: Color(0xFF411217),
  windowClosed: AppColors.red500,
  windowWarning: AppColors.amber500,
  windowOpen: AppColors.lime500,
  recordingLive: AppColors.lime500,
  recordingDepletion: Color(0xFF203040),
  cueSpoken: AppColors.cyan400,
  cueDisplayOnly: AppColors.violet500,
  userRiff: AppColors.teal500,
  diagnosticsGood: AppColors.cyan400,
  diagnosticsNeutral: AppColors.steel200,
  diagnosticsBad: AppColors.red400,
);
