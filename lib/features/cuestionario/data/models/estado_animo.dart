class EstadoAnimo {
  final int id;
  final String nombre;
  final int orden;

  const EstadoAnimo({
    required this.id,
    required this.nombre,
    required this.orden,
  });

  factory EstadoAnimo.fromMap(Map<String, Object?> map) {
    return EstadoAnimo(
      id: int.parse(map['id'].toString()),
      nombre: map['nombre'] as String,
      orden: int.tryParse(map['orden'].toString()) ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'nombre': nombre, 'orden': orden};
  }
}
