import 'package:hive_flutter/hive_flutter.dart';

/// VcCacheService — offline cache for Verifiable Credentials using Hive.
///
/// Call [VcCacheService.init] once at app startup (before runApp).
/// Then use [put], [get], [getAll], [remove], [clear] from anywhere.
///
/// Box layout:
///   Box name: 'vc_cache'
///   Key  : String — credential identifier (e.g. "employment", "salary", "skill_sdjwt")
///   Value: Map    — raw VC JSON or SD-JWT compact string wrapped in a map
///
/// The cache stores the last-known-good credential so the Wallet screen
/// can render even when the device is offline.
class VcCacheService {
  static const _boxName = 'vc_cache';
  static Box? _box;

  /// Initialize Hive and open the vc_cache box.
  /// Must be called once in main() after WidgetsFlutterBinding.ensureInitialized().
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Box get _opened {
    assert(_box != null, 'VcCacheService.init() has not been called');
    return _box!;
  }

  /// Store a credential under [key].
  /// [value] can be a Map (W3C VC JSON) or a plain String (SD-JWT compact).
  static Future<void> put(String key, dynamic value) async {
    await _opened.put(key, value);
  }

  /// Retrieve a cached credential by [key]. Returns null if not cached.
  static dynamic get(String key) => _opened.get(key);

  /// All cached credentials as a Map<key, value>.
  static Map<dynamic, dynamic> getAll() => _opened.toMap();

  /// Remove a specific credential from cache.
  static Future<void> remove(String key) async {
    await _opened.delete(key);
  }

  /// Clear the entire VC cache (e.g. on logout).
  static Future<void> clear() async {
    await _opened.clear();
  }

  /// Watch a specific key for changes — useful for reactive UI.
  static Stream<BoxEvent> watch(String key) => _opened.watch(key: key);

  // ── Convenience helpers for well-known credential types ──────────────────

  static const keyEmployment = 'employment_vc';
  static const keySalaryRange = 'salary_range_vc';
  static const keyPromotion = 'promotion_vc';
  static const keyTermination = 'termination_vc';
  static const keySkillSdJwt = 'skill_sd_jwt';
  static const keyEducationSdJwt = 'education_sd_jwt';

  static Future<void> cacheEmploymentVc(String vcJson) => put(keyEmployment, vcJson);
  static Future<void> cacheSalaryRangeVc(String vcJson) => put(keySalaryRange, vcJson);
  static Future<void> cachePromotionVc(String vcJson) => put(keyPromotion, vcJson);
  static Future<void> cacheTerminationVc(String vcJson) => put(keyTermination, vcJson);
  static Future<void> cacheSkillSdJwt(String sdJwt) => put(keySkillSdJwt, sdJwt);
  static Future<void> cacheEducationSdJwt(String sdJwt) => put(keyEducationSdJwt, sdJwt);

  static String? getEmploymentVc() => _opened.get(keyEmployment) as String?;
  static String? getSalaryRangeVc() => _opened.get(keySalaryRange) as String?;
  static String? getPromotionVc() => _opened.get(keyPromotion) as String?;
  static String? getTerminationVc() => _opened.get(keyTermination) as String?;
  static String? getSkillSdJwt() => _opened.get(keySkillSdJwt) as String?;
  static String? getEducationSdJwt() => _opened.get(keyEducationSdJwt) as String?;
}
