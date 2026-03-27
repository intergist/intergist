// Poker Sharp — Two-Step Card Picker (Rank → Suit)

import 'package:flutter/material.dart';

import '../../../core/poker.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import 'poker_card_widget.dart';

class TwoStepPicker extends StatefulWidget {
  final Set<int> usedCardKeys;
  final void Function(Card card) onCardPicked;

  const TwoStepPicker({
    super.key,
    required this.usedCardKeys,
    required this.onCardPicked,
  });

  @override
  State<TwoStepPicker> createState() => _TwoStepPickerState();
}

class _TwoStepPickerState extends State<TwoStepPicker> {
  int? _selectedRank;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedRank != null) {
      return _SuitPicker(
        rank: _selectedRank!,
        usedCardKeys: widget.usedCardKeys,
        onSuitPicked: (suit) {
          final card = Card(rank: _selectedRank!, suit: suit);
          setState(() => _selectedRank = null);
          widget.onCardPicked(card);
        },
        onBack: () => setState(() => _selectedRank = null),
      );
    }

    return _RankGrid(
      usedCardKeys: widget.usedCardKeys,
      onRankTapped: (rank) => setState(() => _selectedRank = rank),
    );
  }
}

class _RankGrid extends StatelessWidget {
  final Set<int> usedCardKeys;
  final void Function(int rank) onRankTapped;

  const _RankGrid({
    required this.usedCardKeys,
    required this.onRankTapped,
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
            'SELECT RANK',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: displayRanks.map((rank) {
            // Check if all 4 suits for this rank are used
            final allUsed = [0, 1, 2, 3]
                .every((suit) => usedCardKeys.contains(suit * 13 + rank));

            return SizedBox(
              width: 42,
              height: 42,
              child: Material(
                color: allUsed
                    ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.all(AppRadius.xs),
                child: InkWell(
                  onTap: allUsed ? null : () => onRankTapped(rank),
                  borderRadius: BorderRadius.all(AppRadius.xs),
                  child: Center(
                    child: Text(
                      rankNames[rank],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: allUsed
                            ? colorScheme.onSurface.withValues(alpha: 0.2)
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuitPicker extends StatelessWidget {
  final int rank;
  final Set<int> usedCardKeys;
  final void Function(int suit) onSuitPicked;
  final VoidCallback onBack;

  const _SuitPicker({
    required this.rank,
    required this.usedCardKeys,
    required this.onSuitPicked,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back, size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: AppSpace.sm),
            Text(
              '${rankNames[rank]} — SELECT SUIT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [0, 1, 2, 3].map((suit) {
            final key = suit * 13 + rank;
            final isUsed = usedCardKeys.contains(key);
            final color = suitColor(suit, colorScheme);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 56,
                  child: Material(
                    color: isUsed
                        ? colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.3)
                        : suitBgColor(suit),
                    borderRadius: BorderRadius.all(AppRadius.sm),
                    child: InkWell(
                      onTap: isUsed ? null : () => onSuitPicked(suit),
                      borderRadius: BorderRadius.all(AppRadius.sm),
                      child: Center(
                        child: Text(
                          suitSymbols[suit],
                          style: TextStyle(
                            fontSize: 24,
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
      ],
    );
  }
}
