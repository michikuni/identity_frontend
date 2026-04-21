abstract interface class IAnalyticsService {
  Future<void> logScreen(String screenName);
  Future<void> logLogin({required String method});
  Future<void> logSignUp({required String method});
  Future<void> setUserId(String userId);
  Future<void> clearUserId();
  Future<void> setUserRole(String role);
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logVcViewed({required String vcType});
  Future<void> logDidCreated();
  Future<void> logQrScanned({required String resultType});
  Future<void> logAttendanceAction({required String action});
}
