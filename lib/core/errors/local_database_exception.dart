class LocalDatabaseException implements Exception {
  final String message;

  const LocalDatabaseException([
    this.message = 'Ocurrió un error al acceder al almacenamiento local.',
  ]);

  @override
  String toString() => message;
}
