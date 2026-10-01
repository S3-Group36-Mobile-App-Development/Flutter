import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/core/theme/app_text_styles.dart';
import 'package:zenmind/features/authentication/presentation/views/login_page.dart';
import 'package:zenmind/features/authentication/presentation/views/register_page.dart';

import 'package:zenmind/home/home_screen.dart';

import '../viewmodels/auth_view_model.dart';

class WelcomePage extends StatelessWidget {
  final AuthViewModel authViewModel;

  const WelcomePage({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              SizedBox(
                height: 135,
                width: double.infinity,
                child: Image.asset(
                  'lib/core/assets/images/zenmind_logo.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              Text(
                'Z E N M I N D',
                textAlign: TextAlign.center,
                style: AppTextStyles.viewTitle,
              ),

              SizedBox(height: 16),

              Text(
                'Tu espacio para cuidar tu bienestar.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),

              SizedBox(height: 100),

              ElevatedButton(
                style: TextButton.styleFrom(
                  textStyle: GoogleFonts.livvic(
                    fontWeight: FontWeight.bold,
                    color: AppColors.clay,
                  ),
                  foregroundColor: AppColors.coffe,
                  backgroundColor: AppColors.clay,
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(authViewModel: authViewModel),
                    ),
                  );
                },
                child: const Text('Iniciar sesión'),
              ),

              const SizedBox(height: 12),

              // Crear cuenta
              OutlinedButton(
                style: TextButton.styleFrom(
                  textStyle: GoogleFonts.livvic(
                    fontWeight: FontWeight.bold,
                    color: AppColors.clay,
                  ),
                  foregroundColor: AppColors.clay,
                  side: const BorderSide(color: AppColors.clay, width: 2),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegisterPage(authViewModel: authViewModel),
                    ),
                  );
                },
                child: const Text('Crear cuenta'),
              ),

              const SizedBox(height: 12),

              // Continuar como invitado
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: GoogleFonts.livvic(
                    fontWeight: FontWeight.bold,
                    color: AppColors.clay,
                  ),
                  foregroundColor: AppColors.clay,
                ),
                onPressed: () async {
                  await authViewModel.continueAsGuest();

                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(authViewModel: authViewModel),
                    ),
                  );
                },
                child: const Text('Continuar como invitado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
