import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  LoginViewModel({required this._authRepository});

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  User? get user => _user;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = user;
      _isLoading = false;

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
