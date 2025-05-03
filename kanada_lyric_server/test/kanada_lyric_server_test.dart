import 'package:flutter_test/flutter_test.dart';
import 'package:kanada_lyric_server/kanada_lyric_server.dart';
import 'package:kanada_lyric_server/kanada_lyric_server_platform_interface.dart';
import 'package:kanada_lyric_server/kanada_lyric_server_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKanadaLyricServerPlatform
    with MockPlatformInterfaceMixin
    implements KanadaLyricServerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KanadaLyricServerPlatform initialPlatform = KanadaLyricServerPlatform.instance;

  test('$MethodChannelKanadaLyricServer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKanadaLyricServer>());
  });

  test('getPlatformVersion', () async {
    KanadaLyricServer kanadaLyricServerPlugin = KanadaLyricServer();
    MockKanadaLyricServerPlatform fakePlatform = MockKanadaLyricServerPlatform();
    KanadaLyricServerPlatform.instance = fakePlatform;

    expect(await kanadaLyricServerPlugin.getPlatformVersion(), '42');
  });
}
