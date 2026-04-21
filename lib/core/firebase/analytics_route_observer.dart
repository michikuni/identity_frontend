import 'package:flutter/widgets.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';

/// NavigatorObserver bridge — truyền vào GoRouter.observers[]
/// để tự động log screen mỗi khi route thay đổi.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final IAnalyticsService _analytics;

  void _logScreen(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      _analytics.logScreen(name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _logScreen(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _logScreen(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _logScreen(previousRoute);
  }
}
