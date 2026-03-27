import 'package:sqflite/sqflite.dart';
import 'package:scifionly/models/project.dart';
import 'package:scifionly/features/persistence/database.dart';

class ProjectRepository {
  final Future<Database> Function() _getDb;

  ProjectRepository({Future<Database> Function()? getDb})
      : _getDb = getDb ?? (() => AppDatabase.database);

  Future<List<Project>> getAll() async {
    final db = await _getDb();
    final maps = await db.query('projects', orderBy: 'updatedAt DESC');
    return maps.map((m) => Project.fromMap(m)).toList();
  }

  Future<Project?> getById(String id) async {
    final db = await _getDb();
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Project.fromMap(maps.first);
  }

  Future<void> insert(Project project) async {
    final db = await _getDb();
    await db.insert('projects', project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Project project) async {
    final db = await _getDb();
    await db.update('projects', project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
  }

  Future<void> delete(String id) async {
    final db = await _getDb();
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _getDb();
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM projects');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
