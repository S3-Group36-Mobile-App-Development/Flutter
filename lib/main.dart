import 'package:flutter/material.dart';

import 'core/auth/auth_state.dart';
import 'core/constants/api_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/data/services/auth_api_service.dart';
import 'features/authentication/presentation/viewmodels/auth_view_model.dart';
import 'features/authentication/presentation/views/welcome_page.dart';
import 'home/home_screen.dart';

void main() {
  final secureStorage = SecureStorageService();
  final localStorage = LocalStorageService();

  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: secureStorage,
  );

  final authApiService = AuthApiService(apiClient: apiClient);

  final authRepository = AuthRepositoryImpl(
    authApiService: authApiService,
    secureStorage: secureStorage,
    localStorage: localStorage,
  );

  final authViewModel = AuthViewModel(authRepository: authRepository);

  runApp(MyApp(authViewModel: authViewModel));
}

class MyApp extends StatefulWidget {
  final AuthViewModel authViewModel;

  const MyApp({super.key, required this.authViewModel});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    widget.authViewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authViewModel,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    final state = widget.authViewModel.state.status;

    switch (state) {
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.authenticated:
        return HomePage(authViewModel: widget.authViewModel);

      case AuthStatus.guest:
        return HomePage(authViewModel: widget.authViewModel);

      case AuthStatus.unauthenticated:
        return WelcomePage(authViewModel: widget.authViewModel);
    }
  }
}
