import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';

/// A selection card for choosing an import source.
///
/// Displays a leading icon, title, and description. When [selected] is true,
/// the card gets a cyan accent border and tonal highlight.
class ImportSourceCard extends StatelessWidget {
  const ImportSourceCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  /// Title for this import source.
  final String title;

  /// Optional description of the import source.
  final String? description;

  /// Leading icon representing the source type.
  final IconData? icon;

  /// Whether this card is currently selected.
  final bool selected;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accentColor = AppColors.cyan500;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.defaultCurve,
      child: Material(
        color: selected
            ? accentColor.withAlpha(15)
            : cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(
            color: selected ? accentColor : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withAlpha(30)
                          : cs.surfaceContainerHigh,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: selected ? accentColor : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpace.lg),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleM.copyWith(
                          color: selected ? accentColor : cs.onSurface,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: AppSpace.xxs),
                        Text(
                          description!,
                          style: AppTypography.bodyM.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: AppSpace.sm),
                  const Icon(
                    Icons.check_circle,
                    size: 24,
                    color: accentColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
