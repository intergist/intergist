import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/features/sync/sync_state.dart';
import 'package:scifionly/providers/session_providers.dart';
import 'package:scifionly/providers/settings_providers.dart';
import 'package:scifionly/providers/sync_providers.dart';
import 'package:scifionly/ui/components/diagnostics_metric_tile.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/components/scifi_status_chip.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';


/// Diagnostics screen showing a metric tile grid, events log, and sync info.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final syncData = ref.watch(syncStateProvider);
    final elapsed = ref.watch(sessionElapsedProvider);
    final isEnabled = ref.watch(diagnosticsEnabledProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Diagnostics',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
        actions: [
          Switch(
            value: isEnabled,
            onChanged: (v) =>
                ref.read(diagnosticsEnabledProvider.notifier).state = v,
            activeColor: cs.primary,
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: !isEnabled
          ? _DisabledState(
              onEnable: () =>
                  ref.read(diagnosticsEnabledProvider.notifier).state = true,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpace.lg),
              children: [
                // ── Metrics grid ───────────────────────────────────
                const SciFiSectionHeader(title: 'Metrics'),
                const SizedBox(height: AppSpace.md),
                _MetricsGrid(syncData: syncData, elapsed: elapsed),
                const SizedBox(height: AppSpace.xxl),

                // ── Sync info ──────────────────────────────────────
                const SciFiSectionHeader(title: 'Sync State'),
                const SizedBox(height: AppSpace.md),
                _SyncInfoPanel(syncData: syncData),
                const SizedBox(height: AppSpace.xxl),

                // ── Events log ─────────────────────────────────────
                const SciFiSectionHeader(title: 'Recent Events'),
                const SizedBox(height: AppSpace.md),
                _EventsLog(),
                const SizedBox(height: AppSpace.massive),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Disabled State
// ---------------------------------------------------------------------------

class _DisabledState extends StatelessWidget {
  const _DisabledState({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              'Diagnostics disabled',
              style: AppTypography.headlineM.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Enable diagnostics to view sync metrics, events, '
              'and session state information.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            FilledButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.toggle_on_outlined),
              label: const Text('Enable Diagnostics'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics Grid
// ---------------------------------------------------------------------------

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.syncData,
    required this.elapsed,
  });

  final SyncStateData syncData;
  final Duration elapsed;

  DiagnosticsState _syncConfidenceState() {
    if (syncData.confidence >= 0.85) return DiagnosticsState.good;
    if (syncData.confidence >= 0.5) return DiagnosticsState.neutral;
    return DiagnosticsState.bad;
  }

  DiagnosticsState _driftState() {
    final absDrift = syncData.driftMs.abs();
    if (absDrift < 100) return DiagnosticsState.good;
    if (absDrift < 500) return DiagnosticsState.neutral;
    return DiagnosticsState.bad;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpace.md,
      crossAxisSpacing: AppSpace.md,
      childAspectRatio: 1.8,
      children: [
        DiagnosticsMetricTile(
          label: 'Sync Confidence',
          value: '${(syncData.confidence * 100).toStringAsFixed(1)}%',
          state: _syncConfidenceState(),
          trend: DiagnosticsTrend.stable,
        ),
        DiagnosticsMetricTile(
          label: 'Drift',
          value: '${syncData.driftMs}ms',
          state: _driftState(),
          trend: syncData.driftMs > 0
              ? DiagnosticsTrend.up
              : syncData.driftMs < 0
                  ? DiagnosticsTrend.down
                  : DiagnosticsTrend.stable,
        ),
        DiagnosticsMetricTile(
          label: 'Position',
          value: '${syncData.estimatedPositionMs}ms',
          state: DiagnosticsState.neutral,
          trend: DiagnosticsTrend.up,
        ),
        DiagnosticsMetricTile(
          label: 'Session Time',
          value: _formatDuration(elapsed),
          state: DiagnosticsState.neutral,
          trend: DiagnosticsTrend.stable,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

// ---------------------------------------------------------------------------
// Sync Info Panel
// ---------------------------------------------------------------------------

class _SyncInfoPanel extends StatelessWidget {
  const _SyncInfoPanel({required this.syncData});

  final SyncStateData syncData;

  SciFiStatusChipTone _stateTone() {
    switch (syncData.state) {
      case SyncState.locked:
        return SciFiStatusChipTone.success;
      case SyncState.degraded:
        return SciFiStatusChipTone.warning;
      case SyncState.reacquiring:
        return SciFiStatusChipTone.warning;
      case SyncState.unlocked:
        return SciFiStatusChipTone.error;
    }
  }

  String _stateLabel() {
    switch (syncData.state) {
      case SyncState.locked:
        return 'Locked';
      case SyncState.degraded:
        return 'Degraded';
      case SyncState.reacquiring:
        return 'Reacquiring';
      case SyncState.unlocked:
        return 'Unlocked';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Engine State',
                style: AppTypography.labelL.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: AppSpace.md),
              SciFiStatusChip(
                label: _stateLabel(),
                tone: _stateTone(),
                size: SciFiStatusChipSize.sm,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          _SyncRow(
            label: 'Confidence',
            value: '${(syncData.confidence * 100).toStringAsFixed(2)}%',
          ),
          _SyncRow(
            label: 'Est. position',
            value: '${syncData.estimatedPositionMs} ms',
          ),
          _SyncRow(
            label: 'Drift',
            value: '${syncData.driftMs} ms',
          ),
          _SyncRow(
            label: 'Last update',
            value: _formatTime(syncData.lastUpdateTime),
          ),
          _SyncRow(
            label: 'Is tracking',
            value: syncData.isTracking ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.monoM.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Events Log
// ---------------------------------------------------------------------------

class _EventsLog extends StatelessWidget {
  // Placeholder event data. In production this would come from a provider.
  static const _events = <_DiagEvent>[
    _DiagEvent(
      time: '00:12:34',
      type: 'sync',
      message: 'Sync lock acquired (confidence: 92.3%)',
    ),
    _DiagEvent(
      time: '00:11:02',
      type: 'cue',
      message: 'Cue delivered: "That\'s not a spaceship..."',
    ),
    _DiagEvent(
      time: '00:10:45',
      type: 'drift',
      message: 'Drift correction applied: -42ms',
    ),
    _DiagEvent(
      time: '00:08:21',
      type: 'window',
      message: 'Participation window opened (3.2s)',
    ),
    _DiagEvent(
      time: '00:06:55',
      type: 'capture',
      message: 'User riff captured (2.1s, finalized)',
    ),
    _DiagEvent(
      time: '00:05:10',
      type: 'sync',
      message: 'Sync confidence degraded to 68%',
    ),
    _DiagEvent(
      time: '00:03:42',
      type: 'sync',
      message: 'Sync reacquiring...',
    ),
    _DiagEvent(
      time: '00:01:00',
      type: 'session',
      message: 'Session started (standard mode)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _events.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: cs.outlineVariant.withAlpha(60)),
        itemBuilder: (context, index) {
          final event = _events[index];
          return _EventRow(event: event);
        },
      ),
    );
  }
}

class _DiagEvent {
  final String time;
  final String type;
  final String message;

  const _DiagEvent({
    required this.time,
    required this.type,
    required this.message,
  });
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final _DiagEvent event;

  IconData get _icon {
    switch (event.type) {
      case 'sync':
        return Icons.sync;
      case 'cue':
        return Icons.subtitles_outlined;
      case 'drift':
        return Icons.trending_flat;
      case 'window':
        return Icons.timer_outlined;
      case 'capture':
        return Icons.mic_outlined;
      case 'session':
        return Icons.play_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColor(ColorScheme cs) {
    switch (event.type) {
      case 'sync':
        return AppColors.cyan500;
      case 'cue':
        return AppColors.lime500;
      case 'drift':
        return AppColors.amber500;
      case 'window':
        return AppColors.violet500;
      case 'capture':
        return AppColors.red500;
      case 'session':
        return cs.primary;
      default:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_icon, size: 16, color: _iconColor(cs)),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            event.time,
            style: AppTypography.monoS.copyWith(
              color: cs.onSurfaceVariant.withAlpha(180),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              event.message,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
