import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scifionly/ui/theme/app_theme.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';
import 'package:scifionly/ui/theme/scifionly_session_theme.dart';
import 'package:scifionly/ui/theme/scifionly_effects_theme.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';

void main() {
  group('AppTheme', () {
    group('Nebula Command theme', () {
      late ThemeData theme;

      setUp(() {
        theme = buildNebulaCommandTheme();
      });

      test('has dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('applies correct primary color (cyan)', () {
        expect(theme.colorScheme.primary, AppColors.cyan500);
      });

      test('includes SciFiSemanticColors extension', () {
        final sem = theme.extension<SciFiSemanticColors>();
        expect(sem, isNotNull);
      });

      test('includes SciFiSessionTheme extension', () {
        final session = theme.extension<SciFiSessionTheme>();
        expect(session, isNotNull);
      });

      test('includes SciFiEffectsTheme extension', () {
        final effects = theme.extension<SciFiEffectsTheme>();
        expect(effects, isNotNull);
      });

      test('semantic colors have correct sync values', () {
        final sem = theme.extension<SciFiSemanticColors>()!;
        expect(sem.syncLocked, AppColors.lime500);
        expect(sem.syncDegraded, AppColors.amber500);
        expect(sem.syncLost, AppColors.red500);
      });

      test('semantic colors have correct window values', () {
        final sem = theme.extension<SciFiSemanticColors>()!;
        expect(sem.windowClosed, AppColors.steel500);
        expect(sem.windowWarning, AppColors.amber500);
        expect(sem.windowOpen, AppColors.lime500);
      });

      test('session theme has correct ring thickness', () {
        final session = theme.extension<SciFiSessionTheme>()!;
        expect(session.participationRingThickness, 3.0);
      });

      test('effects theme has glow enabled', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.enableGlow, isTrue);
      });

      test('effects theme has grid overlay enabled', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.enableGridOverlay, isTrue);
      });

      test('effects theme has scan line enabled', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.enableScanLine, isTrue);
      });
    });

    group('Cathode Arcade theme', () {
      late ThemeData theme;

      setUp(() {
        theme = buildCathodeArcadeTheme();
      });

      test('has dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('applies correct primary color (green)', () {
        expect(theme.colorScheme.primary, const Color(0xFF33FF66));
      });

      test('includes SciFiSemanticColors extension', () {
        final sem = theme.extension<SciFiSemanticColors>();
        expect(sem, isNotNull);
      });

      test('includes SciFiSessionTheme extension', () {
        final session = theme.extension<SciFiSessionTheme>();
        expect(session, isNotNull);
      });

      test('includes SciFiEffectsTheme extension', () {
        final effects = theme.extension<SciFiEffectsTheme>();
        expect(effects, isNotNull);
      });

      test('semantic colors use phosphor green', () {
        final sem = theme.extension<SciFiSemanticColors>()!;
        expect(sem.syncLocked, const Color(0xFF33FF66));
        expect(sem.windowOpen, const Color(0xFF33FF66));
        expect(sem.cueSpoken, const Color(0xFF33FF66));
      });

      test('session theme has thinner ring', () {
        final session = theme.extension<SciFiSessionTheme>()!;
        expect(session.participationRingThickness, 2.5);
      });

      test('effects theme disables grid overlay', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.enableGridOverlay, isFalse);
      });

      test('effects theme has higher glow opacity', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.glowOpacity, 0.75);
      });
    });

    group('Void Theater theme', () {
      late ThemeData theme;

      setUp(() {
        theme = buildVoidTheaterTheme();
      });

      test('has dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('applies correct primary color (icy blue)', () {
        expect(theme.colorScheme.primary, const Color(0xFF7EC8E3));
      });

      test('includes SciFiSemanticColors extension', () {
        final sem = theme.extension<SciFiSemanticColors>();
        expect(sem, isNotNull);
      });

      test('includes SciFiSessionTheme extension', () {
        final session = theme.extension<SciFiSessionTheme>();
        expect(session, isNotNull);
      });

      test('includes SciFiEffectsTheme extension', () {
        final effects = theme.extension<SciFiEffectsTheme>();
        expect(effects, isNotNull);
      });

      test('semantic colors use icy blue palette', () {
        final sem = theme.extension<SciFiSemanticColors>()!;
        expect(sem.syncLocked, const Color(0xFF7EC8E3));
        expect(sem.windowOpen, const Color(0xFF7EC8E3));
        expect(sem.cueSpoken, const Color(0xFF7EC8E3));
      });

      test('session theme has thinnest ring', () {
        final session = theme.extension<SciFiSessionTheme>()!;
        expect(session.participationRingThickness, 2.0);
      });

      test('effects theme disables grid and scan line', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.enableGridOverlay, isFalse);
        expect(effects.enableScanLine, isFalse);
      });

      test('effects theme has softer glow opacity', () {
        final effects = theme.extension<SciFiEffectsTheme>()!;
        expect(effects.glowOpacity, 0.45);
      });

      test('panel accent uses violet', () {
        final sem = theme.extension<SciFiSemanticColors>()!;
        expect(sem.panelAccent, const Color(0xFFA78BFA));
      });
    });

    group('themeDataFor helper', () {
      test('returns Nebula Command for nebulaCommand mode', () {
        final theme = themeDataFor(AppThemeMode.nebulaCommand);
        expect(theme.colorScheme.primary, AppColors.cyan500);
      });

      test('returns Cathode Arcade for cathodeArcade mode', () {
        final theme = themeDataFor(AppThemeMode.cathodeArcade);
        expect(theme.colorScheme.primary, const Color(0xFF33FF66));
      });

      test('returns Void Theater for voidTheater mode', () {
        final theme = themeDataFor(AppThemeMode.voidTheater);
        expect(theme.colorScheme.primary, const Color(0xFF7EC8E3));
      });
    });

    group('all themes share common properties', () {
      for (final mode in AppThemeMode.values) {
        test('${mode.name} has dark brightness', () {
          final theme = themeDataFor(mode);
          expect(theme.brightness, Brightness.dark);
        });

        test('${mode.name} uses Material 3', () {
          final theme = themeDataFor(mode);
          expect(theme.useMaterial3, isTrue);
        });

        test('${mode.name} includes all three theme extensions', () {
          final theme = themeDataFor(mode);
          expect(theme.extension<SciFiSemanticColors>(), isNotNull);
          expect(theme.extension<SciFiSessionTheme>(), isNotNull);
          expect(theme.extension<SciFiEffectsTheme>(), isNotNull);
        });

        test('${mode.name} has error colors', () {
          final theme = themeDataFor(mode);
          expect(theme.colorScheme.error, AppColors.red500);
        });

        test('${mode.name} has effects pulse animations enabled', () {
          final theme = themeDataFor(mode);
          final effects = theme.extension<SciFiEffectsTheme>()!;
          expect(effects.enablePulseAnimations, isTrue);
        });

        test('${mode.name} has glow enabled', () {
          final theme = themeDataFor(mode);
          final effects = theme.extension<SciFiEffectsTheme>()!;
          expect(effects.enableGlow, isTrue);
        });
      }
    });
  });
}
