import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  RegisterViewModel({required this._authRepository});

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  User? get user => _user;

  Future<bool> register({
    required String email,
    required String password,
    required String nombreVisible,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        nombreVisible: nombreVisible,
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
