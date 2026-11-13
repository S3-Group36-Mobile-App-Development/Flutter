import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';
import 'package:zenmind/features/cuestionario/cuestionario_factory.dart';
import 'package:zenmind/features/cuestionario/data/repositories/cuestionario_repository.dart';
import 'package:zenmind/features/cuestionario/presentation/views/cuestionario_page.dart';

import 'package:zenmind/home/widgets/home_buttons.dart';

import '../features/authentication/presentation/viewmodels/auth_view_model.dart';
import '../features/authentication/presentation/views/welcome_page.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const HomePage({super.key, required this.authViewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CuestionarioRepository? _cuestionarioRepository;

  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((connected) {
          if (!mounted) return;
          setState(() => _isOffline = !connected);
        }, onError: (_) {});

    unawaited(_iniciarSincronizacionCuestionario());
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _cuestionarioRepository?.detenerSincronizacionAutomatica();
    super.dispose();
  }

  String get _usuarioCuestionario =>
      widget.authViewModel.user?.id ?? CuestionarioConfig.usuarioInvitado;

  Future<void> _iniciarSincronizacionCuestionario() async {
    if (!widget.authViewModel.isAuthenticated) return;

    final repositorio = await obtenerCuestionarioRepository();
    if (!mounted) return;

    _cuestionarioRepository = repositorio;
    repositorio.iniciarSincronizacionAutomatica(_usuarioCuestionario);
  }

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

      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isOffline) _buildOfflineBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 120,
                child: ElevatedButton(
                  onPressed: _abrirCuestionario,
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
            HomeButtons(isAuthenticated: widget.authViewModel.isAuthenticated),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
        color: Colors.orange.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No tienes conexión a internet. '
              'Algunas funciones pueden no estar disponibles.',
              style: GoogleFonts.livvic(fontSize: 13, color: AppColors.coffe),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirCuestionario() async {
    final repositorio = await obtenerCuestionarioRepository();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CuestionarioPage(
          repositorio: repositorio,
          usuarioId: _usuarioCuestionario,
          autenticado: widget.authViewModel.isAuthenticated,
          consentimiento:
              widget.authViewModel.user?.consentimientoDatos ?? false,
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
