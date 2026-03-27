import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/models/project.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/providers/project_providers.dart';
import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/components/scifi_status_chip.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';

/// Project details screen with hero section, action row, and track info.
class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final sem = Theme.of(context).extension<SciFiSemanticColors>();
    final projectAsync = ref.watch(selectedProjectProvider);
    final tracksAsync = ref.watch(projectTracksProvider(projectId));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/library'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: TextStyle(color: cs.error)),
        ),
        data: (project) {
          if (project == null) {
            return Center(
              child: Text(
                'Project not found',
                style: AppTypography.titleM.copyWith(color: cs.onSurface),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero section ───────────────────────────────────────
                _HeroSection(project: project, sem: sem),
                const SizedBox(height: AppSpace.xxl),

                // ── Actions row ────────────────────────────────────────
                _ActionsRow(projectId: projectId),
                const SizedBox(height: AppSpace.xxl),

                // ── Track sections ─────────────────────────────────────
                tracksAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpace.xxl),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text(
                    'Failed to load tracks: $e',
                    style: TextStyle(color: cs.error),
                  ),
                  data: (tracks) => _TrackSections(tracks: tracks, cs: cs),
                ),
                const SizedBox(height: AppSpace.massive),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.project, this.sem});

  final Project project;
  final SciFiSemanticColors? sem;

  String _statusLabel() {
    switch (project.status) {
      case ProjectStatus.ready:
        return 'Sync ready';
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.missingRiffTrack:
        return 'Missing riff track';
      case ProjectStatus.malformedPackage:
        return 'Malformed package';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title.
        Text(
          project.title,
          style: AppTypography.displayL.copyWith(
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Metadata chips.
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            if (project.releaseYear != null)
              SciFiStatusChip(
                label: '${project.releaseYear}',
                icon: Icons.calendar_today_outlined,
                tone: SciFiStatusChipTone.neutral,
                size: SciFiStatusChipSize.sm,
              ),
            SciFiStatusChip(
              label: project.locale.toUpperCase(),
              icon: Icons.language,
              tone: SciFiStatusChipTone.neutral,
              size: SciFiStatusChipSize.sm,
            ),
            // Sync readiness chip.
            SciFiStatusChip(
              label: _statusLabel(),
              icon: project.status == ProjectStatus.ready
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              tone: project.status == ProjectStatus.ready
                  ? SciFiStatusChipTone.success
                  : SciFiStatusChipTone.warning,
              size: SciFiStatusChipSize.sm,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions Row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SciFiPrimaryButton(
                label: 'Standard Mode',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.go('/session/standard'),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: SciFiPrimaryButton(
                label: 'Recording Mode',
                icon: Icons.fiber_manual_record_rounded,
                tone: SciFiButtonTone.danger,
                onPressed: () => context.go('/session/recording'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: SciFiSecondaryButton(
                label: 'Edit Tracks',
                icon: Icons.edit_outlined,
                onPressed: () =>
                    context.go('/project/$projectId/tracks'),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: SciFiSecondaryButton(
                label: 'Export',
                icon: Icons.ios_share_outlined,
                onPressed: () =>
                    context.go('/project/$projectId/export'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Track Sections
// ─────────────────────────────────────────────────────────────────────────────

class _TrackSections extends StatelessWidget {
  const _TrackSections({required this.tracks, required this.cs});

  final List<Track> tracks;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final refTracks =
        tracks.where((t) => t.type == TrackType.reference).toList();
    final riffTracks =
        tracks.where((t) => t.type == TrackType.riff).toList();
    final userTracks =
        tracks.where((t) => t.type == TrackType.userRiff).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reference Track section.
        const SciFiSectionHeader(title: 'Reference Track'),
        if (refTracks.isEmpty)
          _EmptyTrackNote(label: 'No reference track imported', cs: cs)
        else
          ...refTracks.map((t) => _TrackInfoTile(track: t)),
        const SizedBox(height: AppSpace.lg),

        // Riff Tracks section.
        const SciFiSectionHeader(title: 'Riff Tracks'),
        if (riffTracks.isEmpty)
          _EmptyTrackNote(label: 'No riff tracks imported', cs: cs)
        else
          ...riffTracks.map((t) => _TrackInfoTile(track: t)),
        const SizedBox(height: AppSpace.lg),

        // User Riff Tracks section.
        const SciFiSectionHeader(title: 'User Riff Tracks'),
        if (userTracks.isEmpty)
          _EmptyTrackNote(label: 'No user riffs recorded yet', cs: cs)
        else
          ...userTracks.map((t) => _TrackInfoTile(track: t)),
      ],
    );
  }
}

class _TrackInfoTile extends StatelessWidget {
  const _TrackInfoTile({required this.track});

  final Track track;

  IconData _typeIcon() {
    switch (track.type) {
      case TrackType.reference:
        return Icons.subtitles_outlined;
      case TrackType.riff:
        return Icons.music_note_outlined;
      case TrackType.userRiff:
        return Icons.mic_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.xs,
      ),
      child: SciFiPanelCard(
        leading: Icon(_typeIcon(), size: 20, color: cs.primary),
        title: track.filename,
        subtitle: '${track.cueCount} cues \u00B7 ${track.language.toUpperCase()}',
        trailing: track.isEnabled
            ? Icon(Icons.check_circle, size: 18, color: cs.primary)
            : Icon(Icons.circle_outlined,
                size: 18, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _EmptyTrackNote extends StatelessWidget {
  const _EmptyTrackNote({required this.label, required this.cs});

  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(80),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpace.sm),
            Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
