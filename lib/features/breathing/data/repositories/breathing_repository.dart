import 'package:dio/dio.dart';
import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/core/errors/network_exception.dart';
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
    try {
      await _breathingApiService.updateCounts(
        id: id,
        rating: rating,
        optional: optional,
      );
    } on DioException catch (e) {
      if (!_isTransient(e)) rethrow;

      await _breathinglocalService.savePendingRating(
        exerciceId: id,
        rating: rating,
        optional: optional,
      );

      throw const NetworkException();
    }
  }

  Future<void> syncPendingRatings() async {
    final List<Map<String, dynamic>> pending;

    try {
      pending = await _breathinglocalService.getPendingRatings();
    } catch (_) {
      throw const LocalDatabaseException(
        'No se pudieron leer las calificaciones pendientes.',
      );
    }

    for (final item in pending) {
      try {
        await _breathingApiService.updateCounts(
          id: item['exerciceId'] as String,
          rating: item['rating'] as int,
          optional: item['optional'] as int,
        );
        await _breathinglocalService.deletePendingRating(
          id: item['id'] as String,
        );

      } on DioException catch (e) {
        
        if (_isTransient(e)) {
          throw const NetworkException();
        }
        await _breathinglocalService.deletePendingRating(
          id: item['id'] as String,
        );
        
      } catch (_) {
        continue;
      }
    }
  }

  bool _isTransient(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return code == 502 || code == 503 || code == 504;
      default:
        return false;
    }
  }
}