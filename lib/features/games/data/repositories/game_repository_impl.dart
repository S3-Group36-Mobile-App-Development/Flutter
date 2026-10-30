import 'package:dio/dio.dart';
import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/core/errors/network_exception.dart';
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
    try {
      await _gamelocalService.saveSession(GameSessionModel.fromEntity(session));
    } catch (e) {
      throw const LocalDatabaseException(
        'No se pudo guardar la partida en el dispositivo.',
      );
    }
  }

  @override
  Future<void> syncPendingSessions() async {
    final List<GameSessionModel> pendingSessions;

    try {
      pendingSessions = await _gamelocalService.getPendingSessions();
    } catch (e) {
      throw const LocalDatabaseException(
        'No se pudieron leer las partidas pendientes.',
      );
    }

    for (final session in pendingSessions) {
      try {
        await _gameApiService.postSession(session: session);

        await _gamelocalService.updateSessionSyncStatus(
          sessionId: session.id,
          status: 'synced',
        );

        await _gamelocalService.deleteSession(sessionId: session.id);
      } on DioException {
        // Problema de red: detenemos la sincronización para reintentar luego.
        throw const NetworkException();
      } catch (e) {
        // Error puntual con una partida: seguimos con las demás.
        continue;
      }
    }
  }

  @override
  Future<double?> getAverageDuration() async {
    try {
      return await _gamelocalService.getAverageDuration();
    } catch (e) {
      return null;
    }
  }
}
