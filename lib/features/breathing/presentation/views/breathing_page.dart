import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../../data/services/sensor_service.dart';
import '../../data/services/vibration_service.dart';
import '../../domain/entities/movement_context.dart';
import '../viewmodels/breathing_view_model.dart';
import '../widgets/breathing_circle.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  late final BreathingViewModel _viewModel;

  
  static const _phases = ['Inhala', 'Sostén', 'Exhala'];

  static const _phaseHints = {
    'Inhala': 'Llena tus pulmones despacio por la nariz',
    'Sostén': 'Mantén el aire sin tensión',
    'Exhala': 'Suelta el aire lentamente por la boca',
  };

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

  Widget _phaseChip(String phase) {
    final isActive = _viewModel.isBreathing && _viewModel.phase == phase;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.eucalyptus : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.eucalyptus : AppColors.coffe.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            phase,
            style: GoogleFonts.livvic(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: AppColors.coffe,
            ),
          ),
          if (isActive)
            Text(
              '${_viewModel.secondsRemaining}s',
              style: GoogleFonts.shortStack(fontSize: 16, color: AppColors.coffe),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final isStill = _viewModel.context == MovementContext.still;
        final isBreathing = _viewModel.isBreathing;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            backgroundColor: AppColors.ivory,
            title: Text('Respiración', style: GoogleFonts.shortStack()),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Text(
                    'Ejercicio de respiración',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.shortStack(
                      fontSize: 28,
                      color: AppColors.coffe,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _viewModel.contextMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.livvic(color: AppColors.coffe),
                  ),

                  const SizedBox(height: 24),

                  BreathingCircle(
                    phase: _viewModel.phase,
                    isBreathing: isBreathing,
                  ),

                  const SizedBox(height: 24),

                  // Fase actual + segundos
                  if (isBreathing) ...[
                    Text(
                      _viewModel.phase,
                      style: GoogleFonts.shortStack(
                        fontSize: 32,
                        letterSpacing: 2,
                        color: AppColors.coffe,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_viewModel.secondsRemaining} s',
                      style: GoogleFonts.livvic(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coffe,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _phaseHints[_viewModel.phase] ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(
                        fontSize: 14,
                        color: AppColors.coffe,
                      ),
                    ),
                  ] else
                    Text(
                      'Movimiento: ${_viewModel.movement.toStringAsFixed(2)}',
                      style: GoogleFonts.livvic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coffe,
                      ),
                    ),

                  const SizedBox(height: 20),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _phases.map(_phaseChip).toList(),
                  ),

                  const SizedBox(height: 16),

                  if (isBreathing)
                    Text(
                      'Ciclo ${_viewModel.currentCycle} de ${_viewModel.totalCycles}',
                      style: GoogleFonts.livvic(
                        fontSize: 16,
                        color: AppColors.coffe,
                      ),
                    ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isStill ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      isStill
                          ? 'Contexto: usuario estable'
                          : 'Contexto: movimiento detectado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(color: AppColors.coffe),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: isBreathing
                        ? OutlinedButton(
                            onPressed: _viewModel.stop,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.coffe,
                              side: const BorderSide(color: AppColors.coffe),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Detener ejercicio',
                              style: GoogleFonts.shortStack(fontSize: 18),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _viewModel.startBreathing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.eucalyptus,
                              foregroundColor: AppColors.coffe,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Comenzar ejercicio',
                              style: GoogleFonts.shortStack(fontSize: 18),
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