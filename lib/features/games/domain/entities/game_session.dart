class GameSession {
  final String id;
  final int durationMs;
  final int errors;
  final int correctTaps;
  final String completedAt;

  const GameSession({
    required this.id,
    required this.durationMs,
    required this.errors,
    required this.correctTaps,
    required this.completedAt,
  });
}
