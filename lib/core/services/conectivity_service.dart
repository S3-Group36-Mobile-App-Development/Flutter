import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  // Consultar el estado actual de la conexión.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();

    return _hasConnection(results);
  }

  // Escuchar los cambios de conexión.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }

  // Determinar si existe algún tipo de conexión.
  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
