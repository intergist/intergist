/// Utilities for working with SubRip (`.srt`) timestamp and index formats.
library;

/// Parses an SRT timestamp string into total milliseconds.
///
/// The expected format is `HH:MM:SS,mmm` (e.g. `01:23:45,678`).
/// Returns the total elapsed time in milliseconds.
///
/// Throws [FormatException] if the string does not match the expected format.
int parseTimestamp(String timestamp) {
  final trimmed = timestamp.trim();
  final match = _timestampRegex.firstMatch(trimmed);
  if (match == null) {
    throw FormatException('Invalid SRT timestamp: "$timestamp"');
  }

  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  final seconds = int.parse(match.group(3)!);
  final millis = int.parse(match.group(4)!);

  return ((hours * 3600) + (minutes * 60) + seconds) * 1000 + millis;
}

/// Formats a millisecond value as an SRT timestamp (`HH:MM:SS,mmm`).
///
/// [ms] must be non-negative.
String formatTimestamp(int ms) {
  assert(ms >= 0, 'Milliseconds must be non-negative');

  final totalSeconds = ms ~/ 1000;
  final millis = ms % 1000;

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  return '${_pad2(hours)}:${_pad2(minutes)}:${_pad2(seconds)},${_pad3(millis)}';
}

/// Returns `true` when [timestamp] matches the SRT timestamp pattern
/// `HH:MM:SS,mmm`.
bool isValidTimestamp(String timestamp) {
  return _timestampRegex.hasMatch(timestamp.trim());
}

/// Attempts to parse an SRT cue index line.
///
/// Returns the integer index, or `null` if [line] is not a valid index.
int? parseSrtIndex(String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Matches `HH:MM:SS,mmm` where each group is strictly numeric.
final RegExp _timestampRegex = RegExp(
  r'^(\d{2}):(\d{2}):(\d{2}),(\d{3})$',
);

String _pad2(int value) => value.toString().padLeft(2, '0');
String _pad3(int value) => value.toString().padLeft(3, '0');
