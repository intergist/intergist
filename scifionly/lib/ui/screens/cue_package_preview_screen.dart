import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';

import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/components/scifi_status_chip.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Cue package preview screen.
///
/// Shows package title, file checklist, cue counts, timing defaults,
/// an expandable manifest inspector (monospaced), and an import CTA.
class CuePackagePreviewScreen extends ConsumerWidget {
  const CuePackagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Mock package data for the preview. In production this would come
    // from a parsed manifest provider.
    const packageTitle = 'Star Wars: A New Hope - Riff Pack v2';
    const files = <_PackageFile>[
      _PackageFile(
          name: 'manifest.json', present: true, icon: Icons.description),
      _PackageFile(
          name: 'reference_en.srt', present: true, icon: Icons.subtitles),
      _PackageFile(
          name: 'riff_comedy.srt', present: true, icon: Icons.music_note),
      _PackageFile(
          name: 'user_template.srt',
          present: false,
          icon: Icons.mic_none),
    ];
    const cueCounts = {'Reference': 247, 'Riff': 89, 'User template': 0};
    const timingDefaults = {
      'Warning lead-in': '1500 ms',
      'Min window': '2000 ms',
      'Max user riff': '7000 ms',
    };
    const manifestJson = '''{
  "schemaVersion": "1.0",
  "packageId": "star-wars-1977-riff-v2",
  "title": "Star Wars: A New Hope - Riff Pack v2",
  "releaseYear": 1977,
  "locale": "en",
  "referenceTrack": {
    "file": "reference_en.srt",
    "type": "reference",
    "language": "en"
  },
  "timing": {
    "warningLeadInMs": 1500,
    "minParticipationWindowMs": 2000,
    "maxUserRiffMs": 7000
  }
}''';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Package Preview',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
              ),
              children: [
                const SizedBox(height: AppSpace.md),

                // Package title.
                Text(
                  packageTitle,
                  style: AppTypography.headlineL.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpace.xxl),

                // File checklist.
                const SciFiSectionHeader(title: 'Included files'),
                const SizedBox(height: AppSpace.sm),
                ...files.map((f) => _FileChecklistItem(file: f)),
                const SizedBox(height: AppSpace.xxl),

                // Cue counts.
                const SciFiSectionHeader(title: 'Cue counts'),
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: cueCounts.entries.map((entry) {
                    return SciFiStatusChip(
                      label: '${entry.key}: ${entry.value}',
                      icon: Icons.format_list_numbered,
                      tone: entry.value > 0
                          ? SciFiStatusChipTone.info
                          : SciFiStatusChipTone.neutral,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpace.xxl),

                // Timing defaults.
                const SciFiSectionHeader(title: 'Timing defaults'),
                const SizedBox(height: AppSpace.sm),
                SciFiPanelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: timingDefaults.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpace.xs,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: AppTypography.bodyM.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              entry.value,
                              style: AppTypography.monoM.copyWith(
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpace.xxl),

                // Manifest inspector (expandable).
                const SciFiSectionHeader(title: 'Manifest inspector'),
                const SizedBox(height: AppSpace.sm),
                _ManifestInspector(
                  jsonContent: manifestJson,
                  cs: cs,
                ),
                const SizedBox(height: AppSpace.xxl),
              ],
            ),
          ),

          // Bottom import CTA.
          Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: cs.outlineVariant, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: SciFiPrimaryButton(
                  label: 'Import package',
                  icon: Icons.file_download_outlined,
                  size: SciFiButtonSize.large,
                  onPressed: () {
                    // In production: trigger import, then navigate.
                    context.go('/library');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Package file data
// ─────────────────────────────────────────────────────────────────────────────

class _PackageFile {
  const _PackageFile({
    required this.name,
    required this.present,
    required this.icon,
  });

  final String name;
  final bool present;
  final IconData icon;
}

class _FileChecklistItem extends StatelessWidget {
  const _FileChecklistItem({required this.file});

  final _PackageFile file;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        children: [
          Icon(
            file.present
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            size: 20,
            color: file.present ? AppColors.lime500 : AppColors.red400,
          ),
          const SizedBox(width: AppSpace.md),
          Icon(file.icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              file.name,
              style: AppTypography.monoM.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
          if (!file.present)
            SciFiStatusChip(
              label: 'Missing',
              tone: SciFiStatusChipTone.error,
              size: SciFiStatusChipSize.sm,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manifest Inspector
// ─────────────────────────────────────────────────────────────────────────────

class _ManifestInspector extends StatefulWidget {
  const _ManifestInspector({
    required this.jsonContent,
    required this.cs,
  });

  final String jsonContent;
  final ColorScheme cs;

  @override
  State<_ManifestInspector> createState() => _ManifestInspectorState();
}

class _ManifestInspectorState extends State<_ManifestInspector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: AppColors.graphite900,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: widget.cs.outlineVariant.withAlpha(60),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 20,
                  color: widget.cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpace.sm),
                Text(
                  'manifest.json',
                  style: AppTypography.monoM.copyWith(
                    color: widget.cs.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  _expanded ? 'Collapse' : 'Expand',
                  style: AppTypography.labelM.copyWith(
                    color: widget.cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpace.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpace.md),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: AppRadius.borderSm,
                ),
                child: SelectableText(
                  widget.jsonContent,
                  style: AppTypography.monoS.copyWith(
                    color: AppColors.steel200,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
