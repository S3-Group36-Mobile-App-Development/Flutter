import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/features/breathing/data/models/breathing_exercice_model.dart';
import 'package:zenmind/features/breathing/data/services/breathing_api_service.dart';
import 'package:zenmind/features/breathing/data/services/breathing_local_service.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';

class BreathingRepository {
  final BreathingApiService _breathingApiService;
  final BreathingLocalService _breathinglocalService;

  BreathingRepository({
    required this._breathingApiService,
    required this._breathinglocalService,
  });

  Future<List<BreathingExercice>> getExercices() async {
    try {
      return await _breathingApiService.getExercices();
    } catch (e) {
      return _breathinglocalService.getExercices();
    }
  }

  Future<BreathingExercice?> getFavorite() async {
    final favorites = await _breathinglocalService.getExercices();
    return favorites.isEmpty ? null : favorites.first;
  }

  Future<void> saveFavorite(BreathingExercice exercice) async {
    try {
      await _breathinglocalService.saveExercice(
        BreathingExerciceModel.fromEntity(exercice),
      );
    } catch (e) {
      throw const LocalDatabaseException(
        'No se pudo guardar tu ejercicio favorito.',
      );
    }
  }

  Future<void> rateExercise({
    required String id,
    required int rating,
    required int optional,
  }) async {
    await _breathingApiService.updateCounts(
      id: id,
      rating: rating,
      optional: optional,
    );
  }
}
