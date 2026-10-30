import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

class NumberBubble extends StatelessWidget {
  final int number;
  final Color color;
  final double size;
  final bool isDone;
  final VoidCallback onTap;

  const NumberBubble({
    super.key,
    required this.number,
    required this.color,
    required this.size,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? color.withValues(alpha: 0.25) : color,
          border: Border.all(
            color: AppColors.coffe.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: isDone
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.coffe.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isDone
              ? Icon(
                  Icons.check,
                  color: AppColors.coffe.withValues(alpha: 0.5),
                  size: size * 0.4,
                )
              : Text(
                  '$number',
                  style: GoogleFonts.shortStack(
                    fontSize: size * 0.34,
                    color: AppColors.coffe,
                  ),
                ),
        ),
      ),
    );
  }
}
