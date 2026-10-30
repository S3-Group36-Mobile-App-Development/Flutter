import 'package:dio/dio.dart';
import 'package:zenmind/core/errors/local_database_exception.dart';
import 'package:zenmind/core/errors/network_exception.dart';
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
  Future<List<Protocol>> getProtocols() {
    // TODO: implement getProtocols
    throw UnimplementedError();
  }

  @override
  Future<void> saveProtocol(Protocol protocol) {
    // TODO: implement saveProtocol
    throw UnimplementedError();
  }

  @override
  Future<void> syncPendingProtocols() {
    // TODO: implement syncPendingProtocols
    throw UnimplementedError();
  }

  @override
  Future<void> updateProtocols() {
    // TODO: implement updateProtocols
    throw UnimplementedError();
  }
}
