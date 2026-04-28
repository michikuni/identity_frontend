import 'dart:convert';
import 'dart:io';

/// Encodes VC payloads into QR-friendly strings and decodes them back.
///
/// Priority:
///   1. If VC JSON has an `id` field → emit `vcid:<id>` (~40 chars, easiest to scan)
///   2. Fallback: gzip+base64url compressed payload with `vcz1:` prefix
///   3. Last resort: raw normalized JSON
class VcQrPayloadCodec {
  VcQrPayloadCodec._();

  static const String _vcIdPrefix = 'vcid:';
  static const String _compressedPrefix = 'vcz1:';

  /// Encode a VC JSON string into the shortest possible QR payload.
  static String encode(String vcJson) {
    // Try short-token path first
    try {
      final vc = jsonDecode(vcJson) as Map<String, dynamic>;
      final id = vc['id'] as String?;
      if (id != null && id.isNotEmpty) {
        return '$_vcIdPrefix$id';
      }
    } catch (_) {}

    // Fallback: gzip+base64url
    final normalized = _normalizeJson(vcJson);
    final compressed = gzip.encode(utf8.encode(normalized));
    final encoded = base64Url.encode(compressed).replaceAll('=', '');
    final payload = '$_compressedPrefix$encoded';
    return payload.length < normalized.length ? payload : normalized;
  }

  /// Decode a QR payload back to VC JSON.
  /// Returns null for vcid: tokens — caller must resolve via backend.
  static String? decode(String payload) {
    if (payload.startsWith(_vcIdPrefix)) {
      // Short-token — caller must call GET /identity/vc/verify-by-id?vcId=...
      return null;
    }
    if (payload.startsWith(_compressedPrefix)) {
      final encoded = payload.substring(_compressedPrefix.length);
      final compressed = base64Url.decode(_restoreBase64Padding(encoded));
      return _normalizeJson(utf8.decode(gzip.decode(compressed)));
    }
    return _normalizeJson(payload);
  }

  /// Extract the VC id from a vcid: token, or null if not that format.
  static String? extractVcId(String payload) {
    if (payload.startsWith(_vcIdPrefix)) {
      return payload.substring(_vcIdPrefix.length);
    }
    return null;
  }

  static bool isVcIdToken(String payload) => payload.startsWith(_vcIdPrefix);

  static bool isCompressedPayload(String payload) =>
      payload.startsWith(_compressedPrefix);

  static String _normalizeJson(String input) {
    try {
      return jsonEncode(jsonDecode(input));
    } catch (_) {
      return input;
    }
  }

  static String _restoreBase64Padding(String input) {
    final remainder = input.length % 4;
    if (remainder == 0) return input;
    return input.padRight(input.length + (4 - remainder), '=');
  }
}
