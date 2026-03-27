import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';

/// A centered, inviting empty-state panel shown when a list or screen
/// has no content yet.
///
/// Displays an optional icon, title, body text, and up to two action buttons.
class EmptyStatePanel extends StatelessWidget {
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

  /// Heading text for the empty state.
  final String title;

  /// Optional descriptive body text.
  final String? body;

  /// Optional large illustrative icon.
  final IconData? icon;

  /// Label for the primary (filled) action button.
  final String? primaryActionLabel;

  /// Callback for the primary action button.
  final VoidCallback? onPrimaryAction;

  /// Label for the secondary (outlined) action button.
  final String? secondaryActionLabel;

  /// Callback for the secondary action button.
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xxxl,
          vertical: AppSpace.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: cs.onSurfaceVariant.withAlpha(120),
              ),
              const SizedBox(height: AppSpace.xl),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineM.copyWith(
                color: cs.onSurface,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyM.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
            if (primaryActionLabel != null || secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpace.xxl),
              Wrap(
                spacing: AppSpace.md,
                runSpacing: AppSpace.sm,
                alignment: WrapAlignment.center,
                children: [
                  if (primaryActionLabel != null)
                    SciFiPrimaryButton(
                      label: primaryActionLabel!,
                      onPressed: onPrimaryAction,
                    ),
                  if (secondaryActionLabel != null)
                    SciFiSecondaryButton(
                      label: secondaryActionLabel!,
                      onPressed: onSecondaryAction,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
