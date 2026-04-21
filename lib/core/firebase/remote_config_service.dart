import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:identity_frontend/core/firebase/repositories/i_remote_config_service.dart';

abstract class RemoteConfigKeys {
  static const String apiBaseUrlDev = 'api_base_url_dev';
  static const String apiBaseUrlProd = 'api_base_url_prod';
}

abstract class RemoteConfigDefaults {
  static const Map<String, dynamic> values = {
    RemoteConfigKeys.apiBaseUrlDev: 'http://188.122.1.106:8080/api/v1',
    RemoteConfigKeys.apiBaseUrlProd: 'https://api.trustid.io/api/v1',
  };
}

class RemoteConfigService implements IRemoteConfigService {
  RemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  static Future<RemoteConfigService> create() async {
    final rc = FirebaseRemoteConfig.instance;

    await rc.setDefaults(RemoteConfigDefaults.values);
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );

    try {
      await rc.fetchAndActivate();
    } catch (e) {
      debugPrint('[RemoteConfig] fetchAndActivate failed: $e');
    }

    return RemoteConfigService(rc);
  }

  @override
  String get activeBaseUrl {
    final key = kDebugMode
        ? RemoteConfigKeys.apiBaseUrlDev
        : RemoteConfigKeys.apiBaseUrlProd;
    final url = _remoteConfig.getString(key);
    return url.isNotEmpty ? url : RemoteConfigDefaults.values[key] as String;
  }

  @override
  String get devBaseUrl => _remoteConfig.getString(RemoteConfigKeys.apiBaseUrlDev);

  @override
  String get prodBaseUrl => _remoteConfig.getString(RemoteConfigKeys.apiBaseUrlProd);
}
