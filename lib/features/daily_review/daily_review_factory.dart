import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/repositories/daily_review_repository_impl.dart';
import 'data/services/daily_review_api_service.dart';
import 'data/services/daily_review_local_service.dart';
import 'domain/repositories/daily_review_repository.dart';

DailyReviewRepository buildDailyReviewRepository() {
  final apiClient = ApiClient(
    baseUrl: ApiConfig.baseUrl,
    secureStorage: SecureStorageService(),
  );

  return DailyReviewRepositoryImpl(
    apiService: DailyReviewApiService(apiClient: apiClient),
    localService: DailyReviewLocalService(),
  );
}