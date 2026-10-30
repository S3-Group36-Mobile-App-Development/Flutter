class Streak {
  final int current;
  final int best;

  const Streak({required this.current, required this.best});

  static const Streak empty = Streak(current: 0, best: 0);
}