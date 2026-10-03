import 'package:dio/dio.dart';

import '../../domain/entities/mood.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/daily_review_repository.dart';
import '../../domain/services/streak_calculator.dart';
import '../services/daily_review_api_service.dart';
import '../services/daily_review_local_service.dart';

class DailyReviewRepositoryImpl implements DailyReviewRepository {
  final DailyReviewApiService _apiService;
  final DailyReviewLocalService _localService;
  final StreakCalculator _calculator = const StreakCalculator();

  DailyReviewRepositoryImpl({
    required this._apiService,
    required this._localService,
  });

  @override
  Future<Mood?> getTodayMood() {
    return _localService.getTodayMood();
  }

  @override
  Future<Streak> getStreak({required bool isGuest}) async {
    if (!isGuest) {
      try {
        final racha = await _apiService.getStreak();

        if (racha == null) return Streak.empty;

        final best = racha['rachaMasLargaDias'] as int? ?? 0;
        var current = racha['rachaActualDias'] as int? ?? 0;

        final last = DateTime.tryParse(
          racha['fechaUltimoCheckin'] as String? ?? '',
        );

        if (last != null) {
          final now = DateTime.now().toUtc();
          final today = DateTime.utc(now.year, now.month, now.day);
          final lastDay = DateTime.utc(last.year, last.month, last.day);

          if (today.difference(lastDay).inDays > 1) current = 0;
        }

        return Streak(current: current, best: best);
      } catch (_) {
      }
    }

    final dates = await _localService.getCheckinDates();

    return _calculator.fromDates(dates, DateTime.now());
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

    for (final item in moods) {
      final backendName = (item['nombre'] as String).toLowerCase();

      if (backendName == mood.label.toLowerCase()) {
        return int.tryParse(item['id'].toString());
      }
    }

    return null;
  }
}