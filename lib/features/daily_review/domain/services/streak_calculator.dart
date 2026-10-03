import '../entities/streak.dart';

class StreakCalculator {
  const StreakCalculator();

  Streak fromDates(List<String> dates, DateTime today) {
    if (dates.isEmpty) return Streak.empty;

    final days = dates.map(_parse).toSet().toList()..sort();

    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;
      run = gap == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }

    final todayDate = DateTime.utc(today.year, today.month, today.day);
    final sinceLast = todayDate.difference(days.last).inDays;
    final current = sinceLast <= 1 ? run : 0;

    return Streak(current: current, best: best);
  }

  DateTime _parse(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }
}