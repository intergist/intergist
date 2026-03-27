import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/providers/session_providers.dart';
import 'package:scifionly/providers/sync_providers.dart';
import 'package:scifionly/ui/components/cue_display_panel.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';
import 'package:scifionly/ui/components/session_top_bar.dart';
import 'package:scifionly/ui/components/sync_state_chip.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';


/// Standard (read-along) session screen.
///
/// Displays the [SessionTopBar] at the top, [CueDisplayPanel] centered in the
/// body, and playback controls at the bottom (pause, switch to recording,
/// mark missed).
class StandardSessionScreen extends ConsumerWidget {
  const StandardSessionScreen({super.key, required this.projectId});

  final String projectId;

  SyncVisualState _toVisualState(double confidence) {
    if (confidence >= 0.85) return SyncVisualState.locked;
    if (confidence >= 0.5) return SyncVisualState.degraded;
    if (confidence > 0) return SyncVisualState.reacquiring;
    return SyncVisualState.lost;
  }

  String _formatElapsed(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  CueVisualMode _toCueVisualMode(CueMode mode) {
    switch (mode) {
      case CueMode.displayOnly:
        return CueVisualMode.displayOnly;
      case CueMode.speak:
        return CueVisualMode.spoken;
      case CueMode.displayAndSpeak:
        return CueVisualMode.displayAndSpoken;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final confidence = ref.watch(syncConfidenceProvider);
    final elapsed = ref.watch(sessionElapsedProvider);
    final currentCue = ref.watch(currentCueProvider);
    final nextCue = ref.watch(nextCueProvider);
    final session = ref.watch(activeSessionProvider);
    final isPaused = session?.state.name == 'paused';

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────
          SessionTopBar(
            syncState: _toVisualState(confidence),
            confidence: confidence * 100,
            modeLabel: 'Standard',
            elapsedTime: _formatElapsed(elapsed),
            onBackTap: () => _showExitConfirmation(context, ref),
            onOverflowTap: () => _showSessionMenu(context, ref),
          ),

          // ── Cue display ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: currentCue != null
                  ? CueDisplayPanel(
                      text: currentCue.text,
                      nextText: nextCue?.text,
                      mode: _toCueVisualMode(currentCue.mode),
                      highlighted: !isPaused,
                      suppressed: isPaused,
                    )
                  : CueDisplayPanel(
                      text: isPaused
                          ? 'Session paused'
                          : 'Waiting for sync lock...',
                      idle: true,
                    ),
            ),
          ),

          // ── Controls ───────────────────────────────────────────────
          _StandardControls(
            isPaused: isPaused,
            onPause: () {
              // Toggle pause state
            },
            onSwitchMode: () {
              context.go('/session/recording');
            },
            onMarkMissed: () {
              // Mark the current cue as missed
            },
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Your progress will be saved. You can resume later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(activeSessionProvider.notifier).state = null;
              context.go('/library');
            },
            child: const Text('End session'),
          ),
        ],
      ),
    );
  }

  void _showSessionMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final cs = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.fiber_manual_record,
                    color: AppColors.red500),
                title: const Text('Switch to Recording Mode'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go('/session/recording');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined,
                    color: cs.onSurface),
                title: const Text('Session Settings'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.bug_report_outlined,
                    color: cs.onSurface),
                title: const Text('Diagnostics'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go('/diagnostics');
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.stop, color: cs.error),
                title: Text(
                  'End Session',
                  style: TextStyle(color: cs.error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showExitConfirmation(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Standard Controls
// ---------------------------------------------------------------------------

class _StandardControls extends StatelessWidget {
  const _StandardControls({
    required this.isPaused,
    required this.onPause,
    required this.onSwitchMode,
    required this.onMarkMissed,
  });

  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onSwitchMode;
  final VoidCallback onMarkMissed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary controls row
            Row(
              children: [
                // Mark missed
                Expanded(
                  child: SciFiSecondaryButton(
                    label: 'Missed',
                    icon: Icons.close,
                    onPressed: onMarkMissed,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                // Pause / Resume
                Expanded(
                  flex: 2,
                  child: SciFiPrimaryButton(
                    label: isPaused ? 'Resume' : 'Pause',
                    icon: isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: SciFiButtonSize.large,
                    onPressed: onPause,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                // Switch to recording mode
                Expanded(
                  child: SciFiSecondaryButton(
                    label: 'Record',
                    icon: Icons.fiber_manual_record,
                    onPressed: onSwitchMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
