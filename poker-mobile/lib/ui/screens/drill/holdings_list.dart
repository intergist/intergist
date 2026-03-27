// Poker Sharp — Holdings List with Reorder and Remove

import 'package:flutter/material.dart';

import '../../../core/poker.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import 'poker_card_widget.dart';

class HoldingsList extends StatelessWidget {
  final List<List<Card>> holdings;
  final int targetCount;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const HoldingsList({
    super.key,
    required this.holdings,
    required this.targetCount,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (holdings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpace.xxl),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: AppStroke.thin,
          ),
        ),
        child: Center(
          child: Text(
            'Pick two cards to add a holding',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppStroke.thin,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(AppRadius.md),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: holdings.length,
          onReorder: onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final elevation = Tween<double>(begin: 0, end: 6)
                    .animate(animation)
                    .value;
                return Material(
                  elevation: elevation,
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.all(AppRadius.sm),
                  child: child,
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final holding = holdings[index];
            final card1 = holding[0];
            final card2 = holding[1];

            return _HoldingRow(
              key: ValueKey('holding_$index'),
              index: index,
              card1: card1,
              card2: card2,
              isLast: index == holdings.length - 1,
              onRemove: () => onRemove(index),
            );
          },
        ),
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  final int index;
  final Card card1;
  final Card card2;
  final bool isLast;
  final VoidCallback onRemove;

  const _HoldingRow({
    super.key,
    required this.index,
    required this.card1,
    required this.card2,
    required this.isLast,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            // Card chips
            CardChip(card: card1),
            const SizedBox(width: AppSpace.xs),
            CardChip(card: card2),
            const Spacer(),
            // Remove button
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            // Drag handle
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
