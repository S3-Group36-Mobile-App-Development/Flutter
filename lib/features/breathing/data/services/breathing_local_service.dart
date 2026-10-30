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
}