import 'package:flutter/material.dart';

import '../../data/services/sensor_service.dart';
import '../../data/services/vibration_service.dart';
import '../../domain/entities/movement_context.dart';
import '../viewmodels/breathing_view_model.dart';
import '../widgets/breathing_circle.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({
    super.key,
  });

  @override
  State<BreathingPage> createState() =>
      _BreathingPageState();
}

class _BreathingPageState
    extends State<BreathingPage> {
  late final BreathingViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = BreathingViewModel(
      sensorService: SensorService(),
      vibrationService: VibrationService(),
    );

    _viewModel.startSensor();
  }

  @override
  void dispose() {
    _viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final isStill =
            _viewModel.context ==
                MovementContext.still;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Respiración',
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Ejercicio de respiración',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _viewModel.contextMessage,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  BreathingCircle(
                    phase: _viewModel.phase,
                    isBreathing:
                        _viewModel.isBreathing,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    _viewModel.isBreathing
                        ? '${_viewModel.secondsRemaining}s'
                        : 'Movimiento: '
                            '${_viewModel.movement.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_viewModel.isBreathing)
                    Text(
                      'Ciclo ${_viewModel.currentCycle} '
                      'de ${_viewModel.totalCycles}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: isStill
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Text(
                      isStill
                          ? 'Contexto: usuario estable'
                          : 'Contexto: movimiento detectado',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  if (!_viewModel.isBreathing)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _viewModel.startBreathing,
                        child: const Text(
                          'Comenzar ejercicio',
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed:
                            _viewModel.stop,
                        child: const Text(
                          'Detener ejercicio',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}