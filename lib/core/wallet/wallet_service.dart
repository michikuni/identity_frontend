import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:identity_frontend/core/security/biometric_service.dart';
import 'package:identity_frontend/core/storage/secure_storage.dart';

/// WalletService — sinh và quản lý ECDSA P-256 keypair cho DID wallet.
///
/// Flow:
///   1. Khi onboarding: [generateAndSave] → sinh keypair, lưu secure storage,
///      trả về publicKeyJwk để gửi lên backend khi Admin approve.
///   2. Khi ký VP/contract: [sign] → biometric gate → load private key → ký.
///   3. Khi resolve DID: [getPublicKeyJwk] → trả về public key đã lưu.
///
/// Biometric gate (Phase 1 / 4.5):
///   [sign] gọi [BiometricService.authenticateNow] trước khi đọc private key.
///   Nếu biometric thất bại → throws [WalletBiometricException].
///   Caller (disclosure picker, contract sign screen) hiển thị lỗi và huỷ.
class WalletService {
  WalletService._();

  /// Sinh keypair P-256 mới, lưu vào SecureStorage.
  /// Trả về publicKeyJwk (JSON string) để gửi lên backend.
  /// Nếu đã có keypair thì trả về publicKeyJwk hiện tại (idempotent).
  static Future<String> generateAndSave() async {
    final existing = await SecureStorage.getPublicKeyJwk();
    if (existing != null && existing.isNotEmpty) return existing;

    final keyPair = _generateP256KeyPair();
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    final privateKeyHex = _bigIntToHex(privateKey.d!);
    final publicKeyJwk = _toJwk(publicKey);

    await SecureStorage.savePrivateKeyHex(privateKeyHex);
    await SecureStorage.savePublicKeyJwk(publicKeyJwk);

    return publicKeyJwk;
  }

  /// Trả về publicKeyJwk đã lưu, null nếu chưa generate.
  static Future<String?> getPublicKeyJwk() => SecureStorage.getPublicKeyJwk();

  /// Kiểm tra wallet đã được khởi tạo chưa.
  static Future<bool> hasWallet() async {
    final key = await SecureStorage.getPublicKeyJwk();
    return key != null && key.isNotEmpty;
  }

  // ── Signing (biometric-gated) ──────────────────────────────────────────────

  /// Sign [payload] bytes with the stored ECDSA P-256 private key.
  ///
  /// Always prompts biometric (or device PIN) before accessing the key.
  /// Throws [WalletBiometricException] if the user cancels or auth fails.
  /// Throws [WalletNotInitializedException] if no keypair has been generated.
  ///
  /// Returns Base64-encoded DER signature (suitable for sending to backend).
  static Future<String> sign(
    Uint8List payload, {
    String biometricReason = 'Touch to sign with your identity key',
  }) async {
    final authed = await BiometricService.authenticateNow(reason: biometricReason);
    if (!authed) throw const WalletBiometricException();

    final privateKeyHex = await SecureStorage.getPrivateKeyHex();
    if (privateKeyHex == null || privateKeyHex.isEmpty) {
      throw const WalletNotInitializedException();
    }

    final d = _hexToBigInt(privateKeyHex);
    final domainParams = ECDomainParameters('prime256v1');
    final privateKey = ECPrivateKey(d, domainParams);

    final signer = ECDSASigner(SHA256Digest())
      ..init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));

    final sig = signer.generateSignature(payload) as ECSignature;
    final derBytes = _encodeDer(sig);
    return base64.encode(derBytes);
  }

  /// Compute SHA-256 of [data] and sign — convenience wrapper for contract signing.
  /// Returns Base64(DER signature) + the hex docHash.
  static Future<({String signatureBase64, String docHash})> signDocument(
    Uint8List documentBytes, {
    String biometricReason = 'Touch to sign contract',
  }) async {
    final digest = SHA256Digest();
    final hash = Uint8List(digest.digestSize);
    digest
      ..update(documentBytes, 0, documentBytes.length)
      ..doFinal(hash, 0);

    final docHash = hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final signatureBase64 = await sign(hash, biometricReason: biometricReason);
    return (signatureBase64: signatureBase64, docHash: docHash);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static BigInt _hexToBigInt(String hex) => BigInt.parse(hex, radix: 16);

  /// Encode ECSignature (r, s) as DER SEQUENCE { INTEGER r, INTEGER s }.
  static Uint8List _encodeDer(ECSignature sig) {
    Uint8List encodeInt(BigInt n) {
      final hex = n.toRadixString(16).padLeft(64, '0');
      var bytes = Uint8List.fromList(
        List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)),
      );
      if (bytes[0] & 0x80 != 0) bytes = Uint8List.fromList([0, ...bytes]);
      return bytes;
    }

    final rBytes = encodeInt(sig.r);
    final sBytes = encodeInt(sig.s);
    final seq = Uint8List.fromList([
      0x02, rBytes.length, ...rBytes,
      0x02, sBytes.length, ...sBytes,
    ]);
    return Uint8List.fromList([0x30, seq.length, ...seq]);
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> _generateP256KeyPair() {
    final secureRandom = _buildSecureRandom();
    final domainParams = ECDomainParameters('prime256v1'); // P-256
    final keyParams = ECKeyGeneratorParameters(domainParams);
    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(keyParams, secureRandom));
    return generator.generateKeyPair();
  }

  static SecureRandom _buildSecureRandom() {
    final random = Random.secure();
    final seed = Uint8List(32);
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    return FortunaRandom()..seed(KeyParameter(seed));
  }

  /// Chuyển ECPublicKey thành JWK JSON string (RFC 7517).
  static String _toJwk(ECPublicKey publicKey) {
    final q = publicKey.Q!;
    final x = _bigIntToBase64Url(q.x!.toBigInteger()!);
    final y = _bigIntToBase64Url(q.y!.toBigInteger()!);
    final jwk = {
      'kty': 'EC',
      'crv': 'P-256',
      'x': x,
      'y': y,
    };
    return jsonEncode(jwk);
  }

  static String _bigIntToBase64Url(BigInt value) {
    final bytes = _bigIntToBytes(value, 32);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _bigIntToHex(BigInt value) {
    final hex = value.toRadixString(16);
    return hex.length.isOdd ? '0$hex' : hex;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final hex = _bigIntToHex(value).padLeft(length * 2, '0');
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class WalletBiometricException implements Exception {
  const WalletBiometricException();
  @override
  String toString() => 'Biometric authentication failed or was cancelled.';
}

class WalletNotInitializedException implements Exception {
  const WalletNotInitializedException();
  @override
  String toString() => 'Wallet not initialized — generate a keypair first.';
}
