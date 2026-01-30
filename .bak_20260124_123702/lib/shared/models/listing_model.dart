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

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    return DateTime.tryParse(s);
  }

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    final media = (map['media_urls'] ?? map['mediaUrls'] ?? []) as dynamic;
    final urls = <String>[];
    if (media is List) {
      for (final x in media) {
        if (x != null) urls.add(x.toString());
      }
    }

    return ListingModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      price: (map['price'] is num) ? map['price'] as num : num.tryParse((map['price'] ?? '0').toString()) ?? 0,
      currency: (map['currency'] ?? 'NGN').toString(),
      location: (map['location'] ?? map['address'] ?? '').toString(),
      status: (map['status'] ?? 'draft').toString(),
      beds: map['beds'] is int ? map['beds'] as int : int.tryParse((map['beds'] ?? '').toString()),
      baths: map['baths'] is int ? map['baths'] as int : int.tryParse((map['baths'] ?? '').toString()),
      type: map['type']?.toString(),
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
