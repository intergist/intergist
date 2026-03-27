enum ProjectStatus { draft, ready, missingRiffTrack, malformedPackage }

class Project {
  final String id;
  final String title;
  final int? releaseYear;
  final String locale;
  final String? packageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatus status;

  const Project({
    required this.id,
    required this.title,
    this.releaseYear,
    required this.locale,
    this.packageId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  Project copyWith({
    String? id,
    String? title,
    int? releaseYear,
    String? locale,
    String? packageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectStatus? status,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseYear: releaseYear ?? this.releaseYear,
      locale: locale ?? this.locale,
      packageId: packageId ?? this.packageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'releaseYear': releaseYear,
      'locale': locale,
      'packageId': packageId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      title: map['title'] as String,
      releaseYear: map['releaseYear'] as int?,
      locale: map['locale'] as String,
      packageId: map['packageId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.title == title &&
        other.releaseYear == releaseYear &&
        other.locale == locale &&
        other.packageId == packageId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      releaseYear,
      locale,
      packageId,
      createdAt,
      updatedAt,
      status,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, releaseYear: $releaseYear, '
        'locale: $locale, packageId: $packageId, createdAt: $createdAt, '
        'updatedAt: $updatedAt, status: $status)';
  }
}
