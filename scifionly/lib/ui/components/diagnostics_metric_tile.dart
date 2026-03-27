import 'package:flutter/material.dart';

import 'package:scifionly/ui/tokens/radius_tokens.dart';
import 'package:scifionly/ui/tokens/spacing_tokens.dart';
import 'package:scifionly/ui/tokens/typography_tokens.dart';
import 'package:scifionly/ui/theme/scifionly_semantic_colors.dart';

/// Health state for a diagnostics metric.
enum DiagnosticsState { good, neutral, bad }

/// Trend direction for a diagnostics metric.
enum DiagnosticsTrend { up, down, stable }

/// A compact tile displaying a single diagnostic metric with its label,
/// value, health state, and trend indicator.
///
/// Uses [AppTypography.labelM] for the label and [AppTypography.monoM]
/// for the value.
class DiagnosticsMetricTile extends StatelessWidget {
  const DiagnosticsMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.state = DiagnosticsState.neutral,
    this.trend = DiagnosticsTrend.stable,
  });

  /// Metric label.
  final String label;

  /// Metric value text (e.g. "98.2%", "42ms").
  final String value;

  /// Health state controlling the value color.
  final DiagnosticsState state;

  /// Trend direction shown as an arrow icon.
  final DiagnosticsTrend trend;

  Color _stateColor(SciFiSemanticColors sem) {
    switch (state) {
      case DiagnosticsState.good:
        return sem.diagnosticsGood;
      case DiagnosticsState.neutral:
        return sem.diagnosticsNeutral;
      case DiagnosticsState.bad:
        return sem.diagnosticsBad;
    }
  }

  IconData get _trendIcon {
    switch (trend) {
      case DiagnosticsTrend.up:
        return Icons.trending_up;
      case DiagnosticsTrend.down:
        return Icons.trending_down;
      case DiagnosticsTrend.stable:
        return Icons.trending_flat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sem = Theme.of(context).extension<SciFiSemanticColors>()!;
    final valueColor = _stateColor(sem);

    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: cs.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelM.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.monoM.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Icon(
                  _trendIcon,
                  size: 16,
                  color: valueColor.withAlpha(180),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
