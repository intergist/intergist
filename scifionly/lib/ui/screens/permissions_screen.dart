import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Microphone permission request screen.
///
/// Shows an icon, headline, explanatory bullets, privacy note, and a CTA
/// to grant microphone access. Navigates to the library on grant.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  void _grantMicAccess(BuildContext context) {
    // In production this would trigger the platform permission dialog.
    // For now we navigate directly to the library.
    context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxxl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Microphone icon in a glowing circle.
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withAlpha(20),
                  border: Border.all(
                    color: cs.primary.withAlpha(80),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withAlpha(30),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 44,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: AppSpace.xxxl),

              // Headline.
              Text(
                'SciFiOnly needs to hear the movie',
                textAlign: TextAlign.center,
                style: AppTypography.headlineL.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppSpace.xxl),

              // Explanatory bullets.
              _BulletPoint(
                icon: Icons.hearing_outlined,
                text: 'Listens to movie audio to stay in perfect sync '
                    'with dialogue timestamps.',
                cs: cs,
              ),
              const SizedBox(height: AppSpace.md),
              _BulletPoint(
                icon: Icons.timer_outlined,
                text: 'Detects participation windows so your riffs land '
                    'at exactly the right moment.',
                cs: cs,
              ),
              const SizedBox(height: AppSpace.md),
              _BulletPoint(
                icon: Icons.mic_none_outlined,
                text: 'In recording mode, captures your live riff '
                    'audio for transcription and export.',
                cs: cs,
              ),
              const SizedBox(height: AppSpace.xxl),

              // Privacy note card.
              SciFiPanelCard(
                leading: Icon(
                  Icons.shield_outlined,
                  color: cs.primary,
                  size: 20,
                ),
                title: 'Privacy first',
                subtitle: 'Audio is processed on-device only. '
                    'Nothing is uploaded or stored beyond your local riff '
                    'captures. You can revoke access any time in Settings.',
              ),

              const Spacer(flex: 3),

              // Grant CTA.
              SizedBox(
                width: double.infinity,
                child: SciFiPrimaryButton(
                  label: 'Grant microphone access',
                  icon: Icons.mic_rounded,
                  size: SciFiButtonSize.large,
                  onPressed: () => _grantMicAccess(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),

              // Skip option.
              SciFiSecondaryButton(
                label: 'Maybe later',
                onPressed: () => context.go('/library'),
              ),
              const SizedBox(height: AppSpace.massive),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.icon,
    required this.text,
    required this.cs,
  });

  final IconData icon;
  final String text;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.sm),
          decoration: BoxDecoration(
            color: cs.primary.withAlpha(20),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, size: 20, color: cs.primary),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpace.xs),
            child: Text(
              text,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
