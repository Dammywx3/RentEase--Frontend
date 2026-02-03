// lib/shared/models/listing_model.dart

class ListingModel {
  const ListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.status, // listing_status
    this.beds,
    this.baths,
    this.type,
    this.mediaUrls = const [],
    this.propertyStatus, // property_status
    this.ownerName,
    this.ownerId,

    /// ✅ IDs used for viewing/inspection booking + apply
    /// - listingId: property_listings.id (or listing_id) used by backend routes
    /// - propertyId: actual properties.id (may be missing in list responses)
    this.listingId,
    this.propertyId,
  });

  final String id;
  final String title;
  final num price;
  final String currency;
  final String location;
  final String status; // listing_status
  final int? beds;
  final int? baths;
  final String? type;
  final List<String> mediaUrls;
  final String? propertyStatus; // property_status (available/occupied/...)
  final String? ownerName;
  final String? ownerId;

  /// ✅ Optional IDs for backend actions
  final String? listingId;

  /// ✅ IMPORTANT: Keep ONLY ONCE, nullable.
  /// DO NOT fallback propertyId to listingId.
  final String? propertyId;

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    // ---------- helpers ----------
    num _parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return num.tryParse(v.toString()) ?? 0;
    }

    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return int.tryParse(v.toString());
    }

    String _countryName(String codeOrName) {
      final v = codeOrName.toUpperCase();
      if (v == 'NG') return 'Nigeria';
      if (v == 'US') return 'USA';
      if (v == 'GB') return 'UK';
      return codeOrName;
    }

    String _buildLocation(Map<String, dynamic> m) {
      final direct = (m['location'] ?? m['address'])?.toString();
      if (direct != null && direct.trim().isNotEmpty) return direct.trim();

      final city = m['city']?.toString();
      final state = m['state']?.toString();
      final country = m['country']?.toString();

      final parts = <String>[];
      if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
      if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
      if (country != null && country.trim().isNotEmpty) {
        parts.add(_countryName(country.trim()));
      }

      if (parts.isEmpty) return 'Location not set';
      return parts.join(' • ');
    }

    String? _mapPropertyTypeToUiType(String? propertyType) {
      if (propertyType == null) return null;
      switch (propertyType) {
        case 'sale':
          return 'Buy';
        case 'rent':
        case 'short_lease':
        case 'long_lease':
          return 'Rent';
        default:
          return propertyType;
      }
    }

    String? _readString(dynamic v) {
      final s = v?.toString();
      if (s == null) return null;
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    // ---------- media parsing ----------
    final urls = <String>[];

    final media = (map['media_urls'] ?? map['mediaUrls']);
    if (media is List) {
      for (final x in media) {
        final s = _readString(x);
        if (s != null) urls.add(s);
      }
    }

    final coverUrl = _readString(map['coverUrl'] ?? map['cover_url']);
    if (coverUrl != null) {
      urls.insert(0, coverUrl);
    }

    // ---------- core fields ----------
    // ✅ IMPORTANT: support id / listing_id / listingId
    final id = _readString(map['id']) ??
        _readString(map['listing_id']) ??
        _readString(map['listingId']) ??
        '';

    final title = (map['title'] ?? map['name'] ?? '').toString();

    final price = (map.containsKey('price'))
        ? _parseNum(map['price'])
        : _parseNum(map['listedPrice'] ?? map['listed_price']);

    final currency = (map['currency'] ?? 'NGN').toString();
    final status = (map['status'] ?? 'draft').toString();

    final beds = map.containsKey('beds')
        ? _parseInt(map['beds'])
        : _parseInt(map['bedrooms']);

    final baths = map.containsKey('baths')
        ? _parseInt(map['baths'])
        : _parseInt(map['bathrooms']);

    final type = map['type']?.toString() ??
        _mapPropertyTypeToUiType(map['propertyType']?.toString());

    // ---------- IDs for backend actions ----------
    // ✅ listingId may come as listingId or listing_id.
    // If missing, fallback to id (safe for viewings create).
    final listingId =
        _readString(map['listingId']) ?? _readString(map['listing_id']) ?? id;

    // ✅ propertyId can appear in multiple shapes
    // IMPORTANT: do NOT fallback to listingId.
    String? propertyId =
        _readString(map['propertyId']) ?? _readString(map['property_id']);

    // sometimes nested: property: { id: ... }
    final propAny = map['property'];
    if (propertyId == null && propAny is Map) {
      propertyId = _readString(propAny['id']) ??
          _readString(propAny['propertyId']) ??
          _readString(propAny['property_id']);
    }

    return ListingModel(
      id: id,
      title: title,
      price: price,
      currency: currency,
      location: _buildLocation(map),
      status: status,
      beds: beds,
      baths: baths,
      type: type,
      mediaUrls: urls,
      propertyStatus:
          (map['property_status'] ?? map['propertyStatus'])?.toString(),
      ownerName: (map['owner_name'] ?? map['ownerName'])?.toString(),
      ownerId: (map['owner_id'] ?? map['ownerId'])?.toString(),
      listingId: listingId,
      propertyId: propertyId, // ✅ may be null
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'currency': currency,
        'location': location,
        'status': status,
        'beds': beds,
        'baths': baths,
        'type': type,
        'media_urls': mediaUrls,
        'property_status': propertyStatus,
        'owner_name': ownerName,
        'owner_id': ownerId,

        // keep both styles for compatibility
        'listingId': listingId,
        'listing_id': listingId,
        'propertyId': propertyId,
        'property_id': propertyId,
      };
}