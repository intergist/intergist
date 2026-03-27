import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';


/// Full-bleed dark splash screen with "SciFiOnly" branding and a scanning-line
/// animation. Auto-navigates to onboarding (or library) after 1.5 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scanAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    // Auto-navigate after 1.5 seconds.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Scanning line effect.
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height *
                    _scanAnimation.value,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyan500.withAlpha(0),
                        AppColors.cyan500.withAlpha(180),
                        AppColors.cyan500.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Centered content.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App title with glow effect.
                Text(
                  'SciFiOnly',
                  style: AppTypography.displayXL.copyWith(
                    color: AppColors.cyan500,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        color: AppColors.cyan500.withAlpha(150),
                        blurRadius: 24,
                      ),
                      Shadow(
                        color: AppColors.cyan500.withAlpha(80),
                        blurRadius: 48,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.xxl),

                // Loading status text.
                Text(
                  'Loading cue library...',
                  style: AppTypography.monoM.copyWith(
                    color: AppColors.steel500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),

                // Loading indicator.
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.graphite700,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.cyan500.withAlpha(180),
                    ),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
