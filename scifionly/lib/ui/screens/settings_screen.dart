import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/providers/settings_providers.dart';
import 'package:scifionly/providers/theme_providers.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/theme/app_theme.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Settings screen with sections for Appearance, Audio, Recording,
/// Accessibility, and About.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/library'),
        ),
        title: Text(
          'Settings',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        children: [
          // ── Appearance ───────────────────────────────────────────
          const SciFiSectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpace.sm),
          _ThemeSelector(ref: ref),
          const SizedBox(height: AppSpace.xxl),

          // ── Audio ────────────────────────────────────────────────
          const SciFiSectionHeader(title: 'Audio'),
          const SizedBox(height: AppSpace.sm),
          _SettingsToggle(
            title: 'Spoken cues',
            subtitle: 'Read riff cues aloud via text-to-speech.',
            value: ref.watch(spokenCuesEnabledProvider),
            onChanged: (v) =>
                ref.read(spokenCuesEnabledProvider.notifier).state = v,
          ),
          _SettingsSlider(
            title: 'Spoken cue volume',
            value: ref.watch(spokenCueVolumeProvider),
            onChanged: (v) =>
                ref.read(spokenCueVolumeProvider.notifier).state = v,
          ),
          const SizedBox(height: AppSpace.xxl),

          // ── Recording ────────────────────────────────────────────
          const SciFiSectionHeader(title: 'Recording'),
          const SizedBox(height: AppSpace.sm),
          _SettingsToggle(
            title: 'Auto-save riffs',
            subtitle:
                'Automatically save captured riffs to the project after '
                'each recording session.',
            value: ref.watch(autoSaveRiffsProvider),
            onChanged: (v) =>
                ref.read(autoSaveRiffsProvider.notifier).state = v,
          ),
          _SettingsToggle(
            title: 'Transcript preview',
            subtitle:
                'Show live speech-to-text preview during recording.',
            value: ref.watch(transcriptPreviewProvider),
            onChanged: (v) =>
                ref.read(transcriptPreviewProvider.notifier).state = v,
          ),
          _SettingsSlider(
            title: 'Sync sensitivity',
            value: ref.watch(syncSensitivityProvider),
            min: 0.5,
            max: 1.0,
            divisions: 10,
            label: '${(ref.watch(syncSensitivityProvider) * 100).round()}%',
            onChanged: (v) =>
                ref.read(syncSensitivityProvider.notifier).state = v,
          ),
          _MaxCaptureDurationSelector(ref: ref),
          const SizedBox(height: AppSpace.xxl),

          // ── Accessibility ────────────────────────────────────────
          const SciFiSectionHeader(title: 'Accessibility'),
          const SizedBox(height: AppSpace.sm),
          _SettingsToggle(
            title: 'Haptic feedback',
            subtitle:
                'Vibrate on cue events, window open/close, and controls.',
            value: ref.watch(hapticFeedbackEnabledProvider),
            onChanged: (v) =>
                ref.read(hapticFeedbackEnabledProvider.notifier).state = v,
          ),
          _SettingsToggle(
            title: 'Reduced motion',
            subtitle: 'Minimize animations and transitions.',
            value: ref.watch(reducedMotionProvider),
            onChanged: (v) =>
                ref.read(reducedMotionProvider.notifier).state = v,
          ),
          _SettingsToggle(
            title: 'High contrast',
            subtitle: 'Increase contrast for text and UI elements.',
            value: ref.watch(highContrastProvider),
            onChanged: (v) =>
                ref.read(highContrastProvider.notifier).state = v,
          ),
          _SettingsToggle(
            title: 'Minimal effects',
            subtitle: 'Disable glow, bloom, and decorative effects.',
            value: ref.watch(minimalEffectsProvider),
            onChanged: (v) =>
                ref.read(minimalEffectsProvider.notifier).state = v,
          ),
          const SizedBox(height: AppSpace.xxl),

          // ── About ────────────────────────────────────────────────
          const SciFiSectionHeader(title: 'About'),
          const SizedBox(height: AppSpace.sm),
          _AboutTile(
            title: 'SciFiOnly',
            subtitle: 'Version 1.0.0 (build 1)',
            icon: Icons.info_outline,
          ),
          _AboutTile(
            title: 'Diagnostics',
            subtitle: 'View sync, audio, and session diagnostics.',
            icon: Icons.bug_report_outlined,
            onTap: () => context.go('/diagnostics'),
          ),
          _AboutTile(
            title: 'Licenses',
            subtitle: 'Open-source licenses and attributions.',
            icon: Icons.description_outlined,
            onTap: () => showLicensePage(context: context),
          ),
          const SizedBox(height: AppSpace.massive),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme Selector
// ---------------------------------------------------------------------------

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentMode = ref.watch(appThemeModeProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant.withAlpha(80), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: AppTypography.labelL.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: AppSpace.md),
          ...AppThemeMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return _ThemeOption(
              label: _themeLabel(mode),
              description: _themeDescription(mode),
              isSelected: isSelected,
              onTap: () =>
                  ref.read(appThemeModeProvider.notifier).state = mode,
            );
          }),
        ],
      ),
    );
  }

  String _themeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.nebulaCommand:
        return 'Nebula Command';
      case AppThemeMode.cathodeArcade:
        return 'Cathode Arcade';
      case AppThemeMode.voidTheater:
        return 'Void Theater';
    }
  }

  String _themeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.nebulaCommand:
        return 'Default command bridge theme with cyan and lime accents.';
      case AppThemeMode.cathodeArcade:
        return 'Retro phosphor-green terminal aesthetic.';
      case AppThemeMode.voidTheater:
        return 'Cinematic deep-space look with icy blue and gold.';
    }
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.sm,
          horizontal: AppSpace.xs,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelL.copyWith(
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Toggle
// ---------------------------------------------------------------------------

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleM.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpace.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Slider
// ---------------------------------------------------------------------------

class _SettingsSlider extends StatelessWidget {
  const _SettingsSlider({
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 20,
    this.label,
  });

  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.titleM.copyWith(
                  color: cs.onSurface,
                ),
              ),
              Text(
                label ?? '${(value * 100).round()}%',
                style: AppTypography.monoM.copyWith(
                  color: cs.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: cs.primary,
            inactiveColor: cs.outlineVariant,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Max Capture Duration
// ---------------------------------------------------------------------------

class _MaxCaptureDurationSelector extends StatelessWidget {
  const _MaxCaptureDurationSelector({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentMs = ref.watch(maxCaptureDurationProvider);
    final currentSec = currentMs / 1000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max capture duration',
                style: AppTypography.titleM.copyWith(
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${currentSec.toStringAsFixed(0)}s',
                style: AppTypography.monoM.copyWith(
                  color: cs.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: currentSec,
            min: 3,
            max: 15,
            divisions: 12,
            activeColor: cs.primary,
            inactiveColor: cs.outlineVariant,
            onChanged: (v) =>
                ref.read(maxCaptureDurationProvider.notifier).state =
                    (v * 1000).round(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About Tile
// ---------------------------------------------------------------------------

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.md,
          horizontal: AppSpace.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleM.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: cs.onSurfaceVariant.withAlpha(150),
              ),
          ],
        ),
      ),
    );
  }
}
