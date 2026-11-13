import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/core/errors/network_exception.dart';
import 'package:zenmind/features/protocols/data/models/protocol_model.dart';
import 'package:zenmind/features/protocols/data/services/protocol_api_service.dart';
import 'package:zenmind/features/protocols/data/services/protocol_cache_service.dart';
import 'package:zenmind/features/protocols/data/services/protocol_local_service.dart';
import 'package:zenmind/features/protocols/domain/entities/protocol.dart';
import 'package:zenmind/features/protocols/domain/repositories/protocol_repository.dart';

class ProtocolRepositoryImpl implements ProtocolRepository {
  final ProtocolApiService _protocolApiService;
  final ProtocolLocalService _protocollocalService;
  final ProtocolCacheService _protocolCacheService;

  ProtocolRepositoryImpl({
    required this._protocolApiService,
    required this._protocollocalService,
    required this._protocolCacheService,
  });

  @override
  Future<void> saveProtocol(Protocol protocol) async {
    final model = ProtocolModel.fromEntity(protocol);

    try {
      final saved = await _protocolApiService.postProtocol(protocol: model);
      _protocolCacheService.save(saved);
    } catch (e) {
      try {
        await _protocollocalService.saveSession(model, syncStatus: 'pending');
      } catch (e) {
        throw const LocalDatabaseException(
          'No se pudo guardar el protocolo en el dispositivo.',
        );
      }

      _protocolCacheService.save(protocol);
    }
  }

  @override
  Future<List<Protocol>> getProtocols() async {
    try {
      final protocols = await _protocolApiService.getProtocol();

      for (final protocol in protocols.take(_protocolCacheService.capacity)) {
        await _protocollocalService.saveSession(
          ProtocolModel.fromEntity(protocol),
        );
      }

      return protocols;
    } catch (e) {
      return await _protocollocalService.getProtocols();
    }
  }

  @override
  Future<void> syncPendingProtocols() async {
    final pendingProtocols = await _protocollocalService.getPendingProtocols();

    for (final protocol in pendingProtocols) {
      await _protocolApiService.postProtocol(protocol: protocol);

      await _protocollocalService.deleteProtocol(protocolId: protocol.id);
    }
  }

  @override
  Future<Protocol> updateProtocol(Protocol protocol) async {
    final updated = await _protocolApiService.putProtocol(
      protocol: ProtocolModel.fromEntity(protocol),
    );

    _protocolCacheService.save(updated);
    await _protocollocalService.saveSession(updated);

    return updated;
  }

  @override
  Future<Protocol> getProtocolForEdit(String protocolId) async {
    final cached = _protocolCacheService.getById(protocolId);
    if (cached != null) {
      return cached;
    }

    final local = await _protocollocalService.getProtocolById(
      protocolId: protocolId,
    );
    if (local != null) {
      _protocolCacheService.save(local);
      return local;
    }

    try {
      final remote = await _protocolApiService.getProtocolById(id: protocolId);
      _protocolCacheService.save(remote);
      await _protocollocalService.saveSession(remote);
      return remote;
    } catch (_) {
      throw const NetworkException(
        'No se pudo obtener el protocolo. Revisa tu conexión.',
      );
    }
  }
}
