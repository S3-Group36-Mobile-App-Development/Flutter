import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zenmind/core/errors/network_exception.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/features/breathing/data/repositories/breathing_repository.dart';
import 'package:zenmind/features/breathing/data/services/sensor_service.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_pattern.dart';
import 'package:zenmind/features/breathing/domain/entities/movement_context.dart';

enum BreathingStatus { idle, running, finished }

class BreathingViewModel extends ChangeNotifier {
  static const double _gravity = 9.8;
  static const double _movementThreshold = 0.5;

  final BreathingRepository _repository;
  final SensorService _sensorService;
  final ConnectivityService _connectivityService;

  BreathingViewModel({
    required this._repository,
    required this._sensorService,
    required this._connectivityService,
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
  Timer? _messageTimer;

  Future<void> initialize() async {
    try {
      _isOnline = await _connectivityService.isConnected;
    } catch (_) {
      _isOnline = false;
    }

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen(
          _onConnectivityChanged,
          onError: (_) {
            _isOnline = false;
            notifyListeners();
          },
        );

    _startSensor();

    if (_isOnline) {
      await _syncPendingRatings();
    }

    await loadExercices();
  }

  void _onConnectivityChanged(bool connected) {
    final wasOffline = !_isOnline;
    _isOnline = connected;

    if (wasOffline && connected) {
      _message = 'Conexión recuperada. Sal y vuelve a entrar para cargar todos lor ejercicios.';
      _hasError = false;
      _scheduleMessageDismiss();
      _syncPendingRatings();
      loadExercices();
    } else if (!connected) {
      _message = 'No tienes conexión';
      _hasError = false;
    }

    notifyListeners();
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

  Future<void> _syncPendingRatings() async {
    try {
      await _repository.syncPendingRatings();
    } catch (_) {}
  }

  void _startSensor() {
    _sensorService.start();
    _movementSubscription?.cancel();
    _movementSubscription = _sensorService.movementStream.listen(
      _onMovementDetected,
    );
  }

  void _onMovementDetected(double value) {
    final next = (value - _gravity).abs() > _movementThreshold
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

    final phases = <({String name, int seconds})>[
      (name: 'Inhala', seconds: pattern.inhaleSeconds),
      (name: 'Sostén', seconds: pattern.holdSeconds),
      (name: 'Exhala', seconds: pattern.exhaleSeconds),
      (name: 'Sostén', seconds: pattern.hold2Seconds),
    ];

    for (int cycle = 1; cycle <= pattern.cycles; cycle++) {
      _currentCycle = cycle;
      notifyListeners();

      for (final phase in phases) {
        await _runPhase(phase.name, phase.seconds);
      }

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
          'No tienes conexión. Guardamos tu calificación y se '
          'enviará automáticamente cuando vuelva el internet.';
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

  // Oculta el mensaje automaticamente tras 10 segundos.
  void _scheduleMessageDismiss() {
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 10), () {
      _message = null;
      _hasError = false;
      notifyListeners();
    });
  }

  void clearMessage() {
    _messageTimer?.cancel();
    _message = null;
    _hasError = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _movementSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
