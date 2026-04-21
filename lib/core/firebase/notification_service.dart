import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Channel ID phải trùng với giá trị trong AndroidManifest.xml
const _channelId = 'default_channel';
const _channelName = 'TrustID Notifications';

/// Hiển thị system notification khi app đang foreground.
///
/// Background/terminated: FCM tự xử lý — không cần làm gì thêm.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Callback khi user tap notification foreground → app layer dùng để navigate
  void Function(String? payload)? onNotificationTapped;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // permission đã xin từ FcmService
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        onNotificationTapped?.call(details.payload);
      },
    );

    await _createChannel();
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Gọi từ FcmService.onMessage khi app đang foreground
  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // data-only message — không show UI

    final android = notification.android;

    await _plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.imageUrl != null ? null : '@mipmap/ic_launcher',
          largeIcon: android?.imageUrl != null
              ? DrawableResourceAndroidBitmap(android!.imageUrl!)
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'], // route path để navigate khi tap
    );
  }
}
