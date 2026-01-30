class TenancyModel {
  const TenancyModel({
    required this.id,
    required this.listingId,
    required this.tenantId,
    required this.status,
    this.startDate,
    this.endDate,
    this.nextDueDate,
    this.rentAmount,
    this.currency = 'NGN',
  });

  final String id;
  final String listingId;
  final String tenantId;
  final String status; // active/ending/ended (or your backend)
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextDueDate;
  final num? rentAmount;
  final String currency;

  static DateTime? _dt(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is DateTime) {
      return v;
    }
    return DateTime.tryParse(v.toString());
  }

  factory TenancyModel.fromMap(Map<String, dynamic> map) {
    return TenancyModel(
      id: (map['id'] ?? '').toString(),
      listingId: (map['listing_id'] ?? map['listingId'] ?? '').toString(),
      tenantId: (map['tenant_id'] ?? map['tenantId'] ?? '').toString(),
      status: (map['status'] ?? 'active').toString(),
      startDate: _dt(map['start_date'] ?? map['startDate']),
      endDate: _dt(map['end_date'] ?? map['endDate']),
      nextDueDate: _dt(map['next_due_date'] ?? map['nextDueDate']),
      rentAmount: (map['rent_amount'] is num)
          ? map['rent_amount'] as num
          : num.tryParse(
              (map['rent_amount'] ?? map['rentAmount'] ?? '').toString(),
            ),
      currency: (map['currency'] ?? 'NGN').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'listing_id': listingId,
    'tenant_id': tenantId,
    'status': status,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'next_due_date': nextDueDate?.toIso8601String(),
    'rent_amount': rentAmount,
    'currency': currency,
  };
}
