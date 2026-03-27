import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';
import 'package:scifionly/ui/theme/scifionly_session_theme.dart';
import 'package:scifionly/ui/theme/scifionly_effects_theme.dart';

/// Visual display modes for a cue in the session view.
enum CueVisualMode {
  /// Cue text is shown on screen only.
  displayOnly,

  /// Cue is being spoken (audio).
  spoken,

  /// Cue is both displayed and spoken.
  displayAndSpoken,
}

/// A large, centered cue display panel for the live session.
///
/// Shows the current cue text prominently with optional next-cue preview
/// and a mode badge indicating how the cue is delivered.
class CueDisplayPanel extends StatelessWidget {
  const CueDisplayPanel({
    super.key,
    required this.text,
    this.nextText,
    this.mode = CueVisualMode.displayOnly,
    this.highlighted = false,
    this.suppressed = false,
    this.idle = false,
  });

  /// The current cue text to display.
  final String text;

  /// Optional preview text for the next upcoming cue.
  final String? nextText;

  /// How the cue is delivered.
  final CueVisualMode mode;

  /// Whether the cue should be visually highlighted (glow effect).
  final bool highlighted;

  /// Whether the cue is suppressed (dimmed / struck-through).
  final bool suppressed;

  /// Whether the panel is in idle state (no active cue).
  final bool idle;

  String get _modeBadgeLabel {
    switch (mode) {
      case CueVisualMode.displayOnly:
        return 'DISPLAY';
      case CueVisualMode.spoken:
        return 'SPOKEN';
      case CueVisualMode.displayAndSpoken:
        return 'DISPLAY + SPOKEN';
    }
  }

  IconData get _modeBadgeIcon {
    switch (mode) {
      case CueVisualMode.displayOnly:
        return Icons.visibility_outlined;
      case CueVisualMode.spoken:
        return Icons.volume_up_outlined;
      case CueVisualMode.displayAndSpoken:
        return Icons.record_voice_over_outlined;
    }
  }

  Color _modeBadgeColor(SciFiSemanticColors sem) {
    switch (mode) {
      case CueVisualMode.displayOnly:
        return sem.cueDisplayOnly;
      case CueVisualMode.spoken:
      case CueVisualMode.displayAndSpoken:
        return sem.cueSpoken;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sem = Theme.of(context).extension<SciFiSemanticColors>()!;
    final sessionTheme = Theme.of(context).extension<SciFiSessionTheme>();
    final effects = Theme.of(context).extension<SciFiEffectsTheme>();
    final maxWidth = sessionTheme?.sessionCueMaxWidth ?? 480.0;
    final glowBlur = sessionTheme?.cueGlowBlur ?? 24.0;
    final enableGlow = effects?.enableGlow ?? true;

    final textOpacity = suppressed ? 0.35 : (idle ? 0.5 : 1.0);
    final badgeColor = _modeBadgeColor(sem);

    return AnimatedOpacity(
      opacity: textOpacity,
      duration: AppMotion.standard,
      curve: AppMotion.defaultCurve,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: AppSpace.xxs,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(25),
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: badgeColor.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_modeBadgeIcon, size: 14, color: badgeColor),
                    const SizedBox(width: AppSpace.xs),
                    Text(
                      _modeBadgeLabel,
                      style: AppTypography.monoS.copyWith(color: badgeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              // Main cue text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.xxl,
                  vertical: AppSpace.xl,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                    color: highlighted
                        ? badgeColor.withAlpha(120)
                        : cs.outlineVariant,
                    width: 1,
                  ),
                  boxShadow: highlighted && enableGlow
                      ? [
                          BoxShadow(
                            color: badgeColor.withAlpha(40),
                            blurRadius: glowBlur,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineL.copyWith(
                    color: cs.onSurface,
                    decoration:
                        suppressed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Next-cue preview
              if (nextText != null && nextText!.isNotEmpty) ...[
                const SizedBox(height: AppSpace.lg),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.skip_next_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant.withAlpha(150),
                    ),
                    const SizedBox(width: AppSpace.xs),
                    Flexible(
                      child: Text(
                        nextText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyM.copyWith(
                          color: cs.onSurfaceVariant.withAlpha(150),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
