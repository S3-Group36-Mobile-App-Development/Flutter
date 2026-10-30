import 'package:zenmind/features/games/domain/entities/game_session.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.durationMs,
    required super.errors,
    required super.correctTaps,
    required super.completedAt,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      id: json['id'].toString(),
      durationMs: json['durationMs'] as int,
      errors: json['errors'] as int,
      correctTaps: json['correctTaps'] as int,
      completedAt: json['completedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMs': durationMs,
      'errors': errors,
      'correctTaps': correctTaps,
      'completedAt': completedAt,
    };
  }
}
