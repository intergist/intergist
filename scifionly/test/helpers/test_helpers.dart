import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scifionly/ui/theme/app_theme.dart';
import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/models/participation_window_model.dart';
import 'package:scifionly/models/project.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/utils/logger.dart';

/// Read a test fixture file
String readFixture(String filename) {
  final file = File('test/fixtures/$filename');
  return file.readAsStringSync();
}

/// Get fixture file path
String fixturePath(String filename) {
  return 'test/fixtures/$filename';
}

/// Wrap a widget in MaterialApp with theme for testing
Widget wrapWithTheme(Widget child, {AppThemeMode theme = AppThemeMode.nebulaCommand}) {
  return ProviderScope(
    child: MaterialApp(
      theme: getThemeData(theme),
      home: Scaffold(body: child),
    ),
  );
}

/// Wrap a widget with all three themes for snapshot testing
List<Widget> wrapWithAllThemes(Widget child) {
  return AppThemeMode.values.map((mode) => wrapWithTheme(child, theme: mode)).toList();
}

/// Create a test CueEventModel
CueEventModel createTestCue({
  String id = 'cue-001',
  String trackId = 'track-001',
  String track = 'riff',
  int startMs = 10000,
  int endMs = 13000,
  String text = 'Test riff cue',
  CueKind kind = CueKind.riff,
  CueMode mode = CueMode.displayAndSpeak,
  int priority = 50,
  SpeakerRole speakerRole = SpeakerRole.app,
  String? windowRef,
  bool interruptible = false,
  bool enabled = true,
  String? sourceFile = 'riffs.srt',
  int? sourceIndex = 1,
  List<String> tags = const [],
}) {
  return CueEventModel(
    id: id,
    trackId: trackId,
    track: track,
    startMs: startMs,
    endMs: endMs,
    text: text,
    kind: kind,
    mode: mode,
    priority: priority,
    speakerRole: speakerRole,
    windowRef: windowRef,
    interruptible: interruptible,
    enabled: enabled,
    sourceFile: sourceFile,
    sourceIndex: sourceIndex,
    tags: tags,
  );
}

/// Create a test ParticipationWindowModel
ParticipationWindowModel createTestWindow({
  String id = 'pw-001',
  int startMs = 10000,
  int endMs = 20000,
  String predictedFrom = 'reference_track_dialogue_gap',
  int stateLeadInMs = 1500,
  int stateLeadOutMs = 1500,
  int minOpenMs = 2500,
  int maxUserRiffMs = 7000,
  bool allowAppSpeech = false,
  bool allowUserCapture = true,
}) {
  return ParticipationWindowModel(
    id: id,
    startMs: startMs,
    endMs: endMs,
    predictedFrom: predictedFrom,
    stateLeadInMs: stateLeadInMs,
    stateLeadOutMs: stateLeadOutMs,
    minOpenMs: minOpenMs,
    maxUserRiffMs: maxUserRiffMs,
    allowAppSpeech: allowAppSpeech,
    allowUserCapture: allowUserCapture,
  );
}

/// Create a test Project
Project createTestProject({
  String id = 'proj-001',
  String title = 'Test Sci-Fi Film',
  int? releaseYear = 2026,
  String locale = 'en-US',
  String? packageId,
  ProjectStatus status = ProjectStatus.ready,
}) {
  return Project(
    id: id,
    title: title,
    releaseYear: releaseYear,
    locale: locale,
    packageId: packageId,
    createdAt: DateTime(2026, 3, 26),
    updatedAt: DateTime(2026, 3, 26),
    status: status,
  );
}

/// Create a test Track
Track createTestTrack({
  String id = 'track-001',
  String projectId = 'proj-001',
  String filename = 'movie.srt',
  TrackType type = TrackType.reference,
  String language = 'en',
  int cueCount = 4,
  bool isEnabled = true,
}) {
  return Track(
    id: id,
    projectId: projectId,
    filename: filename,
    type: type,
    language: language,
    cueCount: cueCount,
    isEnabled: isEnabled,
    createdAt: DateTime(2026, 3, 26),
  );
}

/// Create a test Session
Session createTestSession({
  String id = 'session-001',
  String projectId = 'proj-001',
  SessionMode mode = SessionMode.standard,
  SessionState state = SessionState.active,
}) {
  return Session(
    id: id,
    projectId: projectId,
    mode: mode,
    state: state,
    startedAt: DateTime(2026, 3, 26),
  );
}

/// Enable log collection for tests
void enableTestLogging() {
  AppLogger.minimumLevel = LogLevel.debug;
  AppLogger.consoleOutput = false;
  AppLogger.collectorOutput = true;
  LogCollector.instance.isEnabled = true;
  LogCollector.instance.clear();
}

/// Disable log collection and reset
void disableTestLogging() {
  AppLogger.minimumLevel = LogLevel.info;
  AppLogger.consoleOutput = true;
  AppLogger.collectorOutput = false;
  LogCollector.instance.isEnabled = false;
}
