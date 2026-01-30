class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.listingId,
    required this.tenantId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.note,
  });

  final String id;
  final String listingId;
  final String tenantId;
  final String status; // pending/approved/rejected/withdrawn (or your backend)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? note;

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: (map['id'] ?? '').toString(),
      listingId: (map['listing_id'] ?? map['listingId'] ?? '').toString(),
      tenantId: (map['tenant_id'] ?? map['tenantId'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      createdAt: _dt(map['created_at'] ?? map['createdAt']),
      updatedAt: _dt(map['updated_at'] ?? map['updatedAt']),
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'listing_id': listingId,
    'tenant_id': tenantId,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'note': note,
  };
}
