import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';

class CuestionarioDatabase {
  final Database database;

  CuestionarioDatabase._(this.database);

  static const String _crearCuestionarios = '''
    CREATE TABLE Cuestionarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuario_id TEXT NOT NULL,
      estado_animo_id INTEGER,
      estado_animo_nombre TEXT,
      nota TEXT,
      foto_nombre TEXT,
      fecha_local TEXT NOT NULL,
      creado_en TEXT NOT NULL,
      estado_sync TEXT NOT NULL,
      intentos INTEGER NOT NULL DEFAULT 0,
      detalle_sync TEXT
    )
  ''';

  static const String _crearIndiceCuestionarios = '''
    CREATE INDEX idx_Cuestionarios_usuario_fecha ON Cuestionarios (usuario_id, fecha_local)
  ''';

  static const String _crearEstadosAnimo = '''
    CREATE TABLE estados_animo_cache (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      orden INTEGER NOT NULL,
      guardado_en TEXT NOT NULL
    )
  ''';

  static const String _crearFlashcards = '''
    CREATE TABLE flashcards_cache (
      id INTEGER PRIMARY KEY,
      categoria TEXT NOT NULL,
      titulo TEXT NOT NULL,
      contenido TEXT NOT NULL,
      guardado_en TEXT NOT NULL
    )
  ''';

  static Future<CuestionarioDatabase> open() async {
    final ruta = p.join(await getDatabasesPath(), CuestionarioConfig.nombreBaseDatos);

    final database = await openDatabase(
      ruta,
      version: CuestionarioConfig.versionBaseDatos,
      onCreate: (db, version) async {
        await db.execute(_crearCuestionarios);
        await db.execute(_crearIndiceCuestionarios);
        await db.execute(_crearEstadosAnimo);
        await db.execute(_crearFlashcards);
      },
    );

    return CuestionarioDatabase._(database);
  }
}
