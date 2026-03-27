// Poker Sharp — Individual Poker Card Widget (4-color)

import 'package:flutter/material.dart';

import '../../../core/poker.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/stroke_tokens.dart';

/// Returns the 4-color suit color.
Color suitColor(int suit, ColorScheme colorScheme) {
  switch (suit) {
    case 0:
      return colorScheme.onSurface; // spade — white in dark mode
    case 1:
      return AppColors.red500; // heart — red
    case 2:
      return const Color(0xFF5FA8FF); // diamond — blue
    case 3:
      return const Color(0xFF4CAF50); // club — green
    default:
      return colorScheme.onSurface;
  }
}

/// Returns a tinted background for a suit.
Color suitBgColor(int suit) {
  switch (suit) {
    case 0:
      return Colors.white.withValues(alpha: 0.1);
    case 1:
      return AppColors.red500.withValues(alpha: 0.15);
    case 2:
      return const Color(0xFF5FA8FF).withValues(alpha: 0.15);
    case 3:
      return const Color(0xFF4CAF50).withValues(alpha: 0.15);
    default:
      return Colors.white.withValues(alpha: 0.1);
  }
}

class PokerCardWidget extends StatelessWidget {
  final Card card;
  final double width;
  final double height;
  final bool mini;

  const PokerCardWidget({
    super.key,
    required this.card,
    this.width = 54,
    this.height = 76,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = suitColor(card.suit, colorScheme);
    final rankStr = rankNames[card.rank];
    final suitStr = suitSymbols[card.suit];

    if (mini) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xs + 2,
          vertical: AppSpace.xxs,
        ),
        decoration: BoxDecoration(
          color: suitBgColor(card.suit),
          borderRadius: BorderRadius.all(AppRadius.xs),
        ),
        child: Text(
          '$rankStr$suitStr',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.all(AppRadius.sm),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppStroke.thin,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(
              color: color,
              fontSize: mini ? 10 : 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            suitStr,
            style: TextStyle(
              color: color,
              fontSize: mini ? 14 : 20,
            ),
          ),
          Text(
            rankStr,
            style: TextStyle(
              color: color,
              fontSize: mini ? 10 : 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline card chip for result rows etc.
class CardChip extends StatelessWidget {
  final Card card;

  const CardChip({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = suitColor(card.suit, colorScheme);

    return Text(
      cardToString(card),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: 'monospace',
      ),
    );
  }
}
