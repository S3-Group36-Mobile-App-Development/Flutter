import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.livvic(color: AppColors.coffe);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      enabled: enabled,
      autocorrect: keyboardType != TextInputType.emailAddress,
      style: GoogleFonts.livvic(color: AppColors.coffe),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: labelStyle,
        hintStyle: labelStyle.copyWith(
          color: AppColors.coffe.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, color: AppColors.clay),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: border(AppColors.clay.withValues(alpha: 0.4), 1.5),
        focusedBorder: border(AppColors.clay, 2),
        errorBorder: border(Colors.red.shade400, 1.5),
        focusedErrorBorder: border(Colors.red.shade400, 2),
        errorStyle: GoogleFonts.livvic(
          color: Colors.red.shade700,
          fontSize: 12.5,
        ),
      ),
      validator: validator,
    );
  }
}
