import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mood.dart';

class MoodChip extends StatelessWidget {
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  const MoodChip({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 96,
        decoration: BoxDecoration(
          color: selected ? AppColors.eucalyptus : AppColors.peach,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.eucalyptus : AppColors.clay,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffe.withValues(alpha: 0.12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mood.label,
                style: GoogleFonts.livvic(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.coffe,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}