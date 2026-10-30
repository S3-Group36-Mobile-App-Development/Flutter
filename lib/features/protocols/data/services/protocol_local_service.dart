import 'package:sqflite/sqflite.dart';
import 'package:zenmind/core/localDataBase/app_database.dart';
import 'package:zenmind/features/protocols/data/models/protocol_model.dart';
import 'package:zenmind/features/protocols/data/models/protocol_step_model.dart';

class ProtocolLocalService {
  final AppDatabase _localdatabase;

  ProtocolLocalService({required this._localdatabase});

  Future<void> saveSession(
    ProtocolModel protocol, {
    String syncStatus = 'synced',
  }) async {
    await _localdatabase.database.insert('protocols', {
      'id': protocol.id,
      'usuarioId': protocol.usuarioId,
      'titulo': protocol.titulo,
      'esPredefinido': protocol.esPredefinido ? 1 : 0,
      'syncStatus': syncStatus,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final paso in protocol.pasos) {
      await _localdatabase.database.insert('protocol_steps', {
        'id': paso.id,
        'protocoloId': protocol.id,
        'ordenPaso': paso.ordenPaso,
        'descripcion': paso.descripcion,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<ProtocolModel>> getProtocols() async {
    final response = await _localdatabase.database.query('protocols');

    final List<ProtocolModel> protocols = [];

    for (final item in response) {
      protocols.add(await _buildProtocol(item));
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
      protocols.add(await _buildProtocol(item));
    }

    return protocols;
  }

  Future<ProtocolModel> _buildProtocol(Map<String, dynamic> row) async {
    final id = row['id'].toString();

    final stepRows = await _localdatabase.database.query(
      'protocol_steps',
      where: 'protocoloId = ?',
      whereArgs: [id],
      orderBy: 'ordenPaso ASC',
    );

    final List<ProtocolStepModel> pasos = [];
    for (final step in stepRows) {
      pasos.add(
        ProtocolStepModel(
          id: step['id'].toString(),
          protocoloId: id,
          ordenPaso: step['ordenPaso'] as int,
          descripcion: step['descripcion'] as String,
        ),
      );
    }

    return ProtocolModel(
      id: id,
      usuarioId: row['usuarioId']?.toString(),
      titulo: row['titulo'] as String,
      esPredefinido: (row['esPredefinido'] as int) == 1,
      pasos: pasos,
    );
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
