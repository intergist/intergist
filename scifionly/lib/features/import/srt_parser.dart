/// Full SRT parser with riff-track tag support.
///
/// Parses standard SubRip (.srt) files and extracts custom riff-track tags
/// such as `[APP]`, `[USER]`, `[SPEAK]`, `[DISPLAY]`, `[MUTE_IN_RECORDING]`,
/// `[PRIORITY=NN]`, and `[WINDOW=id]`.
library;

import 'package:scifionly/features/import/models/import_result.dart';
import 'package:scifionly/utils/logger.dart';

/// Tag constants used internally by the parser.
const String _tagApp = '[APP]';
const String _tagUser = '[USER]';
const String _tagSpeak = '[SPEAK]';
const String _tagDisplay = '[DISPLAY]';
const String _tagMuteInRecording = '[MUTE_IN_RECORDING]';

/// Regular expressions compiled once and reused.
final RegExp _timecodeLineRegex = RegExp(
  r'^(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*$',
);
final RegExp _priorityTagRegex = RegExp(r'\[PRIORITY=(\d+)\]');
final RegExp _windowTagRegex = RegExp(r'\[WINDOW=([^\]]+)\]');
final RegExp _allTagsRegex = RegExp(
  r'\[(APP|USER|SPEAK|DISPLAY|MUTE_IN_RECORDING|PRIORITY=\d+|WINDOW=[^\]]+)\]',
);

const String _tag = 'SRT_PARSER';

/// Parses SRT content and returns structured results.
class SrtParser {
  const SrtParser();

  /// Parse an SRT string into [SrtParseResult].
  ///
  /// The [source] label is used for logging and diagnostics only.
  SrtParseResult parse(String content, {String source = 'unknown'}) {
    AppLogger.info(_tag, 'Starting SRT parse from source: $source');

    final List<SrtEntry> entries = [];
    final List<SrtValidationIssue> issues = [];

    // Validate encoding – check for replacement character.
    if (content.contains('\uFFFD')) {
      issues.add(const SrtValidationIssue(
        severity: SrtIssueSeverity.warning,
        message: 'Content contains Unicode replacement characters '
            '(\uFFFD). The file may have encoding issues.',
      ));
      AppLogger.warn(_tag, 'Detected encoding issues in source: $source');
    }

    // Normalise line endings.
    final normalised = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Strip BOM if present.
    final stripped = normalised.startsWith('\uFEFF')
        ? normalised.substring(1)
        : normalised;

    // Split into blocks (separated by blank lines).
    final blocks = _splitBlocks(stripped);

    if (blocks.isEmpty) {
      issues.add(const SrtValidationIssue(
        severity: SrtIssueSeverity.error,
        message: 'SRT content is empty or contains no valid blocks.',
      ));
      AppLogger.error(_tag, 'Empty SRT content from source: $source');
      return SrtParseResult(entries: entries, issues: issues);
    }

    int previousEndMs = -1;

    for (final block in blocks) {
      final result = _parseBlock(block, issues);
      if (result == null) continue;

      // Validate monotonic timecodes.
      if (entries.isNotEmpty && result.startMs < previousEndMs) {
        issues.add(SrtValidationIssue(
          severity: SrtIssueSeverity.warning,
          message:
              'Cue ${result.index} overlaps with previous cue '
              '(starts at ${result.startMs}ms but previous ends at '
              '${previousEndMs}ms).',
          lineNumber: block.startLine,
        ));
        AppLogger.warn(
          _tag,
          'Overlapping cue at index ${result.index}',
        );
      }

      if (entries.isNotEmpty && result.startMs < entries.last.startMs) {
        issues.add(SrtValidationIssue(
          severity: SrtIssueSeverity.warning,
          message:
              'Cue ${result.index} starts before the previous cue '
              '(non-monotonic timecodes).',
          lineNumber: block.startLine,
        ));
        AppLogger.warn(
          _tag,
          'Non-monotonic timecodes at index ${result.index}',
        );
      }

      previousEndMs = result.endMs;
      entries.add(result);
    }

    AppLogger.info(
      _tag,
      'Parsed ${entries.length} entries with ${issues.length} issues '
      'from source: $source',
    );

    return SrtParseResult(entries: entries, issues: issues);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Splits normalised SRT content into raw blocks with line tracking.
  List<_RawBlock> _splitBlocks(String content) {
    final lines = content.split('\n');
    final List<_RawBlock> blocks = [];

    List<String> currentLines = [];
    int blockStartLine = 1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        if (currentLines.isNotEmpty) {
          blocks.add(_RawBlock(currentLines, blockStartLine));
          currentLines = [];
        }
        blockStartLine = i + 2; // next non-empty line (1-indexed)
      } else {
        if (currentLines.isEmpty) {
          blockStartLine = i + 1;
        }
        currentLines.add(lines[i]);
      }
    }

    // Handle last block without trailing newline.
    if (currentLines.isNotEmpty) {
      blocks.add(_RawBlock(currentLines, blockStartLine));
    }

    return blocks;
  }

  /// Parse a single SRT block into an [SrtEntry] or null if invalid.
  SrtEntry? _parseBlock(
    _RawBlock block,
    List<SrtValidationIssue> issues,
  ) {
    final lines = block.lines;

    if (lines.length < 2) {
      issues.add(SrtValidationIssue(
        severity: SrtIssueSeverity.warning,
        message: 'Block starting at line ${block.startLine} has too few lines.',
        lineNumber: block.startLine,
      ));
      return null;
    }

    // Line 1: index
    final indexStr = lines[0].trim();
    final index = int.tryParse(indexStr);
    if (index == null) {
      issues.add(SrtValidationIssue(
        severity: SrtIssueSeverity.error,
        message:
            'Expected a numeric index but found "$indexStr" at line '
            '${block.startLine}.',
        lineNumber: block.startLine,
      ));
      return null;
    }

    // Line 2: timecodes
    final timecodeStr = lines[1].trim();
    final match = _timecodeLineRegex.firstMatch(timecodeStr);
    if (match == null) {
      issues.add(SrtValidationIssue(
        severity: SrtIssueSeverity.error,
        message:
            'Malformed timecode line "$timecodeStr" at line '
            '${block.startLine + 1}.',
        lineNumber: block.startLine + 1,
      ));
      return null;
    }

    final startMs = _timecodeToMs(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
    );

    final endMs = _timecodeToMs(
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
      int.parse(match.group(7)!),
      int.parse(match.group(8)!),
    );

    if (endMs <= startMs) {
      issues.add(SrtValidationIssue(
        severity: SrtIssueSeverity.error,
        message:
            'Cue $index has end time ($endMs ms) <= start time ($startMs ms).',
        lineNumber: block.startLine + 1,
      ));
      return null;
    }

    // Lines 3+: text (may be multiline).
    final rawTextLines = lines.sublist(2);
    if (rawTextLines.isEmpty) {
      issues.add(SrtValidationIssue(
        severity: SrtIssueSeverity.warning,
        message: 'Cue $index has no text content.',
        lineNumber: block.startLine + 2,
      ));
    }
    final rawText = rawTextLines.join('\n').trim();

    // Parse tags.
    final tags = _parseTags(rawText);

    // Strip tags to produce rendered text.
    final text = _stripTags(rawText).trim();

    return SrtEntry(
      index: index,
      startMs: startMs,
      endMs: endMs,
      text: text,
      rawText: rawText,
      tags: tags,
    );
  }

  /// Convert timecode components to milliseconds.
  int _timecodeToMs(int hours, int minutes, int seconds, int millis) {
    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + millis;
  }

  /// Parse riff-track tags from raw text.
  SrtTags _parseTags(String rawText) {
    final upper = rawText.toUpperCase();

    bool isApp = upper.contains(_tagApp);
    bool isUser = upper.contains(_tagUser);
    bool isSpeak = upper.contains(_tagSpeak);
    bool isDisplay = upper.contains(_tagDisplay);
    bool isMuteInRecording = upper.contains(_tagMuteInRecording);

    int? priority;
    final priorityMatch = _priorityTagRegex.firstMatch(rawText);
    if (priorityMatch != null) {
      priority = int.tryParse(priorityMatch.group(1)!);
    }

    String? windowRef;
    final windowMatch = _windowTagRegex.firstMatch(rawText);
    if (windowMatch != null) {
      windowRef = windowMatch.group(1);
    }

    return SrtTags(
      isApp: isApp,
      isUser: isUser,
      isSpeak: isSpeak,
      isDisplay: isDisplay,
      isMuteInRecording: isMuteInRecording,
      priority: priority,
      windowRef: windowRef,
    );
  }

  /// Strip all recognised riff-track tags from text.
  String _stripTags(String rawText) {
    return rawText
        .replaceAll(_allTagsRegex, '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}

/// Internal helper that tracks a block of SRT lines and their start position.
class _RawBlock {
  final List<String> lines;
  final int startLine;

  const _RawBlock(this.lines, this.startLine);
}
