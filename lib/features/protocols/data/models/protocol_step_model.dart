// lib/features/protocols/data/models/protocol_step_model.dart
import 'package:zenmind/features/protocols/domain/entities/protocol_step.dart';

class ProtocolStepModel extends ProtocolStep {
  const ProtocolStepModel({
    required super.id,
    required super.protocoloId,
    required super.ordenPaso,
    required super.descripcion,
  });

  factory ProtocolStepModel.fromJson(Map<String, dynamic> json) {
    return ProtocolStepModel(
      id: json['id'].toString(),
      protocoloId: json['protocoloId'].toString(),
      ordenPaso: json['ordenPaso'] as int,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocoloId': protocoloId,
      'ordenPaso': ordenPaso,
      'descripcion': descripcion,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'ordenPaso': ordenPaso, 'descripcion': descripcion};
  }

  factory ProtocolStepModel.fromEntity(ProtocolStep step) {
    return ProtocolStepModel(
      id: step.id,
      protocoloId: step.protocoloId,
      ordenPaso: step.ordenPaso,
      descripcion: step.descripcion,
    );
  }
}
