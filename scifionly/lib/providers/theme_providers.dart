import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/ui/theme/app_theme.dart';

final appThemeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.nebulaCommand;
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(appThemeModeProvider);
  return getThemeData(mode);
});
