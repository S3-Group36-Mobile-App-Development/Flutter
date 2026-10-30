import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;

  final StreamController<double> _movementController =
      StreamController<double>.broadcast();

  Isolate? _movementIsolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;

  Stream<double> get movementStream => _movementController.stream;

  Future<void> start() async {
    await _subscription?.cancel();

    if (_movementIsolate == null) {
      await _createMovementIsolate();
    }

    _subscription = accelerometerEventStream().listen((event) {
      _sendPort?.send([event.x, event.y, event.z]);
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();

    _movementIsolate?.kill(priority: Isolate.immediate);
    _movementIsolate = null;

    _receivePort?.close();
    _receivePort = null;

    _sendPort = null;

    await _movementController.close();
  }

  Future<void> _createMovementIsolate() async {
    _receivePort = ReceivePort();

    final ready = Completer<void>();

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;

        if (!ready.isCompleted) {
          ready.complete();
        }
      } else if (message is double) {
        _movementController.add(message);
      }
    });

    _movementIsolate = await Isolate.spawn(
      _movementCalcWorker,
      _receivePort!.sendPort,
    );

    await ready.future;
  }

}

void _movementCalcWorker (SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();

  mainSendPort.send(workerReceivePort.sendPort);

  workerReceivePort.listen((message) {
    if (message is List<num>) {
      final x = message[0].toDouble();
      final y = message[1].toDouble();
      final z = message[2].toDouble();

      final acceleration = sqrt(x * x + y * y + z * z);

      mainSendPort.send(acceleration);
    }
  });

}