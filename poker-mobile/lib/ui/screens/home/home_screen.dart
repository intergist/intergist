// Poker Sharp — Home Screen (Dashboard)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/poker.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import '../../components/buttons/scifi_primary_button.dart';
import '../../components/cards/scifi_panel_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

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
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final recentDrills = history.length > 3 ? history.sublist(0, 3) : history;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.xxl,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // Header
          Text(
            '${_getGreeting()}, ${settings.playerName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Poker Sharp',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(
            'Drills That Make You Dangerous',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppSpace.xxl),

          // Start Drill CTA
          SizedBox(
            width: double.infinity,
            child: SciFiPrimaryButton(
              label: 'Start Drill',
              icon: Icons.play_arrow,
              size: SciFiButtonSize.large,
              tone: SciFiButtonTone.secondary,
              onPressed: () => context.go('/config'),
            ),
          ),
          const SizedBox(height: AppSpace.xxl),

          // Mini Stats Row
          Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  icon: Icons.bolt,
                  iconColor: colorScheme.secondary,
                  value: '${stats.drillsToday}',
                  label: 'TODAY',
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _StatMiniCard(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFFF9800),
                  value: '${stats.streak}',
                  label: 'STREAK',
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _StatMiniCard(
                  icon: Icons.gps_fixed,
                  iconColor: colorScheme.primary,
                  value: '${stats.bestAccuracy}%',
                  label: 'BEST (7D)',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xxl),

          // Recent Drills
          Text(
            'RECENT DRILLS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: AppSpace.md),
          if (recentDrills.isEmpty)
            SciFiPanelCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.xxl),
                child: Center(
                  child: Text(
                    'No drills yet. Start your first drill!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ),
            )
          else
            ...recentDrills.map((drill) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: _RecentDrillCard(
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

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatMiniCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: AppSpace.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDrillCard extends StatelessWidget {
  final dynamic drill;
  final Color Function(int) accuracyColor;
  final String Function(int) formatTime;

  const _RecentDrillCard({
    required this.drill,
    required this.accuracyColor,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = drill.scoringResult?.percentage ?? 0;

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
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      drill.board.map((c) => cardToString(c as Card)).join(' '),
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (drill.hintUsed) ...[
                      const SizedBox(width: AppSpace.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.xs + 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.15),
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
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
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
            ],
          ),
        ],
      ),
    );
  }
}
