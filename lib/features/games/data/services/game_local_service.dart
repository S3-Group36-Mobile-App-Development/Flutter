import 'package:zenmind/core/localDataBase/app_database.dart';
import 'package:zenmind/features/games/data/models/game_session_model.dart';

class GameLocalService {
  final AppDatabase _localdatabase;

  GameLocalService({required this._localdatabase});

  Future<void> saveSession(GameSessionModel session) async {
    await _localdatabase.database.insert('game_sessions', session.toJson());
  }

  Future<List<GameSessionModel>> getSessions() async {
    final response = await _localdatabase.database.query('game_sessions');
    final List<GameSessionModel> sessions = [];

    for (final item in response) {
      final json = item as Map<String, dynamic>;
      final session = GameSessionModel.fromJson(json);

      sessions.add(session);
    }
    return sessions;
  }

  Future<void> getPendingSessions() async {}

  Future<void> updateSessionSyncStatus() async {}

  Future<void> deleteSession() async {}

  Future<void> getAverageDuration() async {}
}
