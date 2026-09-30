import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nombreVisible,
    super.fotoPerfilUrl,
    required super.consentimientoDatos,
    required super.idiomaPreferido,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      nombreVisible: json['nombreVisible'] as String,
      fotoPerfilUrl: json['fotoPerfilUrl'] as String?,
      consentimientoDatos: json['consentimientoDatos'] as bool? ?? false,
      idiomaPreferido: json['idiomaPreferido'] as String? ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombreVisible': nombreVisible,
      'fotoPerfilUrl': fotoPerfilUrl,
      'consentimientoDatos': consentimientoDatos,
      'idiomaPreferido': idiomaPreferido,
    };
  }
}
