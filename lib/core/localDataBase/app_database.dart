import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'zenmind.db';
  static const int _databaseVersion = 1;

  final Database database;

  AppDatabase._(this.database);

  static Future<AppDatabase> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE game_sessions (
            id TEXT PRIMARY KEY,
            durationMs INTEGER NOT NULL,
            errors INTEGER NOT NULL,
            correctTaps INTEGER NOT NULL,
            completedAt TEXT NOT NULL,
            syncStatus TEXT NOT NULL
          )
        ''');
      },
    );

    return AppDatabase._(database);
  }

  Future<void> close() async {
    await database.close();
  }
}
