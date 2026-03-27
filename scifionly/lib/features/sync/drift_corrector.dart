/// Drift correction for the sync engine.
///
/// Applies small corrections when drift is within tolerance, and signals
/// reacquisition when drift exceeds tolerance.
library;

import 'package:scifionly/utils/logger.dart';

const String _tag = 'SYNC';

/// Corrects small drift values and detects large drift that requires
/// reacquisition.
class DriftCorrector {
  /// Maximum drift (ms) that can be corrected without reacquisition.
  final int driftToleranceMs;

  /// Fraction of drift to correct per tick (0.0–1.0).
  /// Smaller values = smoother but slower correction.
  final double correctionFactor;

  /// History of recent drift measurements for smoothing.
  final List<int> _driftHistory = [];

  /// Maximum history length for moving average.
  final int _maxHistoryLength;

  DriftCorrector({
    this.driftToleranceMs = 400,
    this.correctionFactor = 0.3,
    int maxHistoryLength = 10,
  }) : _maxHistoryLength = maxHistoryLength;

  /// Apply drift correction.
  ///
  /// If the drift is within [driftToleranceMs], returns a smoothed
  /// correction value. If drift exceeds tolerance, returns the raw drift
  /// unchanged (caller should trigger reacquisition).
  int correct(int rawDriftMs) {
    // Add to history for smoothing.
    _driftHistory.add(rawDriftMs);
    if (_driftHistory.length > _maxHistoryLength) {
      _driftHistory.removeAt(0);
    }

    final absDrift = rawDriftMs.abs();

    // Large drift: return as-is, caller should reacquire.
    if (absDrift > driftToleranceMs) {
      AppLogger.warn(
        _tag,
        'Large drift detected: ${rawDriftMs}ms '
        '(tolerance: ${driftToleranceMs}ms)',
      );
      return rawDriftMs;
    }

    // Small drift: apply partial correction.
    final smoothed = _smoothedDrift();
    final correction = (smoothed * correctionFactor).round();

    AppLogger.debug(
      _tag,
      'Drift correction: raw=${rawDriftMs}ms, smoothed=${smoothed}ms, '
      'correction=${correction}ms',
    );

    return correction;
  }

  /// Whether the given drift (after correction) should trigger reacquisition.
  bool shouldReacquire(int correctedDriftMs) {
    return correctedDriftMs.abs() > driftToleranceMs;
  }

  /// Reset drift history.
  void reset() {
    _driftHistory.clear();
    AppLogger.debug(_tag, 'Drift history cleared');
  }

  /// Current smoothed drift (moving average).
  int get smoothedDrift => _smoothedDrift();

  /// Number of drift samples in history.
  int get historyLength => _driftHistory.length;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  int _smoothedDrift() {
    if (_driftHistory.isEmpty) return 0;

    final sum = _driftHistory.fold<int>(0, (a, b) => a + b);
    return (sum / _driftHistory.length).round();
  }
}
