import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';

class BreathingExerciceModel extends BreathingExercice{
  
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
    return BreathingExerciceModel(
      id: json['id'].toString(),
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      duracion: json['duracion'] as int,
      patron: json['patron'] as Map<String, dynamic>,
      vibra: json['vibra'] as bool,
      usageCount: json['usageCount'] as int,
      raitingAvg: json['raitingAvg'] as double,
      ratingCoutn: json['raitingCount'] as int,
    );

  }

   Map<String, dynamic> toJson(){
    return {
      'id': id,
      'titulo':titulo,
      'descripcion':descripcion,
      'duracion':duracion,
      'patron':patron,
      'vibra':vibra,
      'usageCount':usageCount,
      'raitingAvg':raitingAvg,
      'raitingCount':ratingCoutn,
    };
   }

    factory BreathingExerciceModel.fromEntity(BreathingExercice exercice) {
    return BreathingExerciceModel(
        titulo: exercice.titulo, 
        duracion: exercice.duracion, 
        patron: exercice.patron,
        vibra: exercice.vibra,
        usageCount: exercice.usageCount,
        raitingAvg: exercice.raitingAvg, 
        ratingCoutn: exercice.ratingCoutn, 
        id:exercice.id,
    );
  }

}