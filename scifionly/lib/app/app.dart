import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/app/router/app_router.dart';
import 'package:scifionly/providers/theme_providers.dart';

class SciFiOnlyApp extends ConsumerWidget {
  const SciFiOnlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);

    return MaterialApp.router(
      title: 'SciFiOnly',
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
