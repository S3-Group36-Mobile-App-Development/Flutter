import 'user_model.dart';

class AuthResponseModel {
  final UserModel usuario;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.usuario,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      usuario: UserModel.fromJson(json['usuario'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
