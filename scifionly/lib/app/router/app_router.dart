import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scifionly/ui/screens/splash_screen.dart';
import 'package:scifionly/ui/screens/onboarding_screen.dart';
import 'package:scifionly/ui/screens/permissions_screen.dart';
import 'package:scifionly/ui/screens/library_screen.dart';
import 'package:scifionly/ui/screens/project_details_screen.dart';
import 'package:scifionly/ui/screens/track_manager_screen.dart';
import 'package:scifionly/ui/screens/import_wizard_screen.dart';
import 'package:scifionly/ui/screens/cue_package_preview_screen.dart';
import 'package:scifionly/ui/screens/standard_session_screen.dart';
import 'package:scifionly/ui/screens/recording_session_screen.dart';
import 'package:scifionly/ui/screens/cue_editor_screen.dart';
import 'package:scifionly/ui/screens/export_screen.dart';
import 'package:scifionly/ui/screens/settings_screen.dart';
import 'package:scifionly/ui/screens/diagnostics_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const permissions = '/permissions';
  static const library = '/library';
  static const projectDetails = '/project/:projectId';
  static const trackManager = '/project/:projectId/tracks';
  static const importWizard = '/import';
  static const cuePackagePreview = '/import/preview';
  static const standardSession = '/session/standard/:projectId';
  static const recordingSession = '/session/recording/:projectId';
  static const cueEditor = '/editor/cue/:cueId';
  static const export = '/export/:projectId';
  static const settings = '/settings';
  static const diagnostics = '/diagnostics';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.library,
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: AppRoutes.projectDetails,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ProjectDetailsScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.trackManager,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return TrackManagerScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.importWizard,
      builder: (context, state) => const ImportWizardScreen(),
    ),
    GoRoute(
      path: AppRoutes.cuePackagePreview,
      builder: (context, state) => const CuePackagePreviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.standardSession,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return StandardSessionScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.recordingSession,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return RecordingSessionScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.cueEditor,
      builder: (context, state) {
        final cueId = state.pathParameters['cueId']!;
        return CueEditorScreen(cueId: cueId);
      },
    ),
    GoRoute(
      path: AppRoutes.export,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        return ExportScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.diagnostics,
      builder: (context, state) => const DiagnosticsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
