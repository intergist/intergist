// Poker Sharp — SciFiPrimaryButton Widget

import 'package:flutter/material.dart';

import '../../tokens/radius_tokens.dart';
import '../../tokens/spacing_tokens.dart';

enum SciFiButtonSize { regular, large }

enum SciFiButtonTone { primary, secondary, warning, danger }

class SciFiPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SciFiButtonSize size;
  final SciFiButtonTone tone;

  const SciFiPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.size = SciFiButtonSize.regular,
    this.tone = SciFiButtonTone.primary,
  });

  Color _backgroundColor(ColorScheme colorScheme) {
    switch (tone) {
      case SciFiButtonTone.primary:
        return colorScheme.primary;
      case SciFiButtonTone.secondary:
        return colorScheme.secondary;
      case SciFiButtonTone.warning:
        return colorScheme.tertiary;
      case SciFiButtonTone.danger:
        return colorScheme.error;
    }
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    switch (tone) {
      case SciFiButtonTone.primary:
        return colorScheme.onPrimary;
      case SciFiButtonTone.secondary:
        return colorScheme.onSecondary;
      case SciFiButtonTone.warning:
        return colorScheme.onTertiary;
      case SciFiButtonTone.danger:
        return colorScheme.onError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLarge = size == SciFiButtonSize.large;
    final minHeight = isLarge ? 56.0 : 48.0;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _backgroundColor(colorScheme),
        foregroundColor: _foregroundColor(colorScheme),
        minimumSize: Size(0, minHeight),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? AppSpace.xxl : AppSpace.lg,
          vertical: AppSpace.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _foregroundColor(colorScheme),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: isLarge ? 24 : 20),
                  const SizedBox(width: AppSpace.sm),
                ],
                Text(label),
              ],
            ),
    );
  }
}
