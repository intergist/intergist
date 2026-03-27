import 'package:sqflite/sqflite.dart';
import 'package:scifionly/models/session.dart';
import 'package:scifionly/models/capture_event.dart';
import 'package:scifionly/features/persistence/database.dart';

class SessionRepository {
  final Future<Database> Function() _getDb;

  SessionRepository({Future<Database> Function()? getDb})
      : _getDb = getDb ?? (() => AppDatabase.database);

  Future<List<Session>> getByProject(String projectId) async {
    final db = await _getDb();
    final maps = await db.query('sessions',
        where: 'projectId = ?',
        whereArgs: [projectId],
        orderBy: 'startedAt DESC');
    return maps.map((m) => Session.fromMap(m)).toList();
  }

  Future<Session?> getById(String id) async {
    final db = await _getDb();
    final maps = await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Session.fromMap(maps.first);
  }

  Future<Session?> getActiveSession(String projectId) async {
    final db = await _getDb();
    final maps = await db.query('sessions',
        where: 'projectId = ? AND state = ?',
        whereArgs: [projectId, 'active'],
        limit: 1);
    if (maps.isEmpty) return null;
    return Session.fromMap(maps.first);
  }

  Future<void> insert(Session session) async {
    final db = await _getDb();
    await db.insert('sessions', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Session session) async {
    final db = await _getDb();
    await db.update('sessions', session.toMap(),
        where: 'id = ?', whereArgs: [session.id]);
  }

  Future<void> delete(String id) async {
    final db = await _getDb();
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  // Capture events
  Future<void> insertCapture(CaptureEvent capture) async {
    final db = await _getDb();
    await db.insert('captures', capture.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CaptureEvent>> getCapturesBySession(String sessionId) async {
    final db = await _getDb();
    final maps = await db.query('captures',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
        orderBy: 'startMs ASC');
    return maps.map((m) => CaptureEvent.fromMap(m)).toList();
  }
}
