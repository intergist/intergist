// Poker Sharp — Drill Configuration Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/poker.dart';
import '../../../core/game_state.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import '../../components/buttons/scifi_primary_button.dart';

const _holdingOptions = [5, 10, 15, 20];

class DrillConfigScreen extends ConsumerStatefulWidget {
  const DrillConfigScreen({super.key});

  @override
  ConsumerState<DrillConfigScreen> createState() => _DrillConfigScreenState();
}

class _DrillConfigScreenState extends ConsumerState<DrillConfigScreen> {
  late int _holdingsCount;
  late bool _timerEnabled;
  late PickerMode _pickerMode;

  @override
  void initState() {
    super.initState();
    final config = ref.read(drillConfigProvider);
    _holdingsCount = config.holdingsCount;
    _timerEnabled = config.timerEnabled;
    _pickerMode = config.pickerMode;
  }

  void _handleStart() {
    final notifier = ref.read(drillConfigProvider.notifier);
    notifier.setHoldingsCount(_holdingsCount);
    notifier.setTimerEnabled(_timerEnabled);
    notifier.setPickerMode(_pickerMode);

    // Deal a new board
    final board = dealBoard();
    ref.read(currentBoardProvider.notifier).state = board;

    // Clear holdings
    ref.read(currentHoldingsProvider.notifier).clear();

    context.go('/drill');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Drill'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.xxl,
          ),
          children: [
            Text(
              'Set up your board-reading challenge',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // Holdings Count
            _SectionCard(
              icon: Icons.layers,
              title: 'Holdings to Rank',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: _holdingOptions.map((n) {
                      final isSelected = _holdingsCount == n;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _OptionButton(
                            label: '$n',
                            isSelected: isSelected,
                            onTap: () => setState(() => _holdingsCount = n),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Timer
            _SectionCard(
              icon: Icons.timer,
              title: 'Timer',
              trailing: Switch(
                value: _timerEnabled,
                onChanged: (v) => setState(() => _timerEnabled = v),
                activeColor: colorScheme.primary,
              ),
              subtitle: _timerEnabled
                  ? 'Pro target: ~30s for 20 holdings'
                  : null,
            ),
            const SizedBox(height: AppSpace.lg),

            // Picker Mode
            _SectionCard(
              icon: Icons.grid_view,
              title: 'Card Picker Mode',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionButton(
                          label: 'Two-Step',
                          isSelected: _pickerMode == PickerMode.twoStep,
                          onTap: () =>
                              setState(() => _pickerMode = PickerMode.twoStep),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: _OptionButton(
                          label: 'Full Grid',
                          isSelected: _pickerMode == PickerMode.fullGrid,
                          onTap: () =>
                              setState(() => _pickerMode = PickerMode.fullGrid),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Board Type
            _SectionCard(
              icon: Icons.auto_awesome,
              iconColor: colorScheme.secondary,
              title: 'Board Type',
              subtitle: 'Random board (more options coming soon)',
            ),
            const SizedBox(height: AppSpace.xxxl),

            // Deal Button
            SizedBox(
              width: double.infinity,
              child: SciFiPrimaryButton(
                label: 'Deal',
                icon: Icons.auto_awesome,
                size: SciFiButtonSize.large,
                tone: SciFiButtonTone.secondary,
                onPressed: _handleStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;

  const _SectionCard({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.child,
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
          Row(
            children: [
              Icon(icon, size: 18,
                  color: iconColor ?? colorScheme.primary),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                          ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.all(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
          alignment: Alignment.center,
          child: Text(
            label,
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
    );
  }
}
