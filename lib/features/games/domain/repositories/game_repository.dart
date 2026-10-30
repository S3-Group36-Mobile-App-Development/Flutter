import 'package:zenmind/features/games/domain/entities/game_session.dart';

abstract class GameRepository {
  // 1. Guardar una partida en el almacenamiento local.
  Future<void> saveSession(GameSession session);

  // 2. Consultar el historial de partidas.
  Future<List<GameSession>> getSessionHistory();

  // 3. Sincronizar las partidas pendientes con el backend.
  Future<void> syncPendingSessions();
}
