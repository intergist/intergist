import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';

/// A compact, raised panel showing a single transcript line with a
/// monospace timestamp and body text.
///
/// Supports partial (in-progress) and final (confirmed) transcript states.
class TranscriptStrip extends StatelessWidget {
  const TranscriptStrip({
    super.key,
    required this.text,
    this.timestamp,
    this.isPartial = false,
    this.isFinal = false,
    this.leadingIcon,
  });

  /// The transcript text content.
  final String text;

  /// Formatted timestamp string (e.g. "01:23:45").
  final String? timestamp;

  /// Whether this transcript entry is still being processed / partial.
  final bool isPartial;

  /// Whether this transcript entry is finalized.
  final bool isFinal;

  /// Optional leading icon (e.g. microphone, speaker).
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textOpacity = isPartial ? 0.6 : 1.0;

    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: textOpacity,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: cs.outlineVariant.withAlpha(80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(30),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  leadingIcon,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpace.sm),
            ],
            if (timestamp != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  timestamp!,
                  style: AppTypography.monoS.copyWith(
                    color: cs.onSurfaceVariant.withAlpha(180),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
            ],
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyM.copyWith(
                  color: cs.onSurface,
                  fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            if (isFinal)
              Padding(
                padding: const EdgeInsets.only(left: AppSpace.sm, top: 2),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: cs.primary.withAlpha(180),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
