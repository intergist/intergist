import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/components/sync_state_chip.dart';

/// A compact top bar for the live session screen.
///
/// Displays a back button, sync state chip, mode label, elapsed time,
/// and an overflow action.
class SessionTopBar extends StatelessWidget {
  const SessionTopBar({
    super.key,
    required this.syncState,
    this.confidence,
    this.modeLabel,
    this.elapsedTime,
    this.onOverflowTap,
    this.onBackTap,
  });

  /// Current sync visual state passed to [SyncStateChip].
  final SyncVisualState syncState;

  /// Optional sync confidence percentage.
  final double? confidence;

  /// Label describing the current session mode (e.g. "Live Riff").
  final String? modeLabel;

  /// Formatted elapsed time string (e.g. "01:23:45").
  final String? elapsedTime;

  /// Callback for the overflow (more) button.
  final VoidCallback? onOverflowTap;

  /// Callback for the back / close button.
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withAlpha(80),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              onPressed: onBackTap,
              color: cs.onSurface,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: AppSpace.xs),
            // Sync state chip
            SyncStateChip(
              state: syncState,
              confidence: confidence,
              showConfidence: confidence != null,
            ),
            const Spacer(),
            // Mode label
            if (modeLabel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                child: Text(
                  modeLabel!,
                  style: AppTypography.labelM.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            // Elapsed time
            if (elapsedTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                child: Text(
                  elapsedTime!,
                  style: AppTypography.monoM.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            // Overflow button
            if (onOverflowTap != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 22),
                onPressed: onOverflowTap,
                color: cs.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
