import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl({
    required this._authApiService,
    required this._secureStorage,
    required this._localStorage,
  });

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _authApiService.login(
      email: email,
      password: password,
    );

    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _localStorage.clearGuestMode();

    return response.usuario;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String nombreVisible,
  }) async {
    final response = await _authApiService.register(
      email: email,
      password: password,
      nombreVisible: nombreVisible,
    );

    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _localStorage.clearGuestMode();

    return response.usuario;
  }

  @override
  Future<User> loginWithGoogle({required String idToken}) async {
    final response = await _authApiService.loginWithGoogle(idToken: idToken);

    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    await _localStorage.clearGuestMode();

    return response.usuario;
  }

  @override
  Future<User> getCurrentUser() async {
    return _authApiService.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteTokens();
    await _localStorage.clearGuestMode();
  }

  @override
  Future<void> continueAsGuest() async {
    await _secureStorage.deleteTokens();
    await _localStorage.setGuestMode(true);
  }

  @override
  Future<bool> hasSession() async {
    final accessToken = await _secureStorage.getAccessToken();

    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<bool> isGuestMode() async {
    return _localStorage.isGuestMode();
  }
}
