import 'package:dio/dio.dart';

import '../../domain/entities/mood.dart';
import '../../domain/repositories/daily_review_repository.dart';
import '../services/daily_review_api_service.dart';
import '../services/daily_review_local_service.dart';

class DailyReviewRepositoryImpl implements DailyReviewRepository {
  final DailyReviewApiService _apiService;
  final DailyReviewLocalService _localService;

  DailyReviewRepositoryImpl({
    required this._apiService,
    required this._localService,
  });

  @override
  Future<Mood?> getTodayMood() {
    return _localService.getTodayMood();
  }

  @override
  Future<SaveResult> saveCheckin({
    required Mood mood,
    String? note,
    required bool isGuest,
  }) async {
    await _localService.saveToday(mood);

    if (isGuest) {
      return const SaveResult(
        syncedWithServer: false,
        alreadyCheckedInToday: false,
      );
    }

    try {
      final moodId = await _findBackendMoodId(mood);

      if (moodId == null) {
        return const SaveResult(
          syncedWithServer: false,
          alreadyCheckedInToday: false,
        );
      }

      await _apiService.createCheckin(moodId: moodId, comment: note);

      return const SaveResult(
        syncedWithServer: true,
        alreadyCheckedInToday: false,
      );
    } on DioException catch (error) {
      return SaveResult(
        syncedWithServer: false,
        alreadyCheckedInToday: error.response?.statusCode == 409,
      );
    }
  }

  Future<int?> _findBackendMoodId(Mood mood) async {
    final moods = await _apiService.getMoods();

    for (final name in mood.backendNames) {
      for (final item in moods) {
        final backendName = (item['nombre'] as String).toLowerCase();

        if (backendName == name.toLowerCase()) {
          return int.tryParse(item['id'].toString());
        }
      }
    }

    return null;
  }
}