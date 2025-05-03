import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'kanada_lyric_server_method_channel.dart';

abstract class KanadaLyricServerPlatform extends PlatformInterface {
  /// Constructs a KanadaLyricServerPlatform.
  KanadaLyricServerPlatform() : super(token: _token);

  static final Object _token = Object();

  static KanadaLyricServerPlatform _instance = MethodChannelKanadaLyricServer();

  /// The default instance of [KanadaLyricServerPlatform] to use.
  ///
  /// Defaults to [MethodChannelKanadaLyricServer].
  static KanadaLyricServerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KanadaLyricServerPlatform] when
  /// they register themselves.
  static set instance(KanadaLyricServerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
