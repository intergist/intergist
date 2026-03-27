// Poker Sharp — SyncStateChip Widget
// (From the design spec; unused in poker but included per spec)

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../theme/scifi_semantic_colors.dart';

enum SyncState { locked, reacquiring, degraded, lost }

class SyncStateChip extends StatelessWidget {
  final SyncState state;
  final double? confidence;
  final bool showConfidence;

  const SyncStateChip({
    super.key,
    required this.state,
    this.confidence,
    this.showConfidence = false,
  });

  ({Color bg, Color fg, String label}) _stateStyle(BuildContext context) {
    final semantic = Theme.of(context).extension<SciFiSemanticColors>();
    final colorScheme = Theme.of(context).colorScheme;

    switch (state) {
      case SyncState.locked:
        return (
          bg: semantic?.syncLockedBg ?? colorScheme.primaryContainer,
          fg: semantic?.syncLocked ?? colorScheme.primary,
          label: 'Locked',
        );
      case SyncState.reacquiring:
        return (
          bg: semantic?.syncDegradedBg ?? colorScheme.tertiaryContainer,
          fg: semantic?.syncDegraded ?? colorScheme.tertiary,
          label: 'Reacquiring',
        );
      case SyncState.degraded:
        return (
          bg: semantic?.syncDegradedBg ?? colorScheme.tertiaryContainer,
          fg: semantic?.syncDegraded ?? colorScheme.tertiary,
          label: 'Degraded',
        );
      case SyncState.lost:
        return (
          bg: semantic?.syncLostBg ?? colorScheme.errorContainer,
          fg: semantic?.syncLost ?? colorScheme.error,
          label: 'Lost',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _stateStyle(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.all(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            style.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: style.fg,
                ),
          ),
          if (showConfidence && confidence != null) ...[
            const SizedBox(width: AppSpace.xs),
            Text(
              '${(confidence! * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: style.fg.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
