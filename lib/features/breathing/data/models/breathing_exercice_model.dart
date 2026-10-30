import 'dart:convert';

import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';

class BreathingExerciceModel extends BreathingExercice {
  BreathingExerciceModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    required super.duracion,
    required super.patron,
    required super.vibra,
    required super.usageCount,
    required super.raitingAvg,
    required super.ratingCoutn,
  });

  factory BreathingExerciceModel.fromJson(Map<String, dynamic> json) {
    final rawPatron = json['patron'];

    return BreathingExerciceModel(
      id: json['id'].toString(),
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      duracion: json['duracion'] as int,
      patron: rawPatron is String
          ? Map<String, dynamic>.from(jsonDecode(rawPatron) as Map)
          : Map<String, dynamic>.from(rawPatron as Map),
      vibra: json['vibra'] is bool ? json['vibra'] as bool : json['vibra'] == 1,
      usageCount: json['usageCount'] as int,
      raitingAvg: double.parse(json['ratingAvg'].toString()),
      ratingCoutn: json['ratingCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'duracion': duracion,
      'patron': jsonEncode(patron),
      'vibra': vibra ? 1 : 0,
      'usageCount': usageCount,
      'ratingAvg': raitingAvg.toString(),
      'ratingCount': ratingCoutn,
    };
  }

  factory BreathingExerciceModel.fromEntity(BreathingExercice exercice) {
    return BreathingExerciceModel(
      id: exercice.id,
      titulo: exercice.titulo,
      descripcion: exercice.descripcion,
      duracion: exercice.duracion,
      patron: exercice.patron,
      vibra: exercice.vibra,
      usageCount: exercice.usageCount,
      raitingAvg: exercice.raitingAvg,
      ratingCoutn: exercice.ratingCoutn,
    );
  }
}