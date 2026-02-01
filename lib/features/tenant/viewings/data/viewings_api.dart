// lib/features/tenant/viewings/data/viewings_api.dart
import "package:rentease_frontend/core/config/api_endpoints.dart";
import "package:rentease_frontend/core/network/api_client.dart";
import "package:rentease_frontend/core/network/token_store.dart";

class ViewingsApi {
  ViewingsApi();

  // Assumes your ApiClient can be constructed like this.
  // If your ApiClient constructor differs, adjust ONLY this line.
  final ApiClient _client = ApiClient(tokenProvider: TokenStore.readToken);

  Future<List<Map<String, dynamic>>> listMy({int limit = 50, int offset = 0}) async {
    final res = await _client.get(
      ApiEndpoints.myViewings,
      query: {"limit": "$limit", "offset": "$offset"},
    );

    final items = (res["items"] as List<dynamic>? ?? const []);
    return items.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> cancel(String viewingId) async {
    final res = await _client.patch("${ApiEndpoints.viewings}/$viewingId/cancel");
    return (res["item"] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> create({
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

    final res = await _client.post(ApiEndpoints.viewings, body: body);
    return (res["item"] as Map<String, dynamic>);
  }
}