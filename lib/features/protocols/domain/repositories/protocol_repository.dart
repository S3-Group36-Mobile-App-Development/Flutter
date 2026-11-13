import 'package:zenmind/features/protocols/domain/entities/protocol.dart';

abstract class ProtocolRepository {
  // 1. Guardar un protocolo en el almacenamiento local y en cache por si se quiere actualizar .
  Future<void> saveProtocol(Protocol protocol);

  // 2. Consultar los protocolos y guardar los 5 mas importantes para cuando no hay internet.
  Future<List<Protocol>> getProtocols();

  // 3. Sincronizar los protocolos pendientes con el backend.
  Future<void> syncPendingProtocols();

  //4. Editar un protocolo existente del usuario, reutilizando la cache.
  Future<Protocol> updateProtocol(Protocol protocol);

  // 5. Obtener un protocolo para editarlo: busca primero en cache, luego en
  // local y por ultimo en el backend, para que abrir la edicion sea rapido.
  Future<Protocol> getProtocolForEdit(String protocolId);
}
