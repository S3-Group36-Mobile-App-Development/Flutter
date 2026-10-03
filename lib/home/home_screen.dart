import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import 'package:zenmind/home/widgets/home_buttons.dart';

import '../features/authentication/presentation/viewmodels/auth_view_model.dart';
import '../features/authentication/presentation/views/welcome_page.dart';
import '../features/daily_review/daily_review_factory.dart';
import '../features/daily_review/presentation/views/daily_review_page.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const HomePage({super.key, required this.authViewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        toolbarHeight: 120,
        centerTitle: true,
        backgroundColor: AppColors.ivory,
        leading: const SizedBox(width: 48),
        title: Center(
          child: ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: 0.6,
              child: Image.asset(
                'lib/core/assets/images/zenmind_logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            color: AppColors.clay,
          ),
        ],
      ),

      // Scroll para que no se desborde en pantallas bajitas.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Botón del check-in: ocupa todo el ancho menos 16 a cada lado.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 120,
                child: ElevatedButton(
                  onPressed: _openDailyReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: AppColors.leucal,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'C H E C K - I N',
                          style: GoogleFonts.shortStack(
                            fontSize: 18,
                            letterSpacing: 2,
                            color: AppColors.coffe,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '¿Cómo te sientes hoy? Recibe tu card',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.livvic(
                          fontSize: 14,
                          color: AppColors.coffe,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            HomeButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openDailyReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReviewPage(
          repository: buildDailyReviewRepository(),
          isGuest: widget.authViewModel.isGuest,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await widget.authViewModel.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomePage(authViewModel: widget.authViewModel),
      ),
          (route) => false,
    );
  }
}