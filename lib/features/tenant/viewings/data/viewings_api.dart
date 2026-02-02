import "package:rentease_frontend/core/config/api_endpoints.dart";
import "package:rentease_frontend/core/network/api_client.dart";
import "package:rentease_frontend/core/network/token_store.dart";
import "package:rentease_frontend/shared/models/viewing_model.dart";

class ViewingsApi {
  ViewingsApi();

  final ApiClient _client = ApiClient(tokenProvider: TokenStore.readToken);

  Map<String, dynamic> _unwrap(Map<String, dynamic> res) {
    // supports:
    // { ok: true, data: {...} }
    // { ok: true, item: {...} }
    // { items: [...] }
    final data = res["data"];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return res;
  }

  List<dynamic> _extractItems(Map<String, dynamic> res) {
    final unwrapped = _unwrap(res);

    // common shapes:
    // { items: [...] }
    // { data: { items: [...] } } (handled by unwrap)
    // { data: [...] } (rare)
    final items = unwrapped["items"];
    if (items is List) return items;

    final data = res["data"];
    if (data is List) return data;

    return const [];
  }

  Map<String, dynamic> _extractItem(Map<String, dynamic> res) {
    final unwrapped = _unwrap(res);

    // common shapes:
    // { item: {...} }
    // { data: {...} }
    // { viewing: {...} }
    final item = unwrapped["item"];
    if (item is Map) return Map<String, dynamic>.from(item);

    final viewing = unwrapped["viewing"];
    if (viewing is Map) return Map<String, dynamic>.from(viewing);

    // if data is the object itself
    return unwrapped;
  }

  /// Normalize backend differences so UI doesn't break:
  /// - backend viewing_status: pending -> requested
  /// - US spelling sometimes: canceled -> cancelled
  Map<String, dynamic> _normalizeViewing(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);

    final s = (m["status"] ?? "").toString().trim().toLowerCase();
    if (s == "pending") {
      // Our UI expects requested/confirmed/etc.
      m["status"] = "requested";
    } else if (s == "canceled") {
      m["status"] = "cancelled";
    }

    return m;
  }

  Future<List<ViewingModel>> listMy({int limit = 50, int offset = 0}) async {
    final res = await _client.get(
      ApiEndpoints.myViewings,
      query: {"limit": "$limit", "offset": "$offset"},
    );

    final items = _extractItems(res);

    return items
        .whereType<Map>()
        .map((e) => _normalizeViewing(Map<String, dynamic>.from(e)))
        .map((e) => ViewingModel.fromApi(e))
        .toList();
  }

  /// ✅ Cancel viewing (tries multiple backend patterns)
  Future<ViewingModel> cancel(String viewingId) async {
    // 1) POST /v1/viewings/:id/cancel
    try {
      final res = await _client.post(
        "${ApiEndpoints.viewings}/$viewingId/cancel",
        data: {},
      );
      return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
    } catch (_) {}

    // 2) PATCH /v1/viewings/:id { status: "cancelled" }
    try {
      final res = await _client.patch(
        "${ApiEndpoints.viewings}/$viewingId",
        data: {"status": "cancelled"},
      );
      return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
    } catch (_) {}

    // 3) POST /v1/viewings/:id { status: "cancelled" }
    final res = await _client.post(
      "${ApiEndpoints.viewings}/$viewingId",
      data: {"status": "cancelled"},
    );
    return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
  }

  /// ✅ Reschedule viewing (tries multiple backend patterns)
  Future<ViewingModel> reschedule({
    required String viewingId,
    required DateTime scheduledAtLocal,
  }) async {
    final scheduledAtIsoUtc = scheduledAtLocal.toUtc().toIso8601String();

    // 1) POST /v1/viewings/:id/reschedule
    try {
      final res = await _client.post(
        "${ApiEndpoints.viewings}/$viewingId/reschedule",
        data: {"scheduledAt": scheduledAtIsoUtc},
      );
      return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
    } catch (_) {}

    // 2) PATCH /v1/viewings/:id
    try {
      final res = await _client.patch(
        "${ApiEndpoints.viewings}/$viewingId",
        data: {"scheduledAt": scheduledAtIsoUtc},
      );
      return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
    } catch (_) {}

    // 3) POST /v1/viewings/:id
    final res = await _client.post(
      "${ApiEndpoints.viewings}/$viewingId",
      data: {"scheduledAt": scheduledAtIsoUtc},
    );
    return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
  }

  Future<ViewingModel> create({
    required String listingId,
    required String propertyId,
    required DateTime scheduledAtLocal,
    required String viewMode, // "virtual" | "in_person"
    String? notes,
  }) async {
    final body = <String, dynamic>{
      "listingId": listingId,
      "propertyId": propertyId,
      "scheduledAt": scheduledAtLocal.toUtc().toIso8601String(),
      "viewMode": viewMode,
      if (notes != null && notes.trim().isNotEmpty) "notes": notes.trim(),
    };

    final res = await _client.post(ApiEndpoints.viewings, data: body);
    return ViewingModel.fromApi(_normalizeViewing(_extractItem(res)));
  }
}