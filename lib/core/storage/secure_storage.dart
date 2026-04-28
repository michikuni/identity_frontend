import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _userPhoneKey = 'user_phone';

  // DID wallet keys
  static const _privateKeyHexKey = 'did_private_key_hex';
  static const _publicKeyJwkKey = 'did_public_key_jwk';
  static const _didKey = 'did_identifier';

  // VC wallet keys
  static const _employmentVcKey = 'vc_employment';
  static const _terminationVcKey = 'vc_termination';
  static const _salaryRangeVcKey = 'vc_salary_range';
  static const _promotionVcKey   = 'vc_promotion';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  static Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return _storage.read(key: _userEmailKey);
  }

  static Future<void> saveUserPhone(String phone) async {
    await _storage.write(key: _userPhoneKey, value: phone);
  }

  static Future<String?> getUserPhone() async {
    return _storage.read(key: _userPhoneKey);
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  static Future<String?> getUserRole() async {
    return _storage.read(key: _userRoleKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      // JWT payload là base64url — padding cần được thêm vào thủ công
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static const _employeeNumericIdKey = 'employee_numeric_id';

  static Future<void> saveEmployeeNumericId(String id) async {
    await _storage.write(key: _employeeNumericIdKey, value: id);
  }

  static Future<String?> getEmployeeNumericId() async {
    return _storage.read(key: _employeeNumericIdKey);
  }

  // ── DID Wallet ──────────────────────────────────────────────────────────────

  static Future<void> savePrivateKeyHex(String hex) async {
    await _storage.write(key: _privateKeyHexKey, value: hex);
  }

  static Future<String?> getPrivateKeyHex() async {
    return _storage.read(key: _privateKeyHexKey);
  }

  static Future<void> savePublicKeyJwk(String jwk) async {
    await _storage.write(key: _publicKeyJwkKey, value: jwk);
  }

  static Future<String?> getPublicKeyJwk() async {
    return _storage.read(key: _publicKeyJwkKey);
  }

  static Future<void> saveDid(String did) async {
    await _storage.write(key: _didKey, value: did);
  }

  static Future<String?> getDid() async {
    return _storage.read(key: _didKey);
  }

  // ── Verifiable Credentials ──────────────────────────────────────────────────

  static Future<void> saveEmploymentVC(String vcJson) async {
    await _storage.write(key: _employmentVcKey, value: vcJson);
  }

  static Future<String?> getEmploymentVC() async {
    return _storage.read(key: _employmentVcKey);
  }

  static Future<void> saveTerminationVC(String vcJson) async {
    await _storage.write(key: _terminationVcKey, value: vcJson);
  }

  static Future<String?> getTerminationVC() async {
    return _storage.read(key: _terminationVcKey);
  }

  static Future<void> saveSalaryRangeVC(String vcJson) async {
    await _storage.write(key: _salaryRangeVcKey, value: vcJson);
  }

  static Future<String?> getSalaryRangeVC() async {
    return _storage.read(key: _salaryRangeVcKey);
  }

  static Future<void> savePromotionVC(String vcJson) async {
    await _storage.write(key: _promotionVcKey, value: vcJson);
  }

  static Future<String?> getPromotionVC() async {
    return _storage.read(key: _promotionVcKey);
  }
}