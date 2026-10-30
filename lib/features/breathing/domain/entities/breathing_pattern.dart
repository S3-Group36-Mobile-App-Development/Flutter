class BreathingPattern {
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int hold2Seconds;
  final int cycles;

  const BreathingPattern({
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.hold2Seconds,
    required this.cycles,
  });

  factory BreathingPattern.fromMap(Map<String, dynamic> map) {
    int read(String key, int fallback) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return BreathingPattern(
      inhaleSeconds: read('inhalar', 4),
      holdSeconds: read('sostener', 0),
      exhaleSeconds: read('exhalar', 6),
      hold2Seconds: read('sostener2', 0),
      cycles: read('ciclos', 5),
    );
  }
}