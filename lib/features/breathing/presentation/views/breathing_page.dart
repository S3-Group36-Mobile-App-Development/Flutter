import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/breathing/domain/entities/breathing_exercice.dart';
import 'package:zenmind/features/breathing/domain/entities/movement_context.dart';

import '../viewmodels/breathing_view_model.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/star_rating.dart';

class BreathingPage extends StatefulWidget {
  final BreathingViewModel viewModel;

  const BreathingPage({super.key, required this.viewModel});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  late final BreathingViewModel _viewModel;
  final PageController _pageController = PageController(viewportFraction: 0.82);

  BreathingStatus _lastStatus = BreathingStatus.idle;

  static const _phaseHints = {
    'Inhala': 'Llena tus pulmones despacio por la nariz',
    'Sostén': 'Mantén el aire sin tensión',
    'Exhala': 'Suelta el aire lentamente por la boca',
  };

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }

  void _onViewModelChanged() {
    if (_viewModel.status == BreathingStatus.finished &&
        _lastStatus != BreathingStatus.finished) {
      _lastStatus = _viewModel.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRatingDialog();
      });
    } else {
      _lastStatus = _viewModel.status;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showRatingDialog() async {
    int stars = 0;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Ejercicio completado',
                textAlign: TextAlign.center,
                style: GoogleFonts.shortStack(
                  fontSize: 20,
                  color: AppColors.coffe,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Quieres calificar este ejercicio?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.livvic(
                      fontSize: 15,
                      color: AppColors.coffe,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StarRating(
                    value: stars,
                    onChanged: (value) => setDialogState(() => stars = value),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _viewModel.submitRating(stars: 0);
                    _viewModel.resetToSelection();
                  },
                  child: Text(
                    'Omitir',
                    style: GoogleFonts.livvic(color: AppColors.coffe),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clay,
                    foregroundColor: AppColors.coffe,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: stars == 0
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _viewModel.submitRating(stars: stars);
                          _viewModel.resetToSelection();
                        },
                  child: Text(
                    'Enviar',
                    style: GoogleFonts.shortStack(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.coffe,
        title: Text('Volver', style: GoogleFonts.shortStack(fontSize: 18)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading && _viewModel.exercices.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.clay),
              );
            }

            if (_viewModel.isBreathing) {
              return _buildRunningView();
            }

            return _buildSelectionView();
          },
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    final exercices = _viewModel.exercices;

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'R E S P I R A C I Ó N  G U I A D A',
          textAlign: TextAlign.center,
          style: GoogleFonts.shortStack(fontSize: 18, color: AppColors.coffe),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige un ejercicio para comenzar',
          textAlign: TextAlign.center,
          style: GoogleFonts.livvic(fontSize: 14, color: AppColors.coffe),
        ),
        const SizedBox(height: 12),
        if (!_viewModel.isOnline) _buildOfflineBanner(),
        if (_viewModel.message != null) _buildMessageBanner(),
        Expanded(
          child: exercices.isEmpty
              ? _buildEmptyState()
              : PageView.builder(
                  controller: _pageController,
                  itemCount: exercices.length,
                  onPageChanged: (index) {
                    _viewModel.selectExercice(exercices[index]);
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    return _buildExerciceCard(exercices[index]);
                  },
                ),
        ),
        _buildSelectionActions(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No hay ejercicios disponibles. '
          'Conéctate a internet para descargarlos.',
          textAlign: TextAlign.center,
          style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
        ),
      ),
    );
  }

  Widget _buildExerciceCard(BreathingExercice exercice) {
    final isFavorite =
        _viewModel.favorite != null && _viewModel.favorite!.id == exercice.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.peach.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.clay.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFavorite)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.clay,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Favorito',
                    style: GoogleFonts.livvic(
                      fontSize: 13,
                      color: AppColors.coffe,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              exercice.titulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.shortStack(
                fontSize: 22,
                color: AppColors.coffe,
              ),
            ),
            const SizedBox(height: 12),
            if (exercice.descripcion != null &&
                exercice.descripcion!.isNotEmpty)
              Text(
                exercice.descripcion!,
                textAlign: TextAlign.center,
                style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
              ),
            const SizedBox(height: 20),
            _cardInfoRow(Icons.timer_outlined, '${exercice.duracion} s'),
            const SizedBox(height: 6),
            _cardInfoRow(
              Icons.star_half_rounded,
              exercice.raitingAvg.toStringAsFixed(1),
            ),
            const SizedBox(height: 6),
            _cardInfoRow(Icons.favorite_outline, '${exercice.usageCount} usos'),
          ],
        ),
      ),
    );
  }

  Widget _cardInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.coffe),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
        ),
      ],
    );
  }

  Widget _buildSelectionActions() {
    final hasSelection = _viewModel.selected != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: hasSelection ? _viewModel.startBreathing : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: AppColors.coffe,
                disabledBackgroundColor: AppColors.clay.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Empezar',
                style: GoogleFonts.shortStack(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: hasSelection && !_viewModel.selectedIsFavorite
                  ? _viewModel.markSelectedAsFavorite
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coffe,
                side: const BorderSide(color: AppColors.coffe),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _viewModel.selectedIsFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
              label: Text(
                _viewModel.selectedIsFavorite
                    ? 'Es tu favorito'
                    : 'Marcar como favorito',
                style: GoogleFonts.shortStack(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningView() {
    final isStill = _viewModel.context == MovementContext.still;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _viewModel.selected?.titulo ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shortStack(
                    fontSize: 20,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  width: 220,
                  child: Center(
                    child: BreathingCircle(
                      phase: _viewModel.phase,
                      isBreathing: _viewModel.isBreathing,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _viewModel.phase,
                  style: GoogleFonts.shortStack(
                    fontSize: 30,
                    letterSpacing: 2,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_viewModel.secondsRemaining} s',
                  style: GoogleFonts.livvic(
                    fontSize: 36,
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
                const SizedBox(height: 16),
                Text(
                  'Ciclo ${_viewModel.currentCycle} de ${_viewModel.totalCycles}',
                  style: GoogleFonts.livvic(
                    fontSize: 16,
                    color: AppColors.coffe,
                  ),
                ),
                if (!isStill) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'Detectamos movimiento. Busca una posición estable.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(color: AppColors.coffe),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
        color: Colors.orange.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin conexión. Mostramos tu ejercicio favorito guardado.',
              style: GoogleFonts.livvic(fontSize: 13, color: AppColors.coffe),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBanner() {
    final hasError = _viewModel.hasError;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? Colors.red : AppColors.clay),
        color: hasError
            ? Colors.red.withValues(alpha: 0.08)
            : AppColors.peach.withValues(alpha: 0.4),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.error_outline : Icons.info_outline,
            color: hasError ? Colors.red : AppColors.coffe,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _viewModel.message!,
              style: GoogleFonts.livvic(fontSize: 13, color: AppColors.coffe),
            ),
          ),
        ],
      ),
    );
  }
}