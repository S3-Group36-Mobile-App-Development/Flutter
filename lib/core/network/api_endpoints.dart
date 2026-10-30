class ApiEndpoints {
  //Endpoints AUTH
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const googleLogin = '/api/v1/auth/google';
  static const refresh = '/api/v1/auth/refresh';

  //Endpoints  Checkin
  static const me = '/api/v1/users/me';
  static const moods = '/api/v1/estados-animo';
  static const checkins = '/api/v1/chequeos';
  static const profile = '/api/v1/usuarios/me';

  //Endpoints Games

  static const uploadSesion = '/api/v1/juegos/sesiones';
  static const sessions = '/api/v1/juegos/sesiones';
}
