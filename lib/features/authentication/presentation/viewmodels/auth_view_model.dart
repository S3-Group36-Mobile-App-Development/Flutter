import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = const AuthState.initial();
  User? _user;
  String? _errorMessage;

  AuthViewModel({required this._authRepository});

  AuthState get state => _state;

  User? get user => _user;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _state.status == AuthStatus.loading;

  bool get isAuthenticated => _state.status == AuthStatus.authenticated;

  bool get isGuest => _state.status == AuthStatus.guest;

  Future<void> initialize() async {
    _setLoading();

    try {
      final isGuest = await _authRepository.isGuestMode();

      if (isGuest) {
        _user = null;
        _errorMessage = null;
        _state = const AuthState.guest();

        notifyListeners();
        return;
      }

      final hasSession = await _authRepository.hasSession();

      if (!hasSession) {
        _user = null;
        _errorMessage = null;
        _state = const AuthState.unauthenticated();

        notifyListeners();
        return;
      }

      final user = await _authRepository.getCurrentUser();

      _user = user;
      _errorMessage = null;
      _state = const AuthState.authenticated();

      notifyListeners();
    } catch (error) {
      _user = null;
      _errorMessage = null;
      _state = const AuthState.unauthenticated();

      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = user;
      _errorMessage = null;
      _state = const AuthState.authenticated();

      notifyListeners();

      return true;
    } catch (error) {
      _handleError(error);

      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombreVisible,
  }) async {
    _setLoading();

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        nombreVisible: nombreVisible,
      );

      _user = user;
      _errorMessage = null;
      _state = const AuthState.authenticated();

      notifyListeners();

      return true;
    } catch (error) {
      _handleError(error);

      return false;
    }
  }

  Future<void> loginWithGoogle({required String idToken}) async {
    _setLoading();

    try {
      final user = await _authRepository.loginWithGoogle(idToken: idToken);

      _user = user;
      _errorMessage = null;
      _state = const AuthState.authenticated();

      notifyListeners();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> continueAsGuest() async {
    _setLoading();

    try {
      await _authRepository.continueAsGuest();

      _user = null;
      _errorMessage = null;
      _state = const AuthState.guest();

      notifyListeners();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> logout() async {
    _setLoading();

    try {
      await _authRepository.logout();

      _user = null;
      _errorMessage = null;
      _state = const AuthState.unauthenticated();

      notifyListeners();
    } catch (error) {
      _handleError(error);
    }
  }

  void setUnauthenticated() {
    _user = null;
    _errorMessage = null;
    _state = const AuthState.unauthenticated();

    notifyListeners();
  }

  void _setLoading() {
    _errorMessage = null;
    _state = const AuthState.loading();

    notifyListeners();
  }

  void _handleError(Object error) {
    _errorMessage = error.toString();
    _state = const AuthState.unauthenticated();

    notifyListeners();
  }
}
