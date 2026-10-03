import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/streak.dart';

class StreakChips extends StatelessWidget {
  final Streak streak;

  const StreakChips({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _chip('🔥 Racha actual: ${_days(streak.current)}'),
        _chip('🏆 Mejor: ${_days(streak.best)}'),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pistachio,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.eucalyptus, width: 1.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.livvic(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.coffe,
        ),
      ),
    );
  }

  String _days(int value) => value == 1 ? '1 día' : '$value días';
}