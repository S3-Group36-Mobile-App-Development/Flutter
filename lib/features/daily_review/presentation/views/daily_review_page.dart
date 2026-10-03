import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../breathing/presentation/views/breathing_page.dart';
import '../../domain/entities/mood.dart';
import '../../domain/repositories/daily_review_repository.dart';
import '../viewmodels/daily_review_view_model.dart';
import '../widgets/mood_chip.dart';
import '../widgets/recommendation_card_view.dart';
import '../widgets/streak_chips.dart';

class DailyReviewPage extends StatefulWidget {
  final DailyReviewRepository repository;
  final bool isGuest;

  const DailyReviewPage({
    super.key,
    required this.repository,
    required this.isGuest,
  });

  @override
  State<DailyReviewPage> createState() => _DailyReviewPageState();
}

class _DailyReviewPageState extends State<DailyReviewPage> {
  late final DailyReviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DailyReviewViewModel(
      repository: widget.repository,
      isGuest: widget.isGuest,
    );
    _viewModel.initialize();
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
        return Scaffold(
          backgroundColor: AppColors.ivory,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 32),
                  Expanded(child: _body()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    switch (_viewModel.status) {
      case CheckinStatus.loading:
      case CheckinStatus.saving:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.clay),
        );
      case CheckinStatus.form:
        return _form();
      case CheckinStatus.done:
        return _result();
    }
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.peach,
              border: Border.all(color: AppColors.eucalyptus, width: 2),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.coffe),
          ),
        ),
        Expanded(
          child: Text(
            'C H E C K - I N',
            textAlign: TextAlign.center,
            style: GoogleFonts.shortStack(fontSize: 20, color: AppColors.coffe),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo te sientes hoy?',
                  style: GoogleFonts.livvic(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tómate un instante para evaluar tu estado interno.',
                  style: GoogleFonts.livvic(
                    fontSize: 15,
                    color: AppColors.coffe.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                StreakChips(streak: _viewModel.streak),
                const SizedBox(height: 24),
                Row(
                  children: [
                    for (final mood in Mood.values) ...[
                      Expanded(
                        child: MoodChip(
                          mood: mood,
                          selected: _viewModel.selectedMood == mood,
                          onTap: () => _viewModel.selectMood(mood),
                        ),
                      ),
                      if (mood != Mood.values.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  '¿Quieres agregar algo más?',
                  style: GoogleFonts.livvic(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: _viewModel.updateNote,
                  maxLines: 5,
                  maxLength: 1000,
                  style: GoogleFonts.livvic(color: AppColors.coffe),
                  decoration: InputDecoration(
                    hintText: 'Describe brevemente cómo fluyen tus '
                        'pensamientos hoy...',
                    hintStyle: GoogleFonts.livvic(
                      color: AppColors.coffe.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: AppColors.peach,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.clay),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppColors.clay,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _viewModel.canSave ? _viewModel.save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.clay,
              foregroundColor: AppColors.coffe,
              disabledBackgroundColor: AppColors.clay.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Guardar Check-in',
              style: GoogleFonts.shortStack(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _result() {
    final card = _viewModel.card!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu card de hoy',
            style: GoogleFonts.livvic(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.coffe,
            ),
          ),
          if (_viewModel.message != null) ...[
            const SizedBox(height: 4),
            Text(
              _viewModel.message!,
              style: GoogleFonts.livvic(
                fontSize: 15,
                color: AppColors.coffe.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 20),
          StreakChips(streak: _viewModel.streak),
          const SizedBox(height: 24),
          RecommendationCardView(
            card: card,
            onAction: _openBreathing,
          ),
        ],
      ),
    );
  }

  void _openBreathing() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BreathingPage()),
    );
  }
}