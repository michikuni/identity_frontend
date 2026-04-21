import 'package:firebase_messaging/firebase_messaging.dart';

abstract interface class IFcmService {
  set onMessageReceived(void Function(RemoteMessage)? handler);
  set onMessageOpenedApp(void Function(RemoteMessage)? handler);
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> deleteToken();
}
