import 'package:zenmind/features/games/data/models/game_session_model.dart';
import 'package:zenmind/features/games/data/services/game_api_service.dart';
import 'package:zenmind/features/games/data/services/game_local_service.dart';
import 'package:zenmind/features/games/domain/entities/game_session.dart';
import 'package:zenmind/features/games/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameApiService _gameApiService;
  final GameLocalService _gamelocalService;

  GameRepositoryImpl({
    required this._gameApiService,
    required this._gamelocalService,
  });

  @override
  Future<List<GameSession>> getSessionHistory() async {
    try {
      final sessions = await _gameApiService.getSessions();
      return sessions;
    } catch (e) {
      return await _gamelocalService.getSessions();
    }
  }

  @override
  Future<void> saveSession(GameSession session) async {
    await _gamelocalService.saveSession(GameSessionModel.fromEntity(session));
  }

  @override
  Future<void> syncPendingSessions() async {
    final pendingSessions = await _gamelocalService.getPendingSessions();

    for (final session in pendingSessions) {
      try {
        await _gameApiService.postSession(session: session);

        await _gamelocalService.updateSessionSyncStatus(
          sessionId: session.id,
          status: 'synced',
        );

        await _gamelocalService.deleteSession(sessionId: session.id);
      } catch (e) {
        continue;
      }
    }
  }
}
