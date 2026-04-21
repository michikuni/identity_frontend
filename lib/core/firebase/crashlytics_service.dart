import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:identity_frontend/core/firebase/repositories/i_crashlytics_service.dart';

class CrashlyticsService implements ICrashlyticsService {
  CrashlyticsService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  static Future<CrashlyticsService> create() async {
    final crashlytics = FirebaseCrashlytics.instance;

    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = crashlytics.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    return CrashlyticsService(crashlytics);
  }

  @override
  Future<void> setUser({
    required String userId,
    String? email,
    String? role,
  }) async {
    await _crashlytics.setUserIdentifier(userId);
    if (email != null) await _crashlytics.setCustomKey('email', email);
    if (role != null) await _crashlytics.setCustomKey('role', role);
  }

  @override
  Future<void> clearUser() async {
    await _crashlytics.setUserIdentifier('');
    await _crashlytics.setCustomKey('email', '');
    await _crashlytics.setCustomKey('role', '');
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(exception, stack, reason: reason, fatal: fatal);
  }

  @override
  Future<void> log(String message) async {
    _crashlytics.log(message);
  }

  /// Bao gồm 3 lớp bắt lỗi:
  /// 1. FlutterError.onError       — widget errors, assertion failures (setup trong create())
  /// 2. PlatformDispatcher.onError — isolate/platform channel errors (setup trong create())
  /// 3. runZonedGuarded            — async errors trong zone của runApp
  @override
  void runWithCrashReporting(void Function() body) {
    runZonedGuarded(body, (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
    });
  }
}
