// Poker Sharp — SciFiStatusChip Widget

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../theme/scifi_semantic_colors.dart';

enum SciFiChipTone { neutral, info, success, warning, error, accent }

enum SciFiChipSize { sm, md }

class SciFiStatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final SciFiChipTone tone;
  final SciFiChipSize size;

  const SciFiStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = SciFiChipTone.neutral,
    this.size = SciFiChipSize.md,
  });

  ({Color bg, Color fg}) _colors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<SciFiSemanticColors>();

    switch (tone) {
      case SciFiChipTone.neutral:
        return (
          bg: colorScheme.surfaceContainerHigh,
          fg: colorScheme.onSurface,
        );
      case SciFiChipTone.info:
        return (
          bg: semantic?.syncLockedBg ?? colorScheme.primaryContainer,
          fg: semantic?.syncLocked ?? colorScheme.primary,
        );
      case SciFiChipTone.success:
        return (
          bg: colorScheme.secondaryContainer,
          fg: colorScheme.secondary,
        );
      case SciFiChipTone.warning:
        return (
          bg: semantic?.syncDegradedBg ?? colorScheme.tertiaryContainer,
          fg: semantic?.syncDegraded ?? colorScheme.tertiary,
        );
      case SciFiChipTone.error:
        return (
          bg: semantic?.syncLostBg ?? colorScheme.errorContainer,
          fg: semantic?.syncLost ?? colorScheme.error,
        );
      case SciFiChipTone.accent:
        return (
          bg: colorScheme.primaryContainer,
          fg: colorScheme.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final isSm = size == SciFiChipSize.sm;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: isSm ? AppSpace.xxs : AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.all(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSm ? 12 : 14, color: colors.fg),
            const SizedBox(width: AppSpace.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.fg,
                ),
          ),
        ],
      ),
    );
  }
}
