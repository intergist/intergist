import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// A list-tile–style row representing a single track within a project.
///
/// Displays the track name, kind, language, cue count, an enable/disable
/// switch, and optional overflow action.
class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.name,
    this.kind,
    this.language,
    this.cueCount,
    this.isEnabled = true,
    this.source,
    this.onToggle,
    this.onTap,
    this.onOverflowTap,
  });

  /// Track display name.
  final String name;

  /// Track kind (e.g. "Audio", "Subtitle", "Commentary").
  final String? kind;

  /// Track language code (e.g. "EN").
  final String? language;

  /// Number of cues in this track.
  final int? cueCount;

  /// Whether the track is currently enabled.
  final bool isEnabled;

  /// Source label (e.g. "Local", "Remote").
  final String? source;

  /// Callback when the enable/disable switch is toggled.
  final ValueChanged<bool>? onToggle;

  /// Tap callback for the row body.
  final VoidCallback? onTap;

  /// Callback for the overflow (more) button.
  final VoidCallback? onOverflowTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        child: Row(
          children: [
            // Toggle switch
            SizedBox(
              width: 44,
              child: Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleM.copyWith(
                      color: isEnabled
                          ? cs.onSurface
                          : cs.onSurface.withAlpha(100),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpace.xxs),
                  Row(
                    children: [
                      if (kind != null) ...[
                        Text(
                          kind!,
                          style: AppTypography.labelM.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                      ],
                      if (language != null) ...[
                        Text(
                          language!,
                          style: AppTypography.monoS.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                      ],
                      if (cueCount != null)
                        Text(
                          '$cueCount cues',
                          style: AppTypography.monoS.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (source != null) ...[
                        const SizedBox(width: AppSpace.sm),
                        Icon(
                          Icons.cloud_outlined,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpace.xxs),
                        Text(
                          source!,
                          style: AppTypography.monoS.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Overflow button
            if (onOverflowTap != null)
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: onOverflowTap,
                color: cs.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
