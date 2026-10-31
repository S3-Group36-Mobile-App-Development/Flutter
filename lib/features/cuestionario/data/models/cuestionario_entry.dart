enum SyncStatus {
  borrador,
  pendiente,
  sincronizado,
  soloLocal,
}

class CuestionarioEntry {
  final int? id;
  final String usuarioId;
  final int? estadoAnimoId;
  final String? estadoAnimoNombre;
  final String? nota;
  final String? fotoNombre;
  final String fechaLocal;
  final DateTime creadoEn;
  final SyncStatus estado;
  final int intentos;
  final String? detalleSync;

  const CuestionarioEntry({
    this.id,
    required this.usuarioId,
    this.estadoAnimoId,
    this.estadoAnimoNombre,
    this.nota,
    this.fotoNombre,
    required this.fechaLocal,
    required this.creadoEn,
    required this.estado,
    this.intentos = 0,
    this.detalleSync,
  });

  factory CuestionarioEntry.fromMap(Map<String, Object?> map) {
    return CuestionarioEntry(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as String,
      estadoAnimoId: map['estado_animo_id'] as int?,
      estadoAnimoNombre: map['estado_animo_nombre'] as String?,
      nota: map['nota'] as String?,
      fotoNombre: map['foto_nombre'] as String?,
      fechaLocal: map['fecha_local'] as String,
      creadoEn: DateTime.parse(map['creado_en'] as String),
      estado: SyncStatus.values.byName(map['estado_sync'] as String),
      intentos: map['intentos'] as int? ?? 0,
      detalleSync: map['detalle_sync'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'estado_animo_id': estadoAnimoId,
      'estado_animo_nombre': estadoAnimoNombre,
      'nota': nota,
      'foto_nombre': fotoNombre,
      'fecha_local': fechaLocal,
      'creado_en': creadoEn.toIso8601String(),
      'estado_sync': estado.name,
      'intentos': intentos,
      'detalle_sync': detalleSync,
    };
  }
}

String fechaLocalDe(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');

  return '${fecha.year}-$mes-$dia';
}
