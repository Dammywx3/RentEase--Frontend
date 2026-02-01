// lib/core/network/marketplace_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketplaceApi {
  MarketplaceApi({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl; // e.g. http://172.20.10.2:4000
  final http.Client _client;

  Uri _uri(String path, Map<String, String> query) {
    final cleanedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanedBase$cleanedPath').replace(queryParameters: query);
  }

  void _putIfNotEmpty(Map<String, String> q, String key, String? value) {
    if (value == null) return;
    final v = value.trim();
    if (v.isEmpty) return;
    q[key] = v;
  }

  void _putIfPositive(Map<String, String> q, String key, num? value) {
    if (value == null) return;
    if (value <= 0) return;
    q[key] = value.toInt().toString();
  }

  /// Fetch listings from marketplace.
  ///
  /// Backwards-compatible with Explore:
  /// - types, verifiedOnly, limit, offset
  ///
  /// Extended filters for Search/Results (optional):
  /// - queryText, mode, category, min, max, beds, baths, plotMinSqft
  ///
  /// NOTE:
  /// Your backend may ignore these new params today (that’s okay).
  /// Once backend supports them, results will filter properly without UI changes.
  Future<List<MarketplaceItem>> fetchListings({
    List<String>? types,
    required bool verifiedOnly,
    required int limit,
    required int offset,

    // -------- optional search filters --------
    String? queryText, // location/address keyword
    String? mode, // buy|rent|land|commercial (whatever you use)
    String? category, // Residential|Commercial|Land
    int? min, // min price
    int? max, // max price
    int? beds, // min beds
    int? baths, // min baths
    int? plotMinSqft, // min plot size sqft
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      'verified': verifiedOnly ? 'true' : 'false',
    };

    if (types != null && types.isNotEmpty) {
      query['types'] = types.join(',');
    }

    // Optional params (only send when meaningful)
    _putIfNotEmpty(query, 'query', queryText);
    _putIfNotEmpty(query, 'mode', mode);
    _putIfNotEmpty(query, 'category', category);

    _putIfPositive(query, 'min', min);
    _putIfPositive(query, 'max', max);

    _putIfPositive(query, 'beds', beds);
    _putIfPositive(query, 'baths', baths);

    _putIfPositive(query, 'plotMinSqft', plotMinSqft);

    final url = _uri('/v1/marketplace/listings', query);

    final res = await _client.get(url, headers: {
      'Accept': 'application/json',
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Marketplace error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response: expected object');
    }

    final items = decoded['items'];
    if (items is! List) return <MarketplaceItem>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(MarketplaceItem.fromJson)
        .toList();
  }
}

class MarketplaceItem {
  MarketplaceItem({
    required this.listingId,
    required this.kind,
    required this.status,
    required this.listedPrice,
    required this.createdAt,
    required this.propertyId,
    required this.title,
    required this.propertyType,
    required this.currency,
    required this.city,
    required this.state,
    required this.country,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareMeters,
    required this.verificationStatus,
    required this.coverUrl,
    required this.coverThumb,
  });

  final String listingId;
  final String kind;
  final String status;
  final num listedPrice;
  final String createdAt;

  final String propertyId;
  final String title;
  final String propertyType; // rent|sale|short_lease|long_lease
  final String? currency;
  final String? city;
  final String? state;
  final String? country;

  final int? bedrooms;
  final int? bathrooms;
  final num? squareMeters;

  final String verificationStatus; // pending|verified|...
  final String? coverUrl;
  final String? coverThumb;

  factory MarketplaceItem.fromJson(Map<String, dynamic> j) {
    num? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String _str(dynamic v, {String fallback = ''}) {
      if (v == null) return fallback;
      final s = v.toString();
      return s.isEmpty ? fallback : s;
    }

    return MarketplaceItem(
      listingId: _str(j['listingId']),
      kind: _str(j['kind']),
      status: _str(j['status']),
      listedPrice: _num(j['listedPrice']) ?? 0,
      createdAt: _str(j['createdAt']),
      propertyId: _str(j['propertyId']),
      title: _str(j['title']),
      propertyType: _str(j['propertyType']),
      currency: j['currency'] == null ? null : _str(j['currency']),
      city: j['city'] == null ? null : _str(j['city']),
      state: j['state'] == null ? null : _str(j['state']),
      country: j['country'] == null ? null : _str(j['country']),
      bedrooms: _int(j['bedrooms']),
      bathrooms: _int(j['bathrooms']),
      squareMeters: _num(j['squareMeters']),
      verificationStatus: _str(j['verificationStatus'], fallback: 'pending'),
      coverUrl: j['coverUrl'] == null ? null : _str(j['coverUrl']),
      coverThumb: j['coverThumb'] == null ? null : _str(j['coverThumb']),
    );
  }
}