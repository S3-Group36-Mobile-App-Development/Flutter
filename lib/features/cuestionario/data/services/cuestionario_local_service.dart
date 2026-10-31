import 'package:sqflite/sqflite.dart';
import 'package:zenmind/features/cuestionario/data/models/cuestionario_entry.dart';
import 'package:zenmind/features/cuestionario/data/models/estado_animo.dart';
import 'package:zenmind/features/cuestionario/data/models/flashcard.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_database.dart';

class CuestionarioLocalService {
  final CuestionarioDatabase _baseDatos;

  CuestionarioLocalService({required this._baseDatos});

  Database get _db => _baseDatos.database;


  Future<int> insertar(CuestionarioEntry cuestionario) {
    final datos = cuestionario.toMap()..remove('id'); // SQLite genera el id

    return _db.insert('cuestionarios', datos);
  }

  Future<void> actualizar(CuestionarioEntry cuestionario) async {
    await _db.update(
      'cuestionarios',
      cuestionario.toMap(),
      where: 'id = ?',
      whereArgs: [cuestionario.id],
    );
  }

  Future<void> actualizarSincronizacion({
    required int id,
    required SyncStatus estado,
    required int intentos,
    String? detalle,
  }) async {
    await _db.update(
      'cuestionarios',
      {'estado_sync': estado.name, 'intentos': intentos, 'detalle_sync': detalle},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<CuestionarioEntry?> obtenerBorrador(String usuarioId) async {
    final filas = await _db.query(
      'cuestionarios',
      where: 'usuario_id = ? AND estado_sync = ?',
      whereArgs: [usuarioId, SyncStatus.borrador.name],
      orderBy: 'id DESC',
      limit: 1,
    );

    return filas.isEmpty ? null : CuestionarioEntry.fromMap(filas.first);
  }

  Future<CuestionarioEntry?> obtenerDeFecha(String usuarioId, String fechaLocal) async {
    final filas = await _db.query(
      'cuestionarios',
      where: 'usuario_id = ? AND fecha_local = ? AND estado_sync != ?',
      whereArgs: [usuarioId, fechaLocal, SyncStatus.borrador.name],
      orderBy: 'id DESC',
      limit: 1,
    );

    return filas.isEmpty ? null : CuestionarioEntry.fromMap(filas.first);
  }

  Future<List<CuestionarioEntry>> obtenerPendientes(String usuarioId) async {
    final filas = await _db.query(
      'cuestionarios',
      where: 'usuario_id = ? AND estado_sync = ?',
      whereArgs: [usuarioId, SyncStatus.pendiente.name],
      orderBy: 'creado_en ASC', // el más antiguo primero
    );

    return filas.map(CuestionarioEntry.fromMap).toList();
  }

  Future<List<String>> fechasConCuestionario(String usuarioId) async {
    final filas = await _db.rawQuery(
      'SELECT DISTINCT fecha_local FROM cuestionarios '
      'WHERE usuario_id = ? AND estado_sync != ? '
      'ORDER BY fecha_local DESC',
      [usuarioId, SyncStatus.borrador.name],
    );

    return filas.map((fila) => fila['fecha_local'] as String).toList();
  }


  Future<List<EstadoAnimo>> leerEstados() async {
    final filas = await _db.query('estados_animo_cache', orderBy: 'orden ASC');

    return filas.map(EstadoAnimo.fromMap).toList();
  }

  Future<void> guardarEstados(List<EstadoAnimo> estados) async {
    final ahora = DateTime.now().toIso8601String();

    await _db.transaction((txn) async {
      await txn.delete('estados_animo_cache');

      for (final estado in estados) {
        await txn.insert('estados_animo_cache', {
          ...estado.toMap(),
          'guardado_en': ahora,
        });
      }
    });
  }

  Future<DateTime?> fechaCacheEstados() {
    return _fechaGuardado(
      'SELECT MIN(guardado_en) AS fecha FROM estados_animo_cache',
    );
  }


  Future<List<Flashcard>> leerFlashcards(String categoria) async {
    final filas = await _db.query(
      'flashcards_cache',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'id ASC',
    );

    return filas.map(Flashcard.fromMap).toList();
  }

  Future<void> guardarFlashcards(
    String categoria,
    List<Flashcard> flashcards,
  ) async {
    final ahora = DateTime.now().toIso8601String();

    await _db.transaction((txn) async {
      await txn.delete(
        'flashcards_cache',
        where: 'categoria = ?',
        whereArgs: [categoria],
      );

      for (final flashcard in flashcards) {
        await txn.insert(
          'flashcards_cache',
          {...flashcard.toMap(), 'guardado_en': ahora},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<DateTime?> fechaCacheFlashcards(String categoria) {
    return _fechaGuardado(
      'SELECT MIN(guardado_en) AS fecha FROM flashcards_cache WHERE categoria = ?',
      [categoria],
    );
  }

  Future<DateTime?> _fechaGuardado(
    String consulta, [
    List<Object?>? argumentos,
  ]) async {
    final filas = await _db.rawQuery(consulta, argumentos);
    final valor = filas.first['fecha'] as String?;

    return valor == null ? null : DateTime.parse(valor);
  }
}
