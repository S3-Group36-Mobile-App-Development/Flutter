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
  static const String _createProtocols = '''
  CREATE TABLE IF NOT EXISTS protocols (
    id TEXT PRIMARY KEY,
    usuarioId TEXT,
    titulo TEXT NOT NULL,
    esPredefinido INTEGER NOT NULL,
    syncStatus TEXT NOT NULL DEFAULT 'synced'
  )
''';

  static const String _createProtocolSteps = '''
  CREATE TABLE IF NOT EXISTS protocol_steps (
    id TEXT PRIMARY KEY,
    protocoloId TEXT NOT NULL,
    ordenPaso INTEGER NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (protocoloId) REFERENCES protocols (id) ON DELETE CASCADE
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
        await db.execute(_createProtocols);
        await db.execute(_createProtocolSteps);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute(_createGameSessions);
        await db.execute(_createBreathingExercises);
        await db.execute('DROP TABLE IF EXISTS protocol_steps');
        await db.execute('DROP TABLE IF EXISTS protocols');
        await db.execute(_createProtocols);
        await db.execute(_createProtocolSteps);
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
