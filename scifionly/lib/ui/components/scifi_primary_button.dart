import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Size variants for [SciFiPrimaryButton].
enum SciFiButtonSize { regular, large }

/// Tone / intent variants for [SciFiPrimaryButton].
enum SciFiButtonTone { primary, secondary, warning, danger }

/// A filled primary button following the SciFiOnly design system.
///
/// Uses [AppRadius.md], a minimum height of 48 dp, and [AppTypography.labelL].
class SciFiPrimaryButton extends StatelessWidget {
  const SciFiPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.size = SciFiButtonSize.regular,
    this.tone = SciFiButtonTone.primary,
  });

  /// Button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Tap callback. If null the button appears disabled.
  final VoidCallback? onPressed;

  /// When true, shows a circular progress indicator instead of icon/label.
  final bool isLoading;

  /// Physical size of the button.
  final SciFiButtonSize size;

  /// Color tone / intent.
  final SciFiButtonTone tone;

  Color _backgroundColor(ColorScheme cs) {
    switch (tone) {
      case SciFiButtonTone.primary:
        return cs.primary;
      case SciFiButtonTone.secondary:
        return cs.secondary;
      case SciFiButtonTone.warning:
        return cs.tertiary;
      case SciFiButtonTone.danger:
        return cs.error;
    }
  }

  Color _foregroundColor(ColorScheme cs) {
    switch (tone) {
      case SciFiButtonTone.primary:
        return cs.onPrimary;
      case SciFiButtonTone.secondary:
        return cs.onSecondary;
      case SciFiButtonTone.warning:
        return cs.onTertiary;
      case SciFiButtonTone.danger:
        return cs.onError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _backgroundColor(cs);
    final fg = _foregroundColor(cs);
    final isLarge = size == SciFiButtonSize.large;
    final minHeight = isLarge ? 56.0 : 48.0;
    final horizontalPadding = isLarge ? AppSpace.xxl : AppSpace.lg;

    final style = FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withAlpha(100),
      disabledForegroundColor: fg.withAlpha(100),
      minimumSize: Size(0, minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpace.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      textStyle: AppTypography.labelL,
    );

    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpace.sm),
                  Text(label),
                ],
              )
            : Text(label);

    return FilledButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: child,
    );
  }
}
