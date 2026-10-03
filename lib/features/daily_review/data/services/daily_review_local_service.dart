import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/mood.dart';

class DailyReviewLocalService {
  static const String _dateKey = 'checkin_date';
  static const String _moodKey = 'checkin_mood';
  static const String _datesKey = 'checkin_dates';

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

    final dates = preferences.getStringList(_datesKey) ?? [];
    if (!dates.contains(_today())) dates.add(_today());
    if (dates.length > 365) dates.removeRange(0, dates.length - 365);
    await preferences.setStringList(_datesKey, dates);
  }

  Future<List<String>> getCheckinDates() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getStringList(_datesKey) ?? [];
  }

  String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }
}