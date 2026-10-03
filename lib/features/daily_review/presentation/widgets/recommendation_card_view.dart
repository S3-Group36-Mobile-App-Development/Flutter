import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/recommendation_card.dart';

class RecommendationCardView extends StatelessWidget {
  final RecommendationCard card;
  final VoidCallback onAction;

  const RecommendationCardView({
    super.key,
    required this.card,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.clay),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: GoogleFonts.livvic(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.coffe,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.message,
            style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
          ),
          const SizedBox(height: 12),
          ...card.steps.map(
                (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '•  $step',
                style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
              ),
            ),
          ),
          if (card.actionLabel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clay,
                  foregroundColor: AppColors.coffe,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  card.actionLabel!,
                  style: GoogleFonts.shortStack(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}