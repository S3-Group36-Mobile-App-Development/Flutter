import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zenmind/core/errors/network_exception.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/core/storage/secure_storage_service.dart';
import 'package:zenmind/features/breathing/data/repositories/breathing_repository.dart';
import 'package:zenmind/features/breathing/data/services/sensor_service.dart';
import 'package:zenmind/features/breathing/data/services/vibration_service.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_pattern.dart';
import 'package:zenmind/features/breathing/domain/entities/movement_context.dart';

enum BreathingStatus { idle, running, finished }

class BreathingViewModel extends ChangeNotifier {
  final BreathingRepository _repository;
  final SensorService _sensorService;
  final VibrationService _vibrationService;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorage;

  BreathingViewModel({
    required this._repository,
    required this._sensorService,
    required this._vibrationService,
    required this._connectivityService,
    required this._secureStorage,
  });

  List<BreathingExercice> _exercices = [];
  List<BreathingExercice> get exercices => _exercices;

  BreathingExercice? _selected;
  BreathingExercice? get selected => _selected;

  BreathingExercice? _favorite;
  BreathingExercice? get favorite => _favorite;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isSavingRating = false;
  bool get isSavingRating => _isSavingRating;

  String? _message;
  String? get message => _message;

  bool _hasError = false;
  bool get hasError => _hasError;

  BreathingStatus _status = BreathingStatus.idle;
  BreathingStatus get status => _status;
  bool get isBreathing => _status == BreathingStatus.running;

  MovementContext _context = MovementContext.still;
  MovementContext get context => _context;
  bool get hasHighMovement => _context == MovementContext.moving;

  String _phase = 'Listo para comenzar';
  String get phase => _phase;

  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  int _currentCycle = 0;
  int get currentCycle => _currentCycle;

  int get totalCycles => _activePattern?.cycles ?? 0;

  bool get selectedIsFavorite =>
      _selected != null && _selected!.id == _favorite?.id;

  BreathingPattern? _activePattern;

  StreamSubscription<double>? _movementSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> initialize() async {
    try {
      _isOnline = await _connectivityService.isConnected;
    } catch (_) {
      _isOnline = false;
    }

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen(
          (connected) {
            final wasOffline = !_isOnline;
            _isOnline = connected;

            if (wasOffline && connected) {
              _message = 'Conexión recuperada.';
              _hasError = false;
              loadExercices();
            }

            notifyListeners();
          },
          onError: (_) {
            _isOnline = false;
            notifyListeners();
          },
        );

    _startSensor();
    await loadExercices();
  }

  Future<void> loadExercices() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _exercices = await _repository.getExercices();
      _selected ??= _exercices.isEmpty ? null : _exercices.first;
      _hasError = false;
    } catch (_) {
      _message = 'No se pudieron cargar los ejercicios de respiración.';
      _hasError = true;
    }

    try {
      _favorite = await _repository.getFavorite();
    } catch (_) {
      _favorite = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectExercice(BreathingExercice exercice) {
    _selected = exercice;
  }

  Future<void> markSelectedAsFavorite() async {
    if (_selected == null) return;

    try {
      await _repository.saveFavorite(_selected!);
      _favorite = _selected;
      _message = 'Guardamos "${_selected!.titulo}" como tu favorito.';
      _hasError = false;
    } catch (_) {
      _message = 'No se pudo guardar tu favorito.';
      _hasError = true;
    }

    notifyListeners();
  }

  void _startSensor() {
    _sensorService.start();
    _movementSubscription?.cancel();
    _movementSubscription = _sensorService.movementStream.listen(
      _onMovementDetected,
    );
  }

  void _onMovementDetected(double value) {
    final next = (value - 9.8).abs() > 0.5
        ? MovementContext.moving
        : MovementContext.still;

    if (next == _context) return;
    _context = next;
    notifyListeners();
  }

  Future<void> startBreathing() async {
    if (_status == BreathingStatus.running || _selected == null) return;

    if (hasHighMovement) {
      _phase = 'Busca una posición estable';
      _secondsRemaining = 0;
      notifyListeners();
      return;
    }

    final pattern = BreathingPattern.fromMap(_selected!.patron);
    _activePattern = pattern;
    _status = BreathingStatus.running;
    _currentCycle = 0;
    notifyListeners();

    for (int cycle = 1; cycle <= pattern.cycles; cycle++) {
      _currentCycle = cycle;
      notifyListeners();

      await _runPhase('Inhala', pattern.inhaleSeconds);
      await _runPhase('Sostén', pattern.holdSeconds);
      await _runPhase('Exhala', pattern.exhaleSeconds);
      await _runPhase('Sostén', pattern.hold2Seconds);

      if (_status != BreathingStatus.running) return;
    }

    _phase = 'Ejercicio completado';
    _secondsRemaining = 0;
    _status = BreathingStatus.finished;
    notifyListeners();
  }

  Future<void> _runPhase(String name, int seconds) async {
    if (seconds <= 0 || _status != BreathingStatus.running) return;

    _phase = name;
    _secondsRemaining = seconds;
    if (_selected?.vibra ?? false) {
      await _vibrationService.vibrate();
    }
    notifyListeners();

    while (_secondsRemaining > 0) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (_status != BreathingStatus.running) return;
      _secondsRemaining--;
      notifyListeners();
    }
  }

  Future<void> submitRating({int? stars}) async {
    if (_selected == null) return;

    final bool rated = stars != null && stars > 0;

    _isSavingRating = true;
    notifyListeners();

    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      _message = rated
          ? 'Inicia sesión para calificar los ejercicios.'
          : 'Registramos que completaste el ejercicio.';
      _hasError = false;
      _isSavingRating = false;
      notifyListeners();
      return;
    }

    try {
      await _repository.rateExercise(
        id: _selected!.id,
        rating: rated ? stars : 0,
        optional: rated ? 1 : 0,
      );

      _message = rated
          ? 'Gracias por calificar este ejercicio.'
          : 'Registramos que completaste el ejercicio.';
      _hasError = false;
    } on NetworkException {
      _message =
          'No fue posible enviar tu calificación. '
          'Revisa tu conexión e inténtalo más tarde.';
      _hasError = false;
    } on DioException catch (e) {
      _message = e.response?.statusCode == 401
          ? 'Tu sesión expiró. Inicia sesión para calificar.'
          : 'No se pudo registrar tu calificación.';
      _hasError = false;
    } catch (_) {
      _message = 'No se pudo registrar tu calificación.';
      _hasError = false;
    } finally {
      _isSavingRating = false;
      notifyListeners();
    }
  }

  void stop() => resetToSelection();

  void resetToSelection() {
    _status = BreathingStatus.idle;
    _phase = 'Listo para comenzar';
    _secondsRemaining = 0;
    _currentCycle = 0;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
    _hasError = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _movementSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
