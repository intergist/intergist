// Poker Sharp — DrillHistoryCard (adapted from ProjectCard in spec)

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';

class DrillHistoryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? date;
  final int? accuracy;
  final int? speedRating;
  final VoidCallback? onTap;

  const DrillHistoryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.date,
    this.accuracy,
    this.speedRating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.all(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(AppRadius.md),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: AppStroke.thin,
            ),
          ),
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (accuracy != null)
                    Text(
                      '$accuracy%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                ],
              ),
              // Metadata chips row
              if (subtitle != null || date != null || speedRating != null) ...[
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.xs,
                  children: [
                    if (date != null)
                      _MetadataChip(label: date!, context: context),
                    if (subtitle != null)
                      _MetadataChip(label: subtitle!, context: context),
                    if (speedRating != null)
                      _MetadataChip(
                        label: '${'★' * speedRating!}${'☆' * (5 - speedRating!)}',
                        context: context,
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

class _MetadataChip extends StatelessWidget {
  final String label;
  final BuildContext context;

  const _MetadataChip({required this.label, required this.context});

  @override
  Widget build(BuildContext chipContext) {
    final colorScheme = Theme.of(chipContext).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.all(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(chipContext).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
      ),
    );
  }
}
