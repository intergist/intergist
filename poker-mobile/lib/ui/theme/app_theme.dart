// Poker Sharp — App Theme Assembly

import 'package:flutter/material.dart';

import 'app_color_schemes.dart';
import 'app_text_theme.dart';
import 'scifi_semantic_colors.dart';
import 'scifi_session_theme.dart';
import 'scifi_effects_theme.dart';

ThemeData buildNebulaCommandTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: nebulaCommandColorScheme,
    textTheme: buildAppTextTheme(),
    extensions: const [
      sciFiSemanticColors,
      sciFiSessionTheme,
      sciFiEffectsTheme,
    ],
  );
}
