import 'package:zenmind/features/protocols/data/models/protocol_model.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class ProtocolApiService {
  final ApiClient _apiClient;

  ProtocolApiService({required this._apiClient});

  Future<ProtocolModel> postProtocol({required ProtocolModel protocol}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.createProtocolo,
      data: protocol.toCreateJson(),
    );

    return ProtocolModel.fromJson(response.data!);
  }

  Future<List<ProtocolModel>> getProtocol() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.getAllProtocolos,
    );

    final data = response.data!;
    final List<ProtocolModel> protocols = [];

    for (final item in data) {
      final json = item as Map<String, dynamic>;
      final protocol = ProtocolModel.fromJson(json);

      protocols.add(protocol);
    }

    return protocols;
  }

  Future<ProtocolModel> putProtocol({required ProtocolModel protocol}) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateProtocolo(protocol.id),
      data: protocol.toCreateJson(),
    );

    return ProtocolModel.fromJson(response.data!);
  }
}
