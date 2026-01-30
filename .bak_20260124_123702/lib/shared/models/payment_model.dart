class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.purpose,
    this.reference,
    this.createdAt,
  });

  final String id;
  final String status; // payment_status
  final num amount;
  final String currency;
  final String? purpose; // rent/deposit/balance etc
  final String? reference;
  final DateTime? createdAt;

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: (map['id'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      amount: (map['amount'] is num) ? map['amount'] as num : num.tryParse((map['amount'] ?? '0').toString()) ?? 0,
      currency: (map['currency'] ?? 'NGN').toString(),
      purpose: map['purpose']?.toString(),
      reference: map['reference']?.toString() ?? map['ref']?.toString(),
      createdAt: _dt(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'status': status,
        'amount': amount,
        'currency': currency,
        'purpose': purpose,
        'reference': reference,
        'created_at': createdAt?.toIso8601String(),
      };
}
