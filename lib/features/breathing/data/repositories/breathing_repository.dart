import 'package:dio/dio.dart';
import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/core/errors/network_exception.dart';
import 'package:zenmind/features/breathing/data/models/breathing_exercice_model.dart';
import 'package:zenmind/features/breathing/data/services/breathing_api_service.dart';
import 'package:zenmind/features/breathing/data/services/breathing_local_service.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';
import 'package:zenmind/features/games/data/models/game_session_model.dart';
import 'package:zenmind/features/games/data/services/game_api_service.dart';
import 'package:zenmind/features/games/data/services/game_local_service.dart';
import 'package:zenmind/features/games/domain/entities/game_session.dart';
import 'package:zenmind/features/games/domain/repositories/game_repository.dart';

class BreathingRepository {
  final BreathingApiService _breathingApiService;
  final BreathingLocalService _breathinglocalService;

  BreathingRepository({
   required this._breathingApiService,
   required this._breathinglocalService,
  });

  
  Future<List<BreathingExercice>> getExercice() async {
    try {
      final exercices = await _breathingApiService.getExercices();
      return exercices;
    } catch (e) {
      return await _breathinglocalService.getExercices();
    }
  }


  Future<void> saveSession(BreathingExercice exercice) async {
    try {
      await _breathinglocalService.saveExercice(BreathingExerciceModel.fromEntity(exercice));
    } catch (e) {
      throw const LocalDatabaseException(
        'No se pudo guardar el ejercicio en el dispositivo.',
      );
    }
  }

}
