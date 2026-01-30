class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.type,
    required this.url,
    required this.approvalStatus,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String type; // id_card, utility_bill, etc
  final String url;
  final String approvalStatus; // verified_status
  final String? rejectionReason;
  final DateTime? createdAt;

  static DateTime? _dt(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is DateTime) {
      return v;
    }
    return DateTime.tryParse(v.toString());
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: (map['id'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      url: (map['url'] ?? map['file_url'] ?? '').toString(),
      approvalStatus:
          (map['approval_status'] ?? map['approvalStatus'] ?? 'pending')
              .toString(),
      rejectionReason:
          map['rejection_reason']?.toString() ??
          map['rejectionReason']?.toString(),
      createdAt: _dt(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'url': url,
    'approval_status': approvalStatus,
    'rejection_reason': rejectionReason,
    'created_at': createdAt?.toIso8601String(),
  };
}
