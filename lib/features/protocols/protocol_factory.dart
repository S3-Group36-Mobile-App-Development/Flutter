import '../../core/constants/api_config.dart';
import '../../core/localDataBase/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/services/conectivity_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/repositories/protocol_repository_impl.dart';
import 'data/services/protocol_api_service.dart';
import 'data/services/protocol_cache_service.dart';
import 'data/services/protocol_local_service.dart';
import 'presentation/viewmodels/protocol_view_model.dart';

Future<ProtocolViewModel> buildProtocolViewModel() async {
  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: SecureStorageService(),
  );

  final database = await AppDatabase.open();

  final repository = ProtocolRepositoryImpl(
    protocolApiService: ProtocolApiService(apiClient: apiClient),
    protocollocalService: ProtocolLocalService(localdatabase: database),
    protocolCacheService: ProtocolCacheService(),
  );

  return ProtocolViewModel(
    repository: repository,
    connectivityService: ConnectivityService(),
  );
}
