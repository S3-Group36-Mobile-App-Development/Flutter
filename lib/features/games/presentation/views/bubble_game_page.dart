import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../viewmodels/game_view_model.dart';
import '../widgets/number_bubble.dart';

enum _GamePhase { notStarted, playing, finished }

class BubbleGamePage extends StatefulWidget {
  final GameViewModel viewModel;
  final bool isAuthenticated;

  const BubbleGamePage({
    super.key,
    required this.viewModel,
    required this.isAuthenticated,
  });

  @override
  State<BubbleGamePage> createState() => _BubbleGamePageState();
}

class _BubbleGamePageState extends State<BubbleGamePage> {
  static const int _totalBubbles = 20;
  static const double _bubbleSize = 58;

  final Random _random = Random();

  static const List<Color> _palette = [
    AppColors.clay,
    AppColors.eucalyptus,
    AppColors.peach,
    AppColors.pistachio,
    AppColors.leucal,
  ];

  _GamePhase _phase = _GamePhase.notStarted;

  List<Offset> _positions = [];

  Size _fieldSize = Size.zero;

  int _nextNumber = 1;

  int _errors = 0;
  int _correctTaps = 0;

  DateTime? _startTime;
  Duration _finalDuration = Duration.zero;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(isAuthenticated: widget.isAuthenticated);
  }

  void _startGame() {
    setState(() {
      _phase = _GamePhase.playing;
      _nextNumber = 1;
      _errors = 0;
      _correctTaps = 0;
      _hasSaved = false;
      _startTime = DateTime.now();
      _positions = _buildNonOverlappingPositions();
    });
    widget.viewModel.clearMessage();
  }

  List<Offset> _buildNonOverlappingPositions() {
    if (_fieldSize == Size.zero) return _positions;

    final maxX = (_fieldSize.width - _bubbleSize).clamp(0.0, double.infinity);
    final maxY = (_fieldSize.height - _bubbleSize).clamp(0.0, double.infinity);

    final minDistance = _bubbleSize + 6;

    final List<Offset> result = [];

    for (int i = 0; i < _totalBubbles; i++) {
      Offset candidate = Offset.zero;

      for (int attempt = 0; attempt < 60; attempt++) {
        candidate = Offset(
          _random.nextDouble() * maxX,
          _random.nextDouble() * maxY,
        );

        final overlaps = result.any(
          (other) => (other - candidate).distance < minDistance,
        );

        if (!overlaps) break;
      }

      result.add(candidate);
    }

    return result;
  }

  Color _colorFor(int number) {
    return _palette[(number - 1) % _palette.length];
  }

  void _onBubbleTap(int number) {
    if (_phase != _GamePhase.playing) return;

    if (number == _nextNumber) {
      setState(() {
        _correctTaps++;
        _nextNumber++;
      });

      if (_nextNumber > _totalBubbles) {
        _finishGame();
      }
    } else {
      setState(() {
        _errors++;
        _positions = _buildNonOverlappingPositions();
      });
    }
  }

  Future<void> _finishGame() async {
    if (_hasSaved) return;
    _hasSaved = true;

    final duration = DateTime.now().difference(_startTime!);

    setState(() {
      _finalDuration = duration;
      _phase = _GamePhase.finished;
    });

    await widget.viewModel.finishGame(
      durationMs: duration.inMilliseconds,
      errors: _errors,
      correctTaps: _correctTaps,
      isAuthenticated: widget.isAuthenticated,
    );
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
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
        child: Column(
          children: [
            if (_phase == _GamePhase.playing) _buildGameTitle(),
            Expanded(
              child: Stack(
                children: [
                  _buildBubbleField(),
                  if (_phase == _GamePhase.notStarted) _buildStartOverlay(),
                  if (_phase == _GamePhase.finished) _buildResultOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        children: [
          Text(
            'B U R B U J A S  E N  O R D E N',
            textAlign: TextAlign.center,
            style: GoogleFonts.shortStack(fontSize: 18, color: AppColors.coffe),
          ),
          const SizedBox(height: 4),
          Text(
            'Tócalas del 1 al 20 en orden',
            textAlign: TextAlign.center,
            style: GoogleFonts.livvic(fontSize: 13, color: AppColors.coffe),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (size != _fieldSize) {
          _fieldSize = size;
        }

        if (_phase != _GamePhase.playing) {
          return const SizedBox.expand();
        }

        return Stack(
          children: List.generate(_totalBubbles, (index) {
            final number = index + 1;
            final isDone = number < _nextNumber;
            final pos = _positions.length > index
                ? _positions[index]
                : Offset.zero;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              left: pos.dx,
              top: pos.dy,
              child: NumberBubble(
                number: number,
                color: _colorFor(number),
                size: _bubbleSize,
                isDone: isDone,
                onTap: () => _onBubbleTap(number),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: AppColors.ivory,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'B U R B U J A S  E N  O R D E N',
            textAlign: TextAlign.center,
            style: GoogleFonts.shortStack(fontSize: 20, color: AppColors.coffe),
          ),
          const SizedBox(height: 12),
          Text(
            'Toca las burbujas del 1 al 20 en orden.\n'
            'Si te equivocas, se reacomodarán.',
            textAlign: TextAlign.center,
            style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: AppColors.coffe,
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
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final elapsed = _finalDuration;

        return Container(
          color: AppColors.ivory.withValues(alpha: 0.97),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡J U E G O  C O M P L E T A D O!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shortStack(
                    fontSize: 20,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 24),
                _resultRow('Tiempo', _formatDuration(elapsed)),
                _resultRow('Aciertos', '$_correctTaps'),
                _resultRow('Errores', '$_errors'),
                if (vm.averageDuration != null)
                  _resultRow(
                    'Promedio histórico',
                    _formatDuration(
                      Duration(milliseconds: vm.averageDuration!.round()),
                    ),
                  ),
                const SizedBox(height: 20),

                if (vm.isSaving || vm.isSyncing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(color: AppColors.clay),
                  ),

                if (vm.message != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: vm.hasError ? Colors.red : AppColors.clay,
                      ),
                      color: vm.hasError
                          ? Colors.red.withValues(alpha: 0.08)
                          : AppColors.peach.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          vm.hasError
                              ? Icons.error_outline
                              : Icons.info_outline,
                          color: vm.hasError ? Colors.red : AppColors.coffe,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vm.message!,
                            style: GoogleFonts.livvic(
                              fontSize: 14,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clay,
                      foregroundColor: AppColors.coffe,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Jugar de nuevo',
                      style: GoogleFonts.shortStack(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coffe,
                      side: const BorderSide(color: AppColors.coffe),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Volver al inicio',
                      style: GoogleFonts.shortStack(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.livvic(fontSize: 16, color: AppColors.coffe),
          ),
          Text(
            value,
            style: GoogleFonts.shortStack(fontSize: 18, color: AppColors.coffe),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final seconds = d.inSeconds;
    final millis = (d.inMilliseconds % 1000) ~/ 10;
    return '$seconds.${millis.toString().padLeft(2, '0')} s';
  }
}
