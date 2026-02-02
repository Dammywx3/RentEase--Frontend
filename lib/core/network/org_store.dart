import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the organization id for multi-tenant headers.
/// This must match the org in the JWT or backend will return 403.
class OrgStore {
  OrgStore._();

  static const _storage = FlutterSecureStorage();
  static const _kOrgId = 'organization_id';

  static Future<void> writeOrgId(String orgId) async {
    await _storage.write(key: _kOrgId, value: orgId.trim());
  }

  static Future<String?> readOrgId() async {
    return _storage.read(key: _kOrgId);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kOrgId);
  }
}