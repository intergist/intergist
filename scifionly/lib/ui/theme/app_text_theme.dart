import 'package:flutter/material.dart';

import '../tokens/typography_tokens.dart';

/// Builds a Material 3 [TextTheme] from [AppTypography] tokens.
///
/// This maps our custom type-scale names to the closest M3 slots so that
/// default widget styling (AppBar title, ListTile subtitle, etc.) picks up
/// the correct typeface automatically.
TextTheme buildAppTextTheme() {
  return TextTheme(
    // Display
    displayLarge: AppTypography.displayXL,
    displayMedium: AppTypography.displayL,
    displaySmall: AppTypography.headlineL,
    // Headline
    headlineLarge: AppTypography.headlineL,
    headlineMedium: AppTypography.headlineM,
    headlineSmall: AppTypography.titleL,
    // Title
    titleLarge: AppTypography.titleL,
    titleMedium: AppTypography.titleM,
    titleSmall: AppTypography.labelL,
    // Body
    bodyLarge: AppTypography.bodyL,
    bodyMedium: AppTypography.bodyM,
    bodySmall: AppTypography.labelM,
    // Label
    labelLarge: AppTypography.labelL,
    labelMedium: AppTypography.labelM,
    labelSmall: AppTypography.monoS,
  );
}
