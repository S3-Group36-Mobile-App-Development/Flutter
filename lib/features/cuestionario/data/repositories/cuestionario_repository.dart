import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';
import 'package:zenmind/features/cuestionario/data/models/cuestionario_entry.dart';
import 'package:zenmind/features/cuestionario/data/models/estado_animo.dart';
import 'package:zenmind/features/cuestionario/data/models/flashcard.dart';
import 'package:zenmind/features/cuestionario/data/models/racha.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_api_service.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_local_service.dart';
import 'package:zenmind/features/cuestionario/data/services/photo_storage_service.dart';

class CuestionarioRepository extends ChangeNotifier {
  final CuestionarioApiService _apiService;
  final CuestionarioLocalService _localService;
  final PhotoStorageService _photoService;
  final ConnectivityService _connectivityService;

  CuestionarioRepository({
    required this._apiService,
    required this._localService,
    required this._photoService,
    required this._connectivityService,
  });

  List<EstadoAnimo>? _estadosEnMemoria;
  bool _sincronizando = false;
  bool _repetirSincronizacion = false;
  StreamSubscription<bool>? _suscripcionRed;
  
  Future<CuestionarioEntry?> cuestionarioDeHoy(String usuarioId) {
    return _localService.obtenerDeFecha(usuarioId, fechaLocalDe(DateTime.now()));
  }

  Future<CuestionarioEntry?> borrador(String usuarioId) {
    return _localService.obtenerBorrador(usuarioId);
  }

  Future<int> guardarBorrador(CuestionarioEntry borrador) async {
    final id = borrador.id;

    if (id == null) return _localService.insertar(borrador);

    await _localService.actualizar(borrador);
    return id;
  }

  Future<void> enviar(CuestionarioEntry borrador, {required bool sincronizar}) async {
    final ahora = DateTime.now();

    final cuestionario = CuestionarioEntry(
      id: borrador.id,
      usuarioId: borrador.usuarioId,
      estadoAnimoId: borrador.estadoAnimoId,
      estadoAnimoNombre: borrador.estadoAnimoNombre,
      nota: borrador.nota,
      fotoNombre: borrador.fotoNombre,
      fechaLocal: fechaLocalDe(ahora),
      creadoEn: ahora,
      estado: sincronizar ? SyncStatus.pendiente : SyncStatus.soloLocal,
    );

    await guardarBorrador(cuestionario);

    if (sincronizar) unawaited(sincronizarPendientes(cuestionario.usuarioId));
  }
  
  void iniciarSincronizacionAutomatica(String usuarioId) {
    detenerSincronizacionAutomatica();

    unawaited(sincronizarPendientes(usuarioId));

    _suscripcionRed = _connectivityService.onConnectivityChanged.listen((
      conectado,
    ) {
      if (conectado) unawaited(sincronizarPendientes(usuarioId));
    });
  }

  void detenerSincronizacionAutomatica() {
    _suscripcionRed?.cancel();
    _suscripcionRed = null;
  }

  Future<void> sincronizarPendientes(String usuarioId) async {
    if (_sincronizando) {
      _repetirSincronizacion = true;
      return;
    }

    _sincronizando = true;
    var huboCambios = false;

    try {
      if (!await _connectivityService.isConnected) return;

      final hoy = fechaLocalDe(DateTime.now());
      final pendientes = await _localService.obtenerPendientes(usuarioId);

      for (final cuestionario in pendientes) {
        if (cuestionario.fechaLocal != hoy) {
          await _marcar(
            cuestionario,
            SyncStatus.soloLocal,
            detalle: 'No se envió porque es de un día anterior.',
          );
          huboCambios = true;
          continue;
        }

        try {
          await _apiService.crearCuestionario(
            estadoAnimoId: cuestionario.estadoAnimoId!,
            comentario: cuestionario.nota,
          );
          await _marcar(cuestionario, SyncStatus.sincronizado);
          huboCambios = true;
        } on DioException catch (error) {
          final codigo = error.response?.statusCode;

          if (codigo == 409) {
            await _marcar(
              cuestionario,
              SyncStatus.sincronizado,
              detalle: 'El servidor ya tenía tu check-in de hoy.',
            );
            huboCambios = true;
          } else if (_esRechazoDefinitivo(codigo)) {
            await _marcar(
              cuestionario,
              SyncStatus.soloLocal,
              detalle: _mensajeRechazo(codigo),
            );
            huboCambios = true;
          } else {
            await _marcar(
              cuestionario,
              SyncStatus.pendiente,
              intentos: cuestionario.intentos + 1,
              detalle: 'Último intento falló (${error.type.name}).',
            );
            break;
          }
        }
      }
    } catch (error) {
      debugPrint('Sincronización del check-in falló: $error');
    } finally {
      _sincronizando = false;

      if (huboCambios) notifyListeners();

      if (_repetirSincronizacion) {
        _repetirSincronizacion = false;
        unawaited(sincronizarPendientes(usuarioId));
      }
    }
  }

  Future<void> activarConsentimiento(String usuarioId) async {
    await _apiService.activarConsentimiento();

    final deHoy = await cuestionarioDeHoy(usuarioId);

    if (deHoy != null && deHoy.estado == SyncStatus.soloLocal) {
      await _marcar(deHoy, SyncStatus.pendiente);
    }

    await sincronizarPendientes(usuarioId);
  }

  Future<void> _marcar(
    CuestionarioEntry cuestionario,
    SyncStatus estado, {
    int? intentos,
    String? detalle,
  }) {
    return _localService.actualizarSincronizacion(
      id: cuestionario.id!,
      estado: estado,
      intentos: intentos ?? cuestionario.intentos,
      detalle: detalle,
    );
  }

  bool _esRechazoDefinitivo(int? codigo) {
    if (codigo == null) return false;
    if (codigo == 401 || codigo == 408 || codigo == 429) return false;

    return codigo >= 400 && codigo < 500;
  }

  String _mensajeRechazo(int? codigo) {
    if (codigo == 403) {
      return 'El servidor no lo aceptó porque tu cuenta no tiene activado guardar tus datos.';
    }

    return 'El servidor rechazó el check-in (código $codigo).';
  }

  Future<List<EstadoAnimo>> obtenerEstados() async {
    final enMemoria = _estadosEnMemoria;
    if (enMemoria != null) return enMemoria;

    final guardados = await _localService.leerEstados();
    if (guardados.isEmpty) return _descargarEstados();

    _estadosEnMemoria = guardados;

    final fecha = await _localService.fechaCacheEstados();
    if (!_sigueVigente(fecha)) unawaited(_descargarEstados());

    return guardados;
  }

  Future<List<EstadoAnimo>> _descargarEstados() async {
    if (!await _connectivityService.isConnected) return [];

    try {
      final remotos = await _apiService.obtenerEstados();
      if (remotos.isEmpty) return [];

      await _localService.guardarEstados(remotos);
      _estadosEnMemoria = remotos;

      return remotos;
    } catch (_) {
      return [];
    }
  }


  Future<Flashcard?> recomendacionPara(String? nombreEstado) async {
    final categoria = CuestionarioConfig.categoriaFlashcardPorEstado[nombreEstado];
    if (categoria == null) return null;

    final flashcards = await _flashcardsDe(categoria);

    return flashcards.isEmpty ? null : flashcards.first;
  }

  Future<void> precargarRecomendaciones() async {
    final categorias = CuestionarioConfig.categoriaFlashcardPorEstado.values.toSet();

    for (final categoria in categorias) {
      await _flashcardsDe(categoria);
    }
  }

  Future<List<Flashcard>> _flashcardsDe(String categoria) async {
    final guardadas = await _localService.leerFlashcards(categoria);
    if (guardadas.isEmpty) return _descargarFlashcards(categoria);

    final fecha = await _localService.fechaCacheFlashcards(categoria);
    if (!_sigueVigente(fecha)) unawaited(_descargarFlashcards(categoria));

    return guardadas;
  }

  Future<List<Flashcard>> _descargarFlashcards(String categoria) async {
    if (!await _connectivityService.isConnected) return [];

    try {
      final remotas = await _apiService.obtenerFlashcards(categoria);
      await _localService.guardarFlashcards(categoria, remotas);

      return remotas;
    } catch (_) {
      return [];
    }
  }

  bool _sigueVigente(DateTime? fecha) {
    if (fecha == null) return false;

    return DateTime.now().difference(fecha) < CuestionarioConfig.vigenciaCache;
  }


  Future<Racha> rachaLocal(String usuarioId) async {
    final fechas = await _localService.fechasConCuestionario(usuarioId);

    return calcularRacha(fechas, DateTime.now());
  }

  Future<PerfilCuestionario?> perfilServidor() async {
    if (!await _connectivityService.isConnected) return null;

    try {
      final perfil = await _apiService.obtenerPerfil();
      final racha = perfil['racha'] as Map<String, dynamic>?;

      var actual = racha?['rachaActualDias'] as int? ?? 0;
      final mejor = racha?['rachaMasLargaDias'] as int? ?? 0;


      final ultimo = DateTime.tryParse(
        racha?['fechaUltimoCuestionario']?.toString() ?? '',
      );
      if (ultimo != null) {
        final ahora = DateTime.now().toUtc();
        final hoy = DateTime.utc(ahora.year, ahora.month, ahora.day);
        final dia = DateTime.utc(ultimo.year, ultimo.month, ultimo.day);

        if (hoy.difference(dia).inDays > 1) actual = 0;
      }

      return PerfilCuestionario(
        racha: Racha(actual: actual, mejor: mejor),
        consentimiento: perfil['consentimientoDatos'] == true,
      );
    } catch (_) {
      return null;
    }
  }


  Future<String?> tomarFoto() => _photoService.tomarFoto();

  Future<String?> recuperarFotoPerdida() => _photoService.recuperarFotoPerdida();

  Future<File?> archivoFoto(String nombre) => _photoService.archivo(nombre);

  Future<void> borrarFoto(String nombre) => _photoService.borrar(nombre);
}
