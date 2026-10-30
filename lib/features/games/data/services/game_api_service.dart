import 'package:zenmind/features/games/data/models/game_session_model.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class GameApiService {
  final ApiClient _apiClient;

  GameApiService({required this._apiClient});

  Future<GameSessionModel> postSession({
    required GameSessionModel session,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.uploadSesion,
      data: session.toJson(),
    );

    return GameSessionModel.fromJson(response.data!);
  }

  Future<List<GameSessionModel>> getSessions() async {
    final response = await _apiClient.get<List<dynamic>>(ApiEndpoints.sessions);

    final data = response.data!;
    final List<GameSessionModel> sessions = [];

    for (final item in data) {
      final json = item as Map<String, dynamic>;
      final session = GameSessionModel.fromJson(json);

      sessions.add(session);
    }

    return sessions;
  }
}
