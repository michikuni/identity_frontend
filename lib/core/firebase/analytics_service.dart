import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';

class AnalyticsService implements IAnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  static Future<AnalyticsService> create() async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    return AnalyticsService(analytics);
  }

  @override
  Future<void> logScreen(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> logLogin({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  @override
  Future<void> logSignUp({required String method}) =>
      _analytics.logSignUp(signUpMethod: method);

  @override
  Future<void> setUserId(String userId) => _analytics.setUserId(id: userId);

  @override
  Future<void> clearUserId() => _analytics.setUserId(id: null);

  @override
  Future<void> setUserRole(String role) =>
      _analytics.setUserProperty(name: 'user_role', value: role);

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logVcViewed({required String vcType}) =>
      logEvent('vc_viewed', parameters: {'vc_type': vcType});

  @override
  Future<void> logDidCreated() => logEvent('did_created');

  @override
  Future<void> logQrScanned({required String resultType}) =>
      logEvent('qr_scanned', parameters: {'result_type': resultType});

  @override
  Future<void> logAttendanceAction({required String action}) =>
      logEvent('attendance_action', parameters: {'action': action});
}
