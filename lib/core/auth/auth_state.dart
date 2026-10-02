enum AuthStatus { initial, loading, unauthenticated, authenticated, guest }

class AuthState {
  final AuthStatus status;

  const AuthState({required this.status});

  const AuthState.initial() : status = AuthStatus.initial;

  const AuthState.loading() : status = AuthStatus.loading;

  const AuthState.unauthenticated() : status = AuthStatus.unauthenticated;

  const AuthState.authenticated() : status = AuthStatus.authenticated;

  const AuthState.guest() : status = AuthStatus.guest;
}
