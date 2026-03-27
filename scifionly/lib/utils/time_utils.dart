/// General-purpose time formatting and conversion helpers.
library;

/// Formats a [Duration] as `H:MM:SS` (e.g. `1:23:45`).
///
/// Hours are omitted when zero, giving `M:SS` instead.
String formatDuration(Duration duration) {
  final total = duration.inSeconds.abs();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;

  if (hours > 0) {
    return '$hours:${_pad2(minutes)}:${_pad2(seconds)}';
  }
  return '$minutes:${_pad2(seconds)}';
}

/// Formats a countdown value (in seconds) as a compact decimal string.
///
/// Whole seconds render without a decimal (e.g. `3`).
/// Fractional seconds include one decimal place (e.g. `3.5`).
String formatCountdown(int seconds) {
  // The input is already an integer, so it's always whole.
  return seconds.toString();
}

/// Converts milliseconds to fractional seconds.
double msToSeconds(int ms) => ms / 1000.0;

/// Converts fractional seconds to the nearest millisecond value.
int secondsToMs(double seconds) => (seconds * 1000).round();

/// Formats a [Duration] as zero-padded elapsed time `HH:MM:SS`
/// (e.g. `01:23:45`).
///
/// Unlike [formatDuration], hours are always shown and zero-padded to two
/// digits.
String formatElapsedTime(Duration duration) {
  final total = duration.inSeconds.abs();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;

  return '${_pad2(hours)}:${_pad2(minutes)}:${_pad2(seconds)}';
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

String _pad2(int value) => value.toString().padLeft(2, '0');
