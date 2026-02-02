// lib/core/network/applications_api.dart
import '../config/api_endpoints.dart';
import '../../shared/models/application_model.dart';
import 'api_client.dart';

class ApplicationsApi {
  const ApplicationsApi(this._client);

  final ApiClient _client;

  /// GET /v1/applications?limit=&offset=
  Future<List<ApplicationModel>> listMyApplications({
    int limit = 30,
    int offset = 0,
  }) async {
    final res = await _client.get(
      ApiEndpoints.applications,
      query: {
        'limit': limit,
        'offset': offset,
      },
    );

    final ok = res['ok'] == true;
    if (!ok) {
      throw Exception(res['message'] ?? res['error'] ?? 'Failed to load applications');
    }

    final data = res['data'];
    if (data is! List) return const <ApplicationModel>[];

    return data
        .whereType<Map>()
        .map((x) => ApplicationModel.fromApi(Map<String, dynamic>.from(x)))
        .toList();
  }

  /// GET /v1/applications/:id
  Future<ApplicationModel> getById(String id) async {
    final res = await _client.get('${ApiEndpoints.applications}/$id');

    final ok = res['ok'] == true;
    if (!ok) {
      throw Exception(res['message'] ?? res['error'] ?? 'Failed to load application');
    }

    return ApplicationModel.fromApi(res);
  }

  /// POST /v1/applications
  Future<ApplicationModel> create(CreateApplicationInput input) async {
    final res = await _client.post(
      ApiEndpoints.applications,
      data: input.toJson(),
    );

    final ok = res['ok'] == true;
    if (!ok) {
      throw Exception(res['message'] ?? res['error'] ?? 'Failed to create application');
    }

    return ApplicationModel.fromApi(res);
  }

  /// PATCH /v1/applications/:id
  /// Tenant can update: message, monthlyIncome, moveInDate
  /// Admin can ALSO update: status
  Future<ApplicationModel> patchApplication(
    String id, {
    PatchApplicationInput? patch,
    bool includeStatus = false, // set true for admin UI
  }) async {
    final body = patch?.toJson(includeStatus: includeStatus) ?? <String, dynamic>{};

    final res = await _client.patch(
      '${ApiEndpoints.applications}/$id',
      data: body,
    );

    final ok = res['ok'] == true;
    if (!ok) {
      throw Exception(res['message'] ?? res['error'] ?? 'Failed to update application');
    }

    return ApplicationModel.fromApi(res);
  }

  /// PATCH /v1/applications/:id/withdraw
  Future<ApplicationModel> withdraw(String id) async {
    final res = await _client.patch(
      '${ApiEndpoints.applications}/$id/withdraw',
      data: const {}, // keep JSON body
    );

    final ok = res['ok'] == true;
    if (!ok) {
      throw Exception(res['message'] ?? res['error'] ?? 'Failed to withdraw application');
    }

    return ApplicationModel.fromApi(res);
  }
}