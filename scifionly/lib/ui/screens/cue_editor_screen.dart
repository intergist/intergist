import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scifionly/models/cue_event_model.dart';
import 'package:scifionly/ui/components/scifi_primary_button.dart';
import 'package:scifionly/ui/components/scifi_section_header.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';

/// Cue editor screen for creating or editing a single cue event.
///
/// Provides form fields for cue text, start/end time, mode dropdown,
/// priority slider, tags, and a save action.
class CueEditorScreen extends ConsumerStatefulWidget {
  const CueEditorScreen({super.key, this.cueId});

  /// If null, creates a new cue. Otherwise edits the existing one.
  final String? cueId;

  @override
  ConsumerState<CueEditorScreen> createState() => _CueEditorScreenState();
}

class _CueEditorScreenState extends ConsumerState<CueEditorScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _startMsController = TextEditingController();
  final TextEditingController _endMsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  CueMode _selectedMode = CueMode.displayOnly;
  double _priority = 5;
  bool _isSaving = false;

  bool get _isEditing => widget.cueId != null;

  @override
  void dispose() {
    _textController.dispose();
    _startMsController.dispose();
    _endMsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _textController.text.trim().isNotEmpty &&
      _startMsController.text.trim().isNotEmpty &&
      _endMsController.text.trim().isNotEmpty;



  Future<void> _save() async {
    if (!_isValid) return;
    setState(() => _isSaving = true);

    // In production this would persist via a repository.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Cue' : 'New Cue',
          style: AppTypography.titleL.copyWith(color: cs.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: SciFiPrimaryButton(
              label: 'Save',
              icon: Icons.check,
              isLoading: _isSaving,
              onPressed: _isValid ? _save : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cue text ─────────────────────────────────────────────
            const SciFiSectionHeader(title: 'Cue Text'),
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _textController,
              maxLines: 4,
              style: AppTypography.bodyL.copyWith(color: cs.onSurface),
              decoration: _inputDecoration(
                cs,
                hintText:
                    'Enter the riff text that will be displayed or spoken...',
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Timing ───────────────────────────────────────────────
            const SciFiSectionHeader(title: 'Timing'),
            const SizedBox(height: AppSpace.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start time',
                        style: AppTypography.labelM.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      TextField(
                        controller: _startMsController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.monoM.copyWith(
                          color: cs.onSurface,
                        ),
                        decoration: _inputDecoration(
                          cs,
                          hintText: '0',
                          suffixText: 'ms',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End time',
                        style: AppTypography.labelM.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      TextField(
                        controller: _endMsController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.monoM.copyWith(
                          color: cs.onSurface,
                        ),
                        decoration: _inputDecoration(
                          cs,
                          hintText: '5000',
                          suffixText: 'ms',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Mode ─────────────────────────────────────────────────
            const SciFiSectionHeader(title: 'Delivery Mode'),
            const SizedBox(height: AppSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: cs.outlineVariant,
                  width: 1,
                ),
              ),
              child: DropdownButton<CueMode>(
                value: _selectedMode,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: cs.surfaceContainerHighest,
                style: AppTypography.bodyL.copyWith(color: cs.onSurface),
                items: const [
                  DropdownMenuItem(
                    value: CueMode.displayOnly,
                    child: Text('Display Only'),
                  ),
                  DropdownMenuItem(
                    value: CueMode.speak,
                    child: Text('Speak'),
                  ),
                  DropdownMenuItem(
                    value: CueMode.displayAndSpeak,
                    child: Text('Display + Speak'),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) setState(() => _selectedMode = mode);
                },
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Priority ─────────────────────────────────────────────
            const SciFiSectionHeader(title: 'Priority'),
            const SizedBox(height: AppSpace.sm),
            Row(
              children: [
                Text(
                  'Low',
                  style: AppTypography.labelM.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _priority,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _priority.round().toString(),
                    activeColor: cs.primary,
                    inactiveColor: cs.outlineVariant,
                    onChanged: (v) => setState(() => _priority = v),
                  ),
                ),
                Text(
                  'High',
                  style: AppTypography.labelM.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Priority: ${_priority.round()}',
                style: AppTypography.monoM.copyWith(
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Tags ─────────────────────────────────────────────────
            const SciFiSectionHeader(title: 'Tags'),
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _tagsController,
              style: AppTypography.bodyL.copyWith(color: cs.onSurface),
              decoration: _inputDecoration(
                cs,
                hintText: 'funny, callback, running-gag (comma-separated)',
              ),
            ),
            const SizedBox(height: AppSpace.xxl),

            // ── Bottom save button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: SciFiPrimaryButton(
                label: _isEditing ? 'Update Cue' : 'Create Cue',
                icon: Icons.save_outlined,
                size: SciFiButtonSize.large,
                isLoading: _isSaving,
                onPressed: _isValid ? _save : null,
              ),
            ),
            const SizedBox(height: AppSpace.massive),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme cs, {
    String? hintText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: AppTypography.bodyL.copyWith(
        color: cs.onSurfaceVariant.withAlpha(120),
      ),
      suffixStyle: AppTypography.monoM.copyWith(
        color: cs.onSurfaceVariant,
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
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}
