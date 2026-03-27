// Poker Sharp — Full Grid Card Picker (52-card grid)

import 'package:flutter/material.dart';

import '../../../core/poker.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import 'poker_card_widget.dart';

class FullGridPicker extends StatelessWidget {
  final Set<int> usedCardKeys;
  final void Function(Card card) onCardPicked;

  const FullGridPicker({
    super.key,
    required this.usedCardKeys,
    required this.onCardPicked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Ranks in display order: A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, 2
    final displayRanks = List.generate(13, (i) => 12 - i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.sm),
          child: Text(
            'SELECT CARD',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
          ),
        ),
        // 4 rows (one per suit) × 13 columns (A → 2)
        ...List.generate(4, (suit) {
          final color = suitColor(suit, colorScheme);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xxs),
            child: Row(
              children: displayRanks.map((rank) {
                final key = suit * 13 + rank;
                final isUsed = usedCardKeys.contains(key);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                      height: 36,
                      child: Material(
                        color: isUsed
                            ? colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.2)
                            : suitBgColor(suit),
                        borderRadius: BorderRadius.all(AppRadius.xs),
                        child: InkWell(
                          onTap: isUsed
                              ? null
                              : () => onCardPicked(
                                  Card(rank: rank, suit: suit)),
                          borderRadius: BorderRadius.all(AppRadius.xs),
                          child: Center(
                            child: Text(
                              '${rankNames[rank]}${suitSymbols[suit]}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: isUsed
                                    ? color.withValues(alpha: 0.2)
                                    : color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
