import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';

/// Four-page onboarding flow explaining the SciFiOnly workflow.
/// Primary CTA "Initialize systems" and secondary "Skip" button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.subtitles_outlined,
      title: 'Bring a movie subtitle track',
      body: 'Import an SRT file from your favorite film. '
          'SciFiOnly uses the dialogue timestamps to know exactly '
          'when characters are talking.',
    ),
    _OnboardingPage(
      icon: Icons.music_note_outlined,
      title: 'Add a riff track or create your own',
      body: 'Load a community riff pack or write your own '
          'perfectly-timed one-liners. Every cue is mapped to a '
          'gap between dialogue lines.',
    ),
    _OnboardingPage(
      icon: Icons.sync_outlined,
      title: 'Sync to the TV and wait for the window',
      body: 'SciFiOnly listens to the movie audio to stay in sync. '
          'When a participation window opens you will see a countdown '
          'and your riff text.',
    ),
    _OnboardingPage(
      icon: Icons.mic_outlined,
      title: 'Record your best line. Export the chaos.',
      body: 'In recording mode you can capture your live riffs. '
          'Export everything as an SRT, riff pack, or full '
          'package to share with friends.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.medium,
        curve: AppMotion.defaultCurve,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.go('/permissions');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top-right.
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpace.lg,
                  right: AppSpace.lg,
                ),
                child: SciFiSecondaryButton(
                  label: 'Skip',
                  onPressed: _finish,
                ),
              ),
            ),

            // Page content.
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(page: page);
                },
              ),
            ),

            // Page indicator dots.
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: AppMotion.fast,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpace.xs,
                    ),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? cs.primary
                          : cs.onSurface.withAlpha(60),
                      borderRadius: AppRadius.borderFull,
                    ),
                  );
                }),
              ),
            ),

            // Primary CTA.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SciFiPrimaryButton(
                  label: isLastPage ? 'Initialize systems' : 'Next',
                  icon: isLastPage ? Icons.rocket_launch : Icons.arrow_forward,
                  size: SciFiButtonSize.large,
                  onPressed: _next,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.massive),
          ],
        ),
      ),
    );
  }
}

/// Data holder for a single onboarding page.
class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Renders a single onboarding page with icon, title, and body text.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area: large icon in a glowing container.
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withAlpha(25),
              border: Border.all(
                color: cs.primary.withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withAlpha(40),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: AppSpace.huge),

          // Title.
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineL.copyWith(
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Body text.
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: AppTypography.bodyL.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
