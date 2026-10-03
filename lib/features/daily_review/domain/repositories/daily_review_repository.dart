import '../entities/mood.dart';

class SaveResult {
  final bool syncedWithServer;
  final bool alreadyCheckedInToday;

  const SaveResult({
    required this.syncedWithServer,
    required this.alreadyCheckedInToday,
  });
}

abstract class DailyReviewRepository {
  Future<Mood?> getTodayMood();

  Future<SaveResult> saveCheckin({
    required Mood mood,
    String? note,
    required bool isGuest,
  });
}