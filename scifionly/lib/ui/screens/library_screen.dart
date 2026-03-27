import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/models/project.dart';
import 'package:scifionly/providers/project_providers.dart';
import 'package:scifionly/providers/session_providers.dart';
import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/components/scifi_status_chip.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Main home screen with bottom navigation (Library, Sessions, Create, Settings).
///
/// Displays the project library with a header, optional "continue session" card,
/// recent projects, and an empty state for first-time users.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: const [
          _LibraryTab(),
          _SessionsTab(),
          _CreateTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: _currentTab,
      onDestinationSelected: (index) {
        if (index == 3) {
          // Settings tab navigates to the full settings screen.
          context.go('/settings');
          return;
        }
        setState(() => _currentTab = index);
      },
      backgroundColor: cs.surfaceContainerHighest,
      indicatorColor: cs.primary.withAlpha(30),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.library_music_outlined),
          selectedIcon: Icon(Icons.library_music),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Library Tab
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryTab extends ConsumerWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final projectsAsync = ref.watch(projectListProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header with title and import button.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.xl,
                AppSpace.lg,
                AppSpace.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Library',
                      style: AppTypography.displayL.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => context.go('/import'),
                    icon: const Icon(Icons.file_download_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary.withAlpha(25),
                      foregroundColor: cs.primary,
                    ),
                    tooltip: 'Import',
                  ),
                ],
              ),
            ),
          ),

          // Continue session card (if active session exists).
          if (activeSession != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.lg,
                  vertical: AppSpace.sm,
                ),
                child: SciFiPanelCard(
                  accentColor: AppColors.lime500,
                  title: 'Continue session',
                  subtitle: 'You have an active session in progress',
                  trailing: Icon(
                    Icons.play_circle_filled,
                    color: AppColors.lime500,
                  ),
                  onTap: () {
                    if (activeSession.mode.name == 'recording') {
                      context.go('/session/recording');
                    } else {
                      context.go('/session/standard');
                    }
                  },
                ),
              ),
            ),

          // Project list or states.
          projectsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: cs.error,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      'Failed to load projects',
                      style: AppTypography.titleM.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      error.toString(),
                      style: AppTypography.bodyM.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            data: (projects) {
              if (projects.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyLibraryState(cs: cs),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return const SciFiSectionHeader(
                        title: 'Recent projects',
                      );
                    }
                    final project = projects[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.lg,
                        vertical: AppSpace.xs,
                      ),
                      child: _ProjectListTile(project: project),
                    );
                  },
                  childCount: projects.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project list tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectListTile extends ConsumerWidget {
  const _ProjectListTile({required this.project});

  final Project project;

  SciFiStatusChipTone _chipTone(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.ready:
        return SciFiStatusChipTone.success;
      case ProjectStatus.draft:
        return SciFiStatusChipTone.warning;
      case ProjectStatus.missingRiffTrack:
        return SciFiStatusChipTone.error;
      case ProjectStatus.malformedPackage:
        return SciFiStatusChipTone.error;
    }
  }

  String _chipLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.ready:
        return 'Ready';
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.missingRiffTrack:
        return 'Missing riff';
      case ProjectStatus.malformedPackage:
        return 'Malformed';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SciFiPanelCard(
      title: project.title,
      subtitle: project.releaseYear != null
          ? '${project.releaseYear} \u00B7 ${project.locale.toUpperCase()}'
          : project.locale.toUpperCase(),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(20),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(
          Icons.movie_outlined,
          size: 22,
          color: cs.primary,
        ),
      ),
      trailing: SciFiStatusChip(
        label: _chipLabel(project.status),
        tone: _chipTone(project.status),
        size: SciFiStatusChipSize.sm,
      ),
      onTap: () {
        ref.read(selectedProjectIdProvider.notifier).state = project.id;
        context.go('/project/${project.id}');
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withAlpha(15),
                border: Border.all(
                  color: cs.primary.withAlpha(40),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.movie_filter_outlined,
                size: 36,
                color: cs.primary.withAlpha(150),
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            Text(
              'No projects yet',
              style: AppTypography.headlineM.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Import a subtitle track to create your first '
              'riffing project and start building cue packs.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            SciFiPrimaryButton(
              label: 'Import your first track',
              icon: Icons.file_download_outlined,
              onPressed: () => context.go('/import'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder tabs
// ─────────────────────────────────────────────────────────────────────────────

class _SessionsTab extends StatelessWidget {
  const _SessionsTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: cs.onSurfaceVariant.withAlpha(120),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            'No session history',
            style: AppTypography.headlineM.copyWith(
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Completed sessions will appear here.',
            style: AppTypography.bodyM.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTab extends StatelessWidget {
  const _CreateTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpace.xl),
            Text(
              'Create',
              style: AppTypography.displayL.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            SciFiPanelCard(
              leading: Icon(Icons.file_download_outlined,
                  color: cs.primary, size: 24),
              title: 'Import track or package',
              subtitle: 'Load an SRT, riff track, or cue package',
              onTap: () => context.go('/import'),
            ),
            const SizedBox(height: AppSpace.md),
            SciFiPanelCard(
              leading: Icon(Icons.edit_note_outlined,
                  color: cs.primary, size: 24),
              title: 'New cue from scratch',
              subtitle: 'Write a custom riff cue with timing',
              onTap: () => context.go('/cue-editor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    // This tab redirects to the settings screen via the nav callback.
    return const SizedBox.shrink();
  }
}
