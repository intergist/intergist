import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/ui/components/scifi_panel_card.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_secondary_button.dart';

import 'package:scifionly/ui/tokens/color_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/tokens/motion_tokens.dart';

/// 5-step import wizard:
///   1. Source type selection (Reference Track, Riff Track, Cue Package)
///   2. File picker with filename display
///   3. Validation preview (entry count, samples, warnings)
///   4. Issue resolution (list of validation issues)
///   5. Save project form (title, theme, tags)
class ImportWizardScreen extends ConsumerStatefulWidget {
  const ImportWizardScreen({super.key});

  @override
  ConsumerState<ImportWizardScreen> createState() =>
      _ImportWizardScreenState();
}

class _ImportWizardScreenState extends ConsumerState<ImportWizardScreen> {
  int _currentStep = 0;

  // Step 1 state.
  String? _selectedSourceType;

  // Step 2 state.
  String? _selectedFilename;

  // Step 3 state (mock validation).
  int _entryCount = 0;
  List<String> _sampleLines = [];
  int _warningCount = 0;

  // Step 4 state (mock issues).
  List<_ValidationIssue> _issues = [];

  // Step 5 state.
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedTheme = 'nebulaCommand';

  static const _stepTitles = [
    'Select source type',
    'Choose file',
    'Validation preview',
    'Resolve issues',
    'Save project',
  ];

  void _next() {
    if (_currentStep == 0 && _selectedSourceType == null) return;
    if (_currentStep == 1 && _selectedFilename == null) return;

    if (_currentStep == 1) {
      // Simulate validation results.
      setState(() {
        _entryCount = 247;
        _sampleLines = [
          '00:01:23,456 --> 00:01:25,789: "I have a bad feeling about this."',
          '00:03:45,100 --> 00:03:47,300: "May the Force be with you."',
          '00:12:00,000 --> 00:12:03,500: "That\'s no moon."',
        ];
        _warningCount = 3;
        _issues = [
          _ValidationIssue(
            type: _IssueType.warning,
            line: 42,
            message: 'Overlapping timestamp with entry 41',
          ),
          _ValidationIssue(
            type: _IssueType.warning,
            line: 108,
            message: 'Duration exceeds 10 seconds',
          ),
          _ValidationIssue(
            type: _IssueType.info,
            line: 200,
            message: 'Empty cue text (marker only)',
          ),
        ];
      });
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _saveAndFinish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.go('/library');
    }
  }

  void _saveAndFinish() {
    // In production this would create the project via the provider.
    context.go('/library');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Import',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/library'),
        ),
      ),
      body: Column(
        children: [
          // Step indicator.
          _StepIndicator(
            currentStep: _currentStep,
            totalSteps: 5,
            titles: _stepTitles,
          ),
          const Divider(height: 1),

          // Step content.
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              child: _buildStepContent(),
            ),
          ),

          // Navigation buttons.
          _WizardNavBar(
            currentStep: _currentStep,
            totalSteps: 5,
            canProceed: _canProceed(),
            onBack: _back,
            onNext: _next,
            nextLabel: _currentStep == 4 ? 'Save project' : 'Continue',
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedSourceType != null;
      case 1:
        return _selectedFilename != null;
      case 2:
        return _entryCount > 0;
      case 3:
        return true; // Issues are optional to resolve.
      case 4:
        return _titleController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _SourceTypeStep(
          key: const ValueKey('step0'),
          selected: _selectedSourceType,
          onSelect: (type) => setState(() => _selectedSourceType = type),
        );
      case 1:
        return _FilePickerStep(
          key: const ValueKey('step1'),
          selectedFile: _selectedFilename,
          sourceType: _selectedSourceType!,
          onFilePicked: (name) =>
              setState(() => _selectedFilename = name),
        );
      case 2:
        return _ValidationPreviewStep(
          key: const ValueKey('step2'),
          entryCount: _entryCount,
          sampleLines: _sampleLines,
          warningCount: _warningCount,
        );
      case 3:
        return _IssueResolutionStep(
          key: const ValueKey('step3'),
          issues: _issues,
          onDismiss: (index) {
            setState(() => _issues.removeAt(index));
          },
        );
      case 4:
        return _SaveProjectStep(
          key: const ValueKey('step4'),
          titleController: _titleController,
          tagsController: _tagsController,
          selectedTheme: _selectedTheme,
          onThemeChanged: (v) =>
              setState(() => _selectedTheme = v ?? _selectedTheme),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.sm,
        AppSpace.lg,
        AppSpace.md,
      ),
      child: Column(
        children: [
          // Step circles with connecting lines.
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line.
                final stepBefore = index ~/ 2;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: stepBefore < currentStep
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                );
              }
              final step = index ~/ 2;
              final isActive = step == currentStep;
              final isCompleted = step < currentStep;

              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? cs.primary
                      : isActive
                          ? cs.primary.withAlpha(30)
                          : Colors.transparent,
                  border: Border.all(
                    color: isCompleted || isActive
                        ? cs.primary
                        : cs.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 14, color: cs.onPrimary)
                      : Text(
                          '${step + 1}',
                          style: AppTypography.labelM.copyWith(
                            color: isActive
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpace.sm),
          // Current step title.
          Text(
            titles[currentStep],
            style: AppTypography.labelL.copyWith(
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: Source Type
// ─────────────────────────────────────────────────────────────────────────────

class _SourceTypeStep extends StatelessWidget {
  const _SourceTypeStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: [
        const SizedBox(height: AppSpace.md),
        _ImportSourceOption(
          icon: Icons.subtitles_outlined,
          title: 'Reference Track',
          subtitle: 'SRT subtitle file with dialogue timestamps',
          isSelected: selected == 'reference',
          onTap: () => onSelect('reference'),
        ),
        const SizedBox(height: AppSpace.md),
        _ImportSourceOption(
          icon: Icons.music_note_outlined,
          title: 'Riff Track',
          subtitle: 'SRT file with timed riff cues from the community',
          isSelected: selected == 'riff',
          onTap: () => onSelect('riff'),
        ),
        const SizedBox(height: AppSpace.md),
        _ImportSourceOption(
          icon: Icons.inventory_2_outlined,
          title: 'Cue Package',
          subtitle:
              'ZIP bundle with manifest, tracks, and timing data',
          isSelected: selected == 'package',
          onTap: () => onSelect('package'),
        ),
      ],
    );
  }
}

class _ImportSourceOption extends StatelessWidget {
  const _ImportSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withAlpha(30)
              : cs.surfaceContainerHighest,
          borderRadius: AppRadius.borderMd,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: isSelected
          ? Icon(Icons.check_circle, size: 22, color: cs.primary)
          : Icon(Icons.circle_outlined,
              size: 22, color: cs.outlineVariant),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: File Picker
// ─────────────────────────────────────────────────────────────────────────────

class _FilePickerStep extends StatelessWidget {
  const _FilePickerStep({
    super.key,
    required this.selectedFile,
    required this.sourceType,
    required this.onFilePicked,
  });

  final String? selectedFile;
  final String sourceType;
  final ValueChanged<String> onFilePicked;

  String _fileExtension() {
    switch (sourceType) {
      case 'package':
        return '.zip';
      default:
        return '.srt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // File drop zone / picker button.
          GestureDetector(
            onTap: () {
              // Simulate file picking.
              onFilePicked(
                'star_wars_1977_en${_fileExtension()}',
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpace.huge,
                horizontal: AppSpace.xxl,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: selectedFile != null
                      ? cs.primary.withAlpha(120)
                      : cs.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    selectedFile != null
                        ? Icons.insert_drive_file
                        : Icons.cloud_upload_outlined,
                    size: 48,
                    color: selectedFile != null
                        ? cs.primary
                        : cs.onSurfaceVariant.withAlpha(150),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  if (selectedFile != null) ...[
                    Text(
                      selectedFile!,
                      style: AppTypography.titleM.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      'Tap to choose a different file',
                      style: AppTypography.bodyM.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Tap to choose a ${_fileExtension()} file',
                      style: AppTypography.titleM.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      'Select a file from your device',
                      style: AppTypography.bodyM.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3: Validation Preview
// ─────────────────────────────────────────────────────────────────────────────

class _ValidationPreviewStep extends StatelessWidget {
  const _ValidationPreviewStep({
    super.key,
    required this.entryCount,
    required this.sampleLines,
    required this.warningCount,
  });

  final int entryCount;
  final List<String> sampleLines;
  final int warningCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: [
        // Summary row.
        Row(
          children: [
            Expanded(
              child: SciFiPanelCard(
                title: '$entryCount',
                subtitle: 'Entries found',
                leading: Icon(Icons.format_list_numbered,
                    color: cs.primary, size: 20),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: SciFiPanelCard(
                title: '$warningCount',
                subtitle: 'Warnings',
                variant: warningCount > 0
                    ? SciFiPanelCardVariant.warning
                    : SciFiPanelCardVariant.default_,
                leading: Icon(
                  warningCount > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: warningCount > 0
                      ? AppColors.amber500
                      : AppColors.lime500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xxl),

        // Sample lines.
        Text(
          'Sample entries',
          style: AppTypography.titleM.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpace.md),

        Container(
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: AppColors.graphite900,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: cs.outlineVariant.withAlpha(60),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sampleLines.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  top: entry.key > 0 ? AppSpace.sm : 0,
                ),
                child: Text(
                  entry.value,
                  style: AppTypography.monoS.copyWith(
                    color: AppColors.steel200,
                    height: 1.6,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4: Issue Resolution
// ─────────────────────────────────────────────────────────────────────────────

enum _IssueType { warning, info, error }

class _ValidationIssue {
  const _ValidationIssue({
    required this.type,
    required this.line,
    required this.message,
  });

  final _IssueType type;
  final int line;
  final String message;
}

class _IssueResolutionStep extends StatelessWidget {
  const _IssueResolutionStep({
    super.key,
    required this.issues,
    required this.onDismiss,
  });

  final List<_ValidationIssue> issues;
  final ValueChanged<int> onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.lime500),
            const SizedBox(height: AppSpace.lg),
            Text(
              'All issues resolved',
              style: AppTypography.headlineM.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Your file is ready to save.',
              style: AppTypography.bodyM.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.lg),
      itemCount: issues.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.sm),
      itemBuilder: (context, index) {
        final issue = issues[index];
        return _ValidationIssueTile(
          issue: issue,
          onDismiss: () => onDismiss(index),
        );
      },
    );
  }
}

class _ValidationIssueTile extends StatelessWidget {
  const _ValidationIssueTile({
    required this.issue,
    required this.onDismiss,
  });

  final _ValidationIssue issue;
  final VoidCallback onDismiss;

  IconData _icon() {
    switch (issue.type) {
      case _IssueType.error:
        return Icons.error_outline;
      case _IssueType.warning:
        return Icons.warning_amber_rounded;
      case _IssueType.info:
        return Icons.info_outline;
    }
  }

  Color _color() {
    switch (issue.type) {
      case _IssueType.error:
        return AppColors.red500;
      case _IssueType.warning:
        return AppColors.amber500;
      case _IssueType.info:
        return AppColors.cyan400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _color();

    return SciFiPanelCard(
      accentColor: color,
      leading: Icon(_icon(), size: 20, color: color),
      title: 'Line ${issue.line}',
      subtitle: issue.message,
      trailing: IconButton(
        icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
        onPressed: onDismiss,
        tooltip: 'Dismiss',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 5: Save Project
// ─────────────────────────────────────────────────────────────────────────────

class _SaveProjectStep extends StatelessWidget {
  const _SaveProjectStep({
    super.key,
    required this.titleController,
    required this.tagsController,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  final TextEditingController titleController;
  final TextEditingController tagsController;
  final String selectedTheme;
  final ValueChanged<String?> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: [
        Text(
          'Project title',
          style: AppTypography.labelL.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: titleController,
          style: AppTypography.bodyL.copyWith(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'e.g. Star Wars (1977)',
            hintStyle: AppTypography.bodyL.copyWith(
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.xxl),

        Text(
          'Theme',
          style: AppTypography.labelL.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpace.sm),
        DropdownButtonFormField<String>(
          value: selectedTheme,
          dropdownColor: cs.surfaceContainerHighest,
          style: AppTypography.bodyL.copyWith(color: cs.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'nebulaCommand',
              child: Text('Nebula Command'),
            ),
            DropdownMenuItem(
              value: 'cathodeArcade',
              child: Text('Cathode Arcade'),
            ),
            DropdownMenuItem(
              value: 'voidTheater',
              child: Text('Void Theater'),
            ),
          ],
          onChanged: onThemeChanged,
        ),
        const SizedBox(height: AppSpace.xxl),

        Text(
          'Tags',
          style: AppTypography.labelL.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: tagsController,
          style: AppTypography.bodyL.copyWith(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'sci-fi, classic, comedy (comma separated)',
            hintStyle: AppTypography.bodyL.copyWith(
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wizard Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _WizardNavBar extends StatelessWidget {
  const _WizardNavBar({
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

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
            SciFiSecondaryButton(
              label: currentStep == 0 ? 'Cancel' : 'Back',
              icon: currentStep == 0 ? Icons.close : Icons.arrow_back,
              onPressed: onBack,
            ),
            const Spacer(),
            SciFiPrimaryButton(
              label: nextLabel,
              icon: currentStep == totalSteps - 1
                  ? Icons.save_outlined
                  : Icons.arrow_forward,
              onPressed: canProceed ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
