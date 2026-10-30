import '../../core/constants/api_config.dart';
import '../../core/localDataBase/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/services/conectivity_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/repositories/breathing_repository.dart';
import 'data/services/breathing_api_service.dart';
import 'data/services/breathing_local_service.dart';
import 'data/services/sensor_service.dart';
import 'data/services/vibration_service.dart';
import 'presentation/viewmodels/breathing_view_model.dart';

Future<BreathingViewModel> buildBreathingViewModel() async {
  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: SecureStorageService(),
  );

  final database = await AppDatabase.open();

  final repository = BreathingRepository(
    breathingApiService: BreathingApiService(apiClient: apiClient),
    breathinglocalService: BreathingLocalService(localdatabase: database),
  );

  return BreathingViewModel(
    repository: repository,
    sensorService: SensorService(),
    vibrationService: VibrationService(),
    connectivityService: ConnectivityService(),
  );
}