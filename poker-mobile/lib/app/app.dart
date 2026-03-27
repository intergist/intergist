// Poker Sharp — App Widget

import 'package:flutter/material.dart';

import '../ui/theme/app_theme.dart';
import 'router/app_router.dart';

class PokerSharpApp extends StatelessWidget {
  const PokerSharpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Poker Sharp',
      debugShowCheckedModeBanner: false,
      theme: buildNebulaCommandTheme(),
      routerConfig: appRouter,
    );
  }
}
