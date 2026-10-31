// lib/features/protocols/data/models/protocol_model.dart
import 'package:zenmind/features/protocols/domain/entities/protocol.dart';

import 'protocol_step_model.dart';

class ProtocolModel extends Protocol {
  const ProtocolModel({
    required super.id,
    super.usuarioId,
    required super.titulo,
    required super.esPredefinido,
    required super.pasos,
  });

  factory ProtocolModel.fromJson(Map<String, dynamic> json) {
    return ProtocolModel(
      id: json['id'].toString(),
      usuarioId: json['usuarioId']?.toString(),
      titulo: json['titulo'] as String,
      esPredefinido: json['esPredefinido'] as bool,
      pasos: (json['pasos'] as List<dynamic>? ?? [])
          .map((p) => ProtocolStepModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> pasosJson = [];
    for (final paso in pasos) {
      pasosJson.add(ProtocolStepModel.fromEntity(paso).toJson());
    }

    return {
      'id': id,
      'usuarioId': usuarioId,
      'titulo': titulo,
      'esPredefinido': esPredefinido,
      'pasos': pasosJson,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final List<Map<String, dynamic>> pasosJson = [];
    for (final paso in pasos) {
      pasosJson.add(ProtocolStepModel.fromEntity(paso).toCreateJson());
    }

    return {'titulo': titulo, 'pasos': pasosJson};
  }

  factory ProtocolModel.fromEntity(Protocol protocol) {
    return ProtocolModel(
      id: protocol.id,
      usuarioId: protocol.usuarioId,
      titulo: protocol.titulo,
      esPredefinido: protocol.esPredefinido,
      pasos: protocol.pasos,
    );
  }
}
