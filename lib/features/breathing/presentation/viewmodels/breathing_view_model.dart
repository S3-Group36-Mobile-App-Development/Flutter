import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/services/sensor_service.dart';
import '../../data/services/vibration_service.dart';
import '../../domain/entities/movement_context.dart';

class BreathingViewModel extends ChangeNotifier {
  final SensorService _sensorService;
  final VibrationService _vibrationService;

  StreamSubscription<double>? _movementSubscription;
  Timer? _breathingTimer;

  MovementContext _context = MovementContext.still;

  double _movement = 0;

  bool _isBreathing = false;

  int _secondsRemaining = 0;

  int _currentCycle = 0;

  final int _totalCycles = 5;

  String _phase = 'Listo para comenzar';

  BreathingViewModel({
    required SensorService sensorService,
    required VibrationService vibrationService,
  })  : _sensorService = sensorService,
        _vibrationService = vibrationService;

  MovementContext get context => _context;

  double get movement => _movement;

  bool get isBreathing => _isBreathing;

  int get secondsRemaining => _secondsRemaining;

  int get currentCycle => _currentCycle;

  int get totalCycles => _totalCycles;

  String get phase => _phase;

  bool get hasHighMovement =>
      _context == MovementContext.moving;

  String get contextMessage {
    if (_context == MovementContext.moving) {
      return 'Detectamos movimiento. Busca una posición estable antes de comenzar.';
    }

    return 'Tu movimiento es bajo. Estás listo para comenzar.';
  }

  void startSensor() {
    _sensorService.start();

    _movementSubscription?.cancel();

    _movementSubscription =
        _sensorService.movementStream.listen(
      _onMovementDetected,
    );
  }

  void _onMovementDetected(double value) {
    _movement = value;

    final movementDifference =
        (value - 9.8).abs();

    if (movementDifference > 2.0) {
      _context = MovementContext.moving;
    } else {
      _context = MovementContext.still;
    }

    notifyListeners();
  }

  Future<void> startBreathing() async {
    if (_isBreathing) {
      return;
    }

    if (hasHighMovement) {
      _phase = 'Busca una posición estable';

      _secondsRemaining = 0;

      notifyListeners();

      return;
    }

    _isBreathing = true;

    _currentCycle = 1;

    notifyListeners();

    await _runPhase(
      name: 'Inhala',
      seconds: 4,
    );

    await _runPhase(
      name: 'Sostén',
      seconds: 4,
    );

    await _runPhase(
      name: 'Exhala',
      seconds: 6,
    );

    for (int cycle = 2; cycle <= _totalCycles; cycle++) {
      if (!_isBreathing) {
        return;
      }

      _currentCycle = cycle;

      notifyListeners();

      await _runPhase(
        name: 'Inhala',
        seconds: 4,
      );

      await _runPhase(
        name: 'Sostén',
        seconds: 4,
      );

      await _runPhase(
        name: 'Exhala',
        seconds: 6,
      );
    }

    if (!_isBreathing) {
      return;
    }

    _phase = 'Ejercicio completado';

    _secondsRemaining = 0;

    _isBreathing = false;

    notifyListeners();
  }

  Future<void> _runPhase({
    required String name,
    required int seconds,
  }) async {
    if (!_isBreathing) {
      return;
    }

    _phase = name;

    _secondsRemaining = seconds;

    await _vibrationService.vibrate();

    notifyListeners();

    _breathingTimer?.cancel();

    final completer = Completer<void>();

    int remaining = seconds;

    _breathingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!_isBreathing) {
          timer.cancel();

          if (!completer.isCompleted) {
            completer.complete();
          }

          return;
        }

        remaining--;

        _secondsRemaining = remaining;

        notifyListeners();

        if (remaining <= 0) {
          timer.cancel();

          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
    );

    await completer.future;
  }

  Future<void> stop() async {
    _isBreathing = false;

    _breathingTimer?.cancel();

    _breathingTimer = null;

    _phase = 'Listo para comenzar';

    _secondsRemaining = 0;

    _currentCycle = 0;

    notifyListeners();
  }

  @override
  void dispose() {
    _movementSubscription?.cancel();

    _breathingTimer?.cancel();

    _sensorService.dispose();

    super.dispose();
  }
}