import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/models/track.dart';
import 'package:scifionly/providers/project_providers.dart';
import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';
import 'package:scifionly/ui/components/scifi_status_chip.dart';

import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Track manager with segmented tabs for Reference / Riffs / User Riffs.
///
/// Shows track lists with TrackRow-style widgets, import/export actions,
/// and per-tab empty states.
class TrackManagerScreen extends ConsumerStatefulWidget {
  const TrackManagerScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<TrackManagerScreen> createState() =>
      _TrackManagerScreenState();
}

class _TrackManagerScreenState extends ConsumerState<TrackManagerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tracksAsync = ref.watch(projectTracksProvider(widget.projectId));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Track Manager',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/project/${widget.projectId}'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          labelStyle: AppTypography.labelL,
          unselectedLabelStyle: AppTypography.labelL,
          tabs: const [
            Tab(text: 'Reference'),
            Tab(text: 'Riffs'),
            Tab(text: 'User Riffs'),
          ],
        ),
      ),
      body: tracksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: cs.error)),
        ),
        data: (tracks) {
          final refTracks =
              tracks.where((t) => t.type == TrackType.reference).toList();
          final riffTracks =
              tracks.where((t) => t.type == TrackType.riff).toList();
          final userTracks =
              tracks.where((t) => t.type == TrackType.userRiff).toList();

          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TrackList(
                      tracks: refTracks,
                      emptyIcon: Icons.subtitles_outlined,
                      emptyTitle: 'No reference track',
                      emptySubtitle:
                          'Import an SRT file to use as the dialogue reference.',
                      selectedIds: _selectedIds,
                      onToggle: _toggleSelection,
                    ),
                    _TrackList(
                      tracks: riffTracks,
                      emptyIcon: Icons.music_note_outlined,
                      emptyTitle: 'No riff tracks',
                      emptySubtitle:
                          'Import a community riff pack or create your own cues.',
                      selectedIds: _selectedIds,
                      onToggle: _toggleSelection,
                    ),
                    _TrackList(
                      tracks: userTracks,
                      emptyIcon: Icons.mic_outlined,
                      emptyTitle: 'No user riffs',
                      emptySubtitle:
                          'Record riffs during a session to build your collection.',
                      selectedIds: _selectedIds,
                      onToggle: _toggleSelection,
                    ),
                  ],
                ),
              ),

              // Bottom action bar.
              _BottomActionBar(
                hasSelection: _selectedIds.isNotEmpty,
                selectedCount: _selectedIds.length,
                onImport: () => context.go('/import'),
                onExport: () =>
                    context.go('/project/${widget.projectId}/export'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Track List
// ─────────────────────────────────────────────────────────────────────────────

class _TrackList extends StatelessWidget {
  const _TrackList({
    required this.tracks,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Track> tracks;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return _TrackEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.lg),
      itemCount: tracks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.sm),
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isSelected = selectedIds.contains(track.id);

        return _TrackRowTile(
          track: track,
          isSelected: isSelected,
          onTap: () => onToggle(track.id),
        );
      },
    );
  }
}

class _TrackRowTile extends StatelessWidget {
  const _TrackRowTile({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  final Track track;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SciFiPanelCard(
      variant: isSelected
          ? SciFiPanelCardVariant.selected
          : SciFiPanelCardVariant.default_,
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(20),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(
          track.type == TrackType.reference
              ? Icons.subtitles_outlined
              : track.type == TrackType.riff
                  ? Icons.music_note_outlined
                  : Icons.mic_outlined,
          size: 18,
          color: cs.primary,
        ),
      ),
      title: track.filename,
      subtitle:
          '${track.cueCount} cues \u00B7 ${track.language.toUpperCase()}'
          '${track.source != null ? ' \u00B7 ${track.source}' : ''}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (track.isEnabled)
            SciFiStatusChip(
              label: 'Active',
              tone: SciFiStatusChipTone.success,
              size: SciFiStatusChipSize.sm,
            )
          else
            SciFiStatusChip(
              label: 'Disabled',
              tone: SciFiStatusChipTone.neutral,
              size: SciFiStatusChipSize.sm,
            ),
          if (isSelected) ...[
            const SizedBox(width: AppSpace.sm),
            Icon(Icons.check_circle, size: 18, color: cs.primary),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _TrackEmptyState extends StatelessWidget {
  const _TrackEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withAlpha(15),
              ),
              child: Icon(
                icon,
                size: 28,
                color: cs.primary.withAlpha(150),
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              title,
              style: AppTypography.titleL.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Action Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.hasSelection,
    required this.selectedCount,
    required this.onImport,
    required this.onExport,
  });

  final bool hasSelection;
  final int selectedCount;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SciFiPrimaryButton(
                label: 'Import track',
                icon: Icons.file_download_outlined,
                onPressed: onImport,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: SciFiSecondaryButton(
                label: hasSelection
                    ? 'Export ($selectedCount)'
                    : 'Export selected',
                icon: Icons.ios_share_outlined,
                onPressed: hasSelection ? onExport : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
