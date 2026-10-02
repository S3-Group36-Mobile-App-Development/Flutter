import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  bool _isRefreshing = false;

  ApiClient({required String baseUrl, required this._secureStorage})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _secureStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }

          final refreshToken = await _secureStorage.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            await _secureStorage.deleteTokens();
            handler.next(error);
            return;
          }

          if (_isRefreshing) {
            handler.next(error);
            return;
          }

          _isRefreshing = true;

          try {
            final refreshResponse = await _dio.post(
              ApiEndpoints.refresh,
              data: {'refreshToken': refreshToken},
              options: Options(headers: {'Authorization': null}),
            );

            final data = refreshResponse.data as Map<String, dynamic>;

            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            await _secureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            final requestOptions = error.requestOptions;

            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(requestOptions);

            handler.resolve(retryResponse);
          } catch (_) {
            await _secureStorage.deleteTokens();
            handler.next(error);
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return _dio.delete<T>(path, data: data);
  }
}
