import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// BiometricService — guards wallet private-key access with biometric auth.
///
/// ## Why
/// SSI's core promise: "the private key never leaves the user's device".
/// Biometric challenge before every signing operation is the UX proof of that
/// promise during the demo (step 3 in the 8-step demo flow).
///
/// ## Usage
///
///   final ok = await BiometricService.authenticate(
///     reason: 'Touch to sign Verifiable Presentation',
///   );
///   if (!ok) return; // user cancelled or auth failed
///   // ...proceed with WalletService.sign()
///
/// ## Lock toggle
///
/// [isBiometricLockEnabled] / [setBiometricLockEnabled] are persisted in
/// SharedPreferences so the user can toggle "App Lock" from the wallet screen.
/// The wallet screen reads this flag to show the 🔒/🔓 indicator.
class BiometricService {
  BiometricService._();

  static final _auth = LocalAuthentication();
  static const _prefKey = 'biometric_lock_enabled';

  // ── Capability checks ──────────────────────────────────────────────────────

  /// Whether the device supports biometric authentication at all.
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (fingerprint, face, iris).
  static Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  // ── Lock preference ────────────────────────────────────────────────────────

  static Future<bool> isBiometricLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setBiometricLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  // ── Authentication ─────────────────────────────────────────────────────────

  /// Prompt the user for biometric (or device PIN fallback).
  ///
  /// Returns true if the user authenticated successfully.
  /// Returns false if they cancelled, or if biometrics are not available.
  ///
  /// [reason] is shown in the native OS dialog — make it action-specific:
  ///   "Touch to sign contract"  or  "Unlock wallet"
  static Future<bool> authenticate({
    String reason = 'Authenticate to access your credential wallet',
  }) async {
    if (!await isAvailable()) return true; // no biometrics → skip gate
    if (!await isBiometricLockEnabled()) return true; // lock not enabled → skip

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN as fallback
          stickyAuth: true,     // keep dialog open if user leaves app briefly
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Authenticate regardless of the lock preference — used for one-shot
  /// operations like "Sign with Biometric" button where the user explicitly
  /// initiated the action.
  static Future<bool> authenticateNow({
    String reason = 'Touch to sign',
  }) async {
    if (!await isAvailable()) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
