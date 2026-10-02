import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({required this._apiClient});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String nombreVisible,
    bool? consentimientoDatos,
    String? idiomaPreferido,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
      'nombreVisible': nombreVisible,
    };

    if (consentimientoDatos != null) {
      data['consentimientoDatos'] = consentimientoDatos;
    }

    if (idiomaPreferido != null) {
      data['idiomaPreferido'] = idiomaPreferido;
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: data,
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  Future<AuthResponseModel> loginWithGoogle({required String idToken}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.googleLogin,
      data: {'idToken': idToken},
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  Future<AuthResponseModel> refresh({required String refreshToken}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );

    return UserModel.fromJson(response.data!);
  }
}
