import 'package:dio/dio.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;

  factory AuthException.from(Object error, {String context = 'login'}) {
    if (error is AuthException) {
      return error;
    }

    if (error is DioException) {
      return AuthException(_mapDioError(error, context));
    }

    return const AuthException(
      'Ocurrió un error inesperado. Inténtalo de nuevo.',
    );
  }

  static String _mapDioError(DioException error, String context) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La conexión tardó demasiado. Revisa tu internet e '
            'inténtalo de nuevo.';
      case DioExceptionType.connectionError:
        return 'No pudimos conectarnos. Revisa tu conexión a internet.';
      case DioExceptionType.badCertificate:
        return 'No se pudo establecer una conexión segura.';
      case DioExceptionType.cancel:
        return 'La operación fue cancelada.';
      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response?.statusCode, context);
      case DioExceptionType.unknown:
        return 'No pudimos conectarnos. Revisa tu conexión a internet.';
      default:
        return 'No pudimos completar la operación. Inténtalo de nuevo.';
    }
  }

  static String _mapStatusCode(int? statusCode, String context) {
    switch (statusCode) {
      case 400:
        return 'Los datos ingresados no son válidos. Revísalos e '
            'inténtalo de nuevo.';
      case 401:
        if (context == 'login') {
          return 'Correo o contraseña incorrectos.';
        }
        return 'No pudimos verificar tu identidad. Inténtalo de nuevo.';
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'No encontramos el servicio. Inténtalo más tarde.';
      case 409:
        return 'Este correo ya está registrado. Inicia sesión.';
      case 422:
        return 'Los datos ingresados no son válidos. Revísalos e '
            'inténtalo de nuevo.';
      case 429:
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'El servidor no está disponible en este momento. '
            'Inténtalo más tarde.';
      default:
        return 'No pudimos completar la operación. Inténtalo de nuevo.';
    }
  }
}
