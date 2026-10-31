import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';
import 'package:zenmind/features/cuestionario/data/models/cuestionario_entry.dart';
import 'package:zenmind/features/cuestionario/data/repositories/cuestionario_repository.dart';
import 'package:zenmind/features/cuestionario/presentation/viewmodels/cuestionario_view_model.dart';

class CuestionarioPage extends StatefulWidget {
  final CuestionarioRepository repositorio;
  final String usuarioId;
  final bool autenticado;
  final bool consentimiento;

  const CuestionarioPage({
    super.key,
    required this.repositorio,
    required this.usuarioId,
    required this.autenticado,
    required this.consentimiento,
  });

  @override
  State<CuestionarioPage> createState() => _CuestionarioPageState();
}

class _CuestionarioPageState extends State<CuestionarioPage> {
  late final CuestionarioViewModel _viewModel;
  final TextEditingController _notaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _viewModel = CuestionarioViewModel(
      repositorio: widget.repositorio,
      usuarioId: widget.usuarioId,
      autenticado: widget.autenticado,
      consentimiento: widget.consentimiento,
    );

    _iniciar();
  }

  Future<void> _iniciar() async {
    await _viewModel.iniciar();

    if (mounted) _notaController.text = _viewModel.nota;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.coffe,
        title: Text(
          'Check-in',
          style: GoogleFonts.shortStack(color: AppColors.coffe),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) => _contenido(),
        ),
      ),
    );
  }

  Widget _contenido() {
    switch (_viewModel.pantalla) {
      case PantallaCuestionario.cargando:
      case PantallaCuestionario.guardando:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.clay),
        );
      case PantallaCuestionario.sinCatalogo:
        return _sinCatalogo();
      case PantallaCuestionario.formulario:
        return _formulario();
      case PantallaCuestionario.listo:
        return _resultado();
    }
  }

  Widget _sinCatalogo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.coffe),
            const SizedBox(height: 16),
            Text(
              _viewModel.mensaje ?? '',
              textAlign: TextAlign.center,
              style: _texto(16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _iniciar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    final mensaje = _viewModel.mensaje;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '¿Cómo te sientes hoy?',
          style: GoogleFonts.shortStack(fontSize: 22, color: AppColors.coffe),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final estado in _viewModel.estados)
              ChoiceChip(
                label: Text(estado.nombre, style: _texto(16)),
                selected: _viewModel.estadoSeleccionado?.id == estado.id,
                selectedColor: AppColors.eucalyptus,
                onSelected: (_) => _viewModel.seleccionarEstado(estado),
              ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _notaController,
          onChanged: _viewModel.cambiarNota,
          maxLines: 4,
          maxLength: CuestionarioConfig.notaMaxCaracteres,
          style: _texto(16),
          decoration: const InputDecoration(
            labelText: '¿Quieres contar algo más? (opcional)',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _seccionFoto(),
        if (mensaje != null) ...[const SizedBox(height: 16), _aviso(mensaje)],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _viewModel.puedeEnviar ? _viewModel.enviar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.clay,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Guardar check-in',
            style: GoogleFonts.livvic(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        _filaRacha(),
      ],
    );
  }

  Widget _seccionFoto() {
    final foto = _viewModel.foto;

    if (foto == null) {
      return OutlinedButton.icon(
        onPressed: _viewModel.tomarFoto,
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Agregar una foto (opcional)'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.coffe),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _imagen(foto),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _viewModel.tomarFoto,
              icon: const Icon(Icons.refresh),
              label: const Text('Cambiar'),
            ),
            TextButton.icon(
              onPressed: _viewModel.quitarFoto,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultado() {
    final cuestionario = _viewModel.cuestionarioDeHoy;
    if (cuestionario == null) return const SizedBox.shrink();

    final nota = cuestionario.nota;
    final foto = _viewModel.foto;
    final mensaje = _viewModel.mensaje;
    final recomendacion = _viewModel.recomendacion;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Tu check-in de hoy',
          style: GoogleFonts.shortStack(fontSize: 22, color: AppColors.coffe),
        ),
        const SizedBox(height: 16),
        _tarjeta(
          children: [
            Text(
              cuestionario.estadoAnimoNombre ?? '',
              style: _texto(20, peso: FontWeight.w600),
            ),
            if (nota != null) ...[
              const SizedBox(height: 8),
              Text(nota, style: _texto(16)),
            ],
            if (foto != null) ...[const SizedBox(height: 12), _imagen(foto)],
            const SizedBox(height: 12),
            _estadoSincronizacion(cuestionario.estado),
          ],
        ),
        if (mensaje != null) ...[const SizedBox(height: 12), _aviso(mensaje)],
        if (_viewModel.mostrarActivarConsentimiento) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _viewModel.activandoConsentimiento
                ? null
                : _viewModel.activarConsentimiento,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.coffe),
            child: Text(
              _viewModel.activandoConsentimiento
                  ? 'Activando...'
                  : 'Guardar también en mi cuenta',
            ),
          ),
        ],
        if (recomendacion != null) ...[
          const SizedBox(height: 16),
          _tarjeta(
            color: AppColors.pistachio,
            children: [
              Text(
                'Para ti: ${recomendacion.titulo}',
                style: _texto(18, peso: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(recomendacion.contenido, style: _texto(16)),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _filaRacha(),
      ],
    );
  }

  Widget _estadoSincronizacion(SyncStatus estado) {
    final (icono, texto) = switch (estado) {
      SyncStatus.sincronizado => (Icons.cloud_done_outlined, 'Guardado en tu cuenta'),
      SyncStatus.pendiente => (Icons.schedule, 'Pendiente de envío'),
      SyncStatus.soloLocal => (Icons.phone_android, 'Solo en este teléfono'),
      SyncStatus.borrador => (Icons.edit_note, 'Borrador'),
    };

    return Row(
      children: [
        Icon(icono, size: 20, color: AppColors.coffe),
        const SizedBox(width: 6),
        Text(texto, style: _texto(14)),
      ],
    );
  }

  Widget _filaRacha() {
    final racha = _viewModel.racha;
    final dias = racha.actual == 1 ? 'día' : 'días';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.local_fire_department_outlined, color: AppColors.clay),
        const SizedBox(width: 6),
        Text(
          'Racha: ${racha.actual} $dias · Mejor: ${racha.mejor}',
          style: _texto(16),
        ),
      ],
    );
  }

  Widget _imagen(File foto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        foto,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: CuestionarioConfig.fotoAnchoEnPantalla,
      ),
    );
  }

  Widget _tarjeta({required List<Widget> children, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _aviso(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.coffe),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: _texto(15))),
        ],
      ),
    );
  }

  TextStyle _texto(double tamano, {FontWeight? peso}) {
    return GoogleFonts.livvic(
      fontSize: tamano,
      color: AppColors.coffe,
      fontWeight: peso,
    );
  }
}
