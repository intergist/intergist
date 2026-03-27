import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';
import 'package:scifionly/ui/theme/scifionly_session_theme.dart';

/// Visual states for the participation ring.
enum ParticipationVisualState {
  /// Window is closed — user cannot participate.
  closed,

  /// Window is about to close — warning state.
  warning,

  /// Window is open — user can participate.
  open,

  /// Actively recording user audio.
  recording,

  /// Ring is disabled / inactive.
  disabled,
}

/// A circular participation indicator with a [CustomPaint]-based ring,
/// optional depletion wedge for the recording state, and a central
/// label with optional countdown.
class ParticipationRing extends StatelessWidget {
  const ParticipationRing({
    super.key,
    required this.state,
    this.label,
    this.countdownSeconds,
    this.progress = 1.0,
    this.useDepletionMode = false,
    this.subtitle,
    this.onTap,
  });

  /// The current participation state.
  final ParticipationVisualState state;

  /// Central label text (e.g. "TAP" or "REC").
  final String? label;

  /// Seconds remaining for the countdown display.
  final int? countdownSeconds;

  /// Progress from 0.0 to 1.0 controlling the arc sweep.
  final double progress;

  /// When true, draws the ring as a depleting wedge (recording mode).
  final bool useDepletionMode;

  /// Optional subtitle below the main label.
  final String? subtitle;

  /// Tap callback.
  final VoidCallback? onTap;

  Color _ringColor(SciFiSemanticColors sem) {
    switch (state) {
      case ParticipationVisualState.closed:
        return sem.windowClosed;
      case ParticipationVisualState.warning:
        return sem.windowWarning;
      case ParticipationVisualState.open:
        return sem.windowOpen;
      case ParticipationVisualState.recording:
        return sem.recordingLive;
      case ParticipationVisualState.disabled:
        return AppColors.steel500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).extension<SciFiSemanticColors>()!;
    final sessionTheme = Theme.of(context).extension<SciFiSessionTheme>();
    final cs = Theme.of(context).colorScheme;
    final ringThickness = sessionTheme?.participationRingThickness ?? 6.0;
    final ringColor = _ringColor(sem);
    final isDisabled = state == ParticipationVisualState.disabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: SizedBox(
        width: 160,
        height: 160,
        child: CustomPaint(
          painter: _ParticipationRingPainter(
            color: ringColor,
            progress: progress,
            strokeWidth: ringThickness,
            useDepletion: useDepletionMode &&
                state == ParticipationVisualState.recording,
            depletionColor: sem.recordingDepletion,
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: isDisabled ? 0.4 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (countdownSeconds != null)
                    Text(
                      '${countdownSeconds}s',
                      style: AppTypography.displayL.copyWith(
                        color: ringColor,
                      ),
                    ),
                  if (label != null)
                    Text(
                      label!,
                      style: AppTypography.labelL.copyWith(
                        color: countdownSeconds != null
                            ? cs.onSurfaceVariant
                            : ringColor,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpace.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.monoS.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipationRingPainter extends CustomPainter {
  _ParticipationRingPainter({
    required this.color,
    required this.progress,
    required this.strokeWidth,
    required this.useDepletion,
    required this.depletionColor,
  });

  final Color color;
  final double progress;
  final double strokeWidth;
  final bool useDepletion;
  final Color depletionColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Depletion wedge overlay for recording mode
    if (useDepletion && progress < 1.0) {
      final depletionPaint = Paint()
        ..color = depletionColor.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final depletionStart = startAngle + sweepAngle;
      final depletionSweep = 2 * math.pi - sweepAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        depletionStart,
        depletionSweep,
        false,
        depletionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticipationRingPainter oldDelegate) =>
      color != oldDelegate.color ||
      progress != oldDelegate.progress ||
      strokeWidth != oldDelegate.strokeWidth ||
      useDepletion != oldDelegate.useDepletion ||
      depletionColor != oldDelegate.depletionColor;
}
