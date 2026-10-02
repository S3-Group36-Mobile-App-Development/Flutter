import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<User> register({
    required String email,
    required String password,
    required String nombreVisible,
  });

  Future<User> loginWithGoogle({required String idToken});

  Future<User> getCurrentUser();

  Future<void> logout();

  Future<void> continueAsGuest();

  Future<bool> hasSession();

  Future<bool> isGuestMode();
}
