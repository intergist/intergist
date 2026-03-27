import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Visual variant for [SciFiPanelCard].
enum SciFiPanelCardVariant {
  default_,
  warning,
  critical,
  selected,
}

/// A themed card panel with an optional accent strip, title, subtitle,
/// leading/trailing widgets, and tap callback.
///
/// Uses `surfaceContainer` background from the Material [ColorScheme],
/// [AppRadius.md] corner radius, and a 1 dp outline border.
class SciFiPanelCard extends StatelessWidget {
  const SciFiPanelCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.accentColor,
    this.variant = SciFiPanelCardVariant.default_,
    this.padding,
    this.onTap,
  });

  /// Main content of the card.
  final Widget? child;

  /// Optional title text displayed at the top of the card.
  final String? title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional widget placed before the title (e.g. an icon).
  final Widget? leading;

  /// Optional widget placed after the title row (e.g. an action icon).
  final Widget? trailing;

  /// Override color for the accent strip on the leading edge.
  final Color? accentColor;

  /// Visual variant that controls border and accent strip color.
  final SciFiPanelCardVariant variant;

  /// Custom inner padding. Defaults to [AppSpace.lg] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Tap callback. If non-null the card shows a ripple on press.
  final VoidCallback? onTap;

  Color _resolveAccentColor(ColorScheme cs) {
    if (accentColor != null) return accentColor!;
    switch (variant) {
      case SciFiPanelCardVariant.warning:
        return cs.error.withAlpha(200);
      case SciFiPanelCardVariant.critical:
        return cs.error;
      case SciFiPanelCardVariant.selected:
        return cs.primary;
      case SciFiPanelCardVariant.default_:
        return Colors.transparent;
    }
  }

  Color _resolveBorderColor(ColorScheme cs) {
    switch (variant) {
      case SciFiPanelCardVariant.warning:
        return cs.error.withAlpha(100);
      case SciFiPanelCardVariant.critical:
        return cs.error.withAlpha(150);
      case SciFiPanelCardVariant.selected:
        return cs.primary.withAlpha(150);
      case SciFiPanelCardVariant.default_:
        return cs.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = _resolveAccentColor(cs);
    final showAccentStrip = accent != Colors.transparent;

    final innerPadding =
        padding ?? const EdgeInsets.all(AppSpace.lg);

    final hasHeader = title != null || leading != null || trailing != null;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader)
          Padding(
            padding: innerPadding,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpace.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTypography.titleM.copyWith(
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
                if (trailing != null) ...[
                  const SizedBox(width: AppSpace.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        if (child != null)
          Padding(
            padding: hasHeader
                ? EdgeInsets.only(
                    left: (innerPadding as EdgeInsets).left,
                    right: (innerPadding).right,
                    bottom: (innerPadding).bottom,
                  )
                : innerPadding,
            child: child!,
          ),
      ],
    );

    if (showAccentStrip) {
      content = IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Material(
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(
          color: _resolveBorderColor(cs),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
