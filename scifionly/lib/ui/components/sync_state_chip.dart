import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';
import 'package:scifionly/ui/theme/scifionly_session_theme.dart';

/// Visual states for the sync-state indicator.
enum SyncVisualState {
  /// Sync is fully locked and stable.
  locked,

  /// Sync is re-acquiring lock after a brief disruption.
  reacquiring,

  /// Sync quality is degraded but usable.
  degraded,

  /// Sync has been completely lost.
  lost,
}

/// A compact chip that communicates the current playback-sync state.
///
/// Colors: locked = cyan, reacquiring / degraded = amber, lost = red.
/// Has a fixed minimum width to prevent layout shift when state changes.
class SyncStateChip extends StatelessWidget {
  const SyncStateChip({
    super.key,
    required this.state,
    this.confidence,
    this.showConfidence = false,
  });

  /// Current sync visual state.
  final SyncVisualState state;

  /// Optional confidence percentage (0–100).
  final double? confidence;

  /// Whether to display the numeric confidence value.
  final bool showConfidence;

  String get _label {
    switch (state) {
      case SyncVisualState.locked:
        return 'LOCKED';
      case SyncVisualState.reacquiring:
        return 'REACQUIRING';
      case SyncVisualState.degraded:
        return 'DEGRADED';
      case SyncVisualState.lost:
        return 'LOST';
    }
  }

  IconData get _icon {
    switch (state) {
      case SyncVisualState.locked:
        return Icons.lock_outlined;
      case SyncVisualState.reacquiring:
        return Icons.sync;
      case SyncVisualState.degraded:
        return Icons.warning_amber_rounded;
      case SyncVisualState.lost:
        return Icons.sync_disabled;
    }
  }

  Color _foreground(SciFiSemanticColors sem) {
    switch (state) {
      case SyncVisualState.locked:
        return sem.syncLocked;
      case SyncVisualState.reacquiring:
      case SyncVisualState.degraded:
        return sem.syncDegraded;
      case SyncVisualState.lost:
        return sem.syncLost;
    }
  }

  Color _background(SciFiSemanticColors sem) {
    switch (state) {
      case SyncVisualState.locked:
        return sem.syncLockedBg;
      case SyncVisualState.reacquiring:
      case SyncVisualState.degraded:
        return sem.syncDegradedBg;
      case SyncVisualState.lost:
        return sem.syncLostBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).extension<SciFiSemanticColors>()!;
    final sessionTheme = Theme.of(context).extension<SciFiSessionTheme>();
    final fg = _foreground(sem);
    final bg = _background(sem);
    final chipHeight = sessionTheme?.syncChipHeight ?? 32.0;

    final confidenceText =
        showConfidence && confidence != null
            ? ' ${confidence!.toStringAsFixed(0)}%'
            : '';

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.defaultCurve,
      constraints: BoxConstraints(
        minWidth: 110,
        minHeight: chipHeight,
        maxHeight: chipHeight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: fg.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 14, color: fg),
          const SizedBox(width: AppSpace.xs),
          Text(
            '$_label$confidenceText',
            style: AppTypography.monoS.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
