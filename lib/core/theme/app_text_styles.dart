import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Short Stack: botones principales y títulos de vistas
  static TextStyle get viewTitle => GoogleFonts.shortStack(
    fontSize: 28,
    letterSpacing: 2,
    color: AppColors.clay,
  );

  static TextStyle get button => GoogleFonts.shortStack(
    fontSize: 18,
    letterSpacing: 1.5,
    color: Color(0xFF3A2414),
  );

  // Livvic: texto de flashcards y texto estándar
  static TextStyle get flashcard => GoogleFonts.livvic(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0xFF2F3A2A),
  );

  static TextStyle get bodyLarge =>
      GoogleFonts.livvic(fontSize: 18, height: 1.5, color: Color(0xFF2F3A2A));

  static TextStyle get body =>
      GoogleFonts.livvic(fontSize: 16, height: 1.5, color: Color(0xFF2F3A2A));

  static TextStyle get caption =>
      GoogleFonts.livvic(fontSize: 13, color: Color(0xFF5C6650));
}
