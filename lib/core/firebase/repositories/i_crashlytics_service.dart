abstract interface class ICrashlyticsService {
  Future<void> setUser({required String userId, String? email, String? role});
  Future<void> clearUser();
  Future<void> recordError(dynamic exception, StackTrace? stack, {String? reason, bool fatal});
  Future<void> log(String message);

  /// Wrap [body] trong runZonedGuarded để bắt toàn bộ async errors
  /// trong cùng zone với runApp mà PlatformDispatcher.onError không catch được.
  void runWithCrashReporting(void Function() body);
}
