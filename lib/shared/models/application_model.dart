// lib/shared/models/application_model.dart
import 'package:flutter/foundation.dart';

enum ApplicationStatus { pending, approved, rejected, withdrawn }

extension ApplicationStatusX on ApplicationStatus {
  String toApi() {
    switch (this) {
      case ApplicationStatus.pending:
        return "pending";
      case ApplicationStatus.approved:
        return "approved";
      case ApplicationStatus.rejected:
        return "rejected";
      case ApplicationStatus.withdrawn:
        return "withdrawn";
    }
  }

  static ApplicationStatus fromApi(String s) {
    switch (s.trim().toLowerCase()) {
      case "approved":
        return ApplicationStatus.approved;
      case "rejected":
        return ApplicationStatus.rejected;
      case "withdrawn":
        return ApplicationStatus.withdrawn;
      case "pending":
      default:
        return ApplicationStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return "Pending";
      case ApplicationStatus.approved:
        return "Approved";
      case ApplicationStatus.rejected:
        return "Rejected";
      case ApplicationStatus.withdrawn:
        return "Withdrawn";
    }
  }
}

/// ---------------- Core API Model ----------------
/// Matches your DB row shape:
/// - listing_id, property_id, applicant_id, status, message, monthly_income, move_in_date
@immutable
class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.listingId,
    required this.propertyId,
    required this.applicantId,
    required this.status,
    this.message,
    this.monthlyIncome,
    this.moveInDate, // YYYY-MM-DD (date-only)
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// required by backend schema
  final String listingId;
  final String propertyId;

  final String applicantId;
  final ApplicationStatus status;

  final String? message;
  final num? monthlyIncome;

  /// Store exactly as backend expects (YYYY-MM-DD)
  final String? moveInDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static num? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static String _str(dynamic v) => (v ?? "").toString();

  /// Supports { ok:true, data:{...} } OR direct { ... }
  factory ApplicationModel.fromApi(Map<String, dynamic> raw) {
    final map = _unwrapOkData(raw);

    final id = _str(map["id"]).trim();

    final listingId = _str(map["listing_id"] ?? map["listingId"]).trim();
    final propertyId = _str(map["property_id"] ?? map["propertyId"]).trim();

    final applicantId = _str(
      map["applicant_id"] ??
          map["applicantId"] ??
          map["tenant_id"] ??
          map["tenantId"],
    ).trim();

    final statusRaw = _str(map["status"]).trim();
    final status = ApplicationStatusX.fromApi(statusRaw);

    final message = map["message"]?.toString();
    final monthlyIncome = _num(map["monthly_income"] ?? map["monthlyIncome"]);
    final moveInDate = (map["move_in_date"] ?? map["moveInDate"])?.toString();

    final createdAt = _dt(map["created_at"] ?? map["createdAt"]);
    final updatedAt = _dt(map["updated_at"] ?? map["updatedAt"]);

    return ApplicationModel(
      id: id,
      listingId: listingId,
      propertyId: propertyId,
      applicantId: applicantId,
      status: status,
      message: (message == null || message.trim().isEmpty) ? null : message,
      monthlyIncome: monthlyIncome,
      moveInDate: (moveInDate == null || moveInDate.trim().isEmpty)
          ? null
          : moveInDate.trim(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Map<String, dynamic> _unwrapOkData(Map<String, dynamic> raw) {
    final data = raw["data"];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return raw;
  }
}

/// ---------------- Inputs (NO hardcoding in screen) ----------------
/// These match your Zod schemas exactly.

@immutable
class CreateApplicationInput {
  const CreateApplicationInput({
    required this.listingId,
    required this.propertyId,
    this.message,
    this.monthlyIncome,
    this.moveInDate, // YYYY-MM-DD
    this.status, // admin-only; tenants should omit
  });

  final String listingId;
  final String propertyId;
  final String? message;
  final num? monthlyIncome;
  final String? moveInDate;
  final ApplicationStatus? status;

  Map<String, dynamic> toJson() {
    return {
      "listingId": listingId,
      "propertyId": propertyId,
      if (message != null && message!.trim().isNotEmpty) "message": message!.trim(),
      if (monthlyIncome != null) "monthlyIncome": monthlyIncome,
      if (moveInDate != null && moveInDate!.trim().isNotEmpty)
        "moveInDate": moveInDate!.trim(),
      if (status != null) "status": status!.toApi(),
    };
  }
}

/// Sentinel to distinguish "not provided" from explicit null for PATCH.
class _Unset {
  const _Unset();
}

const _unset = _Unset();

@immutable
class PatchApplicationInput {
  const PatchApplicationInput({
    this.status, // admin-only
    Object? message = _unset, // String? or null
    Object? monthlyIncome = _unset, // num? or null
    Object? moveInDate = _unset, // String? or null
  })  : _message = message,
        _monthlyIncome = monthlyIncome,
        _moveInDate = moveInDate;

  final ApplicationStatus? status;

  final Object? _message;
  final Object? _monthlyIncome;
  final Object? _moveInDate;

  /// Convenience getters (read-only)
  String? get message => _message is _Unset ? null : _message as String?;
  num? get monthlyIncome =>
      _monthlyIncome is _Unset ? null : _monthlyIncome as num?;
  String? get moveInDate =>
      _moveInDate is _Unset ? null : _moveInDate as String?;

  /// Build JSON:
  /// - default: omit fields that are not provided
  /// - allowNulls=true: include provided fields even if null (for clearing)
  Map<String, dynamic> toJson({
    bool includeStatus = false,
    bool allowNulls = false,
  }) {
    final m = <String, dynamic>{};

    if (includeStatus && status != null) {
      m["status"] = status!.toApi();
    }

    void put(String key, Object? v) {
      final provided = v is! _Unset;
      if (!provided) return;

      if (allowNulls) {
        // include even when null
        m[key] = v;
      } else {
        // include only when non-null
        if (v != null) m[key] = v;
      }
    }

    put("message", _message);
    put("monthlyIncome", _monthlyIncome);
    put("moveInDate", _moveInDate);

    return m;
  }
}