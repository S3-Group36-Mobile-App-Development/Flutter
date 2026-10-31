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

  Future<void> updateCounts({
    required String id,
    required int rating,
    required int optional,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.breathingExercice(id),
    );

    final exercice = response.data!;

    final oldUsage = _toInt(exercice['usageCount']);
    final oldRatingCount = _toInt(exercice['ratingCount']);
    final oldRatingAvg = _toDouble(exercice['ratingAvg']);

    final newUsage = oldUsage + 1;
    final newRatingCount = oldRatingCount + optional;

    final double newAvg = newRatingCount == 0
        ? 0
        : (oldRatingAvg * oldRatingCount + rating) / newRatingCount;

    await _apiClient.put<dynamic>(
      ApiEndpoints.breathingExercice(id),
      data: {
        'usageCount': newUsage,
        'ratingCount': newRatingCount,
        'ratingAvg': newAvg.toString(),
      },
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
