// Poker Sharp — Results Screen (Full Implementation)

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/poker.dart';
import '../../../core/scoring.dart';
import '../../../core/game_state.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import '../../tokens/motion_tokens.dart';
import '../../components/buttons/scifi_primary_button.dart';
import '../drill/board_display.dart';
import '../drill/poker_card_widget.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  Color _accuracyColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50);
    if (percentage >= 50) return AppColors.amber500;
    return AppColors.red500;
  }

  String _formatTime(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No results to display',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpace.lg),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final scoring = result.scoringResult;
    final board = result.board;
    final percentage = scoring.percentage;
    final boardTexture = analyzeBoardTexture(board);
    final speedRating = result.timeTakenMs != null
        ? getSpeedRating(result.timeTakenMs!, result.targetCount)
        : null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.xxl, AppSpace.lg, AppSpace.xxl,
          ),
          children: [
            // Header
            Text(
              'Results',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Board replay
            BoardDisplay(board: board, compact: true),
            const SizedBox(height: AppSpace.xxl),

            // Score ring
            Center(
              child: _ScoreRing(
                percentage: percentage,
                color: _accuracyColor(percentage),
              ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniStat(
                  label: 'Exact',
                  value:
                      '${scoring.perPosition.where((p) => p.status == 'exact').length}',
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: AppSpace.xxl),
                _MiniStat(
                  label: 'Points',
                  value: '${scoring.totalPoints}/${scoring.maxPoints}',
                  color: colorScheme.primary,
                ),
                if (result.timeTakenMs != null) ...[
                  const SizedBox(width: AppSpace.xxl),
                  _MiniStat(
                    label: 'Time',
                    value: _formatTime(result.timeTakenMs!),
                    color: _timeColor(result.timeTakenMs!, result.targetCount),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpace.md),

            // Speed stars
            if (speedRating != null) ...[
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < speedRating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: i < speedRating
                          ? AppColors.amber500
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpace.md),
            ],

            // Badges row
            Center(
              child: Wrap(
                spacing: AppSpace.sm,
                children: [
                  if (result.hintUsed)
                    _Badge(
                      label: 'Assisted',
                      color: colorScheme.secondary,
                    ),
                  if (scoring.isSuitSensitive)
                    _Badge(
                      label: 'Suit-Sensitive',
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // Comparison table header
            Text(
              'CLASS COMPARISON',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: AppSpace.sm),

            // Comparison table
            ...scoring.perPosition.map((pos) {
              return _ComparisonRow(
                position: pos,
                board: board,
              );
            }),
            const SizedBox(height: AppSpace.lg),

            // Missed classes
            if (scoring.missedClasses.isNotEmpty) ...[
              Text(
                'MISSED CLASSES',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: AppSpace.sm),
              Container(
                padding: const EdgeInsets.all(AppSpace.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.all(AppRadius.md),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: AppStroke.thin,
                  ),
                ),
                child: Column(
                  children: scoring.missedClasses.map((cls) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpace.xxs),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '#${cls.rank}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              cls.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            cls.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],

            // Board texture
            Container(
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.all(AppRadius.md),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: AppStroke.thin,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 16, color: colorScheme.secondary),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Board Texture',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xxs),
                        Text(
                          boardTexture.description,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SciFiPrimaryButton(
                    label: 'Play Again',
                    icon: Icons.replay,
                    tone: SciFiButtonTone.secondary,
                    onPressed: () {
                      // Deal new board with same config
                      final board = dealBoard();
                      ref.read(currentBoardProvider.notifier).state = board;
                      ref.read(currentHoldingsProvider.notifier).clear();
                      context.go('/drill');
                    },
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: SciFiPrimaryButton(
                    label: 'New Settings',
                    icon: Icons.tune,
                    tone: SciFiButtonTone.primary,
                    onPressed: () => context.go('/config'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home, size: 18),
                label: const Text('Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _timeColor(int ms, int targetCount) {
    final secPerHolding = (ms / 1000) / targetCount;
    if (secPerHolding <= 3) return const Color(0xFF4CAF50);
    if (secPerHolding <= 5) return AppColors.amber500;
    return AppColors.red500;
  }
}

class _ScoreRing extends StatefulWidget {
  final int percentage;
  final Color color;

  const _ScoreRing({required this.percentage, required this.color});

  @override
  State<_ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<_ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.emphasis * 2,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.entrance,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _animation.value,
              color: widget.color,
              trackColor: colorScheme.surfaceContainerHigh,
            ),
            child: Center(
              child: Text(
                '${((_animation.value) * 100).round()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: widget.color,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm + 2,
        vertical: AppSpace.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.all(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatefulWidget {
  final GroupedHoldingScore position;
  final List<Card> board;

  const _ComparisonRow({
    required this.position,
    required this.board,
  });

  @override
  State<_ComparisonRow> createState() => _ComparisonRowState();
}

class _ComparisonRowState extends State<_ComparisonRow> {
  bool _expanded = false;

  IconData _statusIcon() {
    switch (widget.position.status) {
      case 'exact':
        return Icons.check_circle;
      case 'partial':
        return Icons.remove_circle;
      case 'wrong':
        return Icons.cancel;
      case 'missing':
        return Icons.radio_button_unchecked;
      default:
        return Icons.help;
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (widget.position.status) {
      case 'exact':
        return const Color(0xFF4CAF50);
      case 'partial':
        return AppColors.amber500;
      case 'wrong':
        return AppColors.red500;
      case 'missing':
        return colorScheme.onSurface.withValues(alpha: 0.3);
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pos = widget.position;
    final correctClass = pos.correctClass;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpace.xxs),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.all(AppRadius.sm),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: AppStroke.thin,
          ),
        ),
        child: Column(
          children: [
            // Main row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  // Status icon
                  Icon(
                    _statusIcon(),
                    size: 16,
                    color: _statusColor(colorScheme),
                  ),
                  const SizedBox(width: AppSpace.sm),

                  // Rank number
                  SizedBox(
                    width: 22,
                    child: Text(
                      '#${pos.userPosition + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  // User holding
                  SizedBox(
                    width: 52,
                    child: pos.userHolding != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CardChip(card: pos.userHolding!.cards[0]),
                              CardChip(card: pos.userHolding!.cards[1]),
                            ],
                          )
                        : Text(
                            '—',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                  ),

                  const SizedBox(width: AppSpace.sm),
                  // Arrow
                  Icon(Icons.arrow_forward,
                      size: 12,
                      color:
                          colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(width: AppSpace.sm),

                  // Correct class
                  Expanded(
                    child: Text(
                      correctClass.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Member count
                  if (correctClass.memberCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.xs + 1,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.all(AppRadius.pill),
                      ),
                      child: Text(
                        '×${correctClass.memberCount}',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                  const SizedBox(width: AppSpace.sm),
                  // Points
                  Text(
                    '${pos.points}pt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: _statusColor(colorScheme),
                    ),
                  ),

                  // Expand icon
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),

            // Expanded detail
            if (_expanded) _buildExpanded(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context, ColorScheme colorScheme) {
    final pos = widget.position;
    final correctClass = pos.correctClass;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg, 0, AppSpace.lg, AppSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: AppSpace.sm),

          // Hand description
          Text(
            correctClass.description,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpace.sm),

          // Best 5 cards
          Row(
            children: [
              Text(
                'Best 5: ',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              ...correctClass.fiveCards.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: CardChip(card: c),
                  )),
            ],
          ),

          // All members if multi-member class
          if (correctClass.memberCount > 1) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              'All members (${correctClass.memberCount}):',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpace.xxs),
            Wrap(
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xxs,
              children: correctClass.members.map((m) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CardChip(card: m[0]),
                    CardChip(card: m[1]),
                  ],
                );
              }).toList(),
            ),
          ],

          // User's hand if they submitted one
          if (pos.userHolding != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              'Your hand: ${pos.userHolding!.handResult.description}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
