/// Result models for export operations.
///
/// Encapsulates the output of SRT export, riff pack export, or full
/// package export operations. Exactly one of [content], [bytes], or
/// [filePath] will be populated on success.
library;

/// Status of an export operation.
enum ExportStatus {
  /// Export completed successfully.
  success,

  /// Export completed with warnings.
  successWithWarnings,

  /// Export failed.
  failed,
}

/// Represents the outcome of an export operation.
class ExportResult {
  /// Whether the export completed successfully.
  final bool success;

  /// Path to the exported file on disk, if applicable.
  final String? filePath;

  /// String content of the export (e.g., SRT text).
  final String? content;

  /// Binary content of the export (e.g., ZIP bytes).
  final List<int>? bytes;

  /// Human-readable error message when [success] is `false`.
  final String? errorMessage;

  /// List of error messages.
  final List<String> errors;

  /// List of warning messages.
  final List<String> warnings;

  /// List of filenames included in the export.
  final List<String> includedFiles;

  /// Number of cues exported.
  final int cueCount;

  /// Number of tracks exported.
  final int trackCount;

  /// Overall status.
  final ExportStatus status;

  const ExportResult({
    required this.success,
    this.filePath,
    this.content,
    this.bytes,
    this.errorMessage,
    this.errors = const [],
    this.warnings = const [],
    this.includedFiles = const [],
    this.cueCount = 0,
    this.trackCount = 0,
    this.status = ExportStatus.success,
  });

  /// Creates a successful result containing SRT string content.
  factory ExportResult.srtContent({
    required String content,
    int cueCount = 0,
    List<String> includedFiles = const [],
  }) {
    return ExportResult(
      success: true,
      content: content,
      cueCount: cueCount,
      trackCount: 1,
      includedFiles: includedFiles,
      status: ExportStatus.success,
    );
  }

  /// Creates a successful result containing binary (ZIP) data.
  factory ExportResult.zipBytes({
    required List<int> bytes,
    int cueCount = 0,
    int trackCount = 0,
    List<String> includedFiles = const [],
    List<String> warnings = const [],
  }) {
    return ExportResult(
      success: true,
      bytes: bytes,
      cueCount: cueCount,
      trackCount: trackCount,
      includedFiles: includedFiles,
      warnings: warnings,
      status: warnings.isEmpty
          ? ExportStatus.success
          : ExportStatus.successWithWarnings,
    );
  }

  /// Creates a failed result with an error message.
  factory ExportResult.failure(String errorMessage) {
    return ExportResult(
      success: false,
      errorMessage: errorMessage,
      errors: [errorMessage],
      status: ExportStatus.failed,
    );
  }

  /// Whether the export was successful (possibly with warnings).
  bool get isSuccess =>
      status == ExportStatus.success ||
      status == ExportStatus.successWithWarnings;

  /// Whether the export failed.
  bool get isFailed => status == ExportStatus.failed;

  @override
  String toString() {
    if (success) {
      final type = content != null
          ? 'SRT'
          : bytes != null
              ? 'ZIP(${bytes!.length} bytes)'
              : 'file';
      return 'ExportResult(success, $type, cues: $cueCount, '
          'files: $includedFiles)';
    }
    return 'ExportResult(failed: $errorMessage)';
  }
}
