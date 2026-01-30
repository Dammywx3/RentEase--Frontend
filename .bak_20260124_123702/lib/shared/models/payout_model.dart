class PayoutModel {
  const PayoutModel({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.bankName,
    this.accountMask,
    this.createdAt,
  });

  final String id;
  final String status; // payout_status
  final num amount;
  final String currency;
  final String? bankName;
  final String? accountMask;
  final DateTime? createdAt;

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory PayoutModel.fromMap(Map<String, dynamic> map) {
    return PayoutModel(
      id: (map['id'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      amount: (map['amount'] is num) ? map['amount'] as num : num.tryParse((map['amount'] ?? '0').toString()) ?? 0,
      currency: (map['currency'] ?? 'NGN').toString(),
      bankName: map['bank_name']?.toString() ?? map['bankName']?.toString(),
      accountMask: map['account_mask']?.toString() ?? map['accountMask']?.toString(),
      createdAt: _dt(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'status': status,
        'amount': amount,
        'currency': currency,
        'bank_name': bankName,
        'account_mask': accountMask,
        'created_at': createdAt?.toIso8601String(),
      };
}
