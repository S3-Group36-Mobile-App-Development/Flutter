class Flashcard {
  final int id;
  final String categoria;
  final String titulo;
  final String contenido;

  const Flashcard({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.contenido,
  });

  factory Flashcard.fromMap(Map<String, Object?> map) {
    return Flashcard(
      id: int.parse(map['id'].toString()),
      categoria: map['categoria'] as String,
      titulo: map['titulo'] as String,
      contenido: map['contenido'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'categoria': categoria,
      'titulo': titulo,
      'contenido': contenido,
    };
  }
}
