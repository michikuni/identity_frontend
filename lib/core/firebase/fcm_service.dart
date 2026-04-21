import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:identity_frontend/core/firebase/notification_service.dart';
import 'package:identity_frontend/core/firebase/repositories/i_fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmService implements IFcmService {
  FcmService(this._messaging, this._notifications);

  final FirebaseMessaging _messaging;
  final NotificationService _notifications;

  @override
  void Function(RemoteMessage)? onMessageReceived;

  @override
  void Function(RemoteMessage)? onMessageOpenedApp;

  static Future<FcmService> create() async {
    final notifications = NotificationService.instance;
    await notifications.init();

    final messaging = FirebaseMessaging.instance;
    final service = FcmService(messaging, notifications);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await service._requestPermission();
    service._setupForegroundListeners();
    await service._handleInitialMessage();

    return service;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  void _setupForegroundListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground: ${message.notification?.title}');
      // Hiển thị system notification vì FCM suppress UI khi app đang mở
      _notifications.showFromRemoteMessage(message);
      onMessageReceived?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from background: ${message.notification?.title}');
      onMessageOpenedApp?.call(message);
    });
  }

  Future<void> _handleInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Launched from terminated: ${initial.notification?.title}');
      onMessageOpenedApp?.call(initial);
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] getToken failed: $e');
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  @override
  Future<void> deleteToken() => _messaging.deleteToken();
}
