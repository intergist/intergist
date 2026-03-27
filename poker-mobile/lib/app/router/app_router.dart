// Poker Sharp — GoRouter Configuration with ShellRoute for bottom nav

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/drill_config/drill_config_screen.dart';
import '../../ui/screens/drill/drill_screen.dart';
import '../../ui/screens/results/results_screen.dart';
import '../../ui/screens/stats/stats_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/components/navigation/bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Shell route for screens with bottom nav (Home, Stats, Settings)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final location = state.uri.path;
        int index = 0;
        if (location == '/stats') {
          index = 1;
        } else if (location == '/settings') {
          index = 2;
        }
        return ScaffoldWithNav(
          currentIndex: index,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),

    // Standalone routes (no bottom nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/config',
      builder: (context, state) => const DrillConfigScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/drill',
      builder: (context, state) => const DrillScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/results',
      builder: (context, state) => const ResultsScreen(),
    ),
  ],
);
