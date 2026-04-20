import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:identity_frontend/core/storage/secure_storage.dart';

/// WalletService — sinh và quản lý ECDSA P-256 keypair cho DID wallet.
///
/// Flow:
///   1. Khi onboarding: [generateAndSave] → sinh keypair, lưu secure storage,
///      trả về publicKeyJwk để gửi lên backend khi Admin approve.
///   2. Khi cần ký (tương lai): [sign] → lấy privateKey từ storage, ký payload.
///   3. Khi resolve DID: [getPublicKeyJwk] → trả về public key đã lưu.
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

  // ── Internal ───────────────────────────────────────────────────────────────

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
