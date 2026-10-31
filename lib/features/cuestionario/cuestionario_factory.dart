import 'package:zenmind/core/constants/api_config.dart';
import 'package:zenmind/core/network/api_client.dart';
import 'package:zenmind/core/services/conectivity_service.dart';
import 'package:zenmind/core/storage/secure_storage_service.dart';
import 'package:zenmind/features/cuestionario/data/repositories/cuestionario_repository.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_api_service.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_database.dart';
import 'package:zenmind/features/cuestionario/data/services/cuestionario_local_service.dart';
import 'package:zenmind/features/cuestionario/data/services/photo_storage_service.dart';

Future<CuestionarioRepository>? _repositorio;

Future<CuestionarioRepository> obtenerCuestionarioRepository() {
  return _repositorio ??= _crearRepositorio();
}

Future<CuestionarioRepository> _crearRepositorio() async {
  final baseDatos = await CuestionarioDatabase.open();

  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: SecureStorageService(),
  );

  return CuestionarioRepository(
    apiService: CuestionarioApiService(apiClient: apiClient),
    localService: CuestionarioLocalService(baseDatos: baseDatos),
    photoService: PhotoStorageService(),
    connectivityService: ConnectivityService(),
  );
}
