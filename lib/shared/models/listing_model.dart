class ListingModel {
  const ListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.status,
    this.beds,
    this.baths,
    this.type,
    this.mediaUrls = const [],
    this.propertyStatus,
    this.ownerName,
    this.ownerId,
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
      // If explicit location/address exists, prefer it.
      final direct = (m['location'] ?? m['address'])?.toString();
      if (direct != null && direct.trim().isNotEmpty) return direct.trim();

      // Otherwise build from city/state/country (marketplace response style).
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
          return propertyType; // fallback
      }
    }

    // ---------- media parsing ----------
    // Support:
    // - your old 'media_urls' or 'mediaUrls' (list)
    // - marketplace 'coverUrl' / 'coverThumb' (single strings)
    final urls = <String>[];

    final media = (map['media_urls'] ?? map['mediaUrls']);
    if (media is List) {
      for (final x in media) {
        if (x != null && x.toString().trim().isNotEmpty) {
          urls.add(x.toString().trim());
        }
      }
    }

    final coverUrl = map['coverUrl']?.toString();
    if (coverUrl != null && coverUrl.trim().isNotEmpty) {
      urls.insert(0, coverUrl.trim());
    }

    // if you ever want to use thumb too:
    // final coverThumb = map['coverThumb']?.toString();
    // if (coverThumb != null && coverThumb.trim().isNotEmpty) urls.add(coverThumb.trim());

    // ---------- core fields ----------
    final id = (map['id'] ?? map['listingId'] ?? '').toString();
    final title = (map['title'] ?? map['name'] ?? '').toString();

    final price = (map.containsKey('price'))
        ? _parseNum(map['price'])
        : _parseNum(map['listedPrice']);

    // Prefer currency from backend (marketplace returns "NGN")
    final currency = (map['currency'] ?? 'NGN').toString();

    // status from marketplace: "active" etc
    final status = (map['status'] ?? 'draft').toString();

    // beds/baths from either old keys or marketplace keys
    final beds = map.containsKey('beds')
        ? _parseInt(map['beds'])
        : _parseInt(map['bedrooms']);

    final baths = map.containsKey('baths')
        ? _parseInt(map['baths'])
        : _parseInt(map['bathrooms']);

    // type from old 'type' OR from marketplace 'propertyType'
    final type = map['type']?.toString() ?? _mapPropertyTypeToUiType(map['propertyType']?.toString());

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
      propertyStatus: map['property_status']?.toString() ?? map['propertyStatus']?.toString(),
      ownerName: map['owner_name']?.toString() ?? map['ownerName']?.toString(),
      ownerId: map['owner_id']?.toString() ?? map['ownerId']?.toString(),
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
      };
}