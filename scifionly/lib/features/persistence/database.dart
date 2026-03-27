import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;
  static const String _dbName = 'scifionly.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        releaseYear INTEGER,
        locale TEXT NOT NULL DEFAULT 'en-US',
        packageId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft'
      )
    ''');

    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        filename TEXT NOT NULL,
        type TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'en',
        cueCount INTEGER NOT NULL DEFAULT 0,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        source TEXT,
        hashSha256 TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cue_events (
        id TEXT PRIMARY KEY,
        trackId TEXT NOT NULL,
        track TEXT NOT NULL,
        startMs INTEGER NOT NULL,
        endMs INTEGER NOT NULL,
        text TEXT NOT NULL,
        kind TEXT NOT NULL,
        mode TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 50,
        speakerRole TEXT NOT NULL DEFAULT 'app',
        windowRef TEXT,
        interruptible INTEGER NOT NULL DEFAULT 0,
        enabled INTEGER NOT NULL DEFAULT 1,
        sourceFile TEXT,
        sourceIndex INTEGER,
        tags TEXT,
        FOREIGN KEY (trackId) REFERENCES tracks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE participation_windows (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        startMs INTEGER NOT NULL,
        endMs INTEGER NOT NULL,
        predictedFrom TEXT NOT NULL,
        stateLeadInMs INTEGER NOT NULL DEFAULT 1500,
        stateLeadOutMs INTEGER NOT NULL DEFAULT 1500,
        minOpenMs INTEGER NOT NULL DEFAULT 2500,
        maxUserRiffMs INTEGER NOT NULL DEFAULT 7000,
        allowAppSpeech INTEGER NOT NULL DEFAULT 0,
        allowUserCapture INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        mode TEXT NOT NULL,
        state TEXT NOT NULL DEFAULT 'active',
        startedAt TEXT NOT NULL,
        endedAt TEXT,
        lastPositionMs INTEGER,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_snapshots (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        estimatedPositionMs INTEGER NOT NULL,
        confidence REAL NOT NULL,
        driftMs INTEGER NOT NULL DEFAULT 0,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE captures (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        windowId TEXT,
        startMs INTEGER NOT NULL,
        endMs INTEGER NOT NULL,
        transcriptText TEXT NOT NULL DEFAULT '',
        isFinal INTEGER NOT NULL DEFAULT 0,
        capturedAt TEXT NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_tracks_project ON tracks(projectId)
    ''');

    await db.execute('''
      CREATE INDEX idx_cue_events_track ON cue_events(trackId)
    ''');

    await db.execute('''
      CREATE INDEX idx_sessions_project ON sessions(projectId)
    ''');
  }

  /// For testing: create an in-memory database
  static Future<Database> createInMemory() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
