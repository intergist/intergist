// Poker Sharp — SQLite Database Service

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'poker.dart';
import 'scoring.dart';
import 'game_state.dart';

class DatabaseService {
  static Database? _database;
  static const _dbName = 'poker_sharp.db';
  static const _dbVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE drills (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        board TEXT NOT NULL,
        target_count INTEGER NOT NULL,
        picker_mode TEXT NOT NULL,
        timer_enabled INTEGER NOT NULL,
        time_taken_ms INTEGER,
        hint_used INTEGER NOT NULL DEFAULT 0,
        user_holdings TEXT NOT NULL,
        scoring_result TEXT,
        board_texture TEXT,
        suit_sensitive INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        dark_mode INTEGER NOT NULL DEFAULT 1,
        player_name TEXT NOT NULL DEFAULT 'Player',
        default_holdings_count INTEGER NOT NULL DEFAULT 10,
        default_timer_enabled INTEGER NOT NULL DEFAULT 1,
        default_picker_mode TEXT NOT NULL DEFAULT 'twoStep',
        sound_enabled INTEGER NOT NULL DEFAULT 1,
        haptic_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default settings row
    await db.insert('settings', {
      'id': 1,
      'dark_mode': 1,
      'player_name': 'Player',
      'default_holdings_count': 10,
      'default_timer_enabled': 1,
      'default_picker_mode': 'twoStep',
      'sound_enabled': 1,
      'haptic_enabled': 1,
    });
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }

  // --- Drill operations ---

  static Future<void> saveDrill(DrillRecord drill) async {
    final db = await database;
    await db.insert(
      'drills',
      {
        'id': drill.id,
        'date': drill.date.toIso8601String(),
        'board': jsonEncode(
            drill.board.map((c) => {'rank': c.rank, 'suit': c.suit}).toList()),
        'target_count': drill.targetCount,
        'picker_mode': drill.pickerMode.name,
        'timer_enabled': drill.timerEnabled ? 1 : 0,
        'time_taken_ms': drill.timeTakenMs,
        'hint_used': drill.hintUsed ? 1 : 0,
        'user_holdings': jsonEncode(drill.userHoldings
            .map((h) => {
                  'cards': h.cards
                      .map((c) => {'rank': c.rank, 'suit': c.suit})
                      .toList(),
                  'rank': h.rank,
                })
            .toList()),
        'scoring_result': drill.scoringResult != null
            ? jsonEncode({
                'totalPoints': drill.scoringResult!.totalPoints,
                'maxPoints': drill.scoringResult!.maxPoints,
                'percentage': drill.scoringResult!.percentage,
                'isSuitSensitive': drill.scoringResult!.isSuitSensitive,
              })
            : null,
        'board_texture': drill.boardTexture != null
            ? jsonEncode({
                'isMonotone': drill.boardTexture!.isMonotone,
                'isTwoTone': drill.boardTexture!.isTwoTone,
                'isRainbow': drill.boardTexture!.isRainbow,
                'isPaired': drill.boardTexture!.isPaired,
                'isDoublePaired': drill.boardTexture!.isDoublePaired,
                'isTrips': drill.boardTexture!.isTrips,
                'isQuads': drill.boardTexture!.isQuads,
                'connectivity': drill.boardTexture!.connectivity,
                'highestCard': {
                  'rank': drill.boardTexture!.highestCard.rank,
                  'suit': drill.boardTexture!.highestCard.suit,
                },
                'description': drill.boardTexture!.description,
              })
            : null,
        'suit_sensitive': drill.suitSensitive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<DrillRecord>> getDrills() async {
    final db = await database;
    final rows = await db.query('drills', orderBy: 'date DESC');

    return rows.map((row) {
      final boardJson = jsonDecode(row['board'] as String) as List;
      final board =
          boardJson.map((c) => Card(rank: c['rank'], suit: c['suit'])).toList();

      final holdingsJson =
          jsonDecode(row['user_holdings'] as String) as List;
      final userHoldings = holdingsJson.map((h) {
        final cards = (h['cards'] as List)
            .map((c) => Card(rank: c['rank'], suit: c['suit']))
            .toList();
        return (cards: cards, rank: h['rank'] as int);
      }).toList();

      GroupedScoringResult? scoringResult;
      if (row['scoring_result'] != null) {
        final sr = jsonDecode(row['scoring_result'] as String);
        scoringResult = GroupedScoringResult(
          totalPoints: sr['totalPoints'],
          maxPoints: sr['maxPoints'],
          percentage: sr['percentage'],
          perPosition: const [],
          missedClasses: const [],
          isSuitSensitive: sr['isSuitSensitive'] ?? false,
        );
      }

      BoardTexture? boardTexture;
      if (row['board_texture'] != null) {
        final bt = jsonDecode(row['board_texture'] as String);
        boardTexture = BoardTexture(
          isMonotone: bt['isMonotone'],
          isTwoTone: bt['isTwoTone'],
          isRainbow: bt['isRainbow'],
          isPaired: bt['isPaired'],
          isDoublePaired: bt['isDoublePaired'],
          isTrips: bt['isTrips'],
          isQuads: bt['isQuads'],
          connectivity: bt['connectivity'],
          highestCard:
              Card(rank: bt['highestCard']['rank'], suit: bt['highestCard']['suit']),
          description: bt['description'],
        );
      }

      return DrillRecord(
        id: row['id'] as String,
        date: DateTime.parse(row['date'] as String),
        board: board,
        targetCount: row['target_count'] as int,
        pickerMode: PickerMode.values.byName(row['picker_mode'] as String),
        timerEnabled: (row['timer_enabled'] as int) == 1,
        timeTakenMs: row['time_taken_ms'] as int?,
        hintUsed: (row['hint_used'] as int) == 1,
        userHoldings: userHoldings,
        scoringResult: scoringResult,
        boardTexture: boardTexture,
        suitSensitive: (row['suit_sensitive'] as int) == 1,
      );
    }).toList();
  }

  static Future<void> deleteDrill(String id) async {
    final db = await database;
    await db.delete('drills', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearDrills() async {
    final db = await database;
    await db.delete('drills');
  }

  // --- Settings operations ---

  static Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.update(
      'settings',
      {
        'dark_mode': settings.darkMode ? 1 : 0,
        'player_name': settings.playerName,
        'default_holdings_count': settings.defaultHoldingsCount,
        'default_timer_enabled': settings.defaultTimerEnabled ? 1 : 0,
        'default_picker_mode': settings.defaultPickerMode.name,
        'sound_enabled': settings.soundEnabled ? 1 : 0,
        'haptic_enabled': settings.hapticEnabled ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<AppSettings> getSettings() async {
    final db = await database;
    final rows = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    if (rows.isEmpty) {
      return defaultSettings;
    }

    final row = rows.first;
    return AppSettings(
      darkMode: (row['dark_mode'] as int) == 1,
      playerName: row['player_name'] as String,
      defaultHoldingsCount: row['default_holdings_count'] as int,
      defaultTimerEnabled: (row['default_timer_enabled'] as int) == 1,
      defaultPickerMode:
          PickerMode.values.byName(row['default_picker_mode'] as String),
      soundEnabled: (row['sound_enabled'] as int) == 1,
      hapticEnabled: (row['haptic_enabled'] as int) == 1,
    );
  }

  /// Close the database (for testing or cleanup).
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
