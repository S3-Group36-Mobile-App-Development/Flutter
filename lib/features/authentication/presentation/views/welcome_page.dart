import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ZenMind',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const Text(
                'Tu espacio para cuidar tu bienestar.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Iniciar sesión
              ElevatedButton(
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
