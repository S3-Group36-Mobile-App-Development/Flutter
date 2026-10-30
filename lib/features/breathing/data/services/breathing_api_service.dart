import 'package:zenmind/core/network/api_client.dart';
import 'package:zenmind/core/network/api_endpoints.dart';
import 'package:zenmind/features/breathing/data/models/breathing_exercice_model.dart';

class BreathingApiService {
  final ApiClient _apiClient;

  BreathingApiService({required this._apiClient});

  Future<List<BreathingExerciceModel>> getExercices() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.getExercices,
    );

    final data = response.data!;
    final List<BreathingExerciceModel> exercices = [];

    for (final item in data) {
      final json = item as Map<String, dynamic>;
      final exercice = BreathingExerciceModel.fromJson(json);

      exercices.add(exercice);
    }
    return exercices;
  }

  Future<BreathingExerciceModel> updateCounts({
    required String id,
    required int rating,
    required int optional,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.breathingExercice(id),
    );

    final exercice = response.data!;

    final oldUsage = exercice['usageCount'] as int;
    final oldRatingCount = exercice['ratingCount'] as int;
    final oldRatingAvg = double.parse(exercice['ratingAvg'].toString());

    final newUsage = oldUsage + 1;
    final newRatingCount = oldRatingCount + optional;

    final double newAvg = newRatingCount == 0
        ? 0
        : (oldRatingAvg * oldRatingCount + rating) / newRatingCount;

    final data = <String, dynamic>{
      'usageCount': newUsage,
      'ratingCount': newRatingCount,
      'ratingAvg': newAvg.toString(),
    };

    final updated = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.breathingExercice(id),
      data: data,
    );

    return BreathingExerciceModel.fromJson(updated.data!);
  }
}