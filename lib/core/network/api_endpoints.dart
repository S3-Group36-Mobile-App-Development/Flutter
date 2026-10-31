class ApiEndpoints {
  //Endpoints AUTH
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const googleLogin = '/api/v1/auth/google';
  static const refresh = '/api/v1/auth/refresh';

  //Endpoints  Checkin
  static const me = '/api/v1/users/me';
  static const moods = '/api/v1/estados-animo';
  static const cuestionarios = '/api/v1/chequeos';
  static const profile = '/api/v1/usuarios/me';
  static const flashcards = '/api/v1/flashcards';

  //Endpoints Breathing
  static const getExercices = '/api/v1/respira/ejercicios';
  static String breathingExercice(String id) =>
      '/api/v1/respira/ejercicios/$id';

  //Endpoints Games

  static const uploadSesion = '/api/v1/juegos/sesiones';
  static const sessions = '/api/v1/juegos/sesiones';

  //Endpoints protocols
  static const getAllProtocolos = '/api/v1/protocolos';
  static const createProtocolo = '/api/v1/protocolos';
  static String updateProtocolo(String id) => '/api/v1/protocolos/$id';
}
