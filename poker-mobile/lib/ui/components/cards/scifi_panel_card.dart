// Poker Sharp — SciFiPanelCard Widget

import 'package:flutter/material.dart';

import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';

enum SciFiPanelCardVariant { defaultVariant, warning, critical, selected }

class SciFiPanelCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? accentColor;
  final SciFiPanelCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const SciFiPanelCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.accentColor,
    this.variant = SciFiPanelCardVariant.defaultVariant,
    this.padding,
    this.onTap,
  });

  Color _borderColor(ColorScheme colorScheme) {
    switch (variant) {
      case SciFiPanelCardVariant.warning:
        return colorScheme.error.withValues(alpha: 0.6);
      case SciFiPanelCardVariant.critical:
        return colorScheme.error;
      case SciFiPanelCardVariant.selected:
        return accentColor ?? colorScheme.primary;
      case SciFiPanelCardVariant.defaultVariant:
        return colorScheme.outlineVariant;
    }
  }

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
              color: _borderColor(colorScheme),
              width: AppStroke.thin,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpace.lg),
          child: child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null || leading != null || trailing != null)
                    Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: AppSpace.sm),
                        ],
                        if (title != null)
                          Expanded(
                            child: Text(
                              title!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }
}
