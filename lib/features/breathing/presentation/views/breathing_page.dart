import 'dart:async';

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

  bool _showWarning = false;
  Timer? _warningTimer;

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
    _viewModel.addListener(_checkMovement);
    _viewModel.startSensor();
  }

  void _checkMovement() {
    final isStill = _viewModel.context == MovementContext.still;

   
    if (!isStill && !_showWarning && _warningTimer == null) {
      if (!mounted) return;
      setState(() => _showWarning = true);
      _warningTimer = Timer(const Duration(seconds: 3), () {
        _warningTimer = null;
        if (!mounted) return;
        setState(() => _showWarning = false);
      });
    }
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    _viewModel.removeListener(_checkMovement);
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
          color: isActive
              ? AppColors.eucalyptus
              : AppColors.coffe.withValues(alpha: 0.3),
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
              style: GoogleFonts.shortStack(
                fontSize: 16,
                color: AppColors.coffe,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBox({
    required Key key,
    required Color color,
    required String message,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.livvic(color: AppColors.coffe),
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
            title: Text('Volver', style: GoogleFonts.shortStack(fontSize: 15)),
            foregroundColor:AppColors.coffe ,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          Text(
                            'R E S P I R A C I Ó N  G U I A D A',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.shortStack(
                              fontSize: 18,
                              color: AppColors.coffe,
                            ),
                          ),

                          const SizedBox(height: 15),
                           AnimatedSwitcher(
                            
                            duration: const Duration(milliseconds: 300),
                            child: _showWarning
                                ? _statusBox(
                                    key: const ValueKey('warning'),
                                    color: Colors.orange,
                                    message:
                                        'Deja de moverte y encuentra un lugar '
                                        'donde puedas parar a respirar',
                                  )
                                : (isStill && !isBreathing)
                                    ? _statusBox(
                                        key: const ValueKey('ready'),
                                        color: Colors.green,
                                        message: 'Ya estás listo para empezar',
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('none'),
                                      ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 220,
                            width: 220,
                            child: Center(
                              child: BreathingCircle(
                                phase: _viewModel.phase,
                                isBreathing: isBreathing,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

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
                          ],

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _phases.map(_phaseChip).toList(),
                          ),

                          const SizedBox(height: 16),

                          if (isBreathing)
                            Text(
                              'Ciclo ${_viewModel.currentCycle} '
                              'de ${_viewModel.totalCycles}',
                              style: GoogleFonts.livvic(
                                fontSize: 16,
                                color: AppColors.coffe,
                              ),
                            ),

                          const SizedBox(height: 16),

                         
                         

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: isBreathing
                        ? OutlinedButton(
                            onPressed: _viewModel.stop,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.coffe,
                              side: BorderSide(color: AppColors.coffe),
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
                            onPressed:
                                isStill ? _viewModel.startBreathing : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.eucalyptus,
                              foregroundColor: AppColors.coffe,
                              disabledBackgroundColor:
                                  AppColors.eucalyptus.withValues(alpha: 0.5),
                              disabledForegroundColor:
                                  AppColors.coffe.withValues(alpha: 0.5),
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