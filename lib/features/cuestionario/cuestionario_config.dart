/// Valores de configuración del check-in, todos en un solo lugar.
class CuestionarioConfig {
  CuestionarioConfig._();

  static const String nombreBaseDatos = 'checkin.db';
  static const int versionBaseDatos = 1;
  static const String carpetaFotos = 'checkin_photos';

  static const double fotoAnchoMaximo = 1080;
  static const int fotoCalidad = 70;

  static const int fotoAnchoEnPantalla = 720;

  static const int notaMaxCaracteres = 1000;
  static const Duration esperaAutoguardado = Duration(milliseconds: 500);

  static const Duration vigenciaCache = Duration(days: 7);

  static const String usuarioInvitado = 'invitado';

  static const Map<String, String> categoriaFlashcardPorEstado = {
    'Ansioso': 'Ansiedad',
    'Estresado': 'Estrés',
  };
}
