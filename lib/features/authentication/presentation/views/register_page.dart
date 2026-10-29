import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../../../../home/home_screen.dart';
import '../../widgets/auth_text_field.dart';
import '../utils/auth_validators.dart';
import '../viewmodels/auth_view_model.dart';

class RegisterPage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const RegisterPage({super.key, required this.authViewModel});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.authViewModel.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombreVisible: _nameController.text.trim(),
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

    _showMessage(
      widget.authViewModel.errorMessage ?? 'No se pudo crear la cuenta.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, child) {
        final isLoading = widget.authViewModel.isLoading;

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
                      'Crear cuenta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shortStack(
                        fontSize: 26,
                        color: AppColors.coffe,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Comienza tu experiencia en ZenMind',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(
                        fontSize: 15,
                        color: AppColors.coffe.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 36),

                    AuthTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Tu nombre',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                      validator: AuthValidators.name,
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'ejemplo@correo.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator: AuthValidators.email,
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: 'Mínimo 8 caracteres',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      validator: AuthValidators.newPassword,
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
                      onPressed: isLoading ? null : _register,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.coffe,
                              ),
                            )
                          : const Text('Crear cuenta'),
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
