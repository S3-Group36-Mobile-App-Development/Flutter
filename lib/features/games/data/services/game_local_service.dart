import 'package:zenmind/core/localDataBase/app_database.dart';
import 'package:zenmind/features/games/data/models/game_session_model.dart';

class GameLocalService {
  final AppDatabase _localdatabase;

  GameLocalService({required this._localdatabase});

  Future<void> saveSession(GameSessionModel session) async {
    final sessionData = {...session.toJson(), 'syncStatus': 'pending'};

    await _localdatabase.database.insert('game_sessions', sessionData);
  }

  Future<List<GameSessionModel>> getSessions() async {
    final response = await _localdatabase.database.query(
      'game_sessions',
      orderBy: 'completedAt DESC',
    );

    final List<GameSessionModel> sessions = [];

    for (final item in response) {
      final json = Map<String, dynamic>.from(item);
      final session = GameSessionModel.fromJson(json);

      sessions.add(session);
    }

    return sessions;
  }

  Future<List<GameSessionModel>> getPendingSessions() async {
    final response = await _localdatabase.database.query(
      'game_sessions',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
      orderBy: 'completedAt ASC',
    );

    final List<GameSessionModel> sessions = [];

    for (final item in response) {
      final json = Map<String, dynamic>.from(item);
      final session = GameSessionModel.fromJson(json);

      sessions.add(session);
    }

    return sessions;
  }

  Future<void> updateSessionSyncStatus({
    required String sessionId,
    required String status,
  }) async {
    await _localdatabase.database.update(
      'game_sessions',
      {'syncStatus': status},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteSession({required String sessionId}) async {
    await _localdatabase.database.delete(
      'game_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<double?> getAverageDuration() async {
    final response = await _localdatabase.database.rawQuery(
      'SELECT AVG(durationMs) AS averageDuration FROM game_sessions',
    );

    final average = response.first['averageDuration'];

    if (average == null) {
      return null;
    }

    return (average as num).toDouble();
  }
}
