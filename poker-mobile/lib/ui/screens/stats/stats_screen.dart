// Poker Sharp — Stats Screen (Full Implementation)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/poker.dart';
import '../../../core/game_state.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import '../drill/poker_card_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  Color _accuracyColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 50) return AppColors.amber500;
    return AppColors.red500;
  }

  String _formatTime(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final history = ref.watch(drillHistoryProvider);
    final suitSens = ref.watch(suitSensitivityProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.xxl, AppSpace.lg, AppSpace.xxl,
        ),
        children: [
          Text(
            'Stats & History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Track your progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppSpace.xxl),

          // 2×2 Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.layers,
                  iconColor: colorScheme.primary,
                  value: '${stats.totalDrills}',
                  label: 'Total Drills',
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFFF9800),
                  value: '${stats.streak}',
                  label: 'Current Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.gps_fixed,
                  iconColor: const Color(0xFF4CAF50),
                  value: '${stats.bestAccuracy}%',
                  label: 'Best (7d)',
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  iconColor: AppColors.amber500,
                  value: '${stats.longestStreak}',
                  label: 'Longest Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xxl),

          // Suit Sensitivity Comparison
          Text(
            'SUIT SENSITIVITY',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: AppSpace.sm),
          _SuitSensitivityCard(
            sensitiveAvg: suitSens.sensitiveAvg,
            nonSensitiveAvg: suitSens.nonSensitiveAvg,
            sensitiveCount: suitSens.sensitiveCount,
            nonSensitiveCount: suitSens.nonSensitiveCount,
          ),
          const SizedBox(height: AppSpace.xxl),

          // Drill History
          Text(
            'DRILL HISTORY',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpace.xxl),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.all(AppRadius.md),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: AppStroke.thin,
                ),
              ),
              child: Center(
                child: Text(
                  'No drills yet. Complete your first drill to see history!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                ),
              ),
            )
          else
            ...history.map((drill) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: _DrillHistoryCard(
                    drill: drill,
                    accuracyColor: _accuracyColor,
                    formatTime: _formatTime,
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppStroke.thin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: AppSpace.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuitSensitivityCard extends StatelessWidget {
  final int? sensitiveAvg;
  final int? nonSensitiveAvg;
  final int sensitiveCount;
  final int nonSensitiveCount;

  const _SuitSensitivityCard({
    required this.sensitiveAvg,
    required this.nonSensitiveAvg,
    required this.sensitiveCount,
    required this.nonSensitiveCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = sensitiveAvg != null || nonSensitiveAvg != null;

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: AppStroke.thin,
          ),
        ),
        child: Text(
          'Complete drills on both suit-sensitive and non-sensitive boards to see a comparison.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
      );
    }

    // Insight text
    String insight = '';
    if (sensitiveAvg != null && nonSensitiveAvg != null) {
      final diff = sensitiveAvg! - nonSensitiveAvg!;
      if (diff.abs() <= 5) {
        insight = 'Consistent performance across board types.';
      } else if (diff < -5) {
        insight =
            'You score ${-diff}% lower on suit-sensitive boards. Practice flush awareness.';
      } else {
        insight =
            'You score ${diff}% higher on suit-sensitive boards. Strong flush reading.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppStroke.thin,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SensitivityColumn(
                  label: 'Suit-Sensitive',
                  avg: sensitiveAvg,
                  count: sensitiveCount,
                  color: colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: _SensitivityColumn(
                  label: 'Non-Sensitive',
                  avg: nonSensitiveAvg,
                  count: nonSensitiveCount,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          if (insight.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: AppSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SensitivityColumn extends StatelessWidget {
  final String label;
  final int? avg;
  final int count;
  final Color color;

  const _SensitivityColumn({
    required this.label,
    required this.avg,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          avg != null ? '$avg%' : '—',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            color: avg != null ? color : colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: AppSpace.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        Text(
          '$count drills',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _DrillHistoryCard extends StatelessWidget {
  final DrillRecord drill;
  final Color Function(int) accuracyColor;
  final String Function(int) formatTime;

  const _DrillHistoryCard({
    required this.drill,
    required this.accuracyColor,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = drill.scoringResult?.percentage ?? 0;

    // Format date
    final now = DateTime.now();
    final drillDate = drill.date;
    final diff = now.difference(drillDate);
    String dateStr;
    if (diff.inMinutes < 60) {
      dateStr = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      dateStr = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      dateStr = '${diff.inDays}d ago';
    } else {
      dateStr =
          '${drillDate.month}/${drillDate.day}/${drillDate.year}';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppStroke.thin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: board cards + badges
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ...drill.board.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Text(
                            cardToString(c),
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              color: suitColor(c.suit, colorScheme),
                            ),
                          ),
                        )),
                    if (drill.hintUsed) ...[
                      const SizedBox(width: AppSpace.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.xs + 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color:
                              colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.all(AppRadius.pill),
                        ),
                        child: Text(
                          'Assisted',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                    if (drill.suitSensitive) ...[
                      const SizedBox(width: AppSpace.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.xs + 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.all(AppRadius.pill),
                        ),
                        child: Text(
                          'Suit',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),

          // Bottom row: holdings count, accuracy, time
          Row(
            children: [
              Text(
                '${drill.targetCount} holdings',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accuracyColor(percentage),
                ),
              ),
              if (drill.timeTakenMs != null) ...[
                const SizedBox(width: AppSpace.md),
                Text(
                  formatTime(drill.timeTakenMs!),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const Spacer(),
              if (drill.scoringResult != null)
                Text(
                  '${drill.scoringResult!.totalPoints}/${drill.scoringResult!.maxPoints} pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
