// Poker Sharp — Settings Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game_state.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';

const _holdingOptions = [5, 10, 15, 20];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final drillCount = ref.watch(drillHistoryProvider).length;
    final colorScheme = Theme.of(context).colorScheme;
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.xxl, AppSpace.lg, AppSpace.xxl,
        ),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Customize your experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppSpace.xxl),

          // Profile
          _SectionHeader(label: 'Profile'),
          const SizedBox(height: AppSpace.sm),
          _SettingsCard(
            child: Row(
              children: [
                Icon(Icons.person, size: 18, color: colorScheme.primary),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Player Name',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      TextField(
                        controller: TextEditingController(
                          text: settings.playerName,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Player',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.md,
                            vertical: AppSpace.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(AppRadius.sm),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                        onChanged: (value) {
                          settingsNotifier
                              .setPlayerName(value.isEmpty ? 'Player' : value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Appearance
          _SectionHeader(label: 'Appearance'),
          const SizedBox(height: AppSpace.sm),
          _SettingsCard(
            child: Row(
              children: [
                Icon(
                  settings.darkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 18,
                  color: settings.darkMode
                      ? colorScheme.primary
                      : colorScheme.secondary,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.darkMode ? 'Dark Mode' : 'Light Mode',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.darkMode
                            ? 'Casino felt table aesthetic'
                            : 'Light theme for daytime use',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.darkMode,
                  onChanged: (v) => settingsNotifier.setDarkMode(v),
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Drill Defaults
          _SectionHeader(label: 'Drill Defaults'),
          const SizedBox(height: AppSpace.sm),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.layers, size: 18, color: colorScheme.primary),
                    const SizedBox(width: AppSpace.sm),
                    Text(
                      'Default Holdings Count',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                Row(
                  children: _holdingOptions.map((n) {
                    final isSelected = settings.defaultHoldingsCount == n;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Material(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.all(AppRadius.sm),
                          child: InkWell(
                            onTap: () =>
                                settingsNotifier.setDefaultHoldingsCount(n),
                            borderRadius: BorderRadius.all(AppRadius.sm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpace.sm),
                              alignment: Alignment.center,
                              child: Text(
                                '$n',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpace.lg),
                Divider(color: colorScheme.outlineVariant, height: 1),
                const SizedBox(height: AppSpace.lg),
                Row(
                  children: [
                    Icon(Icons.timer, size: 18, color: colorScheme.primary),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        'Timer On by Default',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                    ),
                    Switch(
                      value: settings.defaultTimerEnabled,
                      onChanged: (v) =>
                          settingsNotifier.setDefaultTimerEnabled(v),
                      activeColor: colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Data
          _SectionHeader(label: 'Data'),
          const SizedBox(height: AppSpace.sm),
          _SettingsCard(
            child: InkWell(
              onTap: drillCount > 0
                  ? () => _showResetDialog(context, ref, drillCount)
                  : null,
              child: Opacity(
                opacity: drillCount > 0 ? 1.0 : 0.4,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18,
                        color: colorScheme.error),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset All Stats',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  color: colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            drillCount > 0
                                ? '$drillCount drill${drillCount != 1 ? 's' : ''} will be cleared'
                                : 'No data to clear',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // About
          _SectionHeader(label: 'About'),
          const SizedBox(height: AppSpace.sm),
          _SettingsCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poker Sharp v1.0',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Board-reading drill app based on Angel Largay\'s '
                        'No-Limit Texas Hold\'em: A Complete Course.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        'All hand evaluation runs locally. No data leaves your device.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(
      BuildContext context, WidgetRef ref, int drillCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all statistics?'),
        content: Text(
            'This will permanently delete all $drillCount drill records. '
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(drillHistoryProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

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
      child: child,
    );
  }
}
