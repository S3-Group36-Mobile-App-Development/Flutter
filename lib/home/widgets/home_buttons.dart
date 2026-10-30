import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/breathing/presentation/views/breathing_page.dart';
import 'package:zenmind/features/games/game_factory.dart';
import 'package:zenmind/features/games/presentation/views/bubble_game_page.dart';

class HomeButtons extends StatelessWidget {
  final bool isAuthenticated;

  const HomeButtons({super.key, this.isAuthenticated = false});

  Future<void> _openGame(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: AppColors.clay)),
    );

    final viewModel = await buildGameViewModel();

    if (!context.mounted) return;
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BubbleGamePage(
          viewModel: viewModel,
          isAuthenticated: isAuthenticated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Color(0xFF9D99A6),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/panic_button(b&w).png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'P Á N I C O',
                            style: GoogleFonts.shortStack(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Color(0xFFEAE6E9),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/support_button(b&w).png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'A P O Y O',
                            style: GoogleFonts.shortStack(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Color(0xFF9D99A6),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/flashcards_button(b&w).png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'F L A S H C A R D S',
                            style: GoogleFonts.shortStack(
                              fontSize: 18,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BreathingPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
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
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/breathing_button.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'R E S P I R A',
                            style: GoogleFonts.shortStack(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Color(0xFF9D99A6),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/protocols_button(b&w).png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'P R O T O C O L O S',
                            style: GoogleFonts.shortStack(
                              fontSize: 18,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () => _openGame(context),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 170),
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
                      children: [
                        Expanded(
                          child: Image.asset(
                            'lib/core/assets/images/games_button.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'J U E G O S',
                            style: GoogleFonts.shortStack(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: AppColors.coffe,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
