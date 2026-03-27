import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';

/// Tone variants for [SciFiStatusChip].
enum SciFiStatusChipTone {
  neutral,
  info,
  success,
  warning,
  error,
  accent,
}

/// Size variants for [SciFiStatusChip].
enum SciFiStatusChipSize { sm, md }

/// A compact pill-shaped status chip with an optional leading icon.
///
/// Uses full / pill radius, tonal background, and [AppTypography.labelM].
class SciFiStatusChip extends StatelessWidget {
  const SciFiStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = SciFiStatusChipTone.neutral,
    this.size = SciFiStatusChipSize.md,
  });

  /// Text displayed inside the chip.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Color tone of the chip.
  final SciFiStatusChipTone tone;

  /// Size of the chip.
  final SciFiStatusChipSize size;

  Color _foreground() {
    switch (tone) {
      case SciFiStatusChipTone.neutral:
        return AppColors.steel300;
      case SciFiStatusChipTone.info:
        return AppColors.cyan400;
      case SciFiStatusChipTone.success:
        return AppColors.lime500;
      case SciFiStatusChipTone.warning:
        return AppColors.amber400;
      case SciFiStatusChipTone.error:
        return AppColors.red400;
      case SciFiStatusChipTone.accent:
        return AppColors.violet500;
    }
  }

  Color _background() {
    return _foreground().withAlpha(30);
  }

  @override
  Widget build(BuildContext context) {
    final fg = _foreground();
    final bg = _background();
    final isSmall = size == SciFiStatusChipSize.sm;
    final verticalPad = isSmall ? AppSpace.xxs : AppSpace.xs;
    final horizontalPad = isSmall ? AppSpace.sm : AppSpace.md;
    final iconSize = isSmall ? 12.0 : 16.0;
    final textStyle = isSmall
        ? AppTypography.monoS.copyWith(color: fg)
        : AppTypography.labelM.copyWith(color: fg);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            SizedBox(width: isSmall ? AppSpace.xxs : AppSpace.xs),
          ],
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
