import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// A section header with title, optional subtitle, and an optional action
/// button aligned to the trailing edge.
///
/// Uses [AppTypography.headlineM] for the title and [AppTypography.bodyM]
/// for the subtitle.
class SciFiSectionHeader extends StatelessWidget {
  const SciFiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  /// Primary heading text.
  final String title;

  /// Optional descriptive text below the title.
  final String? subtitle;

  /// Label for the optional trailing action button.
  final String? actionLabel;

  /// Callback for the trailing action. Required when [actionLabel] is set.
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineM.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpace.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: cs.primary,
                textStyle: AppTypography.labelL,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: AppSpace.xs,
                ),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
