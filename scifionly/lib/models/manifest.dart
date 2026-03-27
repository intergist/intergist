import 'dart:convert';

// ---------------------------------------------------------------------------
// ManifestTrackRef
// ---------------------------------------------------------------------------

class ManifestTrackRef {
  final String file;
  final String type;
  final String language;
  final String? hashSha256;
  final bool? optional;

  const ManifestTrackRef({
    required this.file,
    required this.type,
    required this.language,
    this.hashSha256,
    this.optional,
  });

  ManifestTrackRef copyWith({
    String? file,
    String? type,
    String? language,
    String? hashSha256,
    bool? optional,
  }) {
    return ManifestTrackRef(
      file: file ?? this.file,
      type: type ?? this.type,
      language: language ?? this.language,
      hashSha256: hashSha256 ?? this.hashSha256,
      optional: optional ?? this.optional,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'file': file,
      'type': type,
      'language': language,
    };
    if (hashSha256 != null) map['hashSha256'] = hashSha256;
    if (optional != null) map['optional'] = optional;
    return map;
  }

  factory ManifestTrackRef.fromJson(Map<String, dynamic> json) {
    return ManifestTrackRef(
      file: json['file'] as String,
      type: json['type'] as String,
      language: json['language'] as String,
      hashSha256: json['hashSha256'] as String?,
      optional: json['optional'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManifestTrackRef &&
        other.file == file &&
        other.type == type &&
        other.language == language &&
        other.hashSha256 == hashSha256 &&
        other.optional == optional;
  }

  @override
  int get hashCode => Object.hash(file, type, language, hashSha256, optional);

  @override
  String toString() {
    return 'ManifestTrackRef(file: $file, type: $type, language: $language, '
        'hashSha256: $hashSha256, optional: $optional)';
  }
}

// ---------------------------------------------------------------------------
// ManifestTiming
// ---------------------------------------------------------------------------

class ManifestTiming {
  final int warningLeadInMs;
  final int minParticipationWindowMs;
  final int maxUserRiffMs;
  final int? cueAccuracyTargetMs;
  final int? reacquireTargetMs;

  const ManifestTiming({
    required this.warningLeadInMs,
    required this.minParticipationWindowMs,
    required this.maxUserRiffMs,
    this.cueAccuracyTargetMs,
    this.reacquireTargetMs,
  });

  ManifestTiming copyWith({
    int? warningLeadInMs,
    int? minParticipationWindowMs,
    int? maxUserRiffMs,
    int? cueAccuracyTargetMs,
    int? reacquireTargetMs,
  }) {
    return ManifestTiming(
      warningLeadInMs: warningLeadInMs ?? this.warningLeadInMs,
      minParticipationWindowMs:
          minParticipationWindowMs ?? this.minParticipationWindowMs,
      maxUserRiffMs: maxUserRiffMs ?? this.maxUserRiffMs,
      cueAccuracyTargetMs: cueAccuracyTargetMs ?? this.cueAccuracyTargetMs,
      reacquireTargetMs: reacquireTargetMs ?? this.reacquireTargetMs,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'warningLeadInMs': warningLeadInMs,
      'minParticipationWindowMs': minParticipationWindowMs,
      'maxUserRiffMs': maxUserRiffMs,
    };
    if (cueAccuracyTargetMs != null) {
      map['cueAccuracyTargetMs'] = cueAccuracyTargetMs;
    }
    if (reacquireTargetMs != null) {
      map['reacquireTargetMs'] = reacquireTargetMs;
    }
    return map;
  }

  factory ManifestTiming.fromJson(Map<String, dynamic> json) {
    return ManifestTiming(
      warningLeadInMs: json['warningLeadInMs'] as int,
      minParticipationWindowMs: json['minParticipationWindowMs'] as int,
      maxUserRiffMs: json['maxUserRiffMs'] as int,
      cueAccuracyTargetMs: json['cueAccuracyTargetMs'] as int?,
      reacquireTargetMs: json['reacquireTargetMs'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManifestTiming &&
        other.warningLeadInMs == warningLeadInMs &&
        other.minParticipationWindowMs == minParticipationWindowMs &&
        other.maxUserRiffMs == maxUserRiffMs &&
        other.cueAccuracyTargetMs == cueAccuracyTargetMs &&
        other.reacquireTargetMs == reacquireTargetMs;
  }

  @override
  int get hashCode => Object.hash(
        warningLeadInMs,
        minParticipationWindowMs,
        maxUserRiffMs,
        cueAccuracyTargetMs,
        reacquireTargetMs,
      );

  @override
  String toString() {
    return 'ManifestTiming(warningLeadInMs: $warningLeadInMs, '
        'minParticipationWindowMs: $minParticipationWindowMs, '
        'maxUserRiffMs: $maxUserRiffMs, '
        'cueAccuracyTargetMs: $cueAccuracyTargetMs, '
        'reacquireTargetMs: $reacquireTargetMs)';
  }
}

// ---------------------------------------------------------------------------
// ManifestSync
// ---------------------------------------------------------------------------

class ManifestSync {
  final String anchorStrategy;
  final int driftToleranceMs;
  final double lockConfidenceThreshold;
  final int? candidateWindowMs;
  final List<Map<String, dynamic>>? precomputedAnchors;

  const ManifestSync({
    required this.anchorStrategy,
    required this.driftToleranceMs,
    required this.lockConfidenceThreshold,
    this.candidateWindowMs,
    this.precomputedAnchors,
  });

  ManifestSync copyWith({
    String? anchorStrategy,
    int? driftToleranceMs,
    double? lockConfidenceThreshold,
    int? candidateWindowMs,
    List<Map<String, dynamic>>? precomputedAnchors,
  }) {
    return ManifestSync(
      anchorStrategy: anchorStrategy ?? this.anchorStrategy,
      driftToleranceMs: driftToleranceMs ?? this.driftToleranceMs,
      lockConfidenceThreshold:
          lockConfidenceThreshold ?? this.lockConfidenceThreshold,
      candidateWindowMs: candidateWindowMs ?? this.candidateWindowMs,
      precomputedAnchors: precomputedAnchors ?? this.precomputedAnchors,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'anchorStrategy': anchorStrategy,
      'driftToleranceMs': driftToleranceMs,
      'lockConfidenceThreshold': lockConfidenceThreshold,
    };
    if (candidateWindowMs != null) {
      map['candidateWindowMs'] = candidateWindowMs;
    }
    if (precomputedAnchors != null) {
      map['precomputedAnchors'] = precomputedAnchors;
    }
    return map;
  }

  factory ManifestSync.fromJson(Map<String, dynamic> json) {
    final rawAnchors = json['precomputedAnchors'];
    List<Map<String, dynamic>>? anchors;
    if (rawAnchors is List) {
      anchors = rawAnchors
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    return ManifestSync(
      anchorStrategy: json['anchorStrategy'] as String,
      driftToleranceMs: json['driftToleranceMs'] as int,
      lockConfidenceThreshold:
          (json['lockConfidenceThreshold'] as num).toDouble(),
      candidateWindowMs: json['candidateWindowMs'] as int?,
      precomputedAnchors: anchors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ManifestSync) return false;
    if (other.anchorStrategy != anchorStrategy ||
        other.driftToleranceMs != driftToleranceMs ||
        other.lockConfidenceThreshold != lockConfidenceThreshold ||
        other.candidateWindowMs != candidateWindowMs) {
      return false;
    }
    if (other.precomputedAnchors == null && precomputedAnchors == null) {
      return true;
    }
    if (other.precomputedAnchors == null || precomputedAnchors == null) {
      return false;
    }
    if (other.precomputedAnchors!.length != precomputedAnchors!.length) {
      return false;
    }
    // Deep comparison of anchor lists would require custom logic;
    // for practical purposes we compare their JSON representations.
    return jsonEncode(other.precomputedAnchors) ==
        jsonEncode(precomputedAnchors);
  }

  @override
  int get hashCode => Object.hash(
        anchorStrategy,
        driftToleranceMs,
        lockConfidenceThreshold,
        candidateWindowMs,
        precomputedAnchors != null
            ? jsonEncode(precomputedAnchors).hashCode
            : null,
      );

  @override
  String toString() {
    return 'ManifestSync(anchorStrategy: $anchorStrategy, '
        'driftToleranceMs: $driftToleranceMs, '
        'lockConfidenceThreshold: $lockConfidenceThreshold, '
        'candidateWindowMs: $candidateWindowMs, '
        'precomputedAnchors: $precomputedAnchors)';
  }
}

// ---------------------------------------------------------------------------
// ManifestDisplay
// ---------------------------------------------------------------------------

class ManifestDisplay {
  final String? theme;
  final double? fontScale;
  final String? countdownStyle;

  const ManifestDisplay({
    this.theme,
    this.fontScale,
    this.countdownStyle,
  });

  ManifestDisplay copyWith({
    String? theme,
    double? fontScale,
    String? countdownStyle,
  }) {
    return ManifestDisplay(
      theme: theme ?? this.theme,
      fontScale: fontScale ?? this.fontScale,
      countdownStyle: countdownStyle ?? this.countdownStyle,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (theme != null) map['theme'] = theme;
    if (fontScale != null) map['fontScale'] = fontScale;
    if (countdownStyle != null) map['countdownStyle'] = countdownStyle;
    return map;
  }

  factory ManifestDisplay.fromJson(Map<String, dynamic> json) {
    return ManifestDisplay(
      theme: json['theme'] as String?,
      fontScale: (json['fontScale'] as num?)?.toDouble(),
      countdownStyle: json['countdownStyle'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManifestDisplay &&
        other.theme == theme &&
        other.fontScale == fontScale &&
        other.countdownStyle == countdownStyle;
  }

  @override
  int get hashCode => Object.hash(theme, fontScale, countdownStyle);

  @override
  String toString() {
    return 'ManifestDisplay(theme: $theme, fontScale: $fontScale, '
        'countdownStyle: $countdownStyle)';
  }
}

// ---------------------------------------------------------------------------
// ManifestCueDefaults
// ---------------------------------------------------------------------------

class ManifestCueDefaults {
  final String? channel;
  final int? priority;
  final String? mode;

  const ManifestCueDefaults({
    this.channel,
    this.priority,
    this.mode,
  });

  ManifestCueDefaults copyWith({
    String? channel,
    int? priority,
    String? mode,
  }) {
    return ManifestCueDefaults(
      channel: channel ?? this.channel,
      priority: priority ?? this.priority,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (channel != null) map['channel'] = channel;
    if (priority != null) map['priority'] = priority;
    if (mode != null) map['mode'] = mode;
    return map;
  }

  factory ManifestCueDefaults.fromJson(Map<String, dynamic> json) {
    return ManifestCueDefaults(
      channel: json['channel'] as String?,
      priority: json['priority'] as int?,
      mode: json['mode'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManifestCueDefaults &&
        other.channel == channel &&
        other.priority == priority &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(channel, priority, mode);

  @override
  String toString() {
    return 'ManifestCueDefaults(channel: $channel, priority: $priority, '
        'mode: $mode)';
  }
}

// ---------------------------------------------------------------------------
// ManifestAuthoring
// ---------------------------------------------------------------------------

class ManifestAuthoring {
  final String? creator;
  final String? createdAt;
  final String? license;
  final String? notes;

  const ManifestAuthoring({
    this.creator,
    this.createdAt,
    this.license,
    this.notes,
  });

  ManifestAuthoring copyWith({
    String? creator,
    String? createdAt,
    String? license,
    String? notes,
  }) {
    return ManifestAuthoring(
      creator: creator ?? this.creator,
      createdAt: createdAt ?? this.createdAt,
      license: license ?? this.license,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (creator != null) map['creator'] = creator;
    if (createdAt != null) map['createdAt'] = createdAt;
    if (license != null) map['license'] = license;
    if (notes != null) map['notes'] = notes;
    return map;
  }

  factory ManifestAuthoring.fromJson(Map<String, dynamic> json) {
    return ManifestAuthoring(
      creator: json['creator'] as String?,
      createdAt: json['createdAt'] as String?,
      license: json['license'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManifestAuthoring &&
        other.creator == creator &&
        other.createdAt == createdAt &&
        other.license == license &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(creator, createdAt, license, notes);

  @override
  String toString() {
    return 'ManifestAuthoring(creator: $creator, createdAt: $createdAt, '
        'license: $license, notes: $notes)';
  }
}

// ---------------------------------------------------------------------------
// Manifest
// ---------------------------------------------------------------------------

class Manifest {
  final String schemaVersion;
  final String packageId;
  final String title;
  final int? releaseYear;
  final String locale;
  final ManifestTrackRef referenceTrack;
  final ManifestTrackRef? riffTrack;
  final ManifestTrackRef? userTrack;
  final ManifestTiming timing;
  final ManifestSync sync;
  final ManifestDisplay? display;
  final ManifestCueDefaults? cueDefaults;
  final ManifestAuthoring? authoring;

  const Manifest({
    required this.schemaVersion,
    required this.packageId,
    required this.title,
    this.releaseYear,
    required this.locale,
    required this.referenceTrack,
    this.riffTrack,
    this.userTrack,
    required this.timing,
    required this.sync,
    this.display,
    this.cueDefaults,
    this.authoring,
  });

  Manifest copyWith({
    String? schemaVersion,
    String? packageId,
    String? title,
    int? releaseYear,
    String? locale,
    ManifestTrackRef? referenceTrack,
    ManifestTrackRef? riffTrack,
    ManifestTrackRef? userTrack,
    ManifestTiming? timing,
    ManifestSync? sync,
    ManifestDisplay? display,
    ManifestCueDefaults? cueDefaults,
    ManifestAuthoring? authoring,
  }) {
    return Manifest(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      packageId: packageId ?? this.packageId,
      title: title ?? this.title,
      releaseYear: releaseYear ?? this.releaseYear,
      locale: locale ?? this.locale,
      referenceTrack: referenceTrack ?? this.referenceTrack,
      riffTrack: riffTrack ?? this.riffTrack,
      userTrack: userTrack ?? this.userTrack,
      timing: timing ?? this.timing,
      sync: sync ?? this.sync,
      display: display ?? this.display,
      cueDefaults: cueDefaults ?? this.cueDefaults,
      authoring: authoring ?? this.authoring,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'packageId': packageId,
      'title': title,
      'locale': locale,
      'referenceTrack': referenceTrack.toJson(),
      'timing': timing.toJson(),
      'sync': sync.toJson(),
    };
    if (releaseYear != null) map['releaseYear'] = releaseYear;
    if (riffTrack != null) map['riffTrack'] = riffTrack!.toJson();
    if (userTrack != null) map['userTrack'] = userTrack!.toJson();
    if (display != null) map['display'] = display!.toJson();
    if (cueDefaults != null) map['cueDefaults'] = cueDefaults!.toJson();
    if (authoring != null) map['authoring'] = authoring!.toJson();
    return map;
  }

  factory Manifest.fromJson(Map<String, dynamic> json) {
    return Manifest(
      schemaVersion: json['schemaVersion'] as String,
      packageId: json['packageId'] as String,
      title: json['title'] as String,
      releaseYear: json['releaseYear'] as int?,
      locale: json['locale'] as String,
      referenceTrack: ManifestTrackRef.fromJson(
        json['referenceTrack'] as Map<String, dynamic>,
      ),
      riffTrack: json['riffTrack'] != null
          ? ManifestTrackRef.fromJson(
              json['riffTrack'] as Map<String, dynamic>,
            )
          : null,
      userTrack: json['userTrack'] != null
          ? ManifestTrackRef.fromJson(
              json['userTrack'] as Map<String, dynamic>,
            )
          : null,
      timing: ManifestTiming.fromJson(
        json['timing'] as Map<String, dynamic>,
      ),
      sync: ManifestSync.fromJson(
        json['sync'] as Map<String, dynamic>,
      ),
      display: json['display'] != null
          ? ManifestDisplay.fromJson(
              json['display'] as Map<String, dynamic>,
            )
          : null,
      cueDefaults: json['cueDefaults'] != null
          ? ManifestCueDefaults.fromJson(
              json['cueDefaults'] as Map<String, dynamic>,
            )
          : null,
      authoring: json['authoring'] != null
          ? ManifestAuthoring.fromJson(
              json['authoring'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Manifest &&
        other.schemaVersion == schemaVersion &&
        other.packageId == packageId &&
        other.title == title &&
        other.releaseYear == releaseYear &&
        other.locale == locale &&
        other.referenceTrack == referenceTrack &&
        other.riffTrack == riffTrack &&
        other.userTrack == userTrack &&
        other.timing == timing &&
        other.sync == sync &&
        other.display == display &&
        other.cueDefaults == cueDefaults &&
        other.authoring == authoring;
  }

  @override
  int get hashCode {
    return Object.hash(
      schemaVersion,
      packageId,
      title,
      releaseYear,
      locale,
      referenceTrack,
      riffTrack,
      userTrack,
      timing,
      sync,
      display,
      cueDefaults,
      authoring,
    );
  }

  @override
  String toString() {
    return 'Manifest(schemaVersion: $schemaVersion, packageId: $packageId, '
        'title: $title, releaseYear: $releaseYear, locale: $locale, '
        'referenceTrack: $referenceTrack, riffTrack: $riffTrack, '
        'userTrack: $userTrack, timing: $timing, sync: $sync, '
        'display: $display, cueDefaults: $cueDefaults, '
        'authoring: $authoring)';
  }
}
