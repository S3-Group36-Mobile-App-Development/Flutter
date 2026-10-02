import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../../../../home/home_screen.dart';
import '../../data/services/google_auth_service.dart';
import '../viewmodels/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoginPage({super.key, required this.authViewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.authViewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(authViewModel: widget.authViewModel),
        ),
      );

      return;
    }

    final error = widget.authViewModel.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'No se pudo iniciar sesión.')),
    );
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final idToken = await _googleAuthService.signIn();

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google no devolvió un ID Token.');
      }

      await widget.authViewModel.loginWithGoogle(idToken: idToken);

      if (!mounted) {
        return;
      }

      if (widget.authViewModel.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(authViewModel: widget.authViewModel),
          ),
        );

        return;
      }

      final error = widget.authViewModel.errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'No se pudo iniciar sesión con Google.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error con Google: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, child) {
        final isLoading = widget.authViewModel.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Volver',
              style: GoogleFonts.livvic(color: AppColors.coffe),
            ),
            backgroundColor: AppColors.ivory,
          ),
          backgroundColor: AppColors.ivory,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    Text(
                      'B I E N V E N I D O ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shortStack(
                        fontSize: 22,
                        letterSpacing: 2,
                        color: AppColors.coffe,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Inicia sesión para continuar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(color: AppColors.coffe),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        hintStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        labelText: 'Correo electrónico',
                        hintText: 'ejemplo@correo.com',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu correo electrónico.';
                        }

                        if (!value.contains('@')) {
                          return 'Ingresa un correo electrónico válido.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: GoogleFonts.livvic(
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: AppColors.coffe,
                        backgroundColor: AppColors.eucalyptus,
                      ),
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Iniciar sesión'),
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton(
                      style: TextButton.styleFrom(
                        textStyle: GoogleFonts.livvic(
                          fontWeight: FontWeight.bold,
                          color: AppColors.eucalyptus,
                        ),
                        foregroundColor: AppColors.eucalyptus,
                        side: const BorderSide(
                          color: AppColors.eucalyptus,
                          width: 2,
                        ),
                      ),
                      onPressed: isLoading || _isGoogleLoading
                          ? null
                          : _loginWithGoogle,

                      child: _isGoogleLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continuar con Google'),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
