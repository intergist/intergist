// Poker Sharp — ScoreRing Widget (animated circular progress)

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tokens/motion_tokens.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/stroke_tokens.dart';

class ScoreRing extends StatefulWidget {
  final double score; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? activeColor;
  final Color? trackColor;
  final Widget? child;
  final bool animate;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 120,
    this.strokeWidth = 8,
    this.activeColor,
    this.trackColor,
    this.child,
    this.animate = true,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.emphasis,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.standard),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score,
      ).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.standard),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final trackColor =
        widget.trackColor ?? colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreRingPainter(
              score: _animation.value,
              activeColor: activeColor,
              trackColor: trackColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _ScoreRingPainter({
    required this.score,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Active arc
    if (score > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * score,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return score != oldDelegate.score ||
        activeColor != oldDelegate.activeColor ||
        trackColor != oldDelegate.trackColor;
  }
}
