// Poker Sharp — App Text Theme

import 'package:flutter/material.dart';

import '../tokens/typography_tokens.dart';

TextTheme buildAppTextTheme() {
  return TextTheme(
    displayLarge: AppTypography.displayXL,
    displayMedium: AppTypography.displayL,
    headlineLarge: AppTypography.headlineL,
    headlineMedium: AppTypography.headlineM,
    titleLarge: AppTypography.titleL,
    titleMedium: AppTypography.titleM,
    bodyLarge: AppTypography.bodyL,
    bodyMedium: AppTypography.bodyM,
    labelLarge: AppTypography.labelL,
    labelMedium: AppTypography.labelM,
    // Use mono styles for bodySmall and labelSmall
    bodySmall: AppTypography.monoM,
    labelSmall: AppTypography.monoS,
  );
}
