import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Severity levels for [ValidationIssueTile].
enum ValidationSeverity { info, warning, error }

/// A tile displaying a validation issue, color-coded by severity.
///
/// Shows a severity icon, title, optional description, optional line
/// reference, and an optional action button.
class ValidationIssueTile extends StatelessWidget {
  const ValidationIssueTile({
    super.key,
    required this.severity,
    required this.title,
    this.description,
    this.lineRef,
    this.actionLabel,
    this.onActionTap,
  });

  /// The severity of the validation issue.
  final ValidationSeverity severity;

  /// Title / summary of the issue.
  final String title;

  /// Optional detailed description.
  final String? description;

  /// Optional file/line reference string.
  final String? lineRef;

  /// Label for an optional action button.
  final String? actionLabel;

  /// Callback for the action button.
  final VoidCallback? onActionTap;

  Color get _severityColor {
    switch (severity) {
      case ValidationSeverity.info:
        return AppColors.cyan400;
      case ValidationSeverity.warning:
        return AppColors.amber400;
      case ValidationSeverity.error:
        return AppColors.red400;
    }
  }

  IconData get _severityIcon {
    switch (severity) {
      case ValidationSeverity.info:
        return Icons.info_outline;
      case ValidationSeverity.warning:
        return Icons.warning_amber_rounded;
      case ValidationSeverity.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _severityColor;

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_severityIcon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleM.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppSpace.xxs),
                  Text(
                    description!,
                    style: AppTypography.bodyM.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                if (lineRef != null) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    lineRef!,
                    style: AppTypography.monoS.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(180),
                    ),
                  ),
                ],
                if (actionLabel != null) ...[
                  const SizedBox(height: AppSpace.sm),
                  GestureDetector(
                    onTap: onActionTap,
                    child: Text(
                      actionLabel!,
                      style: AppTypography.labelM.copyWith(
                        color: color,
                        decoration: TextDecoration.underline,
                        decorationColor: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
