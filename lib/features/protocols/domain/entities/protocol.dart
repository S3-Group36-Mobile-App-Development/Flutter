import 'protocol_step.dart';

class Protocol {
  final String id;
  final String? usuarioId;
  final String titulo;
  final bool esPredefinido;
  final List<ProtocolStep> pasos;

  const Protocol({
    required this.id,
    this.usuarioId,
    required this.titulo,
    required this.esPredefinido,
    required this.pasos,
  });
}
