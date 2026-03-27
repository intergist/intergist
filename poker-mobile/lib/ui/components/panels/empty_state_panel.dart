// Poker Sharp — EmptyStatePanel Widget

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';
import '../buttons/scifi_primary_button.dart';
import '../buttons/scifi_secondary_button.dart';

class EmptyStatePanel extends StatelessWidget {
  final String title;
  final String? body;
  final IconData? icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const EmptyStatePanel({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpace.xl),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryActionLabel != null) ...[
              const SizedBox(height: AppSpace.xxl),
              SciFiPrimaryButton(
                label: primaryActionLabel!,
                onPressed: onPrimaryAction,
              ),
            ],
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpace.md),
              SciFiSecondaryButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
