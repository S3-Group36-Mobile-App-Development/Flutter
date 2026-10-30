import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/features/games/domain/entities/game_session.dart';
import 'package:zenmind/features/games/domain/repositories/game_repository.dart';

class GameViewModel extends ChangeNotifier {
  final GameRepository _gameRepository;
  final ConnectivityService _connectivityService;

  GameViewModel({
    required this._gameRepository,
    required this._connectivityService,
  });

  // ESTADO
  List<GameSession> _sessions = [];
  List<GameSession> get sessions => _sessions;

  double? _averageDuration;
  double? get averageDuration => _averageDuration;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  String? _message;
  String? get message => _message;

  bool _hasError = false;
  bool get hasError => _hasError;

  StreamSubscription<bool>? _connectivitySubscription;

  // INICIALIZACIÓN
  Future<void> initialize({required bool isAuthenticated}) async {
    try {
      _isOnline = await _connectivityService.isConnected;
    } catch (_) {
      _isOnline = false;
    }

    // Escuchar cambios de conexión.
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen(
          (connected) {
            final wasOffline = !_isOnline;
            _isOnline = connected;
            notifyListeners();

            // Si recuperamos la conexión, intentamos sincronizar.
            if (wasOffline && connected && isAuthenticated) {
              syncPendingSessions(isAuthenticated: isAuthenticated);
            }

            if (wasOffline && connected) {
              _message = 'Conexión recuperada.';
              _hasError = false;
            } else if (!connected) {
              _message =
                  'No tienes conexión a internet. '
                  'Tus partidas se guardarán en el dispositivo '
                  'y se sincronizarán cuando vuelvas a conectarte.';
              _hasError = false;
            }

            notifyListeners();
          },
          onError: (_) {
            _isOnline = false;
            notifyListeners();
          },
        );

    await loadGameData();

    // Al iniciar, intentamos sincronizar si corresponde.
    if (_isOnline && isAuthenticated) {
      await syncPendingSessions(isAuthenticated: isAuthenticated);
    }
  }

  // CARGAR HISTORIAL Y PROMEDIO

  // GUARDAR UNA PARTIDA
  Future<bool> saveSession(
    GameSession session, {
    required bool isAuthenticated,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _hasError = false;
    _message = null;
    notifyListeners();

    try {
      // PASO 1: guardar primero en SQLite.
      await _gameRepository.saveSession(session);
    } on LocalDatabaseException {
      _message =
          'No se pudo guardar tu partida en el dispositivo. '
          'Tus resultados no quedaron registrados.';
      _hasError = true;

      return false;
    } catch (_) {
      _message = 'Ocurrió un error al guardar tu partida.';
      _hasError = true;

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    // PASO 2: actualizar la información local.
    await _refreshLocalData();

    // PASO 3: informar según la conexión y autenticación.
    if (!isAuthenticated) {
      _message =
          'Tu partida quedó guardada en este dispositivo. '
          'Inicia sesión para sincronizarla con tu cuenta.';
      _hasError = false;
    } else if (!_isOnline) {
      _message =
          'Tu partida quedó guardada en este dispositivo. '
          'Se sincronizará cuando vuelva la conexión.';
      _hasError = false;
    } else {
      // PASO 4: intentar sincronizar si hay conexión.
      await syncPendingSessions(isAuthenticated: isAuthenticated);

      // Si la sincronización no pudo completarse,
      // la partida sigue guardada localmente.
      if (_message == null) {
        _message = 'Tu partida se guardó correctamente.';
        _hasError = false;
      }
    }

    notifyListeners();
    return true;
  }

  // -------------------------
  // SINCRONIZAR PENDIENTES
  // -------------------------

  Future<void> syncPendingSessions({required bool isAuthenticated}) async {
    if (_isSyncing || !_isOnline || !isAuthenticated) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      await _gameRepository.syncPendingSessions();

      await _refreshLocalData();

      _message = 'Tus partidas se sincronizaron correctamente.';
      _hasError = false;
    } on NetworkException {
      _message =
          'No fue posible conectar con el servidor. '
          'Tus partidas siguen guardadas y se intentará '
          'sincronizarlas más tarde.';
      _hasError = false;
    } catch (_) {
      _message =
          'No se pudieron sincronizar tus partidas. '
          'Tus datos locales se conservarán para otro intento.';
      _hasError = false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // -------------------------
  // ACTUALIZAR INFORMACIÓN LOCAL
  // -------------------------

  Future<void> _refreshLocalData() async {
    try {
      _sessions = await _gameRepository.getSessionHistory();

      _averageDuration = await _gameRepository.getAverageDuration();
    } catch (_) {
      // No declaramos que falló el guardado:
      // esta operación solo actualiza la información visual.
    }
  }

  // -------------------------
  // LIMPIAR MENSAJE
  // -------------------------

  void clearMessage() {
    _message = null;
    _hasError = false;
    notifyListeners();
  }

  // -------------------------
  // CERRAR VIEWMODEL
  // -------------------------

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
