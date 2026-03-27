import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/providers/project_providers.dart';
import 'package:scifionly/ui/components/import_source_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Export screen with three export format options, a preview section,
/// and a share action.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _selectedFormat = 'package';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final projectAsync = ref.watch(selectedProjectProvider);

    final projectTitle = projectAsync.whenOrNull(
      data: (p) => p?.title,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/project/${widget.projectId}'),
        ),
        title: Text(
          'Export',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Format selection ──────────────────────────────────────
            const SciFiSectionHeader(title: 'Export Format'),
            const SizedBox(height: AppSpace.lg),

            ImportSourceCard(
              title: 'SciFiOnly Package (.scifi)',
              description:
                  'A complete cue package including manifest, tracks, '
                  'and timing data. Ideal for sharing with other users.',
              icon: Icons.inventory_2_outlined,
              selected: _selectedFormat == 'package',
              onTap: () => setState(() => _selectedFormat = 'package'),
            ),
            const SizedBox(height: AppSpace.md),
            ImportSourceCard(
              title: 'SRT Subtitle File (.srt)',
              description:
                  'Export cues as a standard SubRip subtitle file for '
                  'use with any video player.',
              icon: Icons.subtitles_outlined,
              selected: _selectedFormat == 'srt',
              onTap: () => setState(() => _selectedFormat = 'srt'),
            ),
            const SizedBox(height: AppSpace.md),
            ImportSourceCard(
              title: 'JSON Data (.json)',
              description:
                  'Export raw cue data as JSON for integration with '
                  'external tools or analysis.',
              icon: Icons.data_object_outlined,
              selected: _selectedFormat == 'json',
              onTap: () => setState(() => _selectedFormat = 'json'),
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Preview section ──────────────────────────────────────
            const SciFiSectionHeader(title: 'Export Preview'),
            const SizedBox(height: AppSpace.lg),

            _ExportPreview(
              projectTitle: projectTitle ?? 'Untitled Project',
              format: _selectedFormat,
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Actions ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SciFiPrimaryButton(
                    label: 'Export',
                    icon: Icons.file_download_outlined,
                    size: SciFiButtonSize.large,
                    isLoading: _isExporting,
                    onPressed: () => _export(),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: SciFiSecondaryButton(
                    label: 'Share',
                    icon: Icons.ios_share_outlined,
                    onPressed: () => _share(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.massive),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    // Placeholder: in production this would call the export service.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isExporting = false);
      _showExportSuccess();
    }
  }

  void _share() {
    // Placeholder: in production this would invoke the platform share sheet.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share sheet would open here.')),
    );
  }

  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export completed successfully.'),
        backgroundColor: AppColors.lime500.withAlpha(200),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export Preview
// ---------------------------------------------------------------------------

class _ExportPreview extends StatelessWidget {
  const _ExportPreview({
    required this.projectTitle,
    required this.format,
  });

  final String projectTitle;
  final String format;

  String get _filename {
    final sanitized =
        projectTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    switch (format) {
      case 'package':
        return '$sanitized.scifi';
      case 'srt':
        return '$sanitized.srt';
      case 'json':
        return '$sanitized.json';
      default:
        return sanitized;
    }
  }

  String get _formatLabel {
    switch (format) {
      case 'package':
        return 'SciFiOnly Package';
      case 'srt':
        return 'SubRip Subtitle';
      case 'json':
        return 'JSON Data';
      default:
        return format;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 20, color: cs.primary),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  _filename,
                  style: AppTypography.monoM.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          _PreviewRow(label: 'Project', value: projectTitle),
          _PreviewRow(label: 'Format', value: _formatLabel),
          _PreviewRow(label: 'Tracks included', value: 'All enabled'),
          _PreviewRow(label: 'Estimated size', value: '~ 24 KB'),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
