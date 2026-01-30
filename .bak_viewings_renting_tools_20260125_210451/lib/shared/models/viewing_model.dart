class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.listingId,
    required this.requesterId,
    required this.status,
    this.scheduledAt,
    this.mode,
    this.note,
  });

  final String id;
  final String listingId;
  final String requesterId;
  final String status; // viewing_status
  final DateTime? scheduledAt;
  final String? mode; // in_person / virtual etc
  final String? note;

  static DateTime? _dt(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is DateTime) {
      return v;
    }
    return DateTime.tryParse(v.toString());
  }

  factory ViewingModel.fromMap(Map<String, dynamic> map) {
    return ViewingModel(
      id: (map['id'] ?? '').toString(),
      listingId: (map['listing_id'] ?? map['listingId'] ?? '').toString(),
      requesterId: (map['requester_id'] ?? map['requesterId'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      scheduledAt: _dt(map['scheduled_at'] ?? map['scheduledAt']),
      mode: map['mode']?.toString(),
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'listing_id': listingId,
    'requester_id': requesterId,
    'status': status,
    'scheduled_at': scheduledAt?.toIso8601String(),
    'mode': mode,
    'note': note,
  };
}
