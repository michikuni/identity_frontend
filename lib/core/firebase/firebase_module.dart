import 'package:firebase_core/firebase_core.dart';
import 'package:identity_frontend/core/firebase/analytics_service.dart';
import 'package:identity_frontend/core/firebase/crashlytics_service.dart';
import 'package:identity_frontend/core/firebase/fcm_service.dart';
import 'package:identity_frontend/core/firebase/repositories/i_analytics_service.dart';
import 'package:identity_frontend/core/firebase/repositories/i_crashlytics_service.dart';
import 'package:identity_frontend/core/firebase/repositories/i_fcm_service.dart';
import 'package:identity_frontend/core/firebase/repositories/i_remote_config_service.dart';
import 'package:identity_frontend/core/firebase/remote_config_service.dart';
import 'package:identity_frontend/firebase_options.dart';

/// Kết quả khởi tạo Firebase — truyền thẳng vào DI container.
///
/// Dùng Dart record để bundle 4 services mà không cần class wrapper.
typedef FirebaseServices = ({
  IRemoteConfigService remoteConfig,
  ICrashlyticsService crashlytics,
  IFcmService fcm,
  IAnalyticsService analytics,
});

/// Pure factory — không giữ state, không có static singleton.
/// Gọi một lần trong configureDependencies(), kết quả đăng ký vào GetIt.
///
/// Tái sử dụng: copy thư mục core/firebase/ sang dự án khác,
/// gọi FirebaseModule.init() trong configureDependencies(). Xong.
abstract class FirebaseModule {
  static Future<FirebaseServices> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Crashlytics trước để bắt lỗi từ các service khởi tạo sau
    final crashlytics = await CrashlyticsService.create();
    final remoteConfig = await RemoteConfigService.create();
    final fcm = await FcmService.create();
    final analytics = await AnalyticsService.create();

    return (
      remoteConfig: remoteConfig,
      crashlytics: crashlytics,
      fcm: fcm,
      analytics: analytics,
    );
  }
}
