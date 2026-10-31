import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/features/protocols/domain/entities/protocol.dart';
import 'package:zenmind/features/protocols/domain/entities/protocol_step.dart';
import 'package:zenmind/features/protocols/domain/repositories/protocol_repository.dart';

class ProtocolViewModel extends ChangeNotifier {
  final ProtocolRepository _repository;
  final ConnectivityService _connectivityService;

  ProtocolViewModel({
    required this._repository,
    required this._connectivityService,
  });

  List<Protocol> _protocols = [];
  List<Protocol> get protocols => _protocols;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  String? _message;
  String? get message => _message;

  bool _hasError = false;
  bool get hasError => _hasError;

  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> initialize() async {
    try {
      _isOnline = await _connectivityService.isConnected;
    } catch (_) {
      _isOnline = false;
    }

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((connected) {
          final wasOffline = !_isOnline;
          _isOnline = connected;

          if (wasOffline && connected) {
            _repository.syncPendingProtocols().catchError((_) {});
            loadProtocols();
          }

          notifyListeners();
        }, onError: (_) {});

    await loadProtocols();
  }

  Future<void> loadProtocols() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _protocols = await _repository.getProtocols();
      _hasError = false;
    } catch (_) {
      _message = 'No se pudieron cargar los protocolos.';
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProtocol({
    required String titulo,
    required List<String> pasos,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _hasError = false;
    _message = null;
    notifyListeners();

    final protocol = Protocol(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      esPredefinido: false,
      pasos: [
        for (var i = 0; i < pasos.length; i++)
          ProtocolStep(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            protocoloId: '',
            ordenPaso: i + 1,
            descripcion: pasos[i].trim(),
          ),
      ],
    );

    try {
      await _repository.saveProtocol(protocol);
      _message = _isOnline
          ? 'Protocolo creado correctamente.'
          : 'Protocolo guardado. Se enviará cuando vuelva la conexión.';
      _hasError = false;
      await loadProtocols();
      return true;
    } catch (_) {
      _message = 'No se pudo crear el protocolo.';
      _hasError = true;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessage() {
    _message = null;
    _hasError = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
