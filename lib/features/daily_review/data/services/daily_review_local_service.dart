import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/mood.dart';

class DailyReviewLocalService {
  static const String _dateKey = 'checkin_date';
  static const String _moodKey = 'checkin_mood';

  Future<Mood?> getTodayMood() async {
    final preferences = await SharedPreferences.getInstance();

    if (preferences.getString(_dateKey) != _today()) return null;

    final moodName = preferences.getString(_moodKey);

    for (final mood in Mood.values) {
      if (mood.name == moodName) return mood;
    }

    return null;
  }

  Future<void> saveToday(Mood mood) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_dateKey, _today());
    await preferences.setString(_moodKey, mood.name);
  }

  String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }
}