class User {
  final String id;
  final String email;
  final String nombreVisible;
  final String? fotoPerfilUrl;
  final bool consentimientoDatos;
  final String idiomaPreferido;

  const User({
    required this.id,
    required this.email,
    required this.nombreVisible,
    this.fotoPerfilUrl,
    required this.consentimientoDatos,
    required this.idiomaPreferido,
  });
}
