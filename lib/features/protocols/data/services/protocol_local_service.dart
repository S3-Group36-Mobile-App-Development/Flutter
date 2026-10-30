import 'package:zenmind/core/localDataBase/app_database.dart';
import 'package:zenmind/features/protocols/data/models/protocol_model.dart';

class ProtocolLocalService {
  final AppDatabase _localdatabase;

  ProtocolLocalService({required this._localdatabase});

  Future<void> saveSession(ProtocolModel protocol) async {
    final protocolData = {...protocol.toJson(), 'syncStatus': 'pending'};

    await _localdatabase.database.insert('protocols', protocolData);
  }

  Future<List<ProtocolModel>> getProtocols() async {
    final response = await _localdatabase.database.query('protocols');

    final List<ProtocolModel> protocols = [];

    for (final item in response) {
      final json = Map<String, dynamic>.from(item);
      final protocol = ProtocolModel.fromJson(json);

      protocols.add(protocol);
    }

    return protocols;
  }

  Future<List<ProtocolModel>> getPendingProtocols() async {
    final response = await _localdatabase.database.query(
      'protocols',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );

    final List<ProtocolModel> protocols = [];

    for (final item in response) {
      final json = Map<String, dynamic>.from(item);
      final protocol = ProtocolModel.fromJson(json);

      protocols.add(protocol);
    }

    return protocols;
  }

  Future<void> updateProtocolSyncStatus({
    required String protocolId,
    required String status,
  }) async {
    await _localdatabase.database.update(
      'protocols',
      {'syncStatus': status},
      where: 'id = ?',
      whereArgs: [protocolId],
    );
  }

  Future<void> deleteProtocol({required String protocolId}) async {
    await _localdatabase.database.delete(
      'protocols',
      where: 'id = ?',
      whereArgs: [protocolId],
    );
  }
}
