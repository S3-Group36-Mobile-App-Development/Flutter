import 'package:zenmind/core/localDataBase/app_database.dart';
import 'package:zenmind/features/breathing/data/models/breathing_exercice_model.dart';

class BreathingLocalService {
  final AppDatabase _localdatabase;

  BreathingLocalService({required this._localdatabase});

  Future<void> saveExercice(BreathingExerciceModel exercice) async {
    await _localdatabase.database.delete('breathing_exercises');
    await _localdatabase.database.insert(
      'breathing_exercises',
      exercice.toJson(),
    );
  }

  Future<List<BreathingExerciceModel>> getExercices() async {
    final response = await _localdatabase.database.query('breathing_exercises');

    final List<BreathingExerciceModel> exercices = [];

    for (final item in response) {
      final json = Map<String, dynamic>.from(item);
      final exercice = BreathingExerciceModel.fromJson(json);

      exercices.add(exercice);
    }

    return exercices;
  }

  Future<void> savePendingRating({
    required String exerciceId,
    required int rating,
    required int optional,
  }) async {
    final now = DateTime.now();

    await _localdatabase.database.insert('pending_breathing_ratings', {
      'id': now.microsecondsSinceEpoch.toString(),
      'exerciceId': exerciceId,
      'rating': rating,
      'optional': optional,
      'createdAt': now.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingRatings() async {
    final response = await _localdatabase.database.query(
      'pending_breathing_ratings',
      orderBy: 'createdAt ASC',
    );

    return response.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> deletePendingRating({required String id}) async {
    await _localdatabase.database.delete(
      'pending_breathing_ratings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}