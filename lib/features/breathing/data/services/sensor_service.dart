import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;

  final StreamController<double> _movementController =
      StreamController<double>.broadcast();

  Stream<double> get movementStream => _movementController.stream;

  void start() {
    _subscription?.cancel();

    _subscription = accelerometerEventStream().listen(
      (event) {
        final acceleration = sqrt(
          event.x * event.x +
              event.y * event.y +
              event.z * event.z,
        );

        _movementController.add(acceleration);
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _movementController.close();
  }
}