import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:zenmind/features/cuestionario/cuestionario_config.dart';

class FotoException implements Exception {
  final String message;

  const FotoException(this.message);

  @override
  String toString() => message;
}

class PhotoStorageService {
  final ImagePicker _picker;

  PhotoStorageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<String?> tomarFoto() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: CuestionarioConfig.fotoAnchoMaximo,
        imageQuality: CuestionarioConfig.fotoCalidad,
      );

      if (foto == null) return null;

      return await _guardar(foto);
    } on PlatformException {
      throw const FotoException(
        'No pudimos abrir la cámara. Revisa el permiso de cámara en los ajustes del teléfono.',
      );
    }
  }


  Future<String?> recuperarFotoPerdida() async {
    if (!Platform.isAndroid) return null;

    final respuesta = await _picker.retrieveLostData();
    final foto = respuesta.file;

    if (respuesta.isEmpty || foto == null) return null;

    return _guardar(foto);
  }

  Future<File?> archivo(String nombre) async {
    final carpeta = await _carpetaFotos();
    final archivo = File(p.join(carpeta.path, nombre));

    return await archivo.exists() ? archivo : null;
  }

  Future<void> borrar(String nombre) async {
    final foto = await archivo(nombre);

    if (foto != null) await foto.delete();
  }

  Future<String> _guardar(XFile foto) async {
    final carpeta = await _carpetaFotos();
    final tipo = p.extension(foto.path).isEmpty ? '.jpg' : p.extension(foto.path);
    final nombre = '${DateTime.now().millisecondsSinceEpoch}$tipo';

    await foto.saveTo(p.join(carpeta.path, nombre));

    return nombre;
  }

  Future<Directory> _carpetaFotos() async {
    final documentos = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(documentos.path, CuestionarioConfig.carpetaFotos));

    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    return carpeta;
  }
}
