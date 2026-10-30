import '../../core/constants/api_config.dart';
import '../../core/localDataBase/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/services/conectivity_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/repositories/game_repository_impl.dart';
import 'data/services/game_api_service.dart';
import 'data/services/game_local_service.dart';
import 'presentation/viewmodels/game_view_model.dart';

Future<GameViewModel> buildGameViewModel() async {
  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: SecureStorageService(),
  );

  final database = await AppDatabase.open();

  final repository = GameRepositoryImpl(
    gameApiService: GameApiService(apiClient: apiClient),
    gamelocalService: GameLocalService(localdatabase: database),
  );

  return GameViewModel(
    gameRepository: repository,
    connectivityService: ConnectivityService(),
  );
}
