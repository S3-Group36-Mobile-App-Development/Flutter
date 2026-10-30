import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../../../../home/home_screen.dart';
import '../../data/services/google_auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/google_sign_in_button.dart';
import '../utils/auth_validators.dart';
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.livvic(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.coffe,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(authViewModel: widget.authViewModel),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

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
      _goToHome();
      return;
    }

    _showMessage(
      widget.authViewModel.errorMessage ?? 'No se pudo iniciar sesión.',
    );
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final idToken = await _googleAuthService.signIn();

      if (idToken == null || idToken.isEmpty) {
        throw Exception('empty-token');
      }

      await widget.authViewModel.loginWithGoogle(idToken: idToken);

      if (!mounted) {
        return;
      }

      if (widget.authViewModel.isAuthenticated) {
        _goToHome();
        return;
      }

      _showMessage(
        widget.authViewModel.errorMessage ??
            'No se pudo iniciar sesión con Google.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('No se pudo iniciar sesión con Google. Inténtalo de nuevo.');
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
        final isBusy = isLoading || _isGoogleLoading;

        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            backgroundColor: AppColors.ivory,
            elevation: 0,
            foregroundColor: AppColors.coffe,
            title: Text(
              'Volver',
              style: GoogleFonts.livvic(color: AppColors.coffe),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shortStack(
                        fontSize: 26,
                        color: AppColors.coffe,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Inicia sesión para continuar',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(
                        fontSize: 15,
                        color: AppColors.coffe.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 36),

                    AuthTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'ejemplo@correo.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isBusy,
                      validator: AuthValidators.email,
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isBusy,
                      validator: AuthValidators.loginPassword,
                      suffixIcon: IconButton(
                        color: AppColors.clay,
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppColors.coffe,
                        backgroundColor: AppColors.eucalyptus,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.livvic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: isBusy ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.coffe,
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.coffe.withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o',
                            style: GoogleFonts.livvic(color: AppColors.coffe),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.coffe.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GoogleSignInButton(
                      isLoading: _isGoogleLoading,
                      onPressed: isBusy ? null : _loginWithGoogle,
                    ),
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
