import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/providers/session_providers.dart';
import 'package:scifionly/providers/sync_providers.dart';
import 'package:scifionly/ui/components/participation_ring.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';
import 'package:scifionly/ui/components/session_top_bar.dart';
import 'package:scifionly/ui/components/sync_state_chip.dart';
import 'package:scifionly/ui/components/transcript_strip.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Recording session screen.
///
/// Displays [SessionTopBar] at top, a centered [ParticipationRing] (60% of
/// viewport width), guidance text, a [TranscriptStrip] for live STT output,
/// and bottom controls.
class RecordingSessionScreen extends ConsumerWidget {
  const RecordingSessionScreen({super.key, required this.projectId});

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

  ParticipationVisualState _toRingState(ParticipationWindowState ws,
      bool isCapturing) {
    if (isCapturing) return ParticipationVisualState.recording;
    switch (ws) {
      case ParticipationWindowState.closed:
        return ParticipationVisualState.closed;
      case ParticipationWindowState.warning:
        return ParticipationVisualState.warning;
      case ParticipationWindowState.open:
        return ParticipationVisualState.open;
    }
  }

  String _ringLabel(ParticipationVisualState state) {
    switch (state) {
      case ParticipationVisualState.closed:
        return 'WAIT';
      case ParticipationVisualState.warning:
        return 'GET READY';
      case ParticipationVisualState.open:
        return 'TAP';
      case ParticipationVisualState.recording:
        return 'REC';
      case ParticipationVisualState.disabled:
        return 'OFF';
    }
  }

  String _guidanceText(ParticipationVisualState state) {
    switch (state) {
      case ParticipationVisualState.closed:
        return 'Wait for the participation window to open...';
      case ParticipationVisualState.warning:
        return 'A window is about to open. Prepare your riff!';
      case ParticipationVisualState.open:
        return 'Tap the ring to start recording your riff.';
      case ParticipationVisualState.recording:
        return 'Recording in progress. Speak your riff clearly.';
      case ParticipationVisualState.disabled:
        return 'Recording is not available in this state.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final confidence = ref.watch(syncConfidenceProvider);
    final elapsed = ref.watch(sessionElapsedProvider);
    final windowState = ref.watch(participationWindowStateProvider);
    final isCapturing = ref.watch(isCapturingProvider);
    final captureProgress = ref.watch(captureProgressProvider);
    final transcriptText = ref.watch(transcriptTextProvider);
    final isTranscriptFinal = ref.watch(isTranscriptFinalProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final ringState = _toRingState(windowState, isCapturing);
    final ringLabel = _ringLabel(ringState);
    final guidance = _guidanceText(ringState);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────
          SessionTopBar(
            syncState: _toVisualState(confidence),
            confidence: confidence * 100,
            modeLabel: 'Recording',
            elapsedTime: _formatElapsed(elapsed),
            onBackTap: () => _showExitConfirmation(context, ref),
            onOverflowTap: () => _showSessionMenu(context, ref),
          ),

          // ── Body ───────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Participation ring (60% of viewport width)
                  SizedBox(
                    width: screenWidth * 0.6,
                    height: screenWidth * 0.6,
                    child: ParticipationRing(
                      state: ringState,
                      label: ringLabel,
                      progress: isCapturing ? captureProgress : 1.0,
                      useDepletionMode: isCapturing,
                      subtitle: isCapturing ? 'Recording...' : null,
                      onTap: ringState == ParticipationVisualState.open
                          ? () {
                              ref
                                  .read(isCapturingProvider.notifier)
                                  .state = true;
                            }
                          : isCapturing
                              ? () {
                                  ref
                                      .read(isCapturingProvider.notifier)
                                      .state = false;
                                }
                              : null,
                    ),
                  ),

                  const SizedBox(height: AppSpace.xxl),

                  // Guidance text
                  Text(
                    guidance,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Transcript strip
                  if (transcriptText.isNotEmpty)
                    TranscriptStrip(
                      text: transcriptText,
                      isPartial: !isTranscriptFinal,
                      isFinal: isTranscriptFinal,
                      leadingIcon: Icons.mic_outlined,
                    ),

                  const SizedBox(height: AppSpace.lg),
                ],
              ),
            ),
          ),

          // ── Controls ───────────────────────────────────────────────
          _RecordingControls(
            isCapturing: isCapturing,
            onStopCapture: () {
              ref.read(isCapturingProvider.notifier).state = false;
            },
            onSwitchMode: () {
              context.go('/session/standard');
            },
            onPause: () {
              // Pause session
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
        title: const Text('End Recording Session?'),
        content: const Text(
          'All recorded riffs will be saved to this project.',
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
              ref.read(isCapturingProvider.notifier).state = false;
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
                leading: Icon(Icons.play_arrow_rounded,
                    color: cs.primary),
                title: const Text('Switch to Standard Mode'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go('/session/standard');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined,
                    color: cs.onSurface),
                title: const Text('Session Settings'),
                onTap: () => Navigator.of(sheetContext).pop(),
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
// Recording Controls
// ---------------------------------------------------------------------------

class _RecordingControls extends StatelessWidget {
  const _RecordingControls({
    required this.isCapturing,
    required this.onStopCapture,
    required this.onSwitchMode,
    required this.onPause,
  });

  final bool isCapturing;
  final VoidCallback onStopCapture;
  final VoidCallback onSwitchMode;
  final VoidCallback onPause;

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
        child: Row(
          children: [
            // Switch to standard mode
            Expanded(
              child: SciFiSecondaryButton(
                label: 'Standard',
                icon: Icons.play_arrow_rounded,
                onPressed: isCapturing ? null : onSwitchMode,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            // Pause / Stop capture
            Expanded(
              flex: 2,
              child: isCapturing
                  ? SciFiPrimaryButton(
                      label: 'Stop Recording',
                      icon: Icons.stop_rounded,
                      tone: SciFiButtonTone.danger,
                      size: SciFiButtonSize.large,
                      onPressed: onStopCapture,
                    )
                  : SciFiPrimaryButton(
                      label: 'Pause',
                      icon: Icons.pause_rounded,
                      size: SciFiButtonSize.large,
                      onPressed: onPause,
                    ),
            ),
            const SizedBox(width: AppSpace.md),
            // Placeholder for balance
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
