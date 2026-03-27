import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';

/// Status variants for [ProjectCard].
enum ProjectCardStatus {
  /// Project is complete and ready to play.
  ready,

  /// Project is missing its RiffTrack audio asset.
  missingRiffTrack,

  /// Project is still in draft state.
  draft,

  /// The project package file is malformed or corrupt.
  malformedPackage,
}

/// A card summarizing a project in the library.
///
/// Displays a title row, metadata chips (year, language, track count),
/// and a colored status footer.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.year,
    this.language,
    this.trackCount,
    this.status = ProjectCardStatus.ready,
    this.themeTag,
    this.onTap,
    this.onOverflowTap,
  });

  /// Project title.
  final String title;

  /// Optional subtitle / description.
  final String? subtitle;

  /// Release year.
  final int? year;

  /// Primary language code (e.g. "EN").
  final String? language;

  /// Number of tracks in the project.
  final int? trackCount;

  /// Current project status.
  final ProjectCardStatus status;

  /// Optional theme / genre tag.
  final String? themeTag;

  /// Tap callback for the card body.
  final VoidCallback? onTap;

  /// Callback for the overflow (more) button.
  final VoidCallback? onOverflowTap;

  String get _statusLabel {
    switch (status) {
      case ProjectCardStatus.ready:
        return 'Ready';
      case ProjectCardStatus.missingRiffTrack:
        return 'Missing RiffTrack';
      case ProjectCardStatus.draft:
        return 'Draft';
      case ProjectCardStatus.malformedPackage:
        return 'Malformed Package';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case ProjectCardStatus.ready:
        return Icons.check_circle_outline;
      case ProjectCardStatus.missingRiffTrack:
        return Icons.music_off_outlined;
      case ProjectCardStatus.draft:
        return Icons.edit_outlined;
      case ProjectCardStatus.malformedPackage:
        return Icons.error_outline;
    }
  }

  Color _statusColor(SciFiSemanticColors sem) {
    switch (status) {
      case ProjectCardStatus.ready:
        return sem.projectReady;
      case ProjectCardStatus.missingRiffTrack:
        return sem.projectMissingAsset;
      case ProjectCardStatus.draft:
        return sem.projectDraft;
      case ProjectCardStatus.malformedPackage:
        return sem.diagnosticsBad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sem = Theme.of(context).extension<SciFiSemanticColors>()!;
    final statusColor = _statusColor(sem);

    return Material(
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.sm,
                AppSpace.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleL.copyWith(
                            color: cs.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpace.xxs),
                          Text(
                            subtitle!,
                            style: AppTypography.bodyM.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
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
            // Metadata chips
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.xs,
              ),
              child: Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.xs,
                children: [
                  if (year != null) _MetadataChip(label: '$year'),
                  if (language != null) _MetadataChip(label: language!),
                  if (trackCount != null)
                    _MetadataChip(label: '$trackCount tracks'),
                  if (themeTag != null) _MetadataChip(label: themeTag!),
                ],
              ),
            ),
            // Status footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.sm,
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(15),
                border: Border(
                  top: BorderSide(
                    color: statusColor.withAlpha(50),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    _statusLabel,
                    style: AppTypography.labelM.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: AppRadius.borderXs,
        border: Border.all(
          color: cs.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.monoS.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
