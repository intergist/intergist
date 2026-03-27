import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';

/// An outlined / tonal secondary button following the SciFiOnly design system.
///
/// Shares the same prop surface as [SciFiPrimaryButton] but renders as an
/// outlined button with a tonal fill rather than a solid filled button.
class SciFiSecondaryButton extends StatelessWidget {
  const SciFiSecondaryButton({
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

  Color _toneColor(ColorScheme cs) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _toneColor(cs);
    final isLarge = size == SciFiButtonSize.large;
    final minHeight = isLarge ? 56.0 : 48.0;
    final horizontalPadding = isLarge ? AppSpace.xxl : AppSpace.lg;

    final style = OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withAlpha(150), width: 1),
      backgroundColor: color.withAlpha(20),
      disabledForegroundColor: color.withAlpha(80),
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
              valueColor: AlwaysStoppedAnimation<Color>(color),
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

    return OutlinedButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: child,
    );
  }
}
