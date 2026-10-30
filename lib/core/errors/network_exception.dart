class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message =
        'Estas sin conexión, todo lo que hagas se guardara localmente',
  ]);

  @override
  String toString() => message;
}
