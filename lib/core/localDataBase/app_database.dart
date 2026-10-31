import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'zenmind.db';
  static const int _databaseVersion = 3;

  final Database database;

  AppDatabase._(this.database);

  static const String _createGameSessions = '''
    CREATE TABLE IF NOT EXISTS game_sessions (
      id TEXT PRIMARY KEY,
      durationMs INTEGER NOT NULL,
      errors INTEGER NOT NULL,
      correctTaps INTEGER NOT NULL,
      completedAt TEXT NOT NULL,
      syncStatus TEXT NOT NULL
    )
  ''';

  static const String _createBreathingExercises = '''
    CREATE TABLE IF NOT EXISTS breathing_exercises (
      id TEXT PRIMARY KEY,
      titulo TEXT NOT NULL,
      descripcion TEXT,
      duracion INTEGER NOT NULL,
      patron TEXT NOT NULL,
      vibra INTEGER NOT NULL,
      usageCount INTEGER NOT NULL,
      ratingAvg TEXT NOT NULL,
      ratingCount INTEGER NOT NULL
    )
  ''';
  static const String _createPendingBreathingRatings = '''
    CREATE TABLE IF NOT EXISTS pending_breathing_ratings (
      id TEXT PRIMARY KEY,
      exerciceId TEXT NOT NULL,
      rating INTEGER NOT NULL,
      optional INTEGER NOT NULL,
      createdAt TEXT NOT NULL
    )
  ''';


  static Future<AppDatabase> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute(_createGameSessions);
        await db.execute(_createBreathingExercises);
        await db.execute(_createPendingBreathingRatings);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute(_createGameSessions);
        await db.execute(_createBreathingExercises);
        await db.execute(_createPendingBreathingRatings);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return AppDatabase._(database);
  }

  Future<void> close() async {
    await database.close();
  }
}