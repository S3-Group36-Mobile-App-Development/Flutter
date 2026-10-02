import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../../../../home/home_screen.dart';
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

  Future<void> _register() async {
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

    final error = widget.authViewModel.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'No se pudo crear la cuenta.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.ivory,
          appBar: AppBar(
            title: Text(
              'Volver',
              style: GoogleFonts.livvic(color: AppColors.coffe),
            ),
            backgroundColor: AppColors.ivory,
          ),
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
                      'C R E A R  C U E N T A',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shortStack(
                        fontSize: 22,
                        letterSpacing: 2,
                        color: AppColors.coffe,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Comienza tu experiencia en ZenMind.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.livvic(color: AppColors.coffe),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        hintText: 'Tu nombre',
                        hintStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre.';
                        }

                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

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
                        labelText: 'Contraseña',
                        labelStyle: GoogleFonts.livvic(color: AppColors.coffe),
                        hintStyle: GoogleFonts.livvic(color: AppColors.coffe),
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
                          return 'Ingresa una contraseña.';
                        }

                        if (value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres.';
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

                      onPressed: widget.authViewModel.isLoading
                          ? null
                          : _register,
                      child: widget.authViewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Crear cuenta',
                              style: GoogleFonts.livvic(color: AppColors.coffe),
                            ),
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
