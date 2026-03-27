import 'package:sqflite/sqflite.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/features/persistence/database.dart';

class TrackRepository {
  final Future<Database> Function() _getDb;

  TrackRepository({Future<Database> Function()? getDb})
      : _getDb = getDb ?? (() => AppDatabase.database);

  Future<List<Track>> getByProject(String projectId) async {
    final db = await _getDb();
    final maps = await db.query('tracks',
        where: 'projectId = ?',
        whereArgs: [projectId],
        orderBy: 'createdAt ASC');
    return maps.map((m) => Track.fromMap(m)).toList();
  }

  Future<Track?> getById(String id) async {
    final db = await _getDb();
    final maps = await db.query('tracks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Track.fromMap(maps.first);
  }

  Future<void> insert(Track track) async {
    final db = await _getDb();
    await db.insert('tracks', track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Track track) async {
    final db = await _getDb();
    await db.update('tracks', track.toMap(),
        where: 'id = ?', whereArgs: [track.id]);
  }

  Future<void> delete(String id) async {
    final db = await _getDb();
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByProject(String projectId) async {
    final db = await _getDb();
    await db.delete('tracks',
        where: 'projectId = ?', whereArgs: [projectId]);
  }

  Future<int> countByProject(String projectId) async {
    final db = await _getDb();
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM tracks WHERE projectId = ?',
        [projectId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
