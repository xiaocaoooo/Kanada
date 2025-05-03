import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'kanada_lyric_server_platform_interface.dart';

/// An implementation of [KanadaLyricServerPlatform] that uses method channels.
class MethodChannelKanadaLyricServer extends KanadaLyricServerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('kanada_lyric_server');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
