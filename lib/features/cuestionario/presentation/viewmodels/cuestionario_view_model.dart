import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';
import 'package:zenmind/features/cuestionario/data/models/cuestionario_entry.dart';
import 'package:zenmind/features/cuestionario/data/models/estado_animo.dart';
import 'package:zenmind/features/cuestionario/data/models/flashcard.dart';
import 'package:zenmind/features/cuestionario/data/models/racha.dart';
import 'package:zenmind/features/cuestionario/data/repositories/cuestionario_repository.dart';
import 'package:zenmind/features/cuestionario/data/services/photo_storage_service.dart';

enum PantallaCuestionario { cargando, sinCatalogo, formulario, guardando, listo }

class CuestionarioViewModel extends ChangeNotifier {
  final CuestionarioRepository _repositorio;
  final String _usuarioId;
  final bool _autenticado;
  bool _consentimiento;

  CuestionarioViewModel({
    required this._repositorio,
    required this._usuarioId,
    required this._autenticado,
    required this._consentimiento,
  }) {
    _repositorio.addListener(_alCambiarSincronizacion);
  }

  PantallaCuestionario _pantalla = PantallaCuestionario.cargando;
  List<EstadoAnimo> _estados = [];
  EstadoAnimo? _estadoSeleccionado;
  String _nota = '';
  String? _fotoNombre;
  File? _foto;
  int? _idBorrador;
  CuestionarioEntry? _cuestionarioDeHoy;
  Flashcard? _recomendacion;
  Racha _racha = Racha.vacia;
  String? _mensaje;
  bool _activandoConsentimiento = false;
  Timer? _temporizadorNota;
  Future<void> _colaGuardado = Future.value();
  bool _cerrado = false;

  PantallaCuestionario get pantalla => _pantalla;
  List<EstadoAnimo> get estados => _estados;
  EstadoAnimo? get estadoSeleccionado => _estadoSeleccionado;
  String get nota => _nota;
  File? get foto => _foto;
  CuestionarioEntry? get cuestionarioDeHoy => _cuestionarioDeHoy;
  Flashcard? get recomendacion => _recomendacion;
  Racha get racha => _racha;
  String? get mensaje => _mensaje;
  bool get activandoConsentimiento => _activandoConsentimiento;

  bool get puedeEnviar =>
      _estadoSeleccionado != null && _pantalla == PantallaCuestionario.formulario;

  bool get mostrarActivarConsentimiento =>
      _autenticado &&
      !_consentimiento &&
      _cuestionarioDeHoy?.estado == SyncStatus.soloLocal;

  bool get _puedeSincronizar => _autenticado && _consentimiento;

  Future<void> iniciar() async {
    _pantalla = PantallaCuestionario.cargando;
    _mensaje = null;
    _avisar();

    unawaited(_repositorio.precargarRecomendaciones());

    final deHoy = await _repositorio.cuestionarioDeHoy(_usuarioId);

    if (deHoy != null) {
      await _mostrarCuestionario(deHoy);
    } else {
      _estados = await _repositorio.obtenerEstados();

      if (_estados.isEmpty) {
        _mensaje =
            'Necesitamos internet una sola vez para descargar las opciones '
            'del check-in. Conéctate e intenta de nuevo.';
        _pantalla = PantallaCuestionario.sinCatalogo;
      } else {
        await _restaurarBorrador();
        _pantalla = PantallaCuestionario.formulario;
      }
    }

    _avisar();
    await _cargarRacha();

    if (_puedeSincronizar) {
      unawaited(_repositorio.sincronizarPendientes(_usuarioId));
    }
  }

  Future<void> _restaurarBorrador() async {
    final borrador = await _repositorio.borrador(_usuarioId);

    if (borrador != null) {
      _idBorrador = borrador.id;
      _estadoSeleccionado = _estados
          .where((estado) => estado.id == borrador.estadoAnimoId)
          .firstOrNull;
      _nota = borrador.nota ?? '';
      _fotoNombre = borrador.fotoNombre;
    }

    final nombreFoto = _fotoNombre;
    _foto = nombreFoto == null ? null : await _repositorio.archivoFoto(nombreFoto);

    final fotoPerdida = await _repositorio.recuperarFotoPerdida();
    if (fotoPerdida != null) await _reemplazarFoto(fotoPerdida);
  }

  void seleccionarEstado(EstadoAnimo estado) {
    _estadoSeleccionado = estado;
    _mensaje = null;
    _avisar();

    unawaited(_guardarBorrador());
  }

  void cambiarNota(String texto) {
    _nota = texto;

    _temporizadorNota?.cancel();
    _temporizadorNota = Timer(
      CuestionarioConfig.esperaAutoguardado,
      () => unawaited(_guardarBorrador()),
    );
  }

  Future<void> tomarFoto() async {
    try {
      final nombre = await _repositorio.tomarFoto();
      if (nombre == null) return;

      await _reemplazarFoto(nombre);
      _mensaje = null;
    } on FotoException catch (error) {
      _mensaje = error.message;
    }

    _avisar();
  }

  Future<void> quitarFoto() async {
    await _reemplazarFoto(null);
    _avisar();
  }

  Future<void> _reemplazarFoto(String? nuevoNombre) async {
    final anterior = _fotoNombre;
    if (anterior != null && anterior != nuevoNombre) {
      await _repositorio.borrarFoto(anterior);
    }

    _fotoNombre = nuevoNombre;
    _foto = nuevoNombre == null
        ? null
        : await _repositorio.archivoFoto(nuevoNombre);

    await _guardarBorrador();
  }

  Future<void> _guardarBorrador() {
    _colaGuardado = _colaGuardado.then((_) => _guardarBorradorAhora());

    return _colaGuardado;
  }

  Future<void> _guardarBorradorAhora() async {
    if (_pantalla == PantallaCuestionario.listo) return;

    final hayDatos =
        _estadoSeleccionado != null ||
        _nota.trim().isNotEmpty ||
        _fotoNombre != null;
    if (!hayDatos && _idBorrador == null) return;

    try {
      _idBorrador = await _repositorio.guardarBorrador(_armarCuestionario());
    } catch (error) {
      debugPrint('No se pudo guardar el borrador: $error');
    }
  }

  CuestionarioEntry _armarCuestionario() {
    final ahora = DateTime.now();
    final nota = _nota.trim();

    return CuestionarioEntry(
      id: _idBorrador,
      usuarioId: _usuarioId,
      estadoAnimoId: _estadoSeleccionado?.id,
      estadoAnimoNombre: _estadoSeleccionado?.nombre,
      nota: nota.isEmpty ? null : nota,
      fotoNombre: _fotoNombre,
      fechaLocal: fechaLocalDe(ahora),
      creadoEn: ahora,
      estado: SyncStatus.borrador,
    );
  }

  Future<void> enviar() async {
    if (!puedeEnviar) return;

    _temporizadorNota?.cancel();
    _pantalla = PantallaCuestionario.guardando;
    _avisar();

    try {
      await _guardarBorrador();
      await _repositorio.enviar(_armarCuestionario(), sincronizar: _puedeSincronizar);

      final guardado = await _repositorio.cuestionarioDeHoy(_usuarioId);
      if (guardado == null) throw StateError('El check-in no quedó guardado.');

      _idBorrador = null;
      await _mostrarCuestionario(guardado);
    } catch (_) {
      _mensaje = 'No pudimos guardar tu check-in en el teléfono. Intenta de nuevo.';
      _pantalla = PantallaCuestionario.formulario;
    }

    _avisar();
    await _cargarRacha();
  }

  Future<void> _mostrarCuestionario(CuestionarioEntry cuestionario) async {
    _cuestionarioDeHoy = cuestionario;
    _mensaje = _mensajePara(cuestionario);

    final nombreFoto = cuestionario.fotoNombre;
    _foto = nombreFoto == null ? null : await _repositorio.archivoFoto(nombreFoto);

    _recomendacion = await _repositorio.recomendacionPara(cuestionario.estadoAnimoNombre);
    _pantalla = PantallaCuestionario.listo;
  }

  String _mensajePara(CuestionarioEntry cuestionario) {
    switch (cuestionario.estado) {
      case SyncStatus.sincronizado:
        return 'Tu check-in quedó guardado en tu cuenta.';
      case SyncStatus.pendiente:
        return 'Tu check-in quedó guardado en este teléfono. '
            'Lo enviaremos a tu cuenta apenas haya conexión.';
      case SyncStatus.soloLocal:
        if (!_autenticado) {
          return 'Modo invitado: tu check-in se guardó solo en este teléfono.';
        }
        if (!_consentimiento) {
          return 'Tu check-in se guardó solo en este teléfono porque no has '
              'activado guardar tus datos en tu cuenta.';
        }
        final detalle = cuestionario.detalleSync;
        return detalle == null
            ? 'Tu check-in se guardó solo en este teléfono.'
            : 'Tu check-in se guardó solo en este teléfono. $detalle';
      case SyncStatus.borrador:
        return '';
    }
  }

  Future<void> _alCambiarSincronizacion() async {
    if (_cuestionarioDeHoy == null) return;

    final deHoy = await _repositorio.cuestionarioDeHoy(_usuarioId);
    if (_cerrado || deHoy == null) return;

    _cuestionarioDeHoy = deHoy;
    _mensaje = _mensajePara(deHoy);
    _avisar();

    await _cargarRacha();
  }

  Future<void> activarConsentimiento() async {
    if (_activandoConsentimiento) return;

    _activandoConsentimiento = true;
    _avisar();

    try {
      await _repositorio.activarConsentimiento(_usuarioId);
      _consentimiento = true;

      final deHoy = await _repositorio.cuestionarioDeHoy(_usuarioId);
      if (deHoy != null) await _mostrarCuestionario(deHoy);
    } catch (_) {
      _mensaje =
          'No pudimos activar esta opción. Revisa tu conexión e intenta de nuevo.';
    } finally {
      _activandoConsentimiento = false;
      _avisar();
    }

    await _cargarRacha();
  }

  Future<void> _cargarRacha() async {
    _racha = await _repositorio.rachaLocal(_usuarioId);
    _avisar();

    if (!_autenticado) return;

    final perfil = await _repositorio.perfilServidor();
    if (perfil == null || _cerrado) return;

    _consentimiento = perfil.consentimiento;
    if (perfil.consentimiento) _racha = perfil.racha;
    _avisar();
  }

  void _avisar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    _repositorio.removeListener(_alCambiarSincronizacion);

    if (_temporizadorNota?.isActive ?? false) {
      _temporizadorNota?.cancel();
      unawaited(_guardarBorrador());
    }

    super.dispose();
  }
}
