import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class DailyReviewApiService {
  final ApiClient _apiClient;

  DailyReviewApiService({required this._apiClient});

  Future<List<Map<String, dynamic>>> getMoods() async {
    final response = await _apiClient.get<List<dynamic>>(ApiEndpoints.moods);

    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getStreak() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.profile,
    );

    return response.data!['racha'] as Map<String, dynamic>?;
  }

  Future<void> createCheckin({required int moodId, String? comment}) async {
    final data = <String, dynamic>{'estadoAnimoId': moodId};

    if (comment != null && comment.isNotEmpty) {
      data['comentario'] = comment;
    }

    await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.checkins,
      data: data,
    );
  }
}