class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message = 'No te encuentras conectado a internet, todo lo que hagas se guardara localmente hasta que recuperes tu conexión.',
  ]);

  @override
  String toString() => message;
}
