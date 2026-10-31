import 'package:zenmind/core/network/api_client.dart';
import 'package:zenmind/core/network/api_endpoints.dart';
import 'package:zenmind/features/cuestionario/data/models/estado_animo.dart';
import 'package:zenmind/features/cuestionario/data/models/flashcard.dart';

class CuestionarioApiService {
  final ApiClient _apiClient;

  CuestionarioApiService({required this._apiClient});

  Future<List<EstadoAnimo>> obtenerEstados() async {
    final respuesta = await _apiClient.get<List<dynamic>>(ApiEndpoints.moods);
    final datos = respuesta.data ?? [];

    return datos
        .map((item) => EstadoAnimo.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearCuestionario({
    required int estadoAnimoId,
    String? comentario,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.cuestionarios,
      data: {
        'estadoAnimoId': estadoAnimoId,
        if (comentario != null && comentario.isNotEmpty) 'comentario': comentario,
      },
    );
  }

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final respuesta = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.profile,
    );

    return respuesta.data ?? {};
  }

  Future<void> activarConsentimiento() async {
    await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: {'consentimientoDatos': true},
    );
  }

  Future<List<Flashcard>> obtenerFlashcards(String categoria) async {
    final respuesta = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.flashcards,
      queryParameters: {'categoria': categoria},
    );
    final datos = respuesta.data ?? [];

    return datos
        .map((item) => Flashcard.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
