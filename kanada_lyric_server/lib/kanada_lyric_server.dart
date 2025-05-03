
import 'package:flutter/services.dart';

import 'kanada_lyric_server_platform_interface.dart';

class KanadaLyricServer {
  Future<String?> getPlatformVersion() {
    return KanadaLyricServerPlatform.instance.getPlatformVersion();
  }
}

class KanadaLyricServerPlugin{
  // 定义与 Android 端一致的 MethodChannel 名称
  static const platform = MethodChannel('kanada_lyric_server');
  static const backgroundChannel = MethodChannel('kanada_lyric_server/background');

  static Future<void> startForegroundService() async {
    print('Miraiku startForegroundService');
    await platform.invokeMethod('startForegroundService');
  }
  static Future<void> stopForegroundService() async {
    print('Miraiku stopForegroundService');
    await platform.invokeMethod('stopForegroundService');
  }

  static Future<void> setMethodCallHandler(Future<void> Function() handler) async {
    print('Miraiku setMethodCallHandler');
    backgroundChannel.setMethodCallHandler((call){
      if (call.method == "onLyricUpdate") {
        handler();
      }
      return Future.value(null);
    });
  }
}